CREATE OR REPLACE FUNCTION change_user_password(old_password TEXT, new_password TEXT)
RETURNS json AS $$
DECLARE
  _user_id uuid;
  _current_encrypted_password text;
  result json;
BEGIN
  -- Get the user_id from the JWT
  _user_id := auth.uid();

  -- Check if the user is authenticated
  IF _user_id IS NULL THEN
    RETURN json_build_object('success', false, 'error', 'User not authenticated');
  END IF;

  -- Get the current encrypted password
  SELECT encrypted_password INTO _current_encrypted_password
  FROM auth.users
  WHERE id = _user_id;

  -- Verify the old password
  IF crypt(old_password, _current_encrypted_password) != _current_encrypted_password THEN
    RETURN json_build_object('success', false, 'error', 'Current password is incorrect');
  END IF;

  -- Check if new password is the same as the old password
  IF crypt(new_password, _current_encrypted_password) = _current_encrypted_password THEN
    RETURN json_build_object('success', false, 'error', 'New password cannot be the same as the current password');
  END IF;

  -- Update the password
  UPDATE auth.users SET encrypted_password = crypt(new_password, gen_salt('bf'))
  WHERE id = _user_id;

  RETURN json_build_object('success', true);
EXCEPTION
  WHEN OTHERS THEN
    RETURN json_build_object('success', false, 'error', SQLERRM);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;