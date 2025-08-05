CREATE OR REPLACE FUNCTION book_parking_slot(slot_id_in uuid, customer_id_in uuid)
RETURNS uuid AS $$
DECLARE
  current_slot_count int;
  new_reservation_id uuid;
BEGIN
  SELECT number_of_slots INTO current_slot_count
  FROM public.parking_slots
  WHERE id = slot_id_in
  FOR UPDATE;

  IF current_slot_count > 0 THEN
    UPDATE public.parking_slots
    SET number_of_slots = number_of_slots - 1
    WHERE id = slot_id_in;

    INSERT INTO public.reserved_slots (parking_slot_id, customer_id, updated_at)
    VALUES (slot_id_in, customer_id_in, CURRENT_TIMESTAMP)
    RETURNING id INTO new_reservation_id;

    RETURN new_reservation_id;
  ELSE
    RETURN NULL;
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;