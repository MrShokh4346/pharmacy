CREATE OR REPLACE FUNCTION update_user_plan()
RETURNS VOID
LANGUAGE plpgsql
AS 
$$
DECLARE
    plan INTEGER := 0;
    rec RECORD;
BEGIN
    -- Loop through each record in user_product_plan
    FOR rec IN SELECT * FROM reservation_products
    LOOP 
        -- Calculate the sum of monthly plans for the given med_rep_id and product_id
        -- Use COALESCE to handle NULL values by setting them to 0
        SELECT quantity INTO plan
        FROM reservation_payed_amounts
        WHERE reservation_payed_amounts.reservation_id = rec.reservation_id
          AND reservation_payed_amounts.product_id = rec.product_id;

        -- Update the current_amount in user_product_plan
        UPDATE reservation_products 
        SET not_payed_quantity = rec.quantity - plan 
        WHERE reservation_id = rec.reservation_id
          AND product_id = rec.product_id;

    END LOOP;
END;
$$;


-- SELECT update_user_plan()


-- SELECT SUM(doctor_monthly_plan.monthly_plan) FROM doctor_monthly_plan WHERE date >= '2024-08-01'

SELECT COUNT(user_product_plan.amount - user_product_plan.current_amount) FROM user_product_plan WHERE date >= '2024-08-01'

-- update user_product_plan set current_amount=user_product_plan.amount where current_amount=NULL

-- SELECT * from user_product_plan where date >= '2024-08-01';















