CREATE OR REPLACE FUNCTION public.notify_partner_on_new_reservation()
RETURNS TRIGGER AS $$
DECLARE
  partner_fcm_token TEXT;
  parking_title TEXT;
  customer_name TEXT;
  notification_title TEXT;
  notification_body TEXT;
  edge_function_url TEXT := 'https://jsveehvbmqbrjdjeazxc.supabase.co/functions/v1/send-fcm-notification';
  supabase_service_role_key TEXT := 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpzdmVlaHZibXFicmpkamVhenhjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM4ODE1NTQsImV4cCI6MjA2OTQ1NzU1NH0.oxeqcZOx9vgS0IqbX8XHg7H2oyEPTGC3dHJSnzqBUeo';
  request_id BIGINT;
BEGIN
  -- Select necessary data for the notification
  SELECT
    ua.fcm_token,
    ps.title,
    ca.full_name
  INTO
    partner_fcm_token,
    parking_title,
    customer_name
  FROM
    public.reserved_slots rs
  JOIN public.parking_slots ps ON rs.parking_slot_id = ps.id
  JOIN public.partners p ON ps.partner_id = p.partner_id
  JOIN public.user_accounts ua ON p.user_id = ua.id
  JOIN public.customers c ON rs.customer_id = c.customer_id
  JOIN public.user_accounts ca ON c.user_id = ca.id
  WHERE
    rs.id = NEW.id;

  -- If a partner FCM token exists, send the notification
  IF partner_fcm_token IS NOT NULL THEN
    notification_title := 'New Reservation!';
    notification_body := customer_name || ' has booked a spot at ' || parking_title || '.';

    -- Using pg_net's http_post function with correct signature
    SELECT net.http_post(
      url := edge_function_url,
      body := json_build_object(
        'fcm_token', partner_fcm_token,
        'title', notification_title,
        'body', notification_body
      )::jsonb,
      headers := json_build_object(
        'Content-Type', 'application/json',
        'Authorization', 'Bearer ' || supabase_service_role_key
      )::jsonb
    ) INTO request_id;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;