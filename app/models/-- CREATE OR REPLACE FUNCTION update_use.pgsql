-- CREATE OR REPLACE FUNCTION update_postupleniya()
-- RETURNS VOID
-- LANGUAGE plpgsql
-- AS 
-- $$
-- DECLARE
--     sum INTEGER := 0;
--     rec RECORD;
-- BEGIN
--     -- Loop through each record in user_product_plan
--     FOR rec IN SELECT * FROM reservation_payed_amounts where date >='2024-08-01'
--     LOOP 
--         -- Calculate the sum of monthly plans for the given med_rep_id and product_id
--         -- Use COALESCE to handle NULL values by setting them to 0
--         SELECT amount INTO sum
--         FROM reservation_payed_amounts
--         WHERE reservation_payed_amounts.reservation_id = rec.reservation_id
--           AND reservation_payed_amounts.product_id = rec.product_id;

--         -- Update the current_amount in user_product_plan
--         UPDATE doctor_postupleniya_fact 
--         SET fact_price = doctor_postupleniya_fact.fact_price + rec.amount
--         WHERE doctor_id = rec.doctor_id
--           AND product_id = rec.product_id;

--     END LOOP;
-- END;
-- $$;

-- SELECT update_postupleniya()


-- CREATE OR REPLACE FUNCTION update_postupleniya_wholesale()
-- RETURNS VOID
-- LANGUAGE plpgsql
-- AS 
-- $$
-- DECLARE
--     sum INTEGER := 0;
--     rec RECORD;
-- BEGIN
--     -- Loop through each record in user_product_plan
--     FOR rec IN SELECT * FROM wholesale_reservation_payed_amounts where date >='2024-08-01'
--     LOOP 
--         -- Calculate the sum of monthly plans for the given med_rep_id and product_id
--         -- Use COALESCE to handle NULL values by setting them to 0
--         -- SELECT amount INTO sum
--         -- FROM reservation_payed_amounts
--         -- WHERE reservation_payed_amounts.reservation_id = rec.reservation_id
--         --   AND reservation_payed_amounts.product_id = rec.product_id;

--         -- Update the current_amount in user_product_plan
--         UPDATE doctor_postupleniya_fact 
--         SET fact_price = doctor_postupleniya_fact.fact_price + rec.amount
--         WHERE doctor_id = rec.doctor_id
--           AND product_id = rec.product_id;

--     END LOOP;
-- END;
-- $$;

-- SELECT update_postupleniya_wholesale()


-- CREATE OR REPLACE FUNCTION update_postupleniya_hospital()
-- RETURNS VOID
-- LANGUAGE plpgsql
-- AS 
-- $$
-- DECLARE
--     sum INTEGER := 0;
--     rec RECORD;
-- BEGIN
--     -- Loop through each record in user_product_plan
--     FOR rec IN SELECT * FROM hospital_reservation_payed_amounts where date >='2024-08-01'
--     LOOP 
--         -- Calculate the sum of monthly plans for the given med_rep_id and product_id
--         -- Use COALESCE to handle NULL values by setting them to 0
--         SELECT hospital_id INTO sum
--         FROM hospital_reservation
--         WHERE hospital_reservation.id = rec.reservation_id;

--         -- Update the current_amount in user_product_plan
--         UPDATE hospital_postupleniya_fact 
--         SET fact_price = hospital_postupleniya_fact.fact_price + rec.amount
--         WHERE hospital_id = sum
--           AND product_id = rec.product_id;

--     END LOOP;
-- END;
-- $$;

-- SELECT update_postupleniya_hospital()

