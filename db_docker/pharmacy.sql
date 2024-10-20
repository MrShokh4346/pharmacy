--
-- PostgreSQL database dump
--

-- Dumped from database version 16.3 (Ubuntu 16.3-1.pgdg22.04+1)
-- Dumped by pg_dump version 16.3 (Ubuntu 16.3-1.pgdg22.04+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: insert_month(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.insert_month() RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    sum INTEGER := 0;
    rec RECORD;
BEGIN
    -- Loop through each record in user_product_plan
    FOR i IN 1..12
    LOOP 
        -- Calculate the sum of monthly plans for the given med_rep_id and product_id
        -- Use COALESCE to handle NULL values by setting them to 0
        INSERT INTO editable_plan_months(month, status, created_at, updated_at) VALUES(i, '0', now(), now());
    END LOOP;
    UPDATE editable_plan_months set status='1' where month=8;
END;
$$;


ALTER FUNCTION public.insert_month() OWNER TO postgres;

--
-- Name: update_postupleniya(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_postupleniya() RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    sum INTEGER := 0;
    rec RECORD;
BEGIN
    -- Loop through each record in user_product_plan
    FOR rec IN SELECT * FROM reservation_payed_amounts where date >='2024-08-01'
    LOOP 
        -- Calculate the sum of monthly plans for the given med_rep_id and product_id
        -- Use COALESCE to handle NULL values by setting them to 0
        SELECT amount INTO sum
        FROM reservation_payed_amounts
        WHERE reservation_payed_amounts.reservation_id = rec.reservation_id
          AND reservation_payed_amounts.product_id = rec.product_id;

        -- Update the current_amount in user_product_plan
        UPDATE doctor_postupleniya_fact 
        SET fact_price = doctor_postupleniya_fact.fact_price + rec.amount
        WHERE doctor_id = rec.doctor_id
          AND product_id = rec.product_id;

    END LOOP;
END;
$$;


ALTER FUNCTION public.update_postupleniya() OWNER TO postgres;

--
-- Name: update_postupleniya_hospital(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_postupleniya_hospital() RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    sum INTEGER := 0;
    rec RECORD;
BEGIN
    -- Loop through each record in user_product_plan
    FOR rec IN SELECT * FROM hospital_reservation_payed_amounts where date >='2024-08-01'
    LOOP 
        -- Calculate the sum of monthly plans for the given med_rep_id and product_id
        -- Use COALESCE to handle NULL values by setting them to 0
        SELECT hospital_id INTO sum
        FROM hospital_reservation
        WHERE hospital_reservation.id = rec.reservation_id;

        -- Update the current_amount in user_product_plan
        UPDATE hospital_postupleniya_fact 
        SET fact_price = hospital_postupleniya_fact.fact_price + rec.amount
        WHERE hospital_id = sum
          AND product_id = rec.product_id;

    END LOOP;
END;
$$;


ALTER FUNCTION public.update_postupleniya_hospital() OWNER TO postgres;

--
-- Name: update_postupleniya_wholesale(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_postupleniya_wholesale() RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    sum INTEGER := 0;
    rec RECORD;
BEGIN
    -- Loop through each record in user_product_plan
    FOR rec IN SELECT * FROM wholesale_reservation_payed_amounts where date >='2024-08-01'
    LOOP 
        -- Calculate the sum of monthly plans for the given med_rep_id and product_id
        -- Use COALESCE to handle NULL values by setting them to 0
        -- SELECT amount INTO sum
        -- FROM reservation_payed_amounts
        -- WHERE reservation_payed_amounts.reservation_id = rec.reservation_id
        --   AND reservation_payed_amounts.product_id = rec.product_id;

        -- Update the current_amount in user_product_plan
        UPDATE doctor_postupleniya_fact 
        SET fact_price = doctor_postupleniya_fact.fact_price + rec.amount
        WHERE doctor_id = rec.doctor_id
          AND product_id = rec.product_id;

    END LOOP;
END;
$$;


ALTER FUNCTION public.update_postupleniya_wholesale() OWNER TO postgres;

--
-- Name: update_user_plan(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_user_plan() RETURNS void
    LANGUAGE plpgsql
    AS $$
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


ALTER FUNCTION public.update_user_plan() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: alembic_version; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.alembic_version (
    version_num character varying(32) NOT NULL
);


ALTER TABLE public.alembic_version OWNER TO postgres;

--
-- Name: bonus; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.bonus (
    id integer NOT NULL,
    date timestamp without time zone,
    amount integer,
    doctor_id integer,
    payed integer,
    product_id integer,
    product_quantity integer,
    pre_investment integer
);


ALTER TABLE public.bonus OWNER TO postgres;

--
-- Name: bonus_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.bonus_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.bonus_id_seq OWNER TO postgres;

--
-- Name: bonus_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.bonus_id_seq OWNED BY public.bonus.id;


--
-- Name: bonus_payed_amounts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.bonus_payed_amounts (
    id integer NOT NULL,
    amount integer,
    description character varying,
    date timestamp without time zone,
    bonus_id integer
);


ALTER TABLE public.bonus_payed_amounts OWNER TO postgres;

--
-- Name: bonus_payed_amounts_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.bonus_payed_amounts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.bonus_payed_amounts_id_seq OWNER TO postgres;

--
-- Name: bonus_payed_amounts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.bonus_payed_amounts_id_seq OWNED BY public.bonus_payed_amounts.id;


--
-- Name: checking_balance_in_stock; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.checking_balance_in_stock (
    id integer NOT NULL,
    date timestamp without time zone,
    description character varying,
    pharmacy_id integer
);


ALTER TABLE public.checking_balance_in_stock OWNER TO postgres;

--
-- Name: checking_balance_in_stock_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.checking_balance_in_stock_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.checking_balance_in_stock_id_seq OWNER TO postgres;

--
-- Name: checking_balance_in_stock_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.checking_balance_in_stock_id_seq OWNED BY public.checking_balance_in_stock.id;


--
-- Name: checking_stock_products; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.checking_stock_products (
    id integer NOT NULL,
    previous integer,
    saled integer,
    remainder integer,
    stock_id integer,
    product_id integer,
    chack boolean
);


ALTER TABLE public.checking_stock_products OWNER TO postgres;

--
-- Name: checking_stock_products_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.checking_stock_products_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.checking_stock_products_id_seq OWNER TO postgres;

--
-- Name: checking_stock_products_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.checking_stock_products_id_seq OWNED BY public.checking_stock_products.id;


--
-- Name: current_balance_in_stock; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.current_balance_in_stock (
    id integer NOT NULL,
    amount integer,
    product_id integer,
    pharmacy_id integer
);


ALTER TABLE public.current_balance_in_stock OWNER TO postgres;

--
-- Name: current_balance_in_stock_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.current_balance_in_stock_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.current_balance_in_stock_id_seq OWNER TO postgres;

--
-- Name: current_balance_in_stock_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.current_balance_in_stock_id_seq OWNED BY public.current_balance_in_stock.id;


--
-- Name: current_factory_warehouse; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.current_factory_warehouse (
    id integer NOT NULL,
    amount integer,
    factory_id integer,
    product_id integer
);


ALTER TABLE public.current_factory_warehouse OWNER TO postgres;

--
-- Name: current_factory_warehouse_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.current_factory_warehouse_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.current_factory_warehouse_id_seq OWNER TO postgres;

--
-- Name: current_factory_warehouse_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.current_factory_warehouse_id_seq OWNED BY public.current_factory_warehouse.id;


--
-- Name: current_wholesale_warehouse; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.current_wholesale_warehouse (
    id integer NOT NULL,
    amount integer,
    price integer,
    wholesale_id integer,
    product_id integer
);


ALTER TABLE public.current_wholesale_warehouse OWNER TO postgres;

--
-- Name: current_wholesale_warehouse_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.current_wholesale_warehouse_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.current_wholesale_warehouse_id_seq OWNER TO postgres;

--
-- Name: current_wholesale_warehouse_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.current_wholesale_warehouse_id_seq OWNED BY public.current_wholesale_warehouse.id;


--
-- Name: debt; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.debt (
    id integer NOT NULL,
    description character varying,
    amount integer,
    payed boolean,
    date timestamp without time zone,
    pharmacy_id integer
);


ALTER TABLE public.debt OWNER TO postgres;

--
-- Name: debt_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.debt_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.debt_id_seq OWNER TO postgres;

--
-- Name: debt_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.debt_id_seq OWNED BY public.debt.id;


--
-- Name: distance; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.distance (
    id integer NOT NULL,
    distance integer
);


ALTER TABLE public.distance OWNER TO postgres;

--
-- Name: distance_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.distance_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.distance_id_seq OWNER TO postgres;

--
-- Name: distance_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.distance_id_seq OWNED BY public.distance.id;


--
-- Name: doctor; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.doctor (
    id integer NOT NULL,
    full_name character varying,
    contact1 character varying,
    contact2 character varying,
    email character varying,
    latitude character varying,
    longitude character varying,
    deleted boolean,
    med_rep_id integer,
    region_manager_id integer,
    ffm_id integer,
    product_manager_id integer,
    deputy_director_id integer,
    director_id integer,
    region_id integer,
    speciality_id integer,
    category_id integer,
    medical_organization_id integer,
    birth_date timestamp without time zone
);


ALTER TABLE public.doctor OWNER TO postgres;

--
-- Name: doctor_category; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.doctor_category (
    id integer NOT NULL,
    name character varying
);


ALTER TABLE public.doctor_category OWNER TO postgres;

--
-- Name: doctor_category_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.doctor_category_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.doctor_category_id_seq OWNER TO postgres;

--
-- Name: doctor_category_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.doctor_category_id_seq OWNED BY public.doctor_category.id;


--
-- Name: doctor_fact; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.doctor_fact (
    id integer NOT NULL,
    fact integer,
    date timestamp without time zone,
    doctor_id integer,
    pharmacy_id integer,
    product_id integer,
    price integer,
    discount_price integer
);


ALTER TABLE public.doctor_fact OWNER TO postgres;

--
-- Name: doctor_fact_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.doctor_fact_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.doctor_fact_id_seq OWNER TO postgres;

--
-- Name: doctor_fact_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.doctor_fact_id_seq OWNED BY public.doctor_fact.id;


--
-- Name: doctor_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.doctor_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.doctor_id_seq OWNER TO postgres;

--
-- Name: doctor_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.doctor_id_seq OWNED BY public.doctor.id;


--
-- Name: doctor_monthly_plan; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.doctor_monthly_plan (
    id integer NOT NULL,
    date timestamp without time zone,
    product_id integer,
    doctor_id integer,
    monthly_plan integer,
    price integer,
    discount_price integer
);


ALTER TABLE public.doctor_monthly_plan OWNER TO postgres;

--
-- Name: doctor_monthly_plan_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.doctor_monthly_plan_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.doctor_monthly_plan_id_seq OWNER TO postgres;

--
-- Name: doctor_monthly_plan_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.doctor_monthly_plan_id_seq OWNED BY public.doctor_monthly_plan.id;


--
-- Name: doctor_plan; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.doctor_plan (
    id integer NOT NULL,
    description character varying,
    theme character varying,
    date timestamp without time zone,
    status boolean,
    postpone boolean,
    doctor_id integer,
    med_rep_id integer
);


ALTER TABLE public.doctor_plan OWNER TO postgres;

--
-- Name: doctor_plan_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.doctor_plan_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.doctor_plan_id_seq OWNER TO postgres;

--
-- Name: doctor_plan_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.doctor_plan_id_seq OWNED BY public.doctor_plan.id;


--
-- Name: doctor_postupleniya_fact; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.doctor_postupleniya_fact (
    id integer NOT NULL,
    fact integer,
    price integer,
    discount_price integer,
    date timestamp without time zone,
    doctor_id integer,
    product_id integer,
    fact_price integer
);


ALTER TABLE public.doctor_postupleniya_fact OWNER TO postgres;

--
-- Name: doctor_postupleniya_fact_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.doctor_postupleniya_fact_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.doctor_postupleniya_fact_id_seq OWNER TO postgres;

--
-- Name: doctor_postupleniya_fact_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.doctor_postupleniya_fact_id_seq OWNED BY public.doctor_postupleniya_fact.id;


--
-- Name: doctor_visit_info; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.doctor_visit_info (
    id integer NOT NULL,
    recept integer,
    data timestamp without time zone,
    doctor_id integer,
    product_id integer
);


ALTER TABLE public.doctor_visit_info OWNER TO postgres;

--
-- Name: doctor_visit_info_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.doctor_visit_info_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.doctor_visit_info_id_seq OWNER TO postgres;

--
-- Name: doctor_visit_info_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.doctor_visit_info_id_seq OWNED BY public.doctor_visit_info.id;


--
-- Name: editable_plan_months; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.editable_plan_months (
    id integer NOT NULL,
    month integer,
    status boolean,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.editable_plan_months OWNER TO postgres;

--
-- Name: editable_plan_months_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.editable_plan_months_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.editable_plan_months_id_seq OWNER TO postgres;

--
-- Name: editable_plan_months_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.editable_plan_months_id_seq OWNED BY public.editable_plan_months.id;


--
-- Name: expense; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.expense (
    id integer NOT NULL,
    amount integer,
    author character varying,
    description character varying,
    date timestamp without time zone,
    category_id integer
);


ALTER TABLE public.expense OWNER TO postgres;

--
-- Name: expense_category; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.expense_category (
    id integer NOT NULL,
    name character varying
);


ALTER TABLE public.expense_category OWNER TO postgres;

--
-- Name: expense_category_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.expense_category_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.expense_category_id_seq OWNER TO postgres;

--
-- Name: expense_category_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.expense_category_id_seq OWNED BY public.expense_category.id;


--
-- Name: expense_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.expense_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.expense_id_seq OWNER TO postgres;

--
-- Name: expense_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.expense_id_seq OWNED BY public.expense.id;


--
-- Name: hospital; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.hospital (
    id integer NOT NULL,
    company_name character varying,
    company_address character varying,
    inter_branch_turnover character varying,
    bank_account_number character varying,
    director character varying,
    purchasing_manager character varying,
    contact character varying,
    med_rep_id integer,
    region_id integer
);


ALTER TABLE public.hospital OWNER TO postgres;

--
-- Name: hospital_bonus; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.hospital_bonus (
    id integer NOT NULL,
    date timestamp without time zone,
    amount integer,
    payed integer,
    product_quantity integer,
    hospital_id integer,
    product_id integer
);


ALTER TABLE public.hospital_bonus OWNER TO postgres;

--
-- Name: hospital_bonus_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.hospital_bonus_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.hospital_bonus_id_seq OWNER TO postgres;

--
-- Name: hospital_bonus_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.hospital_bonus_id_seq OWNED BY public.hospital_bonus.id;


--
-- Name: hospital_fact; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.hospital_fact (
    id integer NOT NULL,
    fact integer,
    price integer,
    discount_price integer,
    date timestamp without time zone,
    hospital_id integer,
    product_id integer
);


ALTER TABLE public.hospital_fact OWNER TO postgres;

--
-- Name: hospital_fact_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.hospital_fact_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.hospital_fact_id_seq OWNER TO postgres;

--
-- Name: hospital_fact_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.hospital_fact_id_seq OWNED BY public.hospital_fact.id;


--
-- Name: hospital_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.hospital_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.hospital_id_seq OWNER TO postgres;

--
-- Name: hospital_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.hospital_id_seq OWNED BY public.hospital.id;


--
-- Name: hospital_monthly_plan; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.hospital_monthly_plan (
    id integer NOT NULL,
    monthly_plan integer,
    date timestamp without time zone,
    product_id integer,
    price integer,
    discount_price integer,
    hospital_id integer
);


ALTER TABLE public.hospital_monthly_plan OWNER TO postgres;

--
-- Name: hospital_monthly_plan_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.hospital_monthly_plan_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.hospital_monthly_plan_id_seq OWNER TO postgres;

--
-- Name: hospital_monthly_plan_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.hospital_monthly_plan_id_seq OWNED BY public.hospital_monthly_plan.id;


--
-- Name: hospital_postupleniya_fact; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.hospital_postupleniya_fact (
    id integer NOT NULL,
    fact integer,
    price integer,
    discount_price integer,
    date timestamp without time zone,
    hospital_id integer,
    product_id integer,
    fact_price integer
);


ALTER TABLE public.hospital_postupleniya_fact OWNER TO postgres;

--
-- Name: hospital_postupleniya_fact_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.hospital_postupleniya_fact_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.hospital_postupleniya_fact_id_seq OWNER TO postgres;

--
-- Name: hospital_postupleniya_fact_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.hospital_postupleniya_fact_id_seq OWNED BY public.hospital_postupleniya_fact.id;


--
-- Name: hospital_reservation; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.hospital_reservation (
    id integer NOT NULL,
    date timestamp without time zone,
    expire_date timestamp without time zone,
    discount double precision,
    total_quantity integer,
    total_amount double precision,
    total_payable double precision,
    total_payable_with_nds double precision,
    hospital_id integer,
    manufactured_company_id integer,
    payed boolean,
    checked boolean,
    invoice_number integer,
    profit integer,
    debt integer,
    date_implementation timestamp without time zone,
    prosrochenniy_debt boolean,
    med_rep_id integer,
    bonus boolean
);


ALTER TABLE public.hospital_reservation OWNER TO postgres;

--
-- Name: hospital_reservation_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.hospital_reservation_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.hospital_reservation_id_seq OWNER TO postgres;

--
-- Name: hospital_reservation_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.hospital_reservation_id_seq OWNED BY public.hospital_reservation.id;


--
-- Name: hospital_reservation_payed_amounts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.hospital_reservation_payed_amounts (
    id integer NOT NULL,
    amount integer,
    description character varying,
    date timestamp without time zone,
    reservation_id integer,
    total_sum integer,
    remainder_sum integer,
    bonus boolean,
    quantity integer,
    product_id integer,
    bonus_discount integer,
    doctor_id integer,
    nds_sum integer,
    fot_sum integer,
    promo_sum integer,
    skidka_sum integer,
    pure_proceeds integer
);


ALTER TABLE public.hospital_reservation_payed_amounts OWNER TO postgres;

--
-- Name: hospital_reservation_payed_amounts_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.hospital_reservation_payed_amounts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.hospital_reservation_payed_amounts_id_seq OWNER TO postgres;

--
-- Name: hospital_reservation_payed_amounts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.hospital_reservation_payed_amounts_id_seq OWNED BY public.hospital_reservation_payed_amounts.id;


--
-- Name: hospital_reservation_products; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.hospital_reservation_products (
    id integer NOT NULL,
    quantity integer,
    reservation_price integer,
    reservation_discount_price integer,
    product_id integer,
    reservation_id integer,
    not_payed_quantity integer
);


ALTER TABLE public.hospital_reservation_products OWNER TO postgres;

--
-- Name: hospital_reservation_products_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.hospital_reservation_products_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.hospital_reservation_products_id_seq OWNER TO postgres;

--
-- Name: hospital_reservation_products_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.hospital_reservation_products_id_seq OWNED BY public.hospital_reservation_products.id;


--
-- Name: incoming_balance_in_stock; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.incoming_balance_in_stock (
    id integer NOT NULL,
    date timestamp without time zone,
    description character varying,
    wholesale_id integer,
    factory_id integer,
    pharmacy_id integer
);


ALTER TABLE public.incoming_balance_in_stock OWNER TO postgres;

--
-- Name: incoming_balance_in_stock_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.incoming_balance_in_stock_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.incoming_balance_in_stock_id_seq OWNER TO postgres;

--
-- Name: incoming_balance_in_stock_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.incoming_balance_in_stock_id_seq OWNED BY public.incoming_balance_in_stock.id;


--
-- Name: incoming_stock_products; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.incoming_stock_products (
    id integer NOT NULL,
    quantity integer,
    stock_id integer,
    product_id integer
);


ALTER TABLE public.incoming_stock_products OWNER TO postgres;

--
-- Name: incoming_stock_products_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.incoming_stock_products_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.incoming_stock_products_id_seq OWNER TO postgres;

--
-- Name: incoming_stock_products_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.incoming_stock_products_id_seq OWNED BY public.incoming_stock_products.id;


--
-- Name: invoice_number_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.invoice_number_seq
    START WITH 1000
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.invoice_number_seq OWNER TO postgres;

--
-- Name: manufactured_company; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.manufactured_company (
    id integer NOT NULL,
    name character varying
);


ALTER TABLE public.manufactured_company OWNER TO postgres;

--
-- Name: manufactured_company_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.manufactured_company_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.manufactured_company_id_seq OWNER TO postgres;

--
-- Name: manufactured_company_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.manufactured_company_id_seq OWNED BY public.manufactured_company.id;


--
-- Name: medical_organization; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.medical_organization (
    id integer NOT NULL,
    name character varying,
    address character varying,
    latitude character varying,
    longitude character varying,
    region_id integer
);


ALTER TABLE public.medical_organization OWNER TO postgres;

--
-- Name: medical_organization_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.medical_organization_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.medical_organization_id_seq OWNER TO postgres;

--
-- Name: medical_organization_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.medical_organization_id_seq OWNED BY public.medical_organization.id;


--
-- Name: notification; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.notification (
    id integer NOT NULL,
    author character varying,
    theme character varying,
    description character varying,
    description2 character varying,
    date timestamp without time zone,
    unread boolean,
    med_rep_id integer,
    region_manager_id integer,
    pharmacy_id integer,
    doctor_id integer,
    wholesale_id integer
);


ALTER TABLE public.notification OWNER TO postgres;

--
-- Name: notification_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.notification_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.notification_id_seq OWNER TO postgres;

--
-- Name: notification_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.notification_id_seq OWNED BY public.notification.id;


--
-- Name: pharmacy; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pharmacy (
    id integer NOT NULL,
    company_name character varying,
    contact1 character varying,
    contact2 character varying,
    email character varying,
    latitude character varying,
    longitude character varying,
    address character varying,
    bank_account_number character varying,
    inter_branch_turnover character varying,
    classification_of_economic_activities character varying,
    "VAT_payer_code" character varying,
    pharmacy_director character varying,
    discount double precision,
    brand_name character varying,
    med_rep_id integer,
    region_manager_id integer,
    ffm_id integer,
    product_manager_id integer,
    deputy_director_id integer,
    director_id integer,
    region_id integer
);


ALTER TABLE public.pharmacy OWNER TO postgres;

--
-- Name: pharmacy_doctor; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pharmacy_doctor (
    doctor_id integer NOT NULL,
    pharmacy_id integer NOT NULL
);


ALTER TABLE public.pharmacy_doctor OWNER TO postgres;

--
-- Name: pharmacy_fact; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pharmacy_fact (
    id integer NOT NULL,
    quantity integer,
    date timestamp without time zone,
    monthly_plan integer,
    doctor_id integer,
    product_id integer,
    pharmacy_id integer
);


ALTER TABLE public.pharmacy_fact OWNER TO postgres;

--
-- Name: pharmacy_fact_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pharmacy_fact_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.pharmacy_fact_id_seq OWNER TO postgres;

--
-- Name: pharmacy_fact_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.pharmacy_fact_id_seq OWNED BY public.pharmacy_fact.id;


--
-- Name: pharmacy_hot_sale; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pharmacy_hot_sale (
    id integer NOT NULL,
    amount integer,
    date timestamp without time zone,
    product_id integer,
    pharmacy_id integer
);


ALTER TABLE public.pharmacy_hot_sale OWNER TO postgres;

--
-- Name: pharmacy_hot_sale_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pharmacy_hot_sale_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.pharmacy_hot_sale_id_seq OWNER TO postgres;

--
-- Name: pharmacy_hot_sale_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.pharmacy_hot_sale_id_seq OWNED BY public.pharmacy_hot_sale.id;


--
-- Name: pharmacy_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pharmacy_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.pharmacy_id_seq OWNER TO postgres;

--
-- Name: pharmacy_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.pharmacy_id_seq OWNED BY public.pharmacy.id;


--
-- Name: pharmacy_plan; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pharmacy_plan (
    id integer NOT NULL,
    description character varying,
    theme character varying,
    date timestamp without time zone,
    status boolean,
    postpone boolean,
    pharmacy_id integer,
    med_rep_id integer
);


ALTER TABLE public.pharmacy_plan OWNER TO postgres;

--
-- Name: pharmacy_plan_attached_product; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pharmacy_plan_attached_product (
    id integer NOT NULL,
    doctor_name character varying,
    doctor_speciality character varying,
    product_name character varying,
    compleated integer,
    plan_id integer
);


ALTER TABLE public.pharmacy_plan_attached_product OWNER TO postgres;

--
-- Name: pharmacy_plan_attached_product_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pharmacy_plan_attached_product_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.pharmacy_plan_attached_product_id_seq OWNER TO postgres;

--
-- Name: pharmacy_plan_attached_product_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.pharmacy_plan_attached_product_id_seq OWNED BY public.pharmacy_plan_attached_product.id;


--
-- Name: pharmacy_plan_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pharmacy_plan_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.pharmacy_plan_id_seq OWNER TO postgres;

--
-- Name: pharmacy_plan_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.pharmacy_plan_id_seq OWNED BY public.pharmacy_plan.id;


--
-- Name: product_category; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.product_category (
    id integer NOT NULL,
    name character varying
);


ALTER TABLE public.product_category OWNER TO postgres;

--
-- Name: product_category_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.product_category_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.product_category_id_seq OWNER TO postgres;

--
-- Name: product_category_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.product_category_id_seq OWNED BY public.product_category.id;


--
-- Name: product_expenses; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.product_expenses (
    id integer NOT NULL,
    marketing_expense integer,
    salary_expenses integer,
    date timestamp without time zone,
    product_id integer
);


ALTER TABLE public.product_expenses OWNER TO postgres;

--
-- Name: product_expenses_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.product_expenses_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.product_expenses_id_seq OWNER TO postgres;

--
-- Name: product_expenses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.product_expenses_id_seq OWNED BY public.product_expenses.id;


--
-- Name: products; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.products (
    id integer NOT NULL,
    name character varying,
    price integer,
    discount_price integer,
    man_company_id integer,
    category_id integer,
    marketing_expenses integer,
    salary_expenses integer,
    is_exist boolean
);


ALTER TABLE public.products OWNER TO postgres;

--
-- Name: products_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.products_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.products_id_seq OWNER TO postgres;

--
-- Name: products_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.products_id_seq OWNED BY public.products.id;


--
-- Name: region; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.region (
    id integer NOT NULL,
    name character varying
);


ALTER TABLE public.region OWNER TO postgres;

--
-- Name: region_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.region_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.region_id_seq OWNER TO postgres;

--
-- Name: region_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.region_id_seq OWNED BY public.region.id;


--
-- Name: remainder_sum_from_reservation; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.remainder_sum_from_reservation (
    id integer NOT NULL,
    amonut integer,
    date timestamp without time zone,
    pharmacy_id integer,
    wholesale_id integer,
    reservation_invoice_number integer
);


ALTER TABLE public.remainder_sum_from_reservation OWNER TO postgres;

--
-- Name: remainder_sum_from_reservation_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.remainder_sum_from_reservation_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.remainder_sum_from_reservation_id_seq OWNER TO postgres;

--
-- Name: remainder_sum_from_reservation_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.remainder_sum_from_reservation_id_seq OWNED BY public.remainder_sum_from_reservation.id;


--
-- Name: report_factory_warehouse; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.report_factory_warehouse (
    id integer NOT NULL,
    date timestamp without time zone,
    quantity integer,
    factory_id integer,
    product_id integer
);


ALTER TABLE public.report_factory_warehouse OWNER TO postgres;

--
-- Name: report_factory_warehouse_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.report_factory_warehouse_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.report_factory_warehouse_id_seq OWNER TO postgres;

--
-- Name: report_factory_warehouse_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.report_factory_warehouse_id_seq OWNED BY public.report_factory_warehouse.id;


--
-- Name: reservation; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.reservation (
    id integer NOT NULL,
    date timestamp without time zone,
    expire_date timestamp without time zone,
    discount double precision,
    discountable boolean,
    total_quantity integer,
    total_amount double precision,
    total_payable double precision,
    pharmacy_id integer,
    manufactured_company_id integer,
    checked boolean,
    total_payable_with_nds double precision,
    invoice_number integer,
    profit integer,
    debt integer,
    date_implementation timestamp without time zone,
    returned_price double precision,
    prosrochenniy_debt boolean,
    med_rep_id integer,
    bonus boolean,
    description character varying,
    reailized_debt integer
);


ALTER TABLE public.reservation OWNER TO postgres;

--
-- Name: reservation_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.reservation_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.reservation_id_seq OWNER TO postgres;

--
-- Name: reservation_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.reservation_id_seq OWNED BY public.reservation.id;


--
-- Name: reservation_payed_amounts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.reservation_payed_amounts (
    id integer NOT NULL,
    amount integer,
    description character varying,
    date timestamp without time zone,
    reservation_id integer,
    product_id integer,
    doctor_id integer,
    total_sum integer,
    remainder_sum integer,
    quantity integer,
    bonus boolean,
    nds_sum integer,
    fot_sum integer,
    promo_sum integer,
    skidka_sum integer,
    pure_proceeds integer,
    month_number integer
);


ALTER TABLE public.reservation_payed_amounts OWNER TO postgres;

--
-- Name: reservation_payed_amounts_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.reservation_payed_amounts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.reservation_payed_amounts_id_seq OWNER TO postgres;

--
-- Name: reservation_payed_amounts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.reservation_payed_amounts_id_seq OWNED BY public.reservation_payed_amounts.id;


--
-- Name: reservation_products; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.reservation_products (
    id integer NOT NULL,
    quantity integer,
    product_id integer,
    reservation_id integer,
    reservation_price double precision,
    reservation_discount_price integer,
    not_payed_quantity integer
);


ALTER TABLE public.reservation_products OWNER TO postgres;

--
-- Name: reservation_products_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.reservation_products_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.reservation_products_id_seq OWNER TO postgres;

--
-- Name: reservation_products_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.reservation_products_id_seq OWNED BY public.reservation_products.id;


--
-- Name: speciality; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.speciality (
    id integer NOT NULL,
    name character varying
);


ALTER TABLE public.speciality OWNER TO postgres;

--
-- Name: speciality_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.speciality_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.speciality_id_seq OWNER TO postgres;

--
-- Name: speciality_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.speciality_id_seq OWNED BY public.speciality.id;


--
-- Name: user_login_monitoring; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_login_monitoring (
    id integer NOT NULL,
    login_date timestamp without time zone,
    logout_date timestamp without time zone,
    duration character varying,
    user_id integer,
    location character varying,
    latitude character varying,
    longitude character varying
);


ALTER TABLE public.user_login_monitoring OWNER TO postgres;

--
-- Name: user_login_monitoring_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.user_login_monitoring_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.user_login_monitoring_id_seq OWNER TO postgres;

--
-- Name: user_login_monitoring_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.user_login_monitoring_id_seq OWNED BY public.user_login_monitoring.id;


--
-- Name: user_product_plan; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_product_plan (
    id integer NOT NULL,
    amount integer,
    current_amount integer,
    date timestamp without time zone,
    product_id integer,
    med_rep_id integer,
    plan_month timestamp without time zone,
    price integer,
    discount_price integer
);


ALTER TABLE public.user_product_plan OWNER TO postgres;

--
-- Name: user_product_plan_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.user_product_plan_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.user_product_plan_id_seq OWNER TO postgres;

--
-- Name: user_product_plan_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.user_product_plan_id_seq OWNED BY public.user_product_plan.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id integer NOT NULL,
    full_name character varying,
    username character varying,
    hashed_password character varying,
    status character varying,
    deleted boolean,
    region_id integer,
    region_manager_id integer,
    ffm_id integer,
    product_manager_id integer,
    deputy_director_id integer,
    director_id integer,
    email character varying,
    code character varying,
    expire_date timestamp without time zone
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: wholesale; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.wholesale (
    id integer NOT NULL,
    name character varying,
    contact character varying,
    region_id integer
);


ALTER TABLE public.wholesale OWNER TO postgres;

--
-- Name: wholesale_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.wholesale_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.wholesale_id_seq OWNER TO postgres;

--
-- Name: wholesale_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.wholesale_id_seq OWNED BY public.wholesale.id;


--
-- Name: wholesale_output; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.wholesale_output (
    id integer NOT NULL,
    amount integer,
    date timestamp without time zone,
    pharmacy character varying,
    product_id integer,
    wholesale_id integer
);


ALTER TABLE public.wholesale_output OWNER TO postgres;

--
-- Name: wholesale_output_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.wholesale_output_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.wholesale_output_id_seq OWNER TO postgres;

--
-- Name: wholesale_output_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.wholesale_output_id_seq OWNED BY public.wholesale_output.id;


--
-- Name: wholesale_reservation; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.wholesale_reservation (
    id integer NOT NULL,
    date timestamp without time zone,
    date_implementation timestamp without time zone,
    expire_date timestamp without time zone,
    discount double precision,
    discountable boolean,
    total_quantity integer,
    total_amount double precision,
    total_payable double precision,
    total_payable_with_nds double precision,
    invoice_number integer DEFAULT nextval('public.invoice_number_seq'::regclass),
    profit integer,
    debt integer,
    wholesale_id integer,
    manufactured_company_id integer,
    checked boolean,
    med_rep_id integer,
    reailized_debt integer,
    prosrochenniy_debt boolean,
    bonus boolean
);


ALTER TABLE public.wholesale_reservation OWNER TO postgres;

--
-- Name: wholesale_reservation_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.wholesale_reservation_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.wholesale_reservation_id_seq OWNER TO postgres;

--
-- Name: wholesale_reservation_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.wholesale_reservation_id_seq OWNED BY public.wholesale_reservation.id;


--
-- Name: wholesale_reservation_payed_amounts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.wholesale_reservation_payed_amounts (
    id integer NOT NULL,
    amount integer,
    description character varying,
    date timestamp without time zone,
    product_id integer,
    doctor_id integer,
    pharmacy_id integer,
    med_rep_id integer,
    reservation_id integer,
    total_sum integer,
    remainder_sum integer,
    quantity integer,
    payed boolean,
    nds_sum integer,
    fot_sum integer,
    promo_sum integer,
    skidka_sum integer,
    pure_proceeds integer
);


ALTER TABLE public.wholesale_reservation_payed_amounts OWNER TO postgres;

--
-- Name: wholesale_reservation_payed_amounts_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.wholesale_reservation_payed_amounts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.wholesale_reservation_payed_amounts_id_seq OWNER TO postgres;

--
-- Name: wholesale_reservation_payed_amounts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.wholesale_reservation_payed_amounts_id_seq OWNED BY public.wholesale_reservation_payed_amounts.id;


--
-- Name: wholesale_reservation_products; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.wholesale_reservation_products (
    id integer NOT NULL,
    quantity integer,
    product_id integer,
    price double precision,
    reservation_id integer,
    not_payed_quantity integer
);


ALTER TABLE public.wholesale_reservation_products OWNER TO postgres;

--
-- Name: wholesale_reservation_products_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.wholesale_reservation_products_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.wholesale_reservation_products_id_seq OWNER TO postgres;

--
-- Name: wholesale_reservation_products_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.wholesale_reservation_products_id_seq OWNED BY public.wholesale_reservation_products.id;


--
-- Name: bonus id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bonus ALTER COLUMN id SET DEFAULT nextval('public.bonus_id_seq'::regclass);


--
-- Name: bonus_payed_amounts id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bonus_payed_amounts ALTER COLUMN id SET DEFAULT nextval('public.bonus_payed_amounts_id_seq'::regclass);


--
-- Name: checking_balance_in_stock id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.checking_balance_in_stock ALTER COLUMN id SET DEFAULT nextval('public.checking_balance_in_stock_id_seq'::regclass);


--
-- Name: checking_stock_products id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.checking_stock_products ALTER COLUMN id SET DEFAULT nextval('public.checking_stock_products_id_seq'::regclass);


--
-- Name: current_balance_in_stock id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.current_balance_in_stock ALTER COLUMN id SET DEFAULT nextval('public.current_balance_in_stock_id_seq'::regclass);


--
-- Name: current_factory_warehouse id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.current_factory_warehouse ALTER COLUMN id SET DEFAULT nextval('public.current_factory_warehouse_id_seq'::regclass);


--
-- Name: current_wholesale_warehouse id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.current_wholesale_warehouse ALTER COLUMN id SET DEFAULT nextval('public.current_wholesale_warehouse_id_seq'::regclass);


--
-- Name: debt id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.debt ALTER COLUMN id SET DEFAULT nextval('public.debt_id_seq'::regclass);


--
-- Name: distance id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.distance ALTER COLUMN id SET DEFAULT nextval('public.distance_id_seq'::regclass);


--
-- Name: doctor id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.doctor ALTER COLUMN id SET DEFAULT nextval('public.doctor_id_seq'::regclass);


--
-- Name: doctor_category id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.doctor_category ALTER COLUMN id SET DEFAULT nextval('public.doctor_category_id_seq'::regclass);


--
-- Name: doctor_fact id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.doctor_fact ALTER COLUMN id SET DEFAULT nextval('public.doctor_fact_id_seq'::regclass);


--
-- Name: doctor_monthly_plan id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.doctor_monthly_plan ALTER COLUMN id SET DEFAULT nextval('public.doctor_monthly_plan_id_seq'::regclass);


--
-- Name: doctor_plan id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.doctor_plan ALTER COLUMN id SET DEFAULT nextval('public.doctor_plan_id_seq'::regclass);


--
-- Name: doctor_postupleniya_fact id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.doctor_postupleniya_fact ALTER COLUMN id SET DEFAULT nextval('public.doctor_postupleniya_fact_id_seq'::regclass);


--
-- Name: doctor_visit_info id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.doctor_visit_info ALTER COLUMN id SET DEFAULT nextval('public.doctor_visit_info_id_seq'::regclass);


--
-- Name: editable_plan_months id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.editable_plan_months ALTER COLUMN id SET DEFAULT nextval('public.editable_plan_months_id_seq'::regclass);


--
-- Name: expense id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.expense ALTER COLUMN id SET DEFAULT nextval('public.expense_id_seq'::regclass);


--
-- Name: expense_category id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.expense_category ALTER COLUMN id SET DEFAULT nextval('public.expense_category_id_seq'::regclass);


--
-- Name: hospital id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hospital ALTER COLUMN id SET DEFAULT nextval('public.hospital_id_seq'::regclass);


--
-- Name: hospital_bonus id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hospital_bonus ALTER COLUMN id SET DEFAULT nextval('public.hospital_bonus_id_seq'::regclass);


--
-- Name: hospital_fact id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hospital_fact ALTER COLUMN id SET DEFAULT nextval('public.hospital_fact_id_seq'::regclass);


--
-- Name: hospital_monthly_plan id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hospital_monthly_plan ALTER COLUMN id SET DEFAULT nextval('public.hospital_monthly_plan_id_seq'::regclass);


--
-- Name: hospital_postupleniya_fact id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hospital_postupleniya_fact ALTER COLUMN id SET DEFAULT nextval('public.hospital_postupleniya_fact_id_seq'::regclass);


--
-- Name: hospital_reservation id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hospital_reservation ALTER COLUMN id SET DEFAULT nextval('public.hospital_reservation_id_seq'::regclass);


--
-- Name: hospital_reservation_payed_amounts id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hospital_reservation_payed_amounts ALTER COLUMN id SET DEFAULT nextval('public.hospital_reservation_payed_amounts_id_seq'::regclass);


--
-- Name: hospital_reservation_products id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hospital_reservation_products ALTER COLUMN id SET DEFAULT nextval('public.hospital_reservation_products_id_seq'::regclass);


--
-- Name: incoming_balance_in_stock id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.incoming_balance_in_stock ALTER COLUMN id SET DEFAULT nextval('public.incoming_balance_in_stock_id_seq'::regclass);


--
-- Name: incoming_stock_products id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.incoming_stock_products ALTER COLUMN id SET DEFAULT nextval('public.incoming_stock_products_id_seq'::regclass);


--
-- Name: manufactured_company id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.manufactured_company ALTER COLUMN id SET DEFAULT nextval('public.manufactured_company_id_seq'::regclass);


--
-- Name: medical_organization id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.medical_organization ALTER COLUMN id SET DEFAULT nextval('public.medical_organization_id_seq'::regclass);


--
-- Name: notification id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notification ALTER COLUMN id SET DEFAULT nextval('public.notification_id_seq'::regclass);


--
-- Name: pharmacy id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pharmacy ALTER COLUMN id SET DEFAULT nextval('public.pharmacy_id_seq'::regclass);


--
-- Name: pharmacy_fact id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pharmacy_fact ALTER COLUMN id SET DEFAULT nextval('public.pharmacy_fact_id_seq'::regclass);


--
-- Name: pharmacy_hot_sale id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pharmacy_hot_sale ALTER COLUMN id SET DEFAULT nextval('public.pharmacy_hot_sale_id_seq'::regclass);


--
-- Name: pharmacy_plan id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pharmacy_plan ALTER COLUMN id SET DEFAULT nextval('public.pharmacy_plan_id_seq'::regclass);


--
-- Name: pharmacy_plan_attached_product id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pharmacy_plan_attached_product ALTER COLUMN id SET DEFAULT nextval('public.pharmacy_plan_attached_product_id_seq'::regclass);


--
-- Name: product_category id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_category ALTER COLUMN id SET DEFAULT nextval('public.product_category_id_seq'::regclass);


--
-- Name: product_expenses id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_expenses ALTER COLUMN id SET DEFAULT nextval('public.product_expenses_id_seq'::regclass);


--
-- Name: products id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products ALTER COLUMN id SET DEFAULT nextval('public.products_id_seq'::regclass);


--
-- Name: region id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.region ALTER COLUMN id SET DEFAULT nextval('public.region_id_seq'::regclass);


--
-- Name: remainder_sum_from_reservation id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.remainder_sum_from_reservation ALTER COLUMN id SET DEFAULT nextval('public.remainder_sum_from_reservation_id_seq'::regclass);


--
-- Name: report_factory_warehouse id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.report_factory_warehouse ALTER COLUMN id SET DEFAULT nextval('public.report_factory_warehouse_id_seq'::regclass);


--
-- Name: reservation id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reservation ALTER COLUMN id SET DEFAULT nextval('public.reservation_id_seq'::regclass);


--
-- Name: reservation_payed_amounts id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reservation_payed_amounts ALTER COLUMN id SET DEFAULT nextval('public.reservation_payed_amounts_id_seq'::regclass);


--
-- Name: reservation_products id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reservation_products ALTER COLUMN id SET DEFAULT nextval('public.reservation_products_id_seq'::regclass);


--
-- Name: speciality id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.speciality ALTER COLUMN id SET DEFAULT nextval('public.speciality_id_seq'::regclass);


--
-- Name: user_login_monitoring id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_login_monitoring ALTER COLUMN id SET DEFAULT nextval('public.user_login_monitoring_id_seq'::regclass);


--
-- Name: user_product_plan id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_product_plan ALTER COLUMN id SET DEFAULT nextval('public.user_product_plan_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: wholesale id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wholesale ALTER COLUMN id SET DEFAULT nextval('public.wholesale_id_seq'::regclass);


--
-- Name: wholesale_output id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wholesale_output ALTER COLUMN id SET DEFAULT nextval('public.wholesale_output_id_seq'::regclass);


--
-- Name: wholesale_reservation id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wholesale_reservation ALTER COLUMN id SET DEFAULT nextval('public.wholesale_reservation_id_seq'::regclass);


--
-- Name: wholesale_reservation_payed_amounts id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wholesale_reservation_payed_amounts ALTER COLUMN id SET DEFAULT nextval('public.wholesale_reservation_payed_amounts_id_seq'::regclass);


--
-- Name: wholesale_reservation_products id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wholesale_reservation_products ALTER COLUMN id SET DEFAULT nextval('public.wholesale_reservation_products_id_seq'::regclass);


--
-- Data for Name: alembic_version; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.alembic_version (version_num) FROM stdin;
94751066c2d8
\.


--
-- Data for Name: bonus; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.bonus (id, date, amount, doctor_id, payed, product_id, product_quantity, pre_investment) FROM stdin;
580	2024-08-12 04:30:39.216698	0	370	0	31	0	0
587	2024-08-12 12:24:15.799821	0	374	0	18	0	0
651	2024-08-13 02:35:16.525232	800000	314	0	27	20	0
678	2024-08-13 02:35:16.525232	0	412	0	31	0	0
680	2024-08-13 02:35:16.525232	0	384	0	31	0	0
686	2024-08-13 02:35:16.525232	0	410	0	4	0	0
687	2024-08-13 02:35:16.525232	0	411	0	4	0	0
697	2024-08-13 02:35:16.525232	0	391	0	31	0	0
707	2024-08-13 02:35:16.525232	0	420	0	13	0	0
714	2024-08-13 02:35:16.525232	0	426	0	25	0	0
716	2024-08-13 02:35:16.525232	0	422	0	30	0	0
719	2024-08-13 02:35:16.525232	0	419	0	4	0	0
723	2024-08-13 02:35:16.525232	0	418	0	13	0	0
724	2024-08-13 02:35:16.525232	0	417	0	13	0	0
725	2024-08-13 02:35:16.525232	0	423	0	26	0	0
726	2024-08-13 02:35:16.525232	0	423	0	27	0	0
733	2024-08-13 02:35:16.525232	0	448	0	31	0	0
736	2024-08-13 02:35:16.525232	0	445	0	30	0	0
745	2024-08-13 02:35:16.525232	0	447	0	12	0	0
748	2024-08-13 02:35:16.525232	0	443	0	13	0	0
764	2024-08-13 02:35:16.525232	0	380	0	4	0	0
776	2024-08-13 02:35:16.525232	0	299	0	4	0	0
784	2024-08-13 10:07:30.077119	0	459	0	27	0	0
788	2024-08-13 10:07:30.077119	0	299	0	24	0	0
790	2024-08-13 10:07:30.077119	0	470	0	31	0	0
797	2024-08-13 10:07:30.077119	0	469	0	25	0	0
811	2024-08-13 12:09:01.317975	0	481	0	30	0	0
824	2024-08-13 12:09:01.317975	0	478	0	13	0	0
832	2024-08-13 12:09:01.317975	0	480	0	22	0	0
574	2024-08-08 10:41:00.538055	6000000	80	0	25	120	0
845	2024-08-13 12:09:01.317975	560000	313	0	12	35	0
877	2024-08-15 11:23:50.507176	400000	302	0	13	20	0
882	2024-08-15 11:23:50.507176	0	369	0	24	0	0
887	2024-08-15 11:23:50.507176	0	312	0	33	0	0
896	2024-08-15 11:23:50.507176	100000	473	0	13	5	0
908	2024-08-21 07:39:51.732102	400000	591	0	27	10	0
901	2024-08-15 11:23:50.507176	600000	384	0	13	30	0
588	2024-08-12 12:24:15.799821	0	374	0	30	0	0
595	2024-08-12 12:24:15.799821	0	376	0	18	0	0
599	2024-08-12 12:24:15.799821	0	377	0	25	0	0
646	2024-08-13 02:35:16.525232	0	388	0	25	0	0
652	2024-08-13 02:35:16.525232	1050000	361	0	25	21	0
674	2024-08-13 02:35:16.525232	0	405	0	18	0	0
679	2024-08-13 02:35:16.525232	0	413	0	31	0	0
682	2024-08-13 02:35:16.525232	0	407	0	30	0	0
689	2024-08-13 02:35:16.525232	0	413	0	4	0	0
700	2024-08-13 02:35:16.525232	0	407	0	27	0	0
701	2024-08-13 02:35:16.525232	0	411	0	33	0	0
709	2024-08-13 02:35:16.525232	0	417	0	31	0	0
710	2024-08-13 02:35:16.525232	0	419	0	31	0	0
713	2024-08-13 02:35:16.525232	0	426	0	12	0	0
737	2024-08-13 02:35:16.525232	0	443	0	30	0	0
746	2024-08-13 02:35:16.525232	0	440	0	13	0	0
753	2024-08-13 02:35:16.525232	0	451	0	27	0	0
756	2024-08-13 02:35:16.525232	1750000	304	0	5	50	0
763	2024-08-13 02:35:16.525232	0	378	0	12	0	0
768	2024-08-13 02:35:16.525232	0	454	0	24	0	0
779	2024-08-13 10:07:30.077119	0	459	0	30	0	0
786	2024-08-13 10:07:30.077119	0	456	0	27	0	0
787	2024-08-13 10:07:30.077119	0	455	0	27	0	0
789	2024-08-13 10:07:30.077119	10500000	461	0	28	500	0
812	2024-08-13 12:09:01.317975	0	480	0	30	0	0
829	2024-08-13 12:09:01.317975	190000	303	0	7	10	0
846	2024-08-13 12:09:01.317975	16000	313	0	19	1	0
857	2024-08-15 11:23:50.507176	0	311	0	22	0	0
851	2024-08-14 11:51:29.14059	2240000	516	0	5	64	0
883	2024-08-15 11:23:50.507176	0	405	0	19	0	0
888	2024-08-15 11:23:50.507176	0	579	0	18	0	0
889	2024-08-15 11:23:50.507176	0	491	0	31	0	0
897	2024-08-15 11:23:50.507176	1800000	312	0	25	36	0
909	2024-08-21 07:39:51.732102	0	591	0	12	0	0
902	2024-08-21 07:39:51.732102	510000	588	0	24	30	0
708	2024-08-13 02:35:16.525232	1344000	309	0	12	84	0
807	2024-08-13 10:07:30.077119	0	469	6000000	24	0	6000000
747	2024-08-13 02:35:16.525232	400000	441	0	13	20	0
915	2024-08-22 05:40:04.683819	3660000	594	0	33	61	0
905	2024-08-21 07:39:51.732102	1000000	590	0	25	20	0
856	2024-08-14 11:51:29.14059	3500000	531	0	25	70	0
916	2024-08-22 05:40:04.683819	170000	571	0	24	10	0
589	2024-08-12 12:24:15.799821	0	373	0	12	0	0
593	2024-08-12 12:24:15.799821	0	376	0	30	0	0
647	2024-08-13 02:35:16.525232	0	390	0	13	0	0
681	2024-08-13 02:35:16.525232	0	384	0	30	0	0
690	2024-08-13 02:35:16.525232	0	384	0	12	0	0
691	2024-08-13 02:35:16.525232	0	408	0	12	0	0
695	2024-08-13 02:35:16.525232	0	412	0	13	0	0
578	2024-08-12 04:30:39.216698	100000	357	100000	30	5	0
583	2024-08-12 11:58:22.281351	80000	357	80000	12	5	0
581	2024-08-12 04:30:39.216698	16000	370	36000	19	1	20000
806	2024-08-13 10:07:30.077119	2380000	468	0	22	119	0
825	2024-08-13 12:09:01.317975	1600000	480	0	13	80	0
817	2024-08-13 12:09:01.317975	120000	481	0	10	4	0
805	2024-08-13 10:07:30.077119	340000	471	0	22	17	0
831	2024-08-13 12:09:01.317975	320000	477	0	19	20	0
703	2024-08-13 02:35:16.525232	0	416	0	4	0	0
704	2024-08-13 02:35:16.525232	0	416	0	31	0	0
717	2024-08-13 02:35:16.525232	0	424	0	4	0	0
718	2024-08-13 02:35:16.525232	0	422	0	4	0	0
654	2024-08-13 02:35:16.525232	0	369	50	31	0	50
729	2024-08-13 02:35:16.525232	0	440	0	31	0	0
730	2024-08-13 02:35:16.525232	0	441	0	31	0	0
738	2024-08-13 02:35:16.525232	0	441	0	30	0	0
740	2024-08-13 02:35:16.525232	0	447	0	25	0	0
743	2024-08-13 02:35:16.525232	0	441	0	4	0	0
758	2024-08-13 02:35:16.525232	0	382	0	13	0	0
759	2024-08-13 02:35:16.525232	0	383	0	13	0	0
760	2024-08-13 02:35:16.525232	0	383	0	5	0	0
761	2024-08-13 02:35:16.525232	0	380	0	5	0	0
762	2024-08-13 02:35:16.525232	0	379	0	18	0	0
765	2024-08-13 02:35:16.525232	0	453	0	12	0	0
766	2024-08-13 02:35:16.525232	0	453	0	25	0	0
769	2024-08-13 02:35:16.525232	0	458	0	31	0	0
772	2024-08-13 02:35:16.525232	0	456	0	30	0	0
777	2024-08-13 02:35:16.525232	0	456	0	4	0	0
780	2024-08-13 10:07:30.077119	0	458	0	30	0	0
793	2024-08-13 10:07:30.077119	0	468	0	30	0	0
813	2024-08-13 12:09:01.317975	0	477	0	25	0	0
816	2024-08-13 12:09:01.317975	0	476	0	4	0	0
821	2024-08-13 12:09:01.317975	0	479	0	13	0	0
826	2024-08-13 12:09:01.317975	0	481	0	13	0	0
827	2024-08-13 12:09:01.317975	150000	303	0	10	5	0
600	2024-08-12 12:24:15.799821	1500000	378	0	25	30	0
847	2024-08-13 12:09:01.317975	0	508	0	24	0	0
852	2024-08-14 11:51:29.14059	0	80	0	24	0	0
853	2024-08-14 11:51:29.14059	0	474	0	25	0	0
858	2024-08-15 11:23:50.507176	0	311	0	19	0	0
884	2024-08-15 11:23:50.507176	0	513	0	12	0	0
890	2024-08-15 11:23:50.507176	0	579	0	26	0	0
891	2024-08-15 11:23:50.507176	0	474	0	30	0	0
904	2024-08-21 07:39:51.732102	2500000	589	0	25	50	0
911	2024-08-22 05:40:04.683819	0	593	0	24	0	0
903	2024-08-21 07:39:51.732102	160000	588	0	12	10	0
917	2024-08-22 11:35:58.384258	400000	596	0	13	20	0
590	2024-08-12 12:24:15.799821	0	373	0	19	0	0
592	2024-08-12 12:24:15.799821	0	375	0	12	0	0
684	2024-08-13 02:35:16.525232	0	407	0	25	0	0
688	2024-08-13 02:35:16.525232	0	412	0	4	0	0
692	2024-08-13 02:35:16.525232	0	414	0	18	0	0
693	2024-08-13 02:35:16.525232	0	413	0	13	0	0
694	2024-08-13 02:35:16.525232	0	414	0	19	0	0
698	2024-08-13 02:35:16.525232	0	410	0	26	0	0
705	2024-08-13 02:35:16.525232	0	420	0	30	0	0
712	2024-08-13 02:35:16.525232	0	415	0	25	0	0
720	2024-08-13 02:35:16.525232	0	415	0	4	0	0
731	2024-08-13 02:35:16.525232	0	445	0	31	0	0
734	2024-08-13 02:35:16.525232	0	448	0	30	0	0
739	2024-08-13 02:35:16.525232	0	440	0	30	0	0
742	2024-08-13 02:35:16.525232	0	440	0	4	0	0
744	2024-08-13 02:35:16.525232	0	448	0	12	0	0
749	2024-08-13 02:35:16.525232	0	445	0	13	0	0
750	2024-08-13 02:35:16.525232	0	447	0	26	0	0
757	2024-08-13 02:35:16.525232	0	382	0	27	0	0
767	2024-08-13 02:35:16.525232	0	453	0	24	0	0
770	2024-08-13 02:35:16.525232	0	455	0	30	0	0
771	2024-08-13 02:35:16.525232	0	299	0	30	0	0
773	2024-08-13 02:35:16.525232	0	459	0	25	0	0
775	2024-08-13 02:35:16.525232	0	457	0	4	0	0
785	2024-08-13 10:07:30.077119	0	458	0	27	0	0
791	2024-08-13 10:07:30.077119	0	466	0	31	0	0
792	2024-08-13 10:07:30.077119	0	471	0	30	0	0
794	2024-08-13 10:07:30.077119	0	467	0	30	0	0
800	2024-08-13 10:07:30.077119	0	470	0	4	0	0
802	2024-08-13 10:07:30.077119	0	467	0	26	0	0
809	2024-08-13 12:09:01.317975	0	481	0	31	0	0
814	2024-08-13 12:09:01.317975	0	481	0	25	0	0
820	2024-08-13 12:09:01.317975	0	478	0	12	0	0
833	2024-08-13 12:09:01.317975	0	481	0	22	0	0
828	2024-08-13 12:09:01.317975	360000	303	0	23	30	0
843	2024-08-13 12:09:01.317975	120000	300	0	18	10	0
854	2024-08-14 11:51:29.14059	0	532	0	12	0	0
859	2024-08-15 11:23:50.507176	0	311	0	21	0	0
871	2024-08-15 11:23:50.507176	320000	300	0	12	20	0
655	2024-08-13 02:35:16.525232	2550000	301	0	24	150	0
885	2024-08-15 11:23:50.507176	0	577	0	27	0	0
893	2024-08-15 11:23:50.507176	0	483	0	13	0	0
894	2024-08-15 11:23:50.507176	0	489	0	24	0	0
910	2024-08-21 07:39:51.732102	300000	592	0	33	5	0
906	2024-08-21 07:39:51.732102	400000	591	0	15	20	0
918	2024-08-22 11:35:58.384258	352000	343	0	12	22	0
577	2024-08-12 04:30:39.216698	250000	357	250000	25	5	0
576	2024-08-12 04:30:39.216698	4000000	311	2000000	25	80	0
582	2024-08-12 11:58:22.281351	80000	357	80000	19	5	0
912	2024-08-22 05:40:04.683819	272000	593	272000	12	17	0
584	2024-08-12 11:58:22.281351	72000	357	60000	18	6	0
585	2024-08-12 11:58:22.281351	425000	357	425000	24	25	0
913	2024-08-22 05:40:04.683819	400000	593	400000	13	20	0
798	2024-08-13 10:07:30.077119	6100000	467	0	25	122	0
823	2024-08-13 12:09:01.317975	800000	476	0	13	40	0
801	2024-08-13 10:07:30.077119	1280000	466	0	12	80	0
818	2024-08-13 12:09:01.317975	160000	477	0	12	10	0
819	2024-08-13 12:09:01.317975	480000	480	0	12	30	0
899	2024-08-15 11:23:50.507176	500000	583	0	25	10	0
803	2024-08-13 10:07:30.077119	600000	469	0	33	10	0
892	2024-08-15 11:23:50.507176	4048000	482	0	12	253	0
799	2024-08-13 10:07:30.077119	17300000	466	0	25	346	0
848	2024-08-13 12:09:01.317975	1050000	514	0	28	50	0
781	2024-08-13 10:07:30.077119	80000	299	0	12	5	0
721	2024-08-13 02:35:16.525232	150000	425	0	10	5	0
683	2024-08-13 02:35:16.525232	10000000	384	0	25	200	0
815	2024-08-13 12:09:01.317975	4575000	480	0	25	150	0
782	2024-08-13 10:07:30.077119	460000	343	0	13	23	0
579	2024-08-12 04:30:39.216698	0	367	0	18	0	0
591	2024-08-12 12:24:15.799821	0	375	0	13	0	0
594	2024-08-12 12:24:15.799821	0	376	0	13	0	0
596	2024-08-12 12:24:15.799821	0	344	0	13	0	0
476	2024-08-04 13:03:10.906704	0	80	0	31	0	0
486	2024-08-04 13:03:10.906704	0	80	0	25	0	0
650	2024-08-13 02:35:16.525232	200000	314	0	13	10	0
653	2024-08-13 02:35:16.525232	0	369	0	4	0	0
676	2024-08-13 02:35:16.525232	0	410	0	31	0	0
677	2024-08-13 02:35:16.525232	0	411	0	31	0	0
685	2024-08-13 02:35:16.525232	0	408	0	25	0	0
696	2024-08-13 02:35:16.525232	0	411	0	13	0	0
699	2024-08-13 02:35:16.525232	0	413	0	27	0	0
702	2024-08-13 02:35:16.525232	0	408	0	24	0	0
706	2024-08-13 02:35:16.525232	0	420	0	25	0	0
711	2024-08-13 02:35:16.525232	0	418	0	25	0	0
715	2024-08-13 02:35:16.525232	0	417	0	25	0	0
722	2024-08-13 02:35:16.525232	0	425	0	12	0	0
732	2024-08-13 02:35:16.525232	0	447	0	31	0	0
735	2024-08-13 02:35:16.525232	0	447	0	30	0	0
741	2024-08-13 02:35:16.525232	0	448	0	25	0	0
751	2024-08-13 02:35:16.525232	0	448	0	26	0	0
752	2024-08-13 02:35:16.525232	0	450	0	27	0	0
754	2024-08-13 02:35:16.525232	0	445	0	33	0	0
755	2024-08-13 02:35:16.525232	0	443	0	33	0	0
774	2024-08-13 02:35:16.525232	0	455	0	4	0	0
783	2024-08-13 10:07:30.077119	0	457	0	13	0	0
795	2024-08-13 10:07:30.077119	0	466	0	30	0	0
796	2024-08-13 10:07:30.077119	0	468	0	25	0	0
810	2024-08-13 12:09:01.317975	0	477	0	30	0	0
830	2024-08-13 12:09:01.317975	0	476	0	33	0	0
844	2024-08-13 12:09:01.317975	160000	302	0	12	10	0
886	2024-08-15 11:23:50.507176	0	310	0	4	0	0
855	2024-08-14 11:51:29.14059	340000	532	0	24	20	0
907	2024-08-21 07:39:51.732102	350000	591	0	14	10	0
778	2024-08-13 02:35:16.525232	480000	342	0	12	30	0
849	2024-08-13 12:09:01.317975	1120000	485	0	19	70	0
923	2024-08-23 10:32:41.507935	0	344	0	11	0	0
924	2024-08-23 11:35:41.16399	0	599	0	13	0	0
919	2024-08-23 04:46:18.269415	1800000	597	0	31	15	0
925	2024-08-24 09:55:36.503401	420000	600	0	28	20	0
930	2024-08-26 05:57:51.34156	400000	378	0	13	20	0
931	2024-08-26 05:57:51.34156	0	606	0	24	0	0
934	2024-08-26 05:57:51.34156	400000	303	0	13	20	0
935	2024-08-26 05:57:51.34156	0	608	0	4	0	0
936	2024-08-26 05:57:51.34156	0	609	0	13	0	0
937	2024-08-26 05:57:51.34156	0	610	0	12	0	0
932	2024-08-26 05:57:51.34156	1500000	607	0	25	30	0
922	2024-08-23 04:46:18.269415	6000000	598	0	25	120	0
940	2024-08-26 05:57:51.34156	1000000	611	0	13	50	0
941	2024-08-26 05:57:51.34156	1180000	612	0	13	59	0
942	2024-08-26 05:57:51.34156	0	370	0	24	0	0
943	2024-08-26 05:57:51.34156	0	370	0	30	0	0
944	2024-08-26 05:57:51.34156	0	370	0	4	0	0
945	2024-08-30 04:32:52.442717	0	339	0	12	0	0
947	2024-08-30 04:32:52.442717	0	362	0	12	0	0
948	2024-08-30 04:32:52.442717	0	362	0	13	0	0
920	2024-08-23 04:46:18.269415	7500000	472	6000000	25	150	0
949	2024-08-30 04:32:52.442717	0	360	0	27	0	0
965	2024-08-30 06:04:24.202482	0	376	0	25	0	0
966	2024-08-30 06:04:24.202482	0	376	0	12	0	0
967	2024-08-30 06:04:24.202482	0	376	0	19	0	0
968	2024-08-30 06:04:24.202482	0	344	0	25	0	0
969	2024-08-30 06:04:24.202482	0	344	0	12	0	0
970	2024-08-30 06:04:24.202482	0	305	0	25	0	0
971	2024-08-30 06:04:24.202482	0	303	0	12	0	0
972	2024-08-30 06:04:24.202482	0	618	0	31	0	0
973	2024-08-30 06:04:24.202482	0	618	0	13	0	0
974	2024-08-30 06:04:24.202482	0	619	0	12	0	0
975	2024-08-30 06:04:24.202482	0	619	0	13	0	0
976	2024-08-30 06:04:24.202482	0	619	0	25	0	0
979	2024-08-30 06:53:43.890599	0	409	0	13	0	0
881	2024-08-15 11:23:50.507176	1152000	310	0	12	72	0
980	2024-08-30 06:53:43.890599	0	380	0	33	0	0
586	2024-08-12 11:58:22.281351	120000	357	90000	10	4	0
895	2024-08-15 11:23:50.507176	1050000	308	1000000	25	21	0
926	2024-08-24 09:55:36.503401	1750000	601	0	25	35	0
927	2024-08-24 09:55:36.503401	300000	601	0	13	15	0
675	2024-08-13 02:35:16.525232	3520000	409	0	12	220	0
946	2024-08-30 04:32:52.442717	16000000	317	0	25	320	0
977	2024-08-30 06:04:24.202482	600000	616	600000	13	30	0
978	2024-08-30 06:04:24.202482	480000	621	480000	12	30	0
928	2024-08-24 09:55:36.503401	600000	601	0	27	15	0
834	2024-08-13 12:09:01.317975	600000	476	0	29	30	0
822	2024-08-13 12:09:01.317975	400000	477	0	13	20	0
836	2024-08-13 12:09:01.317975	680000	479	0	24	20	0
981	2024-08-30 06:53:43.890599	1088000	409	0	24	64	0
938	2024-08-26 05:57:51.34156	800000	469	0	12	50	0
898	2024-08-15 11:23:50.507176	192000	480	0	19	0	0
939	2024-08-26 05:57:51.34156	1500000	469	0	13	75	0
480	2024-08-04 13:03:10.906704	240000	80	0	33	4	0
929	2024-08-26 05:57:51.34156	391000	602	0	24	23	0
835	2024-08-13 12:09:01.317975	850000	478	0	24	50	0
900	2024-08-15 11:23:50.507176	420000	480	0	28	20	0
673	2024-08-13 02:35:16.525232	10400000	409	0	25	208	0
921	2024-08-23 04:46:18.269415	2100000	597	0	13	105	0
933	2024-08-26 05:57:51.34156	12000000	304	0	25	240	0
983	2024-08-30 06:53:43.890599	0	369	0	19	0	0
984	2024-08-30 11:09:09.43228	0	622	0	24	0	0
985	2024-08-30 11:09:09.43228	0	300	0	24	0	0
986	2024-08-30 11:09:09.43228	0	304	0	12	0	0
987	2024-08-30 11:09:09.43228	0	304	0	13	0	0
988	2024-08-30 11:09:09.43228	0	313	0	22	0	0
989	2024-08-30 11:09:09.43228	0	613	0	19	0	0
990	2024-08-30 11:09:09.43228	0	473	0	25	0	0
991	2024-08-30 11:09:09.43228	0	340	0	27	0	0
992	2024-08-30 11:09:09.43228	0	368	0	25	0	0
993	2024-08-30 11:09:09.43228	0	368	0	19	0	0
994	2024-08-30 11:09:09.43228	0	372	0	25	0	0
995	2024-08-30 11:09:09.43228	0	372	0	13	0	0
996	2024-08-30 11:09:09.43228	0	388	0	13	0	0
997	2024-08-30 11:09:09.43228	0	379	0	25	0	0
998	2024-08-30 11:09:09.43228	0	390	0	12	0	0
999	2024-08-30 11:09:09.43228	0	381	0	13	0	0
1000	2024-08-30 11:09:09.43228	0	532	0	33	0	0
1001	2024-08-30 11:09:09.43228	0	416	0	33	0	0
1002	2024-08-30 11:09:09.43228	0	578	0	18	0	0
1003	2024-08-30 11:09:09.43228	0	578	0	13	0	0
1004	2024-08-30 11:09:09.43228	0	426	0	26	0	0
1005	2024-09-01 07:49:17.895971	150000	368	0	25	3	0
1007	2024-09-02 16:06:40.534158	0	623	0	33	0	0
1008	2024-09-02 16:06:40.534158	16000	339	0	12	1	0
1009	2024-09-03 05:01:24.432247	0	624	0	25	0	0
1010	2024-09-03 05:01:24.432247	0	370	0	25	0	0
1011	2024-09-03 11:45:40.771028	0	488	0	31	0	0
1013	2024-09-03 11:45:40.771028	0	517	0	25	0	0
1014	2024-09-03 11:45:40.771028	0	607	0	30	0	0
1015	2024-09-03 11:45:40.771028	0	411	0	25	0	0
1016	2024-09-03 11:45:40.771028	0	516	0	4	0	0
1018	2024-09-03 11:45:40.771028	0	497	0	13	0	0
1019	2024-09-03 11:45:40.771028	0	518	0	27	0	0
1020	2024-09-03 11:45:40.771028	0	408	0	18	0	0
1021	2024-09-03 11:45:40.771028	0	407	0	18	0	0
1022	2024-09-03 11:45:40.771028	0	607	0	19	0	0
1023	2024-09-03 11:45:40.771028	0	410	0	22	0	0
1024	2024-09-03 11:45:40.771028	0	477	0	25	0	0
1025	2024-09-03 11:45:40.771028	0	480	0	28	0	0
1026	2024-09-03 11:45:40.771028	0	476	0	4	0	0
1027	2024-09-03 11:45:40.771028	0	477	0	19	0	0
1028	2024-09-03 11:45:40.771028	0	481	0	30	0	0
1029	2024-09-03 11:45:40.771028	0	478	0	24	0	0
1030	2024-09-03 11:45:40.771028	0	481	0	12	0	0
1031	2024-09-03 11:45:40.771028	0	477	0	13	0	0
1032	2024-09-03 11:45:40.771028	0	583	0	13	0	0
1033	2024-09-03 11:45:40.771028	0	476	0	13	0	0
1034	2024-09-03 11:45:40.771028	0	481	0	18	0	0
1035	2024-09-03 11:45:40.771028	0	477	0	18	0	0
1036	2024-09-03 11:45:40.771028	0	476	0	33	0	0
1037	2024-09-03 11:45:40.771028	0	583	0	21	0	0
1038	2024-09-03 11:45:40.771028	0	477	0	22	0	0
1039	2024-09-03 11:45:40.771028	0	481	0	22	0	0
1040	2024-09-03 11:45:40.771028	0	417	0	31	0	0
1041	2024-09-03 11:45:40.771028	0	418	0	30	0	0
1042	2024-09-03 11:45:40.771028	0	425	0	25	0	0
1043	2024-09-03 11:45:40.771028	0	423	0	12	0	0
1044	2024-09-03 11:45:40.771028	0	594	0	13	0	0
1046	2024-09-03 11:45:40.771028	0	415	0	18	0	0
1048	2024-09-03 11:45:40.771028	0	418	0	21	0	0
1049	2024-09-03 11:45:40.771028	0	422	0	22	0	0
1051	2024-09-03 11:45:40.771028	0	609	0	25	0	0
1052	2024-09-03 11:45:40.771028	0	617	0	12	0	0
1053	2024-09-03 11:45:40.771028	0	621	0	12	0	0
1056	2024-09-03 11:45:40.771028	0	616	0	27	0	0
1057	2024-09-03 11:45:40.771028	0	620	0	18	0	0
1058	2024-09-03 11:45:40.771028	0	609	0	22	0	0
1059	2024-09-03 11:45:40.771028	0	610	0	22	0	0
1060	2024-09-03 11:45:40.771028	0	620	0	24	0	0
1061	2024-09-03 11:45:40.771028	0	447	0	12	0	0
1062	2024-09-03 11:45:40.771028	0	448	0	12	0	0
1063	2024-09-03 11:45:40.771028	0	611	0	13	0	0
1064	2024-09-03 11:45:40.771028	0	612	0	13	0	0
1065	2024-09-03 11:45:40.771028	0	450	0	27	0	0
1066	2024-09-03 11:45:40.771028	0	451	0	27	0	0
1067	2024-09-03 11:45:40.771028	0	440	0	18	0	0
1068	2024-09-03 11:45:40.771028	0	441	0	18	0	0
1069	2024-09-03 11:45:40.771028	0	443	0	18	0	0
1070	2024-09-03 11:45:40.771028	0	445	0	18	0	0
1071	2024-09-03 11:45:40.771028	0	447	0	22	0	0
1072	2024-09-03 11:45:40.771028	0	448	0	22	0	0
1074	2024-09-03 11:45:40.771028	0	600	0	12	0	0
1075	2024-09-03 11:45:40.771028	0	600	0	13	0	0
1078	2024-09-03 11:45:40.771028	0	600	0	25	0	0
1079	2024-09-03 11:45:40.771028	0	470	0	31	0	0
1080	2024-09-03 11:45:40.771028	0	469	0	31	0	0
1081	2024-09-03 11:45:40.771028	0	468	0	25	0	0
1082	2024-09-03 11:45:40.771028	0	471	0	25	0	0
1083	2024-09-03 11:45:40.771028	0	470	0	4	0	0
1084	2024-09-03 11:45:40.771028	0	472	0	14	0	0
1085	2024-09-03 11:45:40.771028	0	597	0	18	0	0
1086	2024-09-03 11:45:40.771028	0	466	0	18	0	0
1087	2024-09-03 11:45:40.771028	0	598	0	28	0	0
1088	2024-09-03 11:45:40.771028	0	597	0	21	0	0
1090	2024-09-03 11:45:40.771028	0	467	0	24	0	0
1092	2024-09-03 11:45:40.771028	0	598	0	13	0	0
1093	2024-09-03 11:45:40.771028	0	491	0	31	0	0
1094	2024-09-03 11:45:40.771028	0	485	0	30	0	0
1096	2024-09-03 11:45:40.771028	0	80	0	25	0	0
1097	2024-09-03 11:45:40.771028	0	482	0	12	0	0
1098	2024-09-03 11:45:40.771028	0	474	0	12	0	0
1099	2024-09-03 11:45:40.771028	0	483	0	12	0	0
1100	2024-09-03 11:45:40.771028	0	485	0	12	0	0
1101	2024-09-03 11:45:40.771028	0	80	0	13	0	0
1017	2024-09-03 11:45:40.771028	800000	517	0	12	50	0
1047	2024-09-03 11:45:40.771028	300000	423	0	33	5	0
1089	2024-09-03 11:45:40.771028	100000	466	0	22	5	0
1076	2024-09-03 11:45:40.771028	100000	601	100000	13	5	0
1055	2024-09-03 11:45:40.771028	1120000	616	0	13	56	0
1095	2024-09-03 11:45:40.771028	5000000	474	0	25	100	0
1091	2024-09-03 11:45:40.771028	1000000	472	0	13	50	0
1073	2024-09-03 11:45:40.771028	80000	601	0	12	5	0
982	2024-08-30 06:53:43.890599	13000	409	0	20	1	0
1012	2024-09-03 11:45:40.771028	1500000	384	0	25	30	0
1102	2024-09-03 11:45:40.771028	0	490	0	18	0	0
1110	2024-09-03 11:45:40.771028	0	483	0	22	0	0
1114	2024-09-03 11:45:40.771028	0	520	0	25	0	0
1135	2024-09-03 11:45:40.771028	0	322	0	25	0	0
1139	2024-09-03 11:45:40.771028	0	604	0	21	0	0
1140	2024-09-03 11:45:40.771028	0	570	0	18	0	0
1129	2024-09-03 11:45:40.771028	340000	602	0	24	20	0
1103	2024-09-03 11:45:40.771028	0	482	0	18	0	0
1106	2024-09-03 11:45:40.771028	0	80	0	19	0	0
1104	2024-09-03 11:45:40.771028	0	486	0	33	0	0
1107	2024-09-03 11:45:40.771028	0	486	0	19	0	0
1109	2024-09-03 11:45:40.771028	0	486	0	22	0	0
1115	2024-09-03 11:45:40.771028	0	554	0	4	0	0
1117	2024-09-03 11:45:40.771028	0	509	0	12	0	0
1128	2024-09-03 11:45:40.771028	0	588	0	22	0	0
1133	2024-09-03 11:45:40.771028	0	570	0	30	0	0
1136	2024-09-03 11:45:40.771028	0	604	0	4	0	0
1141	2024-09-03 11:45:40.771028	0	604	0	18	0	0
1105	2024-09-03 11:45:40.771028	0	474	0	19	0	0
1108	2024-09-03 11:45:40.771028	0	490	0	21	0	0
1111	2024-09-03 11:45:40.771028	0	487	0	24	0	0
1112	2024-09-03 11:45:40.771028	0	491	0	4	0	0
1113	2024-09-03 11:45:40.771028	0	459	0	25	0	0
1116	2024-09-03 11:45:40.771028	0	458	0	4	0	0
1118	2024-09-03 11:45:40.771028	0	342	0	12	0	0
1119	2024-09-03 11:45:40.771028	0	522	0	13	0	0
1120	2024-09-03 11:45:40.771028	0	520	0	13	0	0
1121	2024-09-03 11:45:40.771028	0	508	0	18	0	0
1122	2024-09-03 11:45:40.771028	0	571	0	18	0	0
1123	2024-09-03 11:45:40.771028	0	606	0	19	0	0
1124	2024-09-03 11:45:40.771028	0	602	0	19	0	0
1125	2024-09-03 11:45:40.771028	0	554	0	21	0	0
1126	2024-09-03 11:45:40.771028	0	458	0	21	0	0
1127	2024-09-03 11:45:40.771028	0	508	0	22	0	0
1130	2024-09-03 11:45:40.771028	0	503	0	24	0	0
1131	2024-09-03 11:45:40.771028	0	604	0	31	0	0
1132	2024-09-03 11:45:40.771028	0	322	0	30	0	0
1134	2024-09-03 11:45:40.771028	0	603	0	25	0	0
1137	2024-09-03 11:45:40.771028	0	603	0	14	0	0
1138	2024-09-03 11:45:40.771028	0	570	0	33	0	0
1142	2024-09-03 11:45:40.771028	0	322	0	18	0	0
1143	2024-09-03 11:45:40.771028	0	603	0	18	0	0
1144	2024-09-03 11:45:40.771028	0	570	0	22	0	0
1145	2024-09-03 11:45:40.771028	0	604	0	12	0	0
1146	2024-09-03 11:45:40.771028	0	322	0	13	0	0
1147	2024-09-03 11:45:40.771028	0	603	0	12	0	0
1216	2024-09-10 12:08:11.045863	500000	369	0	25	10	0
1149	2024-09-03 11:45:40.771028	200000	601	0	27	5	0
1150	2024-09-03 11:45:40.771028	0	636	0	18	0	0
1151	2024-09-03 11:45:40.771028	0	636	0	31	0	0
1152	2024-09-03 11:45:40.771028	0	635	0	30	0	0
1153	2024-09-03 11:45:40.771028	0	635	0	22	0	0
1154	2024-09-03 11:45:40.771028	0	637	0	21	0	0
1155	2024-09-03 11:45:40.771028	0	637	0	30	0	0
1156	2024-09-03 11:45:40.771028	0	637	0	33	0	0
1157	2024-09-03 11:45:40.771028	0	635	0	21	0	0
1158	2024-09-05 08:00:17.071379	0	638	0	12	0	0
1159	2024-09-05 08:00:17.071379	0	638	0	24	0	0
1160	2024-09-05 09:25:02.894517	0	299	0	24	0	0
1161	2024-09-05 09:25:02.894517	0	639	0	12	0	0
1162	2024-09-05 09:25:02.894517	0	640	0	13	0	0
1163	2024-09-05 09:25:02.894517	0	641	0	27	0	0
1168	2024-09-05 09:25:02.894517	0	457	0	24	0	0
1045	2024-09-03 11:45:40.771028	400000	594	0	27	10	0
1170	2024-09-05 09:25:02.894517	850000	648	0	24	50	0
1169	2024-09-05 09:25:02.894517	969000	649	0	24	57	0
1148	2024-09-03 11:45:40.771028	2500000	531	0	25	50	0
1166	2024-09-05 09:25:02.894517	120000	643	0	31	2	0
1174	2024-09-09 09:56:53.451808	400000	651	0	27	10	0
1175	2024-09-09 09:56:53.451808	400000	650	0	27	10	0
1176	2024-09-09 09:56:53.451808	0	635	0	25	0	0
1177	2024-09-09 09:56:53.451808	0	637	0	25	0	0
1178	2024-09-09 09:56:53.451808	0	409	0	33	0	0
1179	2024-09-09 09:56:53.451808	0	473	0	27	0	0
1182	2024-09-09 09:56:53.451808	0	591	0	27	0	0
1183	2024-09-09 09:56:53.451808	0	532	0	18	0	0
1184	2024-09-09 09:56:53.451808	0	314	0	18	0	0
1185	2024-09-09 09:56:53.451808	0	312	0	33	0	0
1186	2024-09-09 09:56:53.451808	0	369	0	30	0	0
1187	2024-09-09 09:56:53.451808	0	306	0	5	0	0
1188	2024-09-09 09:56:53.451808	0	306	0	22	0	0
1189	2024-09-09 09:56:53.451808	0	306	0	18	0	0
1190	2024-09-09 09:56:53.451808	0	306	0	21	0	0
1191	2024-09-09 09:56:53.451808	0	306	0	12	0	0
1192	2024-09-09 09:56:53.451808	0	306	0	13	0	0
1193	2024-09-09 09:56:53.451808	0	306	0	24	0	0
1195	2024-09-09 09:56:53.451808	0	632	0	13	0	0
1196	2024-09-09 09:56:53.451808	0	306	0	30	0	0
1197	2024-09-09 09:56:53.451808	0	583	0	29	0	0
1200	2024-09-09 09:56:53.451808	0	409	0	18	0	0
1201	2024-09-09 09:56:53.451808	0	653	0	18	0	0
1203	2024-09-09 09:56:53.451808	0	456	0	24	0	0
1204	2024-09-09 09:56:53.451808	0	632	0	18	0	0
1205	2024-09-09 09:56:53.451808	0	601	0	22	0	0
1206	2024-09-09 09:56:53.451808	0	384	0	5	0	0
1207	2024-09-10 10:17:50.422756	0	415	0	33	0	0
1208	2024-09-10 10:17:50.422756	210000	652	0	28	10	0
1209	2024-09-10 10:17:50.422756	51000	652	0	24	3	0
1210	2024-09-10 12:08:11.045863	0	652	0	27	0	0
1212	2024-09-10 12:08:11.045863	500000	426	0	25	10	0
1213	2024-09-10 12:08:11.045863	240000	340	0	27	6	0
1181	2024-09-09 09:56:53.451808	51000	652	0	24	3	0
1214	2024-09-10 12:08:11.045863	800000	577	0	27	20	0
1202	2024-09-09 09:56:53.451808	100000	468	0	22	5	0
1219	2024-09-10 12:08:11.045863	11000000	472	0	25	220	0
1215	2024-09-10 12:08:11.045863	5000000	466	0	25	100	0
1217	2024-09-10 12:08:11.045863	8400000	461	0	28	400	0
1226	2024-09-01 00:00:00	4400000	656	3630000	27	110	0
1220	2024-09-01 00:00:00	1050000	590	1050000	25	21	0
1223	2024-09-01 00:00:00	0	409	0	13	0	0
1173	2024-09-09 09:56:53.451808	2500000	450	0	25	50	0
1224	2024-09-01 00:00:00	0	657	0	27	0	0
1225	2024-09-01 00:00:00	0	658	0	27	0	0
1229	2024-09-01 00:00:00	200000	659	0	13	10	0
1234	2024-09-01 00:00:00	500000	626	500000	25	10	0
1231	2024-09-01 00:00:00	160000	357	160000	12	10	0
1172	2024-09-05 09:25:02.894517	368000	590	368000	12	23	0
1233	2024-09-01 00:00:00	900000	426	0	11	20	0
1235	2024-09-01 00:00:00	120000	481	0	10	4	0
1232	2024-09-01 00:00:00	200000	357	200000	30	10	0
1227	2024-09-01 00:00:00	8500000	317	0	25	170	0
1230	2024-09-01 00:00:00	750000	312	750000	25	15	0
1228	2024-09-01 00:00:00	400000	659	0	30	20	0
1198	2024-09-09 09:56:53.451808	120000	300	0	18	10	0
1218	2024-09-10 12:08:11.045863	550000	654	550000	25	11	0
1165	2024-09-05 09:25:02.894517	500000	613	500000	25	10	0
1199	2024-09-09 09:56:53.451808	1300000	300	0	21	100	0
1211	2024-09-10 12:08:11.045863	160000	302	0	19	10	0
1167	2024-09-05 09:25:02.894517	160000	643	0	12	10	0
1077	2024-09-03 11:45:40.771028	3700000	601	250000	25	74	0
1194	2024-09-09 09:56:53.451808	2100000	600	0	28	100	0
1236	2024-09-01 00:00:00	2000000	311	1000000	25	40	0
1171	2024-09-05 09:25:02.894517	672000	351	368000	12	42	0
1237	2024-09-01 00:00:00	0	369	0	23	0	0
1180	2024-09-09 09:56:53.451808	168000	652	0	28	8	0
1238	2024-08-01 00:00:00	210000	652	0	28	10	0
1239	2024-08-01 00:00:00	68000	652	0	24	4	0
1242	2024-09-01 00:00:00	0	662	0	27	0	0
1245	2024-09-01 00:00:00	640000	313	0	12	40	0
1307	2024-09-01 00:00:00	0	412	0	11	0	0
1308	2024-09-01 00:00:00	0	384	0	10	0	0
1309	2024-08-01 00:00:00	210000	384	0	10	7	0
1310	2024-08-01 00:00:00	1350000	412	0	11	30	0
1247	2024-09-01 00:00:00	240000	309	240000	12	15	0
1311	2024-09-01 00:00:00	80000	362	0	12	5	0
1306	2024-09-01 00:00:00	0	362	0	37	20	0
1312	2024-09-01 00:00:00	0	322	0	10	0	0
1249	2024-09-01 00:00:00	0	317	0	20	0	0
1250	2024-09-01 00:00:00	0	663	0	13	0	0
1251	2024-09-01 00:00:00	0	663	0	27	0	0
1252	2024-09-01 00:00:00	0	663	0	24	0	0
1313	2024-09-01 00:00:00	0	322	0	12	0	0
1254	2024-09-01 00:00:00	0	622	0	38	48	0
1255	2024-09-01 00:00:00	0	666	0	38	48	0
1348	2024-10-01 00:00:00	0	409	0	22	0	0
1244	2024-09-01 00:00:00	6000000	304	0	25	120	0
1257	2024-09-01 00:00:00	0	409	0	11	0	0
1258	2024-09-01 00:00:00	0	409	0	4	0	0
1259	2024-09-01 00:00:00	300000	416	0	31	5	0
1260	2024-09-01 00:00:00	1000000	378	0	25	20	0
1261	2024-09-01 00:00:00	0	420	0	31	0	0
1262	2024-09-01 00:00:00	0	420	0	30	0	0
1314	2024-09-01 00:00:00	800000	302	0	13	40	0
1315	2024-09-01 00:00:00	0	664	0	33	0	0
1248	2024-09-01 00:00:00	560000	310	240000	12	35	0
1263	2024-09-01 00:00:00	170000	668	0	24	10	0
1264	2024-09-01 00:00:00	400000	457	0	30	20	0
1265	2024-09-01 00:00:00	200000	643	0	13	10	0
1266	2024-09-01 00:00:00	340000	588	0	24	20	0
1267	2024-09-01 00:00:00	320000	588	0	12	20	0
1269	2024-09-01 00:00:00	0	610	0	13	0	0
1273	2024-09-01 00:00:00	1300000	669	0	13	65	0
1274	2024-09-01 00:00:00	800000	670	0	27	20	0
1270	2024-09-01 00:00:00	800000	616	0	12	50	0
1271	2024-09-01 00:00:00	1000000	616	0	25	20	0
1349	2024-10-01 00:00:00	0	379	0	18	0	0
1268	2024-09-01 00:00:00	900000	652	0	11	20	0
1278	2024-09-01 00:00:00	500000	308	0	25	10	0
1279	2024-09-01 00:00:00	256000	591	0	12	16	0
1280	2024-09-01 00:00:00	800000	684	0	12	50	0
1316	2024-08-01 00:00:00	80000	604	0	12	5	0
1317	2024-08-01 00:00:00	140000	603	0	14	4	0
1281	2024-09-01 00:00:00	340000	684	0	24	20	0
1282	2024-09-01 00:00:00	3000000	589	0	25	60	0
1243	2024-09-01 00:00:00	320000	655	160000	19	20	0
1318	2024-08-01 00:00:00	8500000	603	0	25	170	0
1240	2024-09-01 00:00:00	800000	472	0	12	50	0
1283	2024-08-01 00:00:00	0	369	0	25	0	0
1284	2024-08-01 00:00:00	708000	477	0	18	59	0
1285	2024-09-01 00:00:00	0	481	0	11	0	0
1286	2024-09-01 00:00:00	0	481	0	5	0	0
1287	2024-08-01 00:00:00	665000	481	0	5	19	0
1288	2024-08-01 00:00:00	1080000	481	0	11	24	0
1289	2024-09-01 00:00:00	0	478	0	23	0	0
1290	2024-08-01 00:00:00	12000	478	0	23	1	0
1291	2024-09-01 00:00:00	0	644	0	28	0	0
1292	2024-09-01 00:00:00	0	466	0	10	0	0
1293	2024-09-01 00:00:00	0	362	0	31	0	0
1294	2024-08-01 00:00:00	2100000	644	0	28	100	0
1301	2024-08-01 00:00:00	150000	466	0	10	5	0
1241	2024-09-01 00:00:00	4690000	303	0	5	134	0
1304	2024-09-01 00:00:00	0	522	0	19	0	0
1305	2024-08-01 00:00:00	48000	522	0	19	3	0
1319	2024-08-01 00:00:00	90000	322	0	10	3	0
1320	2024-09-01 00:00:00	640000	302	0	12	40	0
1256	2024-09-01 00:00:00	560000	300	0	12	35	0
1321	2024-09-01 00:00:00	0	486	0	25	0	0
1322	2024-09-01 00:00:00	0	485	0	25	0	0
1323	2024-10-01 00:00:00	0	675	0	25	0	0
1324	2024-10-01 00:00:00	0	674	0	12	0	0
1325	2024-10-01 00:00:00	0	674	0	13	0	0
1326	2024-09-01 00:00:00	160000	674	0	12	10	0
1327	2024-09-01 00:00:00	500000	675	0	25	10	0
1276	2024-09-01 00:00:00	400000	676	0	13	20	0
1331	2024-10-01 00:00:00	0	654	0	25	0	0
1334	2024-10-01 00:00:00	0	591	0	12	0	0
1335	2024-10-01 00:00:00	0	313	0	12	0	0
1337	2024-10-01 00:00:00	0	593	0	24	0	0
1338	2024-10-01 00:00:00	0	684	0	24	0	0
1339	2024-10-01 00:00:00	0	312	0	33	0	0
1341	2024-10-01 00:00:00	0	311	0	22	0	0
1342	2024-10-01 00:00:00	0	312	0	31	0	0
1343	2024-10-01 00:00:00	0	357	0	30	0	0
1344	2024-10-01 00:00:00	0	409	0	31	0	0
1346	2024-10-01 00:00:00	0	409	0	20	0	0
1350	2024-10-01 00:00:00	0	383	0	25	0	0
1354	2024-10-01 00:00:00	0	303	0	5	0	0
1355	2024-10-01 00:00:00	0	303	0	13	0	0
1356	2024-10-01 00:00:00	0	303	0	12	0	0
1357	2024-10-01 00:00:00	0	304	0	25	0	0
1358	2024-10-01 00:00:00	0	305	0	20	0	0
1361	2024-10-01 00:00:00	0	317	0	12	0	0
1362	2024-10-01 00:00:00	0	317	0	13	0	0
1363	2024-10-01 00:00:00	0	361	0	12	0	0
1345	2024-10-01 00:00:00	5328000	409	0	12	333	0
1352	2024-10-01 00:00:00	1800000	664	0	31	30	0
1336	2024-10-01 00:00:00	600000	473	0	13	30	0
1329	2024-10-01 00:00:00	2400000	311	0	25	48	0
1359	2024-10-01 00:00:00	6000000	361	0	25	120	0
1328	2024-10-01 00:00:00	1500000	308	0	25	30	0
1333	2024-10-01 00:00:00	480000	351	0	12	30	0
1351	2024-10-01 00:00:00	750000	453	0	25	15	0
1360	2024-10-01 00:00:00	5000000	317	1000000	25	100	0
1330	2024-10-01 00:00:00	1500000	590	0	25	30	0
1347	2024-10-01 00:00:00	4500000	409	0	25	90	0
1253	2024-09-01 00:00:00	3500006	667	3500000	27	100	0
1340	2024-10-01 00:00:00	960000	685	0	19	60	0
1332	2024-10-01 00:00:00	1104000	593	0	12	69	0
1272	2024-09-01 00:00:00	1040000	669	0	12	65	0
1364	2024-10-01 00:00:00	0	361	0	13	0	0
1373	2024-10-01 00:00:00	0	306	0	24	0	0
1365	2024-10-01 00:00:00	0	307	0	25	0	0
1367	2024-10-01 00:00:00	0	306	0	22	0	0
1370	2024-10-01 00:00:00	0	306	0	13	0	0
1378	2024-10-01 00:00:00	0	686	0	30	0	0
1385	2024-10-01 00:00:00	390000	690	0	20	30	0
1366	2024-10-01 00:00:00	0	306	0	29	0	0
1368	2024-10-01 00:00:00	0	306	0	5	0	0
1369	2024-10-01 00:00:00	0	306	0	12	0	0
1371	2024-10-01 00:00:00	0	306	0	19	0	0
1372	2024-10-01 00:00:00	0	306	0	18	0	0
1374	2024-10-01 00:00:00	4641000	461	0	28	221	0
1377	2024-10-01 00:00:00	0	687	0	4	0	0
1485	2024-10-01 00:00:00	960000	485	0	19	60	0
1380	2024-10-01 00:00:00	0	689	0	18	0	0
1384	2024-10-01 00:00:00	0	664	0	33	0	0
1388	2024-10-01 00:00:00	0	360	0	12	0	0
1390	2024-10-01 00:00:00	0	692	0	31	0	0
1391	2024-10-01 00:00:00	0	378	0	5	0	0
1392	2024-10-01 00:00:00	0	314	0	28	0	0
1393	2024-10-01 00:00:00	0	300	0	18	0	0
1394	2024-10-01 00:00:00	0	302	0	19	0	0
1395	2024-10-01 00:00:00	0	301	0	5	0	0
1396	2024-10-01 00:00:00	0	531	0	5	0	0
1397	2024-10-01 00:00:00	0	302	0	5	0	0
1398	2024-10-01 00:00:00	0	648	0	24	0	0
1399	2024-10-01 00:00:00	0	650	0	27	0	0
1400	2024-10-01 00:00:00	0	651	0	27	0	0
1401	2024-10-01 00:00:00	0	693	0	20	0	0
1402	2024-10-01 00:00:00	0	694	0	20	0	0
1403	2024-10-01 00:00:00	0	300	0	12	0	0
1404	2024-10-01 00:00:00	0	302	0	12	0	0
1405	2024-10-01 00:00:00	0	302	0	13	0	0
1406	2024-10-01 00:00:00	0	300	0	13	0	0
1407	2024-10-01 00:00:00	0	589	0	5	0	0
1408	2024-10-01 00:00:00	0	473	0	5	0	0
1409	2024-10-01 00:00:00	0	593	0	5	0	0
1410	2024-10-01 00:00:00	0	695	0	31	0	0
1353	2024-10-01 00:00:00	3000000	303	0	25	60	0
1411	2024-10-01 00:00:00	0	628	0	31	0	0
1412	2024-10-01 00:00:00	0	696	0	31	0	0
1413	2024-10-01 00:00:00	0	697	0	30	0	0
1414	2024-10-01 00:00:00	0	629	0	30	0	0
1416	2024-10-01 00:00:00	0	698	0	12	0	0
1417	2024-10-01 00:00:00	0	699	0	12	0	0
1415	2024-10-01 00:00:00	500000	626	0	25	10	0
1418	2024-10-01 00:00:00	0	699	0	13	0	0
1419	2024-10-01 00:00:00	0	698	0	13	0	0
1420	2024-10-01 00:00:00	0	603	0	33	0	0
1421	2024-10-01 00:00:00	0	700	0	20	0	0
1422	2024-10-01 00:00:00	0	701	0	21	0	0
1423	2024-10-01 00:00:00	0	417	0	31	0	0
1424	2024-10-01 00:00:00	0	702	0	30	0	0
1425	2024-10-01 00:00:00	0	415	0	25	0	0
1426	2024-10-01 00:00:00	0	703	0	25	0	0
1427	2024-10-01 00:00:00	0	419	0	11	0	0
1428	2024-10-01 00:00:00	0	419	0	5	0	0
1429	2024-10-01 00:00:00	0	415	0	13	0	0
1430	2024-10-01 00:00:00	0	594	0	27	0	0
1431	2024-10-01 00:00:00	0	417	0	33	0	0
1432	2024-10-01 00:00:00	0	415	0	28	0	0
1433	2024-10-01 00:00:00	0	417	0	20	0	0
1434	2024-10-01 00:00:00	0	413	0	31	0	0
1470	2024-10-01 00:00:00	0	451	0	27	0	0
1381	2024-10-01 00:00:00	1000000	378	0	13	50	0
1435	2024-10-01 00:00:00	0	704	0	30	0	0
1387	2024-10-01 00:00:00	3000000	691	0	25	60	0
1436	2024-10-01 00:00:00	0	705	0	30	0	0
1437	2024-10-01 00:00:00	0	607	0	25	0	0
1438	2024-10-01 00:00:00	0	384	0	25	0	0
1439	2024-10-01 00:00:00	0	706	0	4	0	0
1440	2024-10-01 00:00:00	0	411	0	5	0	0
1441	2024-10-01 00:00:00	0	413	0	5	0	0
1442	2024-10-01 00:00:00	0	706	0	11	0	0
1443	2024-10-01 00:00:00	0	704	0	12	0	0
1444	2024-10-01 00:00:00	0	707	0	12	0	0
1445	2024-10-01 00:00:00	0	706	0	12	0	0
1447	2024-10-01 00:00:00	0	518	0	13	0	0
1448	2024-10-01 00:00:00	0	706	0	13	0	0
1449	2024-10-01 00:00:00	0	407	0	13	0	0
1446	2024-10-01 00:00:00	700000	377	0	25	14	0
1450	2024-10-01 00:00:00	0	708	0	27	0	0
1451	2024-10-01 00:00:00	0	704	0	33	0	0
1452	2024-10-01 00:00:00	0	610	0	25	0	0
1453	2024-10-01 00:00:00	0	669	0	25	0	0
1454	2024-10-01 00:00:00	0	608	0	5	0	0
1455	2024-10-01 00:00:00	0	709	0	5	0	0
1456	2024-10-01 00:00:00	0	710	0	12	0	0
1457	2024-10-01 00:00:00	0	610	0	12	0	0
1458	2024-10-01 00:00:00	0	608	0	13	0	0
1459	2024-10-01 00:00:00	0	669	0	13	0	0
1460	2024-10-01 00:00:00	0	601	0	30	0	0
1461	2024-10-01 00:00:00	0	711	0	25	0	0
1462	2024-10-01 00:00:00	0	712	0	4	0	0
1463	2024-10-01 00:00:00	0	676	0	12	0	0
1464	2024-10-01 00:00:00	0	630	0	13	0	0
1465	2024-10-01 00:00:00	0	676	0	13	0	0
1466	2024-10-01 00:00:00	0	600	0	28	0	0
1467	2024-10-01 00:00:00	0	712	0	33	0	0
1468	2024-10-01 00:00:00	0	612	0	13	0	0
1375	2024-10-01 00:00:00	1500000	531	0	25	30	0
1376	2024-10-01 00:00:00	340000	649	0	24	20	0
1471	2024-10-01 00:00:00	0	450	0	27	0	0
1472	2024-10-01 00:00:00	0	440	0	4	0	0
1473	2024-10-01 00:00:00	0	441	0	4	0	0
1475	2024-10-01 00:00:00	0	673	0	25	0	0
1476	2024-10-01 00:00:00	0	491	0	4	0	0
1477	2024-10-01 00:00:00	0	474	0	5	0	0
1478	2024-10-01 00:00:00	0	485	0	12	0	0
1479	2024-10-01 00:00:00	0	486	0	12	0	0
1480	2024-10-01 00:00:00	0	474	0	12	0	0
1481	2024-10-01 00:00:00	0	485	0	13	0	0
1482	2024-10-01 00:00:00	0	486	0	13	0	0
1483	2024-10-01 00:00:00	0	474	0	13	0	0
1484	2024-10-01 00:00:00	0	514	0	28	0	0
1486	2024-10-01 00:00:00	0	486	0	19	0	0
1487	2024-10-01 00:00:00	0	474	0	19	0	0
1488	2024-10-01 00:00:00	0	490	0	24	0	0
1489	2024-10-01 00:00:00	0	597	0	31	0	0
1382	2024-10-01 00:00:00	800000	381	0	27	20	0
1474	2024-10-01 00:00:00	1500000	474	0	25	30	0
1469	2024-10-01 00:00:00	2000000	611	0	13	100	0
1383	2024-10-01 00:00:00	3000000	532	0	33	50	0
1386	2024-10-01 00:00:00	680000	690	0	24	40	0
1389	2024-10-01 00:00:00	2000000	691	0	13	100	0
1490	2024-10-01 00:00:00	0	467	0	30	0	0
1491	2024-10-01 00:00:00	0	466	0	25	0	0
1493	2024-10-01 00:00:00	0	467	0	25	0	0
1494	2024-10-01 00:00:00	0	472	0	25	0	0
1498	2024-10-01 00:00:00	0	469	0	13	0	0
1501	2024-10-01 00:00:00	0	468	0	22	0	0
1504	2024-10-01 00:00:00	0	477	0	30	0	0
1505	2024-10-01 00:00:00	0	481	0	30	0	0
1508	2024-10-01 00:00:00	0	481	0	5	0	0
1509	2024-10-01 00:00:00	0	480	0	12	0	0
1512	2024-10-01 00:00:00	0	476	0	13	0	0
1513	2024-10-01 00:00:00	0	477	0	13	0	0
1515	2024-10-01 00:00:00	0	480	0	19	0	0
1526	2024-10-01 00:00:00	0	456	0	18	0	0
1530	2024-10-01 00:00:00	0	713	0	25	0	0
1532	2024-10-01 00:00:00	0	715	0	21	0	0
1529	2024-10-01 00:00:00	340000	457	0	24	20	0
1492	2024-10-01 00:00:00	0	598	0	25	0	0
1496	2024-10-01 00:00:00	0	469	0	12	0	0
1499	2024-10-01 00:00:00	0	597	0	13	0	0
1502	2024-10-01 00:00:00	0	471	0	22	0	0
1495	2024-10-01 00:00:00	0	470	0	4	0	0
1500	2024-10-01 00:00:00	0	644	0	28	0	0
1503	2024-10-01 00:00:00	0	469	0	24	0	0
1507	2024-10-01 00:00:00	0	480	0	25	0	0
1510	2024-10-01 00:00:00	0	477	0	12	0	0
1514	2024-10-01 00:00:00	0	477	0	18	0	0
1517	2024-10-01 00:00:00	0	481	0	29	0	0
1520	2024-10-01 00:00:00	0	520	0	30	0	0
1521	2024-10-01 00:00:00	0	458	0	4	0	0
1527	2024-10-01 00:00:00	0	299	0	24	0	0
1497	2024-10-01 00:00:00	0	466	0	12	0	0
1506	2024-10-01 00:00:00	0	583	0	25	0	0
1511	2024-10-01 00:00:00	0	480	0	13	0	0
1516	2024-10-01 00:00:00	0	477	0	21	0	0
1518	2024-10-01 00:00:00	0	478	0	24	0	0
1519	2024-10-01 00:00:00	0	479	0	24	0	0
1522	2024-10-01 00:00:00	0	458	0	5	0	0
1523	2024-10-01 00:00:00	0	509	0	12	0	0
1528	2024-10-01 00:00:00	0	508	0	24	0	0
1531	2024-10-01 00:00:00	0	714	0	20	0	0
1533	2024-10-01 00:00:00	0	603	0	5	0	0
1534	2024-10-01 00:00:00	0	322	0	11	0	0
1379	2024-10-01 00:00:00	1500000	688	3000000	13	75	1500000
1535	2024-08-01 00:00:00	800000	658	0	27	20	0
1525	2024-10-01 00:00:00	160000	596	0	13	8	0
1524	2024-10-01 00:00:00	320000	342	0	12	20	0
1536	2024-10-01 00:00:00	250000	378	0	26	10	0
1537	2024-08-01 00:00:00	6600000	415	0	13	330	0
1538	2024-09-01 00:00:00	2500000	673	0	25	50	0
\.


--
-- Data for Name: bonus_payed_amounts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.bonus_payed_amounts (id, amount, description, date, bonus_id) FROM stdin;
10	50	\N	2024-08-13 00:00:00	654
11	6000000	\N	2024-08-30 00:00:00	807
12	6000000	\N	2024-08-30 00:00:00	920
13	1000000	\N	2024-09-03 00:00:00	576
14	1000000	\N	2024-09-03 00:00:00	576
15	90000	\N	2024-09-03 00:00:00	586
16	100000	\N	2024-09-03 00:00:00	578
17	250000	\N	2024-09-03 00:00:00	577
18	80000	\N	2024-09-03 00:00:00	583
19	80000	\N	2024-09-03 00:00:00	582
20	100000	\N	2024-09-03 00:00:00	585
21	60000	\N	2024-09-03 00:00:00	584
22	1000000	\N	2024-09-03 00:00:00	895
23	325000	\N	2024-09-03 00:00:00	585
24	272000	\N	2024-09-03 00:00:00	912
25	400000	\N	2024-09-03 00:00:00	913
26	0	\N	2024-09-03 00:00:00	1008
27	0	\N	2024-09-03 00:00:00	1008
28	0	test	2024-09-03 00:00:00	1008
29	0	test	2024-09-03 00:00:00	1008
30	0	test	2024-09-03 00:00:00	1008
31	0	test	2024-09-03 00:00:00	1008
32	0	test	2024-09-03 00:00:00	1008
33	250000	05,09,24 за 5уп Креакарда	2024-09-10 00:00:00	1077
34	100000	05,09,24 Эксипар 6 - 5 уп	2024-09-10 00:00:00	1076
35	16000	TEST BONUS	2024-09-10 00:00:00	581
36	20000	TEST2	2024-09-10 00:00:00	581
37	500000	апт Орзигуль фарм	2024-09-16 00:00:00	1165
40	160000	апт Жаннат шифо	2024-09-16 00:00:00	1243
41	200000	апт Фирдавс	2024-09-16 00:00:00	1232
42	160000	апт Фирдавс сент	2024-09-16 00:00:00	1231
43	500000	аптека Бинафша сент	2024-09-16 00:00:00	1234
44	368000	апт Статус дармон сент	2024-09-16 00:00:00	1172
48	240000	апт Статус	2024-09-16 00:00:00	1247
50	240000	,	2024-09-16 00:00:00	1248
51	368000	апт Статус дармон	2024-09-16 00:00:00	1171
52	1000000	апт	2024-09-16 00:00:00	1236
53	800000	апт	2024-09-16 00:00:00	1220
54	750000	апт Китоб виолет	2024-09-16 00:00:00	1230
55	550000	апт Статус дармон	2024-09-16 00:00:00	1218
56	250000	апт Статус дармон	2024-09-16 00:00:00	1220
57	600000	апт Хужаи жахон	2024-09-16 00:00:00	977
58	480000	апт Хужаи жахон	2024-09-16 00:00:00	978
59	0		2024-09-19 00:00:00	1237
60	0	T	2024-09-19 00:00:00	1237
61	0	T	2024-09-19 00:00:00	1237
62	0	Y	2024-09-19 00:00:00	1237
63	0	W	2024-09-19 00:00:00	1237
64	0	W	2024-09-19 00:00:00	1237
65	0	Q	2024-09-19 00:00:00	1237
66	3000000	04,10,24 на карту Мелиевой за 150 уп Эритропен 2	2024-10-08 22:22:53.205708	1379
67	3630000	20% от 18 150 000	2024-10-11 14:48:56.417109	1226
68	3500000	20% от 17 500 000	2024-10-11 14:48:56.417109	1253
69	1000000	Зайнаб динара	2024-10-11 14:48:56.417109	1360
\.


--
-- Data for Name: checking_balance_in_stock; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.checking_balance_in_stock (id, date, description, pharmacy_id) FROM stdin;
114	2024-08-12 00:00:00	description	101
115	2024-08-12 00:00:00	description	91
116	2024-08-12 00:00:00	description	113
117	2024-08-12 00:00:00	description	113
118	2024-08-12 00:00:00	description	92
119	2024-08-13 00:00:00	description	117
120	2024-08-13 00:00:00	description	21
121	2024-08-13 00:00:00	description	120
122	2024-08-13 00:00:00	description	91
123	2024-08-13 00:00:00	description	108
124	2024-08-13 00:00:00	description	121
125	2024-08-13 00:00:00	description	122
126	2024-08-13 00:00:00	description	19
127	2024-08-13 00:00:00	description	42
128	2024-08-13 00:00:00	description	103
129	2024-08-13 00:00:00	description	109
130	2024-08-13 00:00:00	description	95
131	2024-08-13 00:00:00	description	123
132	2024-08-14 00:00:00	description	123
133	2024-08-14 00:00:00	description	124
134	2024-08-14 00:00:00	description	124
135	2024-08-14 00:00:00	description	69
136	2024-08-14 00:00:00	description	135
137	2024-08-15 00:00:00	description	22
138	2024-08-15 00:00:00	description	14
139	2024-08-15 00:00:00	description	91
140	2024-08-15 00:00:00	description	142
141	2024-08-21 00:00:00	description	143
142	2024-08-21 00:00:00	description	30
143	2024-08-21 00:00:00	description	151
144	2024-08-22 00:00:00	description	14
145	2024-08-22 00:00:00	description	92
146	2024-08-22 00:00:00	description	62
147	2024-08-22 00:00:00	description	64
148	2024-08-22 00:00:00	description	144
149	2024-08-22 00:00:00	description	144
150	2024-08-22 00:00:00	description	109
151	2024-08-23 00:00:00	description	81
152	2024-08-23 00:00:00	description	81
153	2024-08-23 00:00:00	description	81
154	2024-08-23 00:00:00	description	145
155	2024-08-23 00:00:00	description	81
156	2024-08-23 00:00:00	description	81
157	2024-08-23 00:00:00	description	79
158	2024-08-23 00:00:00	description	81
159	2024-08-23 00:00:00	description	31
160	2024-08-23 00:00:00	description	124
161	2024-08-23 00:00:00	description	31
162	2024-08-24 00:00:00	description	26
163	2024-08-24 00:00:00	description	154
164	2024-08-26 00:00:00	description	153
165	2024-08-26 00:00:00	description	91
166	2024-08-26 00:00:00	description	91
167	2024-08-26 00:00:00	description	153
168	2024-08-26 00:00:00	description	91
169	2024-08-26 00:00:00	description	146
170	2024-08-26 00:00:00	description	42
171	2024-08-26 00:00:00	description	19
172	2024-08-26 00:00:00	description	81
173	2024-08-26 00:00:00	description	163
174	2024-08-26 00:00:00	description	71
175	2024-08-30 00:00:00	description	164
176	2024-08-30 00:00:00	description	120
177	2024-08-30 00:00:00	description	120
178	2024-08-30 00:00:00	description	26
179	2024-08-30 00:00:00	description	78
180	2024-08-30 00:00:00	description	78
181	2024-08-30 00:00:00	description	78
182	2024-09-03 00:00:00	description	32
183	2024-09-03 00:00:00	description	157
184	2024-09-05 00:00:00	description	21
185	2024-09-05 00:00:00	description	24
186	2024-09-05 00:00:00	description	21
187	2024-09-05 00:00:00	description	21
188	2024-09-05 00:00:00	description	91
189	2024-09-05 00:00:00	description	91
190	2024-09-09 00:00:00	description	21
191	2024-09-09 00:00:00	description	21
192	2024-09-09 00:00:00	description	50
193	2024-09-09 00:00:00	description	158
194	2024-09-09 00:00:00	description	32
195	2024-09-09 00:00:00	description	68
196	2024-09-10 00:00:00	description	159
197	2024-09-10 00:00:00	description	64
198	2024-09-10 00:00:00	description	62
199	2024-09-10 00:00:00	description	62
200	2024-09-10 00:00:00	description	35
201	2024-09-10 00:00:00	description	21
202	2024-09-10 00:00:00	description	35
203	2024-09-10 00:00:00	description	135
204	2024-09-10 00:00:00	description	121
205	2024-09-10 00:00:00	description	91
206	2024-09-11 00:00:00	description	21
207	2024-09-12 00:00:00	description	22
208	2024-09-12 00:00:00	description	110
209	2024-09-12 00:00:00	description	110
210	2024-09-12 00:00:00	description	205
211	2024-09-12 00:00:00	description	207
212	2024-09-12 00:00:00	description	206
213	2024-09-13 00:00:00	description	178
214	2024-09-13 00:00:00	description	122
215	2024-09-13 00:00:00	description	113
216	2024-09-13 00:00:00	description	169
217	2024-09-13 00:00:00	description	92
218	2024-09-13 00:00:00	description	93
219	2024-09-13 00:00:00	description	91
220	2024-09-13 00:00:00	description	91
221	2024-09-13 00:00:00	description	91
222	2024-09-16 00:00:00	description	213
223	2024-09-16 00:00:00	description	173
224	2024-09-16 00:00:00	description	173
225	2024-09-16 00:00:00	description	217
226	2024-09-16 00:00:00	description	216
227	2024-09-16 00:00:00	description	91
228	2024-09-16 00:00:00	description	91
229	2024-09-16 00:00:00	description	91
230	2024-09-16 00:00:00	description	91
231	2024-09-16 00:00:00	description	19
232	2024-09-16 00:00:00	description	103
233	2024-09-16 00:00:00	description	21
234	2024-09-16 00:00:00	description	219
235	2024-09-16 00:00:00	description	220
236	2024-09-16 00:00:00	description	22
237	2024-09-16 00:00:00	description	22
238	2024-09-16 00:00:00	description	22
239	2024-09-19 00:00:00	description	22
240	2024-09-20 00:00:00	description	222
241	2024-09-20 00:00:00	description	50
242	2024-09-20 00:00:00	description	153
243	2024-09-20 00:00:00	description	42
244	2024-09-20 00:00:00	description	221
245	2024-09-20 00:00:00	description	78
246	2024-09-20 00:00:00	description	78
247	2024-09-20 00:00:00	description	115
248	2024-09-20 00:00:00	description	205
249	2024-09-20 00:00:00	description	224
250	2024-09-20 00:00:00	description	91
251	2024-09-20 00:00:00	description	91
252	2024-09-20 00:00:00	description	172
253	2024-09-24 00:00:00	description	30
254	2024-09-24 00:00:00	description	225
255	2024-09-24 00:00:00	description	225
256	2024-09-24 00:00:00	description	225
257	2024-09-24 00:00:00	description	161
258	2024-09-24 00:00:00	description	164
259	2024-09-25 00:00:00	description	157
260	2024-09-25 00:00:00	description	92
261	2024-09-25 00:00:00	description	24
262	2024-09-26 00:00:00	description	216
263	2024-09-26 00:00:00	description	230
264	2024-09-26 00:00:00	description	215
265	2024-09-26 00:00:00	description	151
266	2024-09-26 00:00:00	description	151
267	2024-09-26 00:00:00	description	179
268	2024-09-26 00:00:00	description	91
269	2024-09-26 00:00:00	description	161
270	2024-09-26 00:00:00	description	161
271	2024-09-26 00:00:00	description	177
272	2024-09-26 00:00:00	description	177
273	2024-09-26 00:00:00	description	218
274	2024-09-26 00:00:00	description	123
275	2024-09-26 00:00:00	description	231
276	2024-09-26 00:00:00	description	79
277	2024-09-26 00:00:00	description	81
278	2024-10-03 23:09:31.301393	description	72
279	2024-10-03 23:09:31.301393	description	196
280	2024-10-03 23:09:31.301393	description	154
281	2024-10-03 23:09:31.301393	description	175
282	2024-10-08 22:22:53.242981	description	121
283	2024-10-08 22:22:53.242981	description	135
284	2024-10-08 22:22:53.242981	description	26
285	2024-10-08 22:22:53.242981	description	26
286	2024-10-08 22:22:53.242981	description	193
287	2024-10-08 22:22:53.242981	description	19
288	2024-10-08 22:22:53.242981	description	14
289	2024-10-08 22:22:53.242981	description	14
290	2024-10-08 22:22:53.242981	description	14
291	2024-10-08 22:22:53.242981	description	169
292	2024-10-08 22:22:53.242981	description	17
293	2024-10-08 22:22:53.242981	description	92
294	2024-10-08 22:22:53.242981	description	91
295	2024-10-08 22:22:53.242981	description	91
296	2024-10-08 22:22:53.242981	description	160
297	2024-10-08 22:22:53.242981	description	160
298	2024-10-08 22:22:53.242981	description	160
299	2024-10-08 22:22:53.242981	description	44
300	2024-10-08 22:22:53.242981	description	42
301	2024-10-08 22:22:53.242981	description	42
302	2024-10-08 22:22:53.242981	description	50
303	2024-10-08 22:22:53.242981	description	21
\.


--
-- Data for Name: checking_stock_products; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.checking_stock_products (id, previous, saled, remainder, stock_id, product_id, chack) FROM stdin;
121	50	50	0	114	5	t
122	18	18	0	115	25	t
126	5	5	0	116	30	t
124	5	5	0	116	19	t
128	5	5	0	116	12	t
125	5	5	0	116	24	t
123	5	5	0	116	18	t
127	5	5	0	116	25	t
130	3	3	0	117	10	t
129	3	3	0	116	10	t
131	20	20	0	118	25	t
132	21	21	0	119	25	t
133	100	100	0	120	24	t
134	200	200	0	121	12	t
135	47	47	0	122	12	t
136	10	10	0	123	13	t
137	20	20	0	123	27	t
138	500	500	0	124	28	t
140	5	5	0	125	13	t
139	20	20	0	125	25	t
142	120	120	0	126	25	t
144	10	10	0	126	7	t
145	5	5	0	126	10	t
143	20	20	0	126	13	t
141	30	30	0	126	23	t
146	30	30	0	127	25	t
148	35	35	0	128	12	t
147	20	20	0	128	25	t
149	50	50	0	129	24	t
150	50	50	0	130	12	t
151	50	50	0	130	13	t
154	50	50	0	131	25	t
153	50	50	0	131	19	t
152	20	20	0	131	28	t
155	20	20	0	133	25	t
157	34	34	0	135	5	t
158	10	10	0	136	25	t
159	20	20	0	137	12	t
160	20	20	0	137	13	t
161	5	5	0	138	15	f
162	5	5	0	138	14	f
163	32	32	0	139	12	t
164	20	20	0	140	28	t
165	20	20	0	140	19	t
167	150	150	0	140	25	t
168	30	30	0	140	13	t
156	0	0	0	134	25	t
170	30	30	0	141	13	t
169	30	30	0	141	25	t
172	10	10	0	142	24	t
171	10	10	0	142	12	t
174	50	50	0	143	25	t
178	20	20	0	143	15	t
177	10	10	0	143	14	t
176	10	10	0	143	27	t
175	20	20	0	143	12	t
173	5	5	0	143	33	t
180	17	17	0	144	12	t
179	20	20	0	144	24	t
181	20	20	0	144	13	t
182	20	20	0	145	25	t
184	30	0	30	147	33	t
183	330	0	330	146	13	t
186	10	10	0	149	24	t
187	30	30	0	150	12	t
188	20	20	0	150	13	t
189	15	10	5	151	31	t
190	112	64	48	152	25	t
191	50	0	50	153	13	t
192	50	50	0	154	25	t
197	30	30	0	159	11	t
196	48	48	0	158	25	t
198	30	30	0	160	25	t
199	20	20	0	160	19	t
195	100	100	0	157	25	t
200	10	10	0	162	25	t
201	20	20	0	163	28	t
202	30	30	0	163	25	t
203	10	10	0	163	13	t
204	10	10	0	163	27	t
205	100	100	0	167	12	t
206	100	100	0	167	13	t
208	20	10	10	168	25	t
207	35	18	17	168	12	t
209	20	20	0	169	24	t
210	20	20	0	170	13	t
185	10	0	10	148	24	t
194	50	50	0	156	13	t
211	120	120	0	171	25	t
213	30	30	0	173	25	t
214	109	109	0	174	13	t
166	20	20	0	140	24	t
212	60	60	0	172	25	t
216	30	30	0	175	13	t
215	30	30	0	175	12	t
217	200	200	0	176	24	t
218	200	200	0	176	20	t
220	300	300	0	177	12	t
219	300	300	0	177	25	t
221	60	20	40	178	25	t
222	20	20	0	179	25	f
223	0	0	0	180	25	f
225	40	20	20	182	24	t
226	5	5	0	183	25	t
227	5	5	0	183	13	t
228	5	5	0	183	27	t
224	0	0	0	181	25	t
229	20	20	0	184	25	f
230	10	10	0	185	25	t
193	5	5	0	155	31	t
231	107	50	57	186	24	t
232	57	57	0	187	24	t
233	66	23	43	188	12	t
235	43	23	20	189	12	t
236	10	0	10	189	25	t
234	10	0	10	188	25	t
237	20	10	10	190	27	t
238	10	0	10	191	27	t
239	50	50	0	192	25	t
240	20	20	0	193	24	f
242	30	30	0	195	5	f
244	30	30	0	197	33	f
246	31	31	0	199	33	f
248	100	100	0	201	24	t
249	20	20	0	202	27	t
250	10	10	0	203	25	t
251	400	400	0	204	28	t
252	20	0	20	205	12	f
247	20	20	0	201	19	t
241	20	20	0	194	24	t
254	10	0	10	206	27	t
245	330	330	0	198	13	t
243	30	30	0	196	25	t
256	100	100	0	206	24	t
253	32	22	10	205	25	t
255	20	20	0	206	19	t
257	50	50	0	207	24	t
258	87	22	65	208	31	t
259	670	320	350	209	25	t
261	140	140	0	210	27	t
262	20	20	0	211	27	t
263	30	30	0	212	27	t
264	10	10	0	213	30	t
265	10	10	0	213	13	t
266	15	15	0	214	25	t
267	10	10	0	215	30	t
268	10	10	0	215	12	t
269	10	10	0	216	25	t
270	40	20	20	217	25	t
271	20	20	0	218	11	t
273	10	10	0	219	25	t
274	12	1	11	220	25	t
276	11	11	0	221	25	t
277	134	134	0	222	5	t
278	10	10	0	224	25	t
279	75	75	0	225	27	t
280	10	10	0	226	19	t
281	10	5	5	227	25	t
283	5	5	0	228	25	t
286	50	15	35	229	12	t
287	35	15	20	230	12	t
288	120	120	0	231	25	t
289	40	40	0	232	12	t
291	60	60	0	233	12	t
292	30	30	0	234	18	t
293	3	3	0	235	20	t
295	10	0	10	236	19	f
296	96	0	96	236	38	f
294	10	10	0	236	18	t
297	0	0	0	237	18	f
298	10	10	0	237	19	t
300	0	0	0	238	18	f
301	0	0	0	238	19	f
302	96	96	0	238	38	t
299	96	0	96	237	38	t
303	15	15	0	239	12	t
321	10	10	0	255	13	t
304	5	5	0	240	4	t
305	5	5	0	240	11	t
306	9	9	0	240	25	t
307	120	120	0	241	25	t
308	45	45	0	242	13	t
309	20	20	0	243	25	t
311	5	5	0	244	31	t
310	10	10	0	244	30	t
312	20	10	10	247	25	t
313	110	110	0	248	27	t
314	100	100	0	249	21	t
315	59	20	39	250	12	t
316	39	19	20	251	12	t
317	10	10	0	252	24	t
260	65	0	65	209	31	t
284	50	0	50	228	12	t
318	20	20	0	253	12	t
319	20	20	0	253	24	t
320	10	10	0	254	14	f
325	20	20	0	256	30	f
326	15	15	0	257	12	t
327	15	15	0	257	13	t
324	10	10	0	256	12	t
323	10	10	0	256	13	t
328	20	20	0	257	27	t
329	56	56	0	258	13	t
330	50	50	0	258	12	t
331	20	20	0	258	25	t
335	40	20	20	260	25	t
336	10	10	0	261	25	t
333	5	5	0	259	27	t
337	10	10	0	262	19	t
338	20	20	0	263	11	f
339	16	16	0	264	12	t
342	50	50	0	265	12	t
341	20	20	0	265	24	t
345	60	60	0	266	25	t
346	10	10	0	267	25	t
347	20	20	0	268	12	t
344	0	0	0	266	12	t
332	5	5	0	259	13	t
290	10	0	10	233	27	t
340	60	0	60	265	25	t
349	50	35	15	269	13	t
348	50	35	15	269	12	t
351	15	15	0	270	13	f
352	100	100	0	271	12	t
322	2	2	0	256	31	t
353	20	20	0	271	37	t
354	20	20	0	273	33	t
350	15	15	0	270	12	t
282	50	0	50	227	12	t
275	20	0	20	221	12	t
334	15	5	10	259	25	t
355	100	100	0	274	25	t
285	0	0	0	229	25	t
356	50	50	0	275	25	t
357	100	50	50	276	25	t
358	50	50	0	277	12	t
359	50	50	0	277	13	t
360	120	120	0	277	25	t
361	50	50	0	278	25	t
363	10	10	0	279	25	t
362	20	20	0	279	13	t
365	10	10	0	280	12	t
364	20	20	0	280	13	t
366	9	9	0	281	25	t
367	5	5	0	281	12	t
368	400	400	0	282	28	t
369	10	10	0	283	25	t
370	20	20	0	284	25	t
371	20	20	0	285	24	t
372	150	150	0	286	13	t
373	120	120	0	287	25	t
374	10	10	0	288	19	t
375	30	30	0	289	12	t
272	20	0	20	219	12	t
376	30	30	0	290	13	t
377	10	10	0	291	25	t
378	20	20	0	292	25	t
379	40	20	20	293	25	t
380	10	10	0	294	25	t
343	0	0	0	266	24	t
386	0	0	0	297	27	f
381	0	0	0	295	25	f
382	30	30	0	295	12	t
383	10	0	10	296	13	f
384	10	0	10	296	24	f
385	10	10	0	296	27	t
387	10	0	10	297	13	f
388	10	10	0	297	24	f
389	0	0	0	298	27	f
390	0	0	0	298	24	f
391	10	10	0	298	13	t
392	14	14	0	299	25	t
394	15	0	15	300	25	f
393	30	30	0	300	13	t
395	0	0	0	301	13	f
396	15	15	0	301	25	t
397	120	120	0	302	25	t
398	10	10	0	303	27	t
\.


--
-- Data for Name: current_balance_in_stock; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.current_balance_in_stock (id, amount, product_id, pharmacy_id) FROM stdin;
101	0	5	101
103	0	18	113
104	0	19	113
105	0	24	113
107	0	25	113
109	0	10	113
119	0	13	122
120	0	23	19
122	0	13	19
123	0	7	19
124	0	10	19
171	0	33	151
140	0	25	103
125	0	24	109
135	0	12	95
136	0	13	95
127	0	28	123
130	0	5	69
146	0	13	22
99	0	15	14
100	0	14	14
151	0	28	142
152	0	19	142
153	0	24	142
154	0	25	142
155	0	13	142
157	0	25	143
158	0	13	143
174	0	27	151
175	0	14	151
176	0	15	151
168	0	24	14
166	0	19	92
167	0	22	92
179	20	5	108
180	20	25	149
149	0	12	109
150	0	13	109
159	0	25	145
129	0	31	81
182	30	8	31
183	0	11	31
186	0	27	154
191	100	25	36
189	0	12	153
162	0	24	146
193	20	13	162
195	0	25	163
197	100	25	80
205	20	25	158
200	0	24	120
201	0	20	120
206	0	25	120
115	0	12	120
142	0	25	78
207	0	25	21
208	0	25	24
187	50	25	154
215	10	27	176
237	0	19	216
139	0	25	42
216	5	33	176
277	10	25	17
112	10	27	108
256	0	21	224
204	0	24	158
160	0	24	32
131	0	5	68
258	0	13	225
161	0	33	64
165	0	13	62
199	0	33	62
147	0	24	22
198	150	12	80
220	0	27	35
217	350	25	110
144	0	25	135
213	0	24	172
117	0	28	121
232	0	27	207
181	10	19	124
233	0	27	206
252	0	12	81
219	0	19	21
114	0	24	21
141	0	12	103
238	0	12	21
225	0	30	178
226	0	13	178
118	0	25	122
113	60	25	117
108	0	12	113
224	0	25	169
263	0	11	230
234	0	11	93
239	0	18	219
240	0	20	220
235	0	5	213
221	0	25	173
274	0	25	26
236	0	27	217
210	0	13	157
241	0	18	22
242	0	19	22
243	0	38	22
190	0	13	153
145	0	12	22
244	50	12	155
245	0	4	222
246	0	11	222
247	0	25	222
156	0	12	30
250	0	30	221
251	0	31	221
230	0	25	72
222	0	13	196
253	10	25	115
248	0	25	175
231	0	27	205
218	130	31	110
163	0	24	30
192	30	25	159
257	0	14	225
261	0	31	225
260	0	12	225
259	0	30	225
185	100	28	154
211	0	27	157
229	0	27	161
203	0	13	164
202	0	12	164
254	0	25	164
227	0	12	161
228	0	13	161
209	10	25	157
265	0	12	215
172	0	25	151
128	50	19	123
266	0	24	151
173	0	12	151
214	0	25	50
196	150	13	80
255	100	25	192
267	100	12	121
268	20	31	121
269	0	12	177
270	0	37	177
271	0	33	218
132	0	25	123
272	0	25	231
148	39	12	91
143	0	13	81
133	0	25	81
223	0	25	196
188	0	13	154
262	0	12	154
249	0	12	175
194	100	13	71
106	15	30	113
273	0	24	26
275	0	13	193
121	0	25	19
170	0	13	14
276	0	19	14
169	0	12	14
212	20	27	21
178	0	25	91
184	0	13	42
110	38	25	92
134	30	25	124
164	20	24	144
126	250	25	79
264	10	25	179
279	0	27	160
280	0	24	160
278	0	13	160
281	0	25	44
282	20	25	14
283	100	25	48
284	100	13	48
285	10	27	234
111	10	13	108
286	50	19	203
287	250	25	67
288	8	13	32
289	20	12	144
290	10	31	41
291	40	13	233
292	10	26	233
293	20	31	233
294	300	25	237
295	50	33	233
296	30	20	233
297	30	24	233
298	130	12	239
299	100	13	240
300	19	40	238
301	5	31	241
302	100	25	52
\.


--
-- Data for Name: current_factory_warehouse; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.current_factory_warehouse (id, amount, factory_id, product_id) FROM stdin;
43	76	3	35
35	450	3	29
33	80	1	15
32	1354	1	30
23	5823	1	12
21	3662	1	25
27	6394	1	13
49	19	1	39
50	0	1	40
24	70	1	31
37	795	3	19
30	69	1	7
29	273	1	5
46	956	3	21
25	0	1	14
36	684	3	18
44	219	1	8
41	369	3	22
47	0	3	38
31	309	1	27
26	317	1	10
39	340	3	28
42	191	3	23
28	109	1	11
22	935	1	26
45	1016	1	4
48	0	1	37
38	990	3	33
40	49	3	20
34	8510	3	24
\.


--
-- Data for Name: current_wholesale_warehouse; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.current_wholesale_warehouse (id, amount, price, wholesale_id, product_id) FROM stdin;
16	0	80640	5	24
17	0	125552	5	26
20	160	309120	9	33
24	141	87584	9	29
27	17	159712	9	8
31	232	97888	9	15
32	97	195776	9	27
39	4	159712	3	8
40	52	133952	3	10
41	26	48944	8	18
44	85	66976	8	19
48	60	133952	8	10
51	120	97888	8	15
56	44	180320	2	14
57	30	195776	2	27
58	30	178259	2	11
62	33	48944	7	18
63	365	66976	7	19
64	2	61824	7	20
65	84	74189	7	24
70	123	180320	7	14
72	60	133952	1	10
75	25	48944	1	18
76	52	87584	1	28
77	103	66976	1	19
87	136	463680	9	31
88	96	77280	9	30
92	10	77280	4	7
94	93	133952	4	10
96	35	178259	4	11
81	0	309120	11	33
84	0	195776	11	27
85	0	180320	11	14
86	0	97888	11	15
98	100	133952	13	10
100	149	157239	13	5
97	44	159712	13	8
28	89	133952	9	10
33	59	157239	9	5
34	90	178259	9	11
125	10	71089	10	4
126	12	178259	10	11
80	108	159712	10	25
71	224	193760	7	11
130	120	72128	9	4
67	98	145600	7	10
68	940	80640	7	12
69	986	95200	7	13
26	721	159712	9	25
104	128	60984	14	7
102	129	58545	14	12
103	121	69115	14	13
47	690	154747	8	25
99	69	87584	13	13
50	495	84859	8	13
93	101	152457	4	8
95	19	150097	4	5
105	30	83603	4	13
106	20	70820	4	12
107	50	121121	11	8
108	10	101585	11	10
19	236	48938	9	18
22	374	66968	9	19
109	176	35103	4	18
90	152	36581	4	23
91	417	53210	4	24
89	228	48038	4	19
110	88	57956	13	19
111	28	35256	2	18
18	132	36740	2	23
115	75	126674	1	8
15	10	173600	5	25
66	302	159574	7	8
53	110	125441	2	10
79	124	74189	10	24
114	97	66976	10	19
131	20	74189	11	24
82	60	159712	11	25
118	5	159642	2	8
119	3	77246	2	7
54	36	74157	2	12
55	26	87546	2	13
120	25	66475	15	4
121	20	81901	15	13
116	51	124713	1	5
117	51	141385	1	11
73	76	58842	1	12
74	99	69466	1	13
42	214	309120	8	33
43	230	87584	8	28
45	89	87584	8	22
46	296	74189	8	24
49	469	74189	8	12
122	100	72128	8	4
123	0	53200	16	18
83	50	74189	11	12
35	92	66976	3	19
36	209	61824	3	20
37	91	87584	3	22
38	8	51005	3	23
112	71	48944	10	18
78	15	309120	10	33
124	2	61824	10	20
113	67	51005	10	23
127	55	121587	10	26
128	76	74189	10	12
129	88	87584	10	13
101	99	178259	13	11
25	405	74189	9	24
29	1592	74189	9	12
23	455	87584	9	22
30	1143	87584	9	13
21	452	87584	9	28
52	990	149563	2	25
\.


--
-- Data for Name: debt; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.debt (id, description, amount, payed, date, pharmacy_id) FROM stdin;
\.


--
-- Data for Name: distance; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.distance (id, distance) FROM stdin;
1	500
\.


--
-- Data for Name: doctor; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.doctor (id, full_name, contact1, contact2, email, latitude, longitude, deleted, med_rep_id, region_manager_id, ffm_id, product_manager_id, deputy_director_id, director_id, region_id, speciality_id, category_id, medical_organization_id, birth_date) FROM stdin;
299	Сиддиков Файзулла	+998-91-101-23-11			\N	\N	f	46	42	31	29	73	1	\N	4	1	41	\N
300	Норматив Бахром	+998-97-590-01-73			\N	\N	f	54	36	35	30	73	1	\N	4	1	30	\N
301	Турдиева Лола	+998-97-597-70-16			\N	\N	f	54	36	35	30	73	1	\N	1	1	95	\N
302	Хатамкулов Акмал	+998-91-203-88-85			\N	\N	f	54	36	35	30	73	1	\N	1	2	28	\N
303	Турсунов Баходир	+998-97-426-80-50			\N	\N	f	53	36	35	30	73	1	\N	2	1	73	\N
304	Маматжонов Иброхим	+998-97-250-83-10			\N	\N	f	53	36	35	30	73	1	\N	1	1	73	\N
305	Сатторов Мухаммадсоли	+998-94-447-27-04			\N	\N	f	53	36	35	30	73	1	\N	1	1	97	\N
307	Наманган Кардиология	+998-91-362-62-42			\N	\N	f	51	36	35	30	73	1	\N	18	2	27	\N
308	Назаров Сарвар	+998-97-223-67-73			\N	\N	f	60	59	35	30	73	1	\N	1	2	84	\N
309	Инатов Исмат	+998-91-210-76-54			\N	\N	f	60	59	35	30	73	1	\N	3	2	107	\N
311	Бердиева Шаходат	+998-91-213-88-69			\N	\N	f	60	59	35	30	73	1	\N	1	2	26	\N
312	Эсанов Зафар	+998-91-641-64-00			\N	\N	f	60	59	35	30	73	1	\N	10	2	26	\N
313	Мансуров Кодир	+998-91-957-56-76			\N	\N	f	60	59	35	30	73	1	\N	1	2	117	\N
310	Хидиров Абдурасул	+998-91-321-49-33			\N	\N	f	60	59	35	30	73	1	\N	3	2	107	\N
314	Рамазанов Бахтиёр	+998-93-424-00-03			\N	\N	f	62	59	35	30	73	1	\N	4	2	79	\N
317	Эркебай	+998-93-772-34-03			\N	\N	f	85	55	35	30	73	1	\N	2	1	75	\N
318	Рая	+998-97-220-48-00			\N	\N	f	85	55	35	30	73	1	\N	11	2	78	\N
322	Бейметов Даврон	+998-91-421-08-70			\N	\N	f	90	37	31	29	73	1	\N	1	1	57	\N
339	Азиза Бахтияровна	+998-93-586-48-40			\N	\N	f	82	65	64	63	73	1	\N	6	1	112	\N
340	Хакимжанова Сурайе	+998-93-512-16-84			\N	\N	f	82	65	64	63	73	1	\N	12	1	125	\N
342	Гульбахор Пиримкуловна	+998-11-111-11-11			\N	\N	f	46	42	31	29	73	1	\N	6	1	46	\N
343	Саера Халдаровна	+998-91-622-04-05			\N	\N	f	46	42	31	29	73	1	\N	6	1	156	\N
344	Мафтуна Хамидуллаевна	+998-90-953-85-65			\N	\N	f	66	65	64	63	73	1	\N	1	3	29	\N
351	Азизов Уткир	Азизов Уткир	914673505		\N	\N	f	60	59	35	30	73	1	\N	3	2	107	\N
357	Бокиев Намоз	+998914663538			\N	\N	f	60	59	35	30	73	1	\N	1	2	165	\N
360	Рахат	913901601			\N	\N	f	85	55	35	30	73	1	\N	5	2	76	\N
80	Умарова Шахло	900107511			\N	\N	f	50	47	31	29	73	1	\N	2	1	55	\N
361	Салиев Махмут	913889733			\N	\N	f	85	55	35	30	73	1	\N	1	2	167	\N
362	Камилла	907230003			\N	\N	f	85	55	35	30	73	1	\N	5	2	76	\N
368	Хаким Санаевич	+998-71-281-23-87			\N	\N	f	82	65	64	63	73	1	\N	20	1	106	\N
369	Рустама Атхам	+998-93-333-33-33			\N	\N	f	80	7	4	3	73	1	\N	1	2	22	\N
372	Юлдошев Набижон Примович	+998-90-973-03-11			\N	\N	f	82	65	64	63	73	1	\N	1	1	119	\N
373	Максума Умаровна	+998-93-516-32-02			\N	\N	f	66	65	64	63	73	1	\N	1	1	29	\N
374	Гусаков Бахтиер Султанович	+998-93-333-33-33			\N	\N	f	66	65	64	63	73	1	\N	4	1	169	\N
375	Дилфуза Бахтияровна	+998-94-444-44-44			\N	\N	f	66	65	64	63	73	1	\N	6	1	170	\N
376	Чернов денис Андреевич	+998-91-185-35-99			\N	\N	f	66	65	64	63	73	1	\N	1	1	4	\N
377	Бобур Хамидов	+998-90-425-96-05			\N	\N	f	62	59	35	30	73	1	\N	1	1	105	\N
378	Акром Рустамов	+998-90-733-52-85			\N	\N	f	62	59	35	30	73	1	\N	1	1	40	\N
379	Рузиев Элдор	+998-97-315-05-06			\N	\N	f	62	59	35	30	73	1	\N	4	2	109	\N
380	Ачилов  Шохсувор	+998-99-503-22-33			\N	\N	f	62	59	35	30	73	1	\N	11	1	37	\N
306	Нодир ака Наманган ШТБ	+998-91-362-62-42	+998-91-362-62-42	sjhjh@mail.ru	\N	\N	f	51	36	35	30	73	1	\N	18	2	27	1980-01-01 00:00:00
381	Икром Хайитов	+998-91-945-44-32			\N	\N	f	62	59	35	30	73	1	\N	2	1	171	\N
382	Шоира Муродова	+998-97-585-19-60			\N	\N	f	62	59	35	30	73	1	\N	2	2	36	\N
383	Абдураҳмон Дустияров	+998-99-016-01-68			\N	\N	f	62	59	35	30	73	1	\N	2	2	37	\N
384	Махмуд	+998-90-713-12-66			\N	\N	f	40	37	31	29	73	1	\N	1	1	51	\N
388	Хидиров Акром  Бахтиерович	+998-97-333-02-11			\N	\N	f	82	65	64	63	73	1	\N	1	1	47	\N
390	Ганиев Бахтиер Абдунабиевич	+998-99-851-58-51			\N	\N	f	82	65	64	63	73	1	\N	1	1	120	\N
391	Холматов Рустам	+998-93-397-61-75			\N	\N	f	82	65	64	63	73	1	\N	7	1	128	\N
415	Кучкаров Отабек	+998-93-469-16-22			\N	\N	f	39	37	31	29	73	1	\N	4	1	53	\N
416	Яхиеев Хаким	+998-98-364-14-24			\N	\N	f	82	65	64	63	73	1	\N	9	1	163	\N
389	Мусаев Султанбек Алмаматович	+998-99-851-58-51	 	 	\N	\N	f	82	65	64	63	73	1	\N	10	1	120	1900-01-01 00:00:00
405	Аскаров Элер	+998-78-777-03-03			\N	\N	f	82	65	64	63	73	1	\N	4	2	45	\N
407	Бекчанов Мадиер	+998-97-451-69-69			\N	\N	f	40	37	31	29	73	1	\N	4	1	53	\N
408	Ярашев Рустам	+998-93-754-00-03			\N	\N	f	40	37	31	29	73	1	\N	4	1	53	\N
409	Жураев Чари	 942003824			\N	\N	f	86	59	35	30	73	1	\N	1	2	15	\N
410	Даврон	+998-91-421-08-70			\N	\N	f	40	37	31	29	73	1	\N	3	1	53	\N
411	Анвар	+998-97-987-77-17			\N	\N	f	40	37	31	29	73	1	\N	3	1	53	\N
412	Дильшод	+998-90-184-93-93			\N	\N	f	40	37	31	29	73	1	\N	3	1	53	\N
413	Шерзод	+998-93-741-20-80			\N	\N	f	40	37	31	29	73	1	\N	3	1	53	\N
414	Мухашова Дилноза	+998-99-856-87-89			\N	\N	f	82	65	64	63	73	1	\N	4	2	45	\N
417	Рахимов Жушкин	+998-98-458-47-67			\N	\N	f	39	37	31	29	73	1	\N	3	1	53	\N
418	Исмоилов Вохид	+998-97-220-11-03			\N	\N	f	39	37	31	29	73	1	\N	1	1	52	\N
420	Султанов Абдурасул	+998-97-401-99-33			\N	\N	f	82	65	64	63	73	1	\N	1	1	163	\N
422	Рахманов Мурод	+998-97-355-61-01			\N	\N	f	39	37	31	29	73	1	\N	3	1	54	\N
367	Низомидинова Гулчехра	+998-90-934-98-37	 	 	\N	\N	f	82	65	64	63	73	1	\N	18	1	106	1902-02-02 00:00:00
423	Собиров Дильшод	+998-91-452-12-31			\N	\N	f	39	37	31	29	73	1	\N	11	1	53	\N
424	Хусаинов Адхам	+998-99-541-65-34			\N	\N	f	39	37	31	29	73	1	\N	8	1	53	\N
425	Атажанова Наргиза	+998-93-922-05-01			\N	\N	f	39	37	31	29	73	1	\N	1	1	53	\N
426	Мансуров Абдурахман	+998-97-455-50-22			\N	\N	f	82	65	64	63	73	1	\N	1	1	48	\N
440	Эргашев Комил	+998-91-412-40-85			\N	\N	f	43	42	31	29	73	1	\N	3	1	66	\N
441	Хамраев Эльер	+998-91-442-35-50			\N	\N	f	43	42	31	29	73	1	\N	3	1	66	\N
442	Азизов Бахтиёр	976770520			\N	\N	f	51	36	35	30	73	1	\N	4	1	33	\N
443	Камилов Фаррух	+998-91-441-39-94			\N	\N	f	43	42	31	29	73	1	\N	3	1	66	\N
444	Бабахонов Одилжон 	913626233			\N	\N	f	51	36	35	30	73	1	\N	3	1	102	\N
445	Турдиев Латиф	+998-91-409-56-65			\N	\N	f	43	42	31	29	73	1	\N	3	1	66	\N
446	Бутабоев Тохир	950168585			\N	\N	f	51	36	35	30	73	1	\N	1	2	70	\N
447	Исмаилов Олим	+998-91-454-59-46			\N	\N	f	43	42	31	29	73	1	\N	1	1	68	\N
448	Мехмонов Алишер	+998-91-414-35-07			\N	\N	f	43	42	31	29	73	1	\N	1	1	113	\N
449	Исматуллаев Шерзод				\N	\N	f	51	36	35	30	73	1	\N	4	1	101	\N
450	Хаттабов Музаффар	+998-91-646-07-77			\N	\N	f	43	42	31	29	73	1	\N	11	1	114	\N
451	Ашуров Азиз	+998-91-646-07-77			\N	\N	f	43	42	31	29	73	1	\N	11	1	114	\N
452	Зариф ака	932727727			\N	\N	f	51	36	35	30	73	1	\N	5	1	103	\N
453	Буриев Нурбек	+998-99-666-84-08			\N	\N	f	62	59	35	30	73	1	\N	2	1	171	\N
454	Алишер Унгбоев	+998-93-930-33-00			\N	\N	f	62	59	35	30	73	1	\N	15	1	44	\N
455	Юлчираев Ахрор	+998-97-340-03-01			\N	\N	f	46	42	31	29	73	1	\N	4	1	42	\N
419	Рузимов Кахрамон	+998-93-468-00-76	00000	kmshh@mail.ru	\N	\N	f	39	37	31	29	73	1	\N	3	1	53	1979-05-11 00:00:00
456	Бегматов Шавкат	+998-97-277-00-24			\N	\N	f	46	42	31	29	73	1	\N	4	1	42	\N
457	Тураев Бахтиер	+998-97-245-70-89			\N	\N	f	46	42	31	29	73	1	\N	4	1	50	\N
458	Хусанбаева Гавхар	+998-97-340-27-07			\N	\N	f	46	42	31	29	73	1	\N	3	1	49	\N
459	Умарбеков Бекзод	+998-91-573-49-94			\N	\N	f	46	42	31	29	73	1	\N	1	1	46	\N
461	Ким Марина				\N	\N	f	104	55	35	30	73	1	\N	18	2	21	\N
466	Азамат Бахадирович	+998-99-883-50-76			\N	\N	f	49	47	31	29	73	1	\N	2	1	60	\N
467	Нурбек Джураев	+998-99-600-63-14			\N	\N	f	49	47	31	29	73	1	\N	2	1	60	\N
468	Нозигуль Кудратовна	+998-93-386-05-12			\N	\N	f	49	47	31	29	73	1	\N	1	1	60	\N
469	Озода Эргашевна	+998-98-812-05-85			\N	\N	f	49	47	31	29	73	1	\N	3	1	65	\N
470	Тамара Артиковна	+998-97-445-69-61			\N	\N	f	49	47	31	29	73	1	\N	9	3	67	\N
471	Насиба Унарбаевна	+998-94-665-74-61			\N	\N	f	49	47	31	29	73	1	\N	1	1	67	\N
472	Ботирали Эгамбердиевич	+998-90-994-19-74			\N	\N	f	49	47	31	29	73	1	\N	11	1	74	\N
473	Рахмонов Шербек 	908876655			\N	\N	f	60	59	35	30	73	1	\N	1	2	173	\N
474	Шкурова Шодия	+998-99-884-30-62			\N	\N	f	50	47	31	29	73	1	\N	1	1	55	\N
476	Худойбергенов Муроджон	+998-99-400-22-41			\N	\N	f	100	47	31	29	73	1	\N	9	1	175	\N
477	Орзимурод	+998-99-275-04-60			\N	\N	f	100	47	31	29	73	1	\N	1	1	175	\N
478	Дильмурод	+998-99-520-42-49			\N	\N	f	100	47	31	29	73	1	\N	14	1	175	\N
479	Хабибуллаев Нодир	+998-94-701-03-03			\N	\N	f	100	47	31	29	73	1	\N	14	1	176	\N
480	Камолиддин	+998-99-667-31-92			\N	\N	f	100	47	31	29	73	1	\N	8	1	176	\N
481	Суханова Раьно Рашидовна	+998-97-739-76-71			\N	\N	f	100	47	31	29	73	1	\N	3	1	177	\N
482	Рахматов Мирзокул	+998-94-619-14-16			\N	\N	f	50	47	31	29	73	1	\N	2	2	55	\N
483	Шохюсупов Оловиддин	+998-99-926-29-91			\N	\N	f	50	47	31	29	73	1	\N	2	2	55	\N
484	Курбонкулова Шоира	+998-90-350-94-48			\N	\N	f	50	47	31	29	73	1	\N	6	2	55	\N
485	Содикова Дилрабо	+998-93-376-19-74			\N	\N	f	50	47	31	29	73	1	\N	1	1	55	\N
486	Дадажонов Собиржон	+998-99-862-22-85			\N	\N	f	50	47	31	29	73	1	\N	3	1	55	\N
487	Эргашев Абдугаффор	+998-93-958-56-62			\N	\N	f	50	47	31	29	73	1	\N	14	2	55	\N
489	Атахонов Азизбек	+998-94-635-57-90			\N	\N	f	50	47	31	29	73	1	\N	14	2	55	\N
490	Оринбоев Бахром	+998-90-920-31-65			\N	\N	f	50	47	31	29	73	1	\N	4	2	55	\N
491	Раджапов Азизбек	+998-99-489-06-68			\N	\N	f	50	47	31	29	73	1	\N	9	2	55	\N
492	Хасанова. Фотима	+998-88-878-22-91			\N	\N	f	50	47	31	29	73	1	\N	6	1	55	\N
488	Eshmat Tesha	77777777777777	88888888888888	aaa@gmail.com	\N	\N	f	40	37	31	29	73	1	\N	7	2	17	2012-02-08 00:00:00
370	Абдуллаева Махсудa	88888	00000	fair.boy@email.ru	\N	\N	f	80	7	4	3	73	1	\N	2	3	29	2024-08-14 00:00:00
503	Аюпова Гулбахор	+998-97-275-95-49			\N	\N	f	46	42	31	29	73	1	\N	15	2	41	\N
509	Сайера Холдоровна	+998-91-662-04-05			\N	\N	f	46	42	31	29	73	1	\N	6	1	42	\N
513	Саратов Дилшод Раупович	+998-98-126-16-74			\N	\N	f	82	65	64	63	73	1	\N	4	1	183	\N
514	Шодмонкулова Дилором	+998-97-232-67-64			\N	\N	f	50	47	31	29	73	1	\N	8	1	174	\N
517	Шерзод	+998-91-879-99-76			\N	\N	f	40	37	31	29	73	1	\N	1	1	57	\N
518	Жасур	+998-99-505-70-43			\N	\N	f	40	37	31	29	73	1	\N	3	1	53	\N
520	Жура Охунович	+998-97-271-61-51			\N	\N	f	46	42	31	29	73	1	\N	1	2	50	\N
522	Олим Нуруллаевич	+998-91-102-57-63			\N	\N	f	46	42	31	29	73	1	\N	1	2	50	\N
523	Шахриер Бахтиярович	+998-95-222-63-94			\N	\N	f	46	42	31	29	73	1	\N	4	2	50	\N
531	Ботиров Ахмаджон	+998901519520	+998901519520	botirov@mail.ru	\N	\N	f	54	36	35	30	73	1	\N	1	1	30	1980-01-01 00:00:00
532	Қутлиев Одил	+998-99-667-04-05			\N	\N	f	62	59	35	30	73	1	\N	20	1	187	\N
497	Хилола	+99895555555	+998944444444	test@gmail.com	\N	\N	f	40	37	31	29	73	1	\N	6	2	18	2024-08-07 00:00:00
508	Дустмуродов Низомиддин	+998-97-470-09-26	/	12@mail.ru	\N	\N	f	46	42	31	29	73	1	\N	4	1	181	1980-01-01 00:00:00
554	Суюндикова Дилбар	+998-97-245-88-31			\N	\N	f	46	42	31	29	73	1	\N	3	2	49	\N
570	шерзод	+998-93-741-20-80			\N	\N	f	90	37	31	29	73	1	\N	3	1	53	\N
571	Мухаммадали Озодов	941943733	0000000	mmm@mail.ru	\N	\N	f	46	42	31	29	73	1	\N	4	1	181	1975-04-01 00:00:00
577	Азамов Отабек	+998946643303	..	..@mail.ru	\N	\N	f	82	65	64	63	73	1	\N	12	1	198	2000-01-01 00:00:00
578	Мухаммадшокир	+998880134040	...	ADF@MAIL.RU	\N	\N	f	82	65	64	63	73	1	\N	4	1	29	2000-01-01 00:00:00
579	Мухаммадшокир	+998880134040	...	ADF@MAIL.RU	\N	\N	f	82	65	64	63	73	1	\N	4	1	29	2000-01-01 00:00:00
583	Даврон	+998-94-675-48-46			\N	\N	f	100	47	31	29	73	1	\N	17	1	199	\N
588	Каххор	+998-88-909-06-63			\N	\N	f	46	42	31	29	73	1	\N	4	1	46	\N
589	Муродов Голиб	+998 90 880 27 77	+998 90 880 27 77	golib@mail.ru	\N	\N	f	60	59	35	30	73	1	\N	1	2	25	1980-01-01 00:00:00
590	Олмос Исматов	+998-97-706-76-86			\N	\N	f	60	59	35	30	73	1	\N	1	2	107	\N
591	Мустафаева Мастура	+998 91 633 51 26	+998 91 633 51 26	mastura@mail.ru	\N	\N	f	60	59	35	30	73	1	\N	8	2	25	1980-01-01 00:00:00
592	Исанова Гузаль	+998913225362	+998913225362	guzal@mail.ru	\N	\N	f	60	59	35	30	73	1	\N	3	2	26	1980-01-01 00:00:00
593	Эшонкулова Оиша	+998908050891	+998908050891	oysha@mail.ru	\N	\N	f	60	59	35	30	73	1	\N	1	2	23	1980-01-01 00:00:00
594	Ахмедов Камолиддин	+998-97-859-88-92			\N	\N	f	39	37	31	29	73	1	\N	11	1	53	\N
597	Исмоил Туйчиев	+998-94-425-35-03			\N	\N	f	49	47	31	29	73	1	\N	3	1	201	\N
598	Мужахон	+998-93-997-60-00			\N	\N	f	49	47	31	29	73	1	\N	1	1	201	\N
599	Каримова Насиба	+998996553906	.	1@mail.ru	\N	\N	f	82	65	64	63	73	1	\N	6	1	202	1976-01-01 00:00:00
600	Наби	887973736	0000000	nabi@mail.ru	\N	\N	f	110	42	31	29	73	1	\N	8	1	96	1975-05-01 00:00:00
601	Ибрагимов Жамол	913097771	0000000	ibragimov@mail.ru	\N	\N	f	110	42	31	29	73	1	\N	1	1	96	1979-06-05 00:00:00
602	Холжигитов Аваз	973400301	00000	avaz@mail.ru	\N	\N	f	46	42	31	29	73	1	\N	4	1	46	1975-05-01 00:00:00
604	жуманязов рустам	+998-91-916-04-18	+998-91-916-04-18		\N	\N	f	90	37	31	29	73	1	\N	7	1	57	\N
605	жуманязов рустам	+998-94-232-28-56			\N	\N	f	90	37	31	29	73	1	\N	7	1	51	\N
606	АЪЗАМОВ ШАСУТДИН	331323033	00000	azamov@mail.ru	\N	\N	f	46	42	31	29	73	1	\N	4	1	205	1978-04-04 00:00:00
607	Азимбой	995005878	00000	azimboy@mail.ru	\N	\N	f	40	37	31	29	73	1	\N	3	1	62	1975-06-01 00:00:00
608	Бозоров Ихтиёр	905008144	00000	bozorov@mail.ru	\N	\N	f	114	42	31	29	73	1	\N	2	1	98	1977-07-07 00:00:00
609	Шухрат	939557888	00000	shux@mail.ru	\N	\N	f	114	42	31	29	73	1	\N	2	1	98	1979-07-07 00:00:00
610	Олим Хайдарович	934380010	00000	olim@mail.ru	\N	\N	f	114	42	31	29	73	1	\N	2	1	98	1977-12-20 00:00:00
596	Камбаров Комилжон	+998-97-2770024	00000	QAM@mail.ru	\N	\N	f	46	42	31	29	73	1	\N	4	1	181	1975-04-01 00:00:00
611	Хусенов Миазиз Уктамович	906366404	00000	xusen@mail.ru	\N	\N	f	43	42	31	29	73	1	\N	2	1	124	1977-01-20 00:00:00
603	Юлдашев Бобомурод	+998-94-512-35-30	00000000	00000	\N	\N	f	90	37	31	29	73	1	\N	3	1	51	1979-05-01 00:00:00
725	Шохсувор Очилов	+998-99-503-22-33			\N	\N	f	62	59	35	30	73	1	\N	11	1	37	\N
727	Бахром Сувонов	+998-93-525-55-25			\N	\N	f	62	59	35	30	73	1	\N	1	2	104	\N
612	Нарзиев К	914434422	00000	narziev@mail.ru	\N	\N	f	43	42	31	29	73	1	\N	2	1	124	1979-05-01 00:00:00
613	Икромов Ислом	+998-99-811-50-62			\N	\N	f	60	59	35	30	73	1	\N	3	2	83	\N
614	Расулов Шухрат	+998-97-224-68-75			\N	\N	f	46	42	31	29	73	1	\N	7	2	50	\N
615	Нуриддин Муминов	+998-97-275-55-40			\N	\N	f	46	42	31	29	73	1	\N	7	2	50	\N
616	Бобоназаров Хакназар	998999086	00000	bobonazarov@mail.ru	\N	\N	f	114	42	31	29	73	1	\N	2	1	98	1975-05-05 00:00:00
617	Равшан 	977712126	00000	rav.x@mail.ru	\N	\N	f	114	42	31	29	73	1	\N	2	1	98	1979-04-21 00:00:00
618	Фархад Равшанович	+998-93-333-33-33			\N	\N	f	66	65	64	63	73	1	\N	22	1	4	\N
619	Салима Гадаевна	+998-93-333-33-33			\N	\N	f	66	65	64	63	73	1	\N	1	2	4	\N
620	Жураев Зухриддин	972978882	00000	jujrayev@mail.ru	\N	\N	f	114	42	31	29	73	1	\N	19	1	98	1979-05-01 00:00:00
621	Мафтуна	952390878	00000	maftuna@mail.ru	\N	\N	f	114	42	31	29	73	1	\N	6	1	98	1985-07-15 00:00:00
622	Холиков Шахбоз	+998-91-286-57-07		holikov@mail.ru	\N	\N	f	54	36	35	30	73	1	\N	14	2	30	\N
623	КАмола Шавкатовна	+998-90-123-45-67			\N	\N	f	66	65	64	63	73	1	\N	10	1	147	\N
624	Авазов Аскар	+998-97-678-22-88		avazov@mail.ru	\N	\N	f	86	59	35	30	73	1	\N	1	2	105	\N
516	Ризаев Хамро	+998-91-988-87-58	00000	riza@mail.ru	\N	\N	f	40	37	31	29	73	1	\N	9	1	53	1977-04-01 00:00:00
625	Исмоилов Шухрат	+998-91-637-41-50			\N	\N	f	60	59	35	30	73	1	\N	10	2	206	\N
626	Буронова Гулнора	+998-97-387-67-64			\N	\N	f	60	59	35	30	73	1	\N	1	2	23	\N
627	Дустова Зарнигор	+998-88-384-00-53			\N	\N	f	60	59	35	30	73	1	\N	1	2	23	\N
628	Салаев Жамшид	+998-93-454-86-48			\N	\N	f	90	37	31	29	73	1	\N	1	1	207	\N
629	Мадаминов Кадамбай	+998-91-946-48-46			\N	\N	f	90	37	31	29	73	1	\N	1	1	208	\N
630	Басчаева Азиза	+998-91-688-68-00			\N	\N	f	110	42	31	29	73	1	\N	6	1	96	\N
631	Ибрагимов Халил	+998-93-575-88-48			\N	\N	f	110	42	31	29	73	1	\N	1	1	209	\N
632	Дильноза	+998-93-574-88-08			\N	\N	f	110	42	31	29	73	1	\N	4	1	210	\N
633	Ойбек Уразалиевич	+998-97-909-11-15			\N	\N	f	46	42	31	29	73	1	\N	5	2	211	\N
634	Икром Эргашев	+998-90-335-20-27			\N	\N	f	46	42	31	29	73	1	\N	5	2	211	\N
635	Олим Хайдаров	+998-91-308-02-03			\N	\N	f	115	42	31	29	73	1	\N	1	1	98	\N
636	Зухриддин	+998-97-297-88-82			\N	\N	f	115	42	31	29	73	1	\N	19	1	98	\N
637	Хожиев Навбахор	+998-90-089-30-30			\N	\N	f	115	42	31	29	73	1	\N	1	1	98	\N
638	Топганов Рустам Хидирович	+998-91-507-33-77			\N	\N	f	46	42	31	29	73	1	\N	14	1	49	\N
639	Файзуллаева Назокат	+998-90-512-09-97			\N	\N	f	43	42	31	29	73	1	\N	3	1	124	\N
640	Ниезов Зохид	+998-93-080-01-04			\N	\N	f	43	42	31	29	73	1	\N	3	1	114	\N
641	Хаттабов Музаффар	+998-91-646-07-77			\N	\N	f	43	42	31	29	73	1	\N	8	1	114	\N
642	Икромов Ислом	+998-99-811-50-62			\N	\N	f	60	59	35	30	73	1	\N	3	2	83	\N
643	Холбутаева Фотима	9911040138	00000	holbutaeva@mail.ru	\N	\N	f	46	42	31	29	73	1	\N	12	1	50	1979-06-04 00:00:00
644	Обидов Мирали	995425252	00000	obidov@mail.ru	\N	\N	f	49	47	31	29	73	1	\N	8	1	212	1978-02-01 00:00:00
645	Сергазиев Алихан	935666644	00000	alixan@mail.ru	\N	\N	f	49	47	31	29	73	1	\N	8	1	212	1971-12-04 00:00:00
646	Кушбеков Ильхом	974475778	00000	kushbekov@mail.ru	\N	\N	f	49	47	31	29	73	1	\N	4	1	212	1971-12-04 00:00:00
647	Йулчи Комилов	994770425	00000	yolchi@mail.ru	\N	\N	f	49	47	31	29	73	1	\N	8	1	212	1979-02-12 00:00:00
649	Мазохидов Йулчибек	+998-97-502-89-84	+998-97-502-89-84	mazoxidov@mail.ru	\N	\N	f	54	36	35	30	73	1	\N	14	1	94	1980-01-01 00:00:00
648	Олимжонович Азизбек	+998-91-146-12-35	+998-91-146-12-35	azizbek@mail.ru	\N	\N	f	54	36	35	30	73	1	\N	14	1	41	1980-01-01 00:00:00
651	Диля онколог	+998902938338	+998902938338	onkolog@mail.ru	\N	\N	f	54	36	35	30	73	1	\N	5	2	220	1980-01-01 00:00:00
650	Тохиров Ахроржон	+998911383072	+998911383072	toxirov@mail.ru	\N	\N	f	54	36	35	30	73	1	\N	12	2	221	1980-02-01 00:00:00
653	Хамраев Кобил	+998-99-032-17-51			\N	\N	f	60	59	35	30	73	1	\N	4	2	79	\N
652	Кадирова Мадина	+998-93-321-32-14	1	1@mail.ru	\N	\N	f	82	65	64	63	73	1	\N	3	1	11	2002-02-12 00:00:00
654	Камол Рахимов	+998505033190	+998505033190	raximov@mail.ru	\N	\N	f	60	59	35	30	73	1	\N	2	2	107	1980-01-01 00:00:00
660	Test doctor	+99895555555	+998944444444	test@gmail.com	\N	\N	f	100	47	31	29	73	1	\N	9	1	18	2024-09-10 00:00:00
656	Провизор Нукус ШТБ	 933672717	 933672717	oysha@mail.ru	\N	\N	f	116	55	35	30	73	1	\N	18	2	21	1980-01-01 00:00:00
657	Провизор Шуманай ТТБ	 933672717	 933672717	oysha@mail.ru	\N	\N	f	116	55	35	30	73	1	\N	18	2	16	1980-01-01 00:00:00
658	Провизор Канлыколь 	913889733	913889733	oysha@mail.ru	\N	\N	f	116	55	35	30	73	1	\N	18	2	222	1980-01-01 00:00:00
659	Расулова Феруза	+998974008503	.	1@mail.ru	\N	\N	f	82	65	64	63	73	1	\N	1	2	162	1999-02-01 00:00:00
661	Test doctor	+99895555555	+998944444444	test@gmail.com	\N	\N	f	80	7	4	3	73	1	\N	2	1	224	2024-09-12 00:00:00
662	Провизор Кунград	 912110400	 912110400	qungrad@mail.ru	\N	\N	f	116	55	35	30	73	1	\N	18	2	17	1980-01-01 00:00:00
655	Пардаев Ботир	+998974491974	+998974491974	pardaev@mail.ru	\N	\N	f	60	59	35	30	73	1	\N	3	2	225	1980-01-01 00:00:00
663	Шахбоз Язданов	+998-90-939-73-13			\N	\N	f	62	59	35	30	73	1	\N	4	1	104	\N
664	Исломов Дилшод Норпулатович	+998-88-310-00-68			\N	\N	f	62	59	35	30	73	1	\N	9	1	226	\N
665	Камолов Шерали	934277144	934277144	kamolov@mail.ru	\N	\N	f	54	36	35	30	73	1	\N	4	2	31	1980-01-01 00:00:00
666	Эргашхужаев Шохжахон	+998912014875	+998912014875	ergashxujaev@mail.ru	\N	\N	f	54	36	35	30	73	1	\N	14	2	30	1980-01-01 00:00:00
726	Шерзод Зарипов	+998-91-550-29-00			\N	\N	f	62	59	35	30	73	1	\N	11	2	104	\N
667	Провизор Чимбай ТТБ	913791301	913791301	chimbay@mail.ru	\N	\N	f	116	55	35	30	73	1	\N	18	2	227	1980-01-01 00:00:00
668	Ноила Аскаровна	+998-97-909-22-07	00000	oli@mail.ru	\N	\N	f	46	42	31	29	73	1	\N	3	2	50	1975-07-01 00:00:00
669	Тагаев	970001835	00000	aza@mail.ru	\N	\N	f	114	42	31	29	73	1	\N	23	1	98	1975-04-01 00:00:00
670	Каримов Умр	000000	00000	KARIMOV@mail.ru	\N	\N	f	114	42	31	29	73	1	\N	12	1	98	1970-05-04 00:00:00
671	Каримов Умр	000000	00000	KARIMOV@mail.ru	\N	\N	f	114	42	31	29	73	1	\N	12	1	98	1970-05-04 00:00:00
672	Шерзод Қурбонов	+998-91-215-77-99			\N	\N	f	62	59	35	30	73	1	\N	4	2	37	\N
673	Хатамова Саодат	903291061	00000	xatav@mail.ru	\N	\N	f	50	47	31	29	73	1	\N	1	1	55	1979-05-01 00:00:00
674	Учкун 	935545412	00000	sam@mail.ru	\N	\N	f	110	42	31	29	73	1	\N	14	1	98	1972-06-04 00:00:00
675	Авазов А	909542586	00000	amov@mail.ru	\N	\N	f	110	42	31	29	73	1	\N	3	1	98	1986-05-06 00:00:00
676	Азиз	945642148	00000	azav@mail.ru	\N	\N	f	110	42	31	29	73	1	\N	6	1	98	1981-05-17 00:00:00
677	Хамидов Бобур	904259605	904259605	xamidov@mail.ru	\N	\N	f	60	59	35	30	73	1	\N	1	2	228	1980-01-01 00:00:00
678	Eshmat Toshmatov	+99895555555	+998944444444	test@gmail.com	\N	\N	f	80	7	4	3	73	1	\N	1	1	18	2024-09-26 00:00:00
679	Eshmat Toshmatov	+99895555555	+998944444444	test@gmail.com	\N	\N	f	80	7	4	3	73	1	\N	1	1	18	2024-09-26 00:00:00
680	Eshmat Toshmatov	+99895555555	+998944444444	test@gmail.com	\N	\N	f	80	7	4	3	73	1	\N	1	1	18	2024-09-26 00:00:00
681	Eshmat Toshmatov	+99895555555	+998944444444	test@gmail.com	\N	\N	f	80	7	4	3	73	1	\N	1	1	18	2024-09-26 00:00:00
682	Toshmat Eshmatov	+99895555555	+998944444444	test@gmail.com	\N	\N	f	80	7	4	3	73	1	\N	10	2	15	2024-09-27 00:00:00
683	Провизор Кушкупыр ТТБ	913791821	913791821	kushkupir@mail.ru	\N	\N	f	85	55	35	30	73	1	\N	18	2	229	1980-01-01 00:00:00
684	Халиков Нуриддин	+998912260600	+998912260600	xalikov@mail.ru	\N	\N	f	60	59	35	30	73	1	\N	7	2	230	1980-01-01 00:00:00
685	Рахмонов Насим	+998-90-522-86-65			\N	\N	f	60	59	35	30	73	1	\N	1	2	231	\N
686	Рахманов Бегзод	944941020	944941020	raxmanov@mail.ru	\N	\N	f	51	36	35	30	73	1	\N	4	2	35	1980-01-01 00:00:00
687	Махкамов Мансур	976770520	976770520	maxkamov@mail.ru	\N	\N	f	51	36	35	30	73	1	\N	9	2	33	1980-01-01 00:00:00
688	Эргашев Элёр	988373033	988373033	ergashev@mail.ru	\N	\N	f	51	36	35	30	73	1	\N	8	2	101	1980-01-01 00:00:00
689	Бахромзода Бехруз	991081006	991081006	bexruz@mail.ru	\N	\N	f	62	59	35	30	73	1	\N	4	2	37	1980-01-01 00:00:00
690	Ашурова Раъно	916766556	916766556	ashurova@mail.ru	\N	\N	f	62	59	35	30	73	1	\N	4	2	37	1980-01-01 00:00:00
691	Даут	904565622	904565622	daut@mail.ru	\N	\N	f	85	55	35	30	73	1	\N	1	2	233	1980-01-01 00:00:00
692	Зульфия	976770522	976770522	rax.@mail.ru	\N	\N	f	85	55	35	30	73	1	\N	9	2	21	1980-01-01 00:00:00
693	Исакова Башорат 	906325545	906325545	isakova@mail.ru	\N	\N	f	53	36	35	30	73	1	\N	3	2	73	1980-01-01 00:00:00
694	Ирисбаева Махбуба	903654321	903654321	irisbaeva@mail.ru	\N	\N	f	53	36	35	30	73	1	\N	3	2	73	1980-01-01 00:00:00
695	Жамоллидин	+998911460061	+998911460061	raxm@mail.ru	\N	\N	f	54	36	35	30	73	1	\N	9	2	32	1980-01-01 00:00:00
696	Бекчанова Гульнара	+998-94-678-54-99		mak@mail.ru	\N	\N	f	90	37	31	29	73	1	\N	6	1	234	\N
697	Бунед	+998-94-987-85-84		bun@maul.ru	\N	\N	f	90	37	31	29	73	1	\N	4	1	236	\N
698	Гульназа	+998-90-415-86-85		gul@mail.ru	\N	\N	f	90	37	31	29	73	1	\N	6	1	237	\N
699	Хасият	+998-90-261-85-78		xas@mail.ru	\N	\N	f	90	37	31	29	73	1	\N	6	1	237	\N
700	Ганишер	+998-94-678-75-49		gan@mail.ru	\N	\N	f	90	37	31	29	73	1	\N	4	1	235	\N
701	Мухайе	+998-90-982-69-52		mux@mail.ru	\N	\N	f	90	37	31	29	73	1	\N	8	1	237	\N
702	Малика Ходжаева	+998-97-945-48-45		malika@mail.ru	\N	\N	f	39	37	31	29	73	1	\N	8	1	238	\N
703	Тангриберганов Тангриберган	+998-94-846-49-48		tqngri@mail.ru	\N	\N	f	39	37	31	29	73	1	\N	1	1	239	\N
704	Дильфуза	+998-90-956-81-25		dil@mail.ru	\N	\N	f	40	37	31	29	73	1	\N	6	1	57	\N
705	Сардор	+998-93-545-28-66		sar@mail.ru	\N	\N	f	40	37	31	29	73	1	\N	3	1	57	\N
706	Камалиддин	+998-97-738-45-58		kam@msil.ru	\N	\N	f	40	37	31	29	73	1	\N	9	1	58	\N
707	Хамро	+998-90-556-85-55			\N	\N	f	40	37	31	29	73	1	\N	3	1	57	\N
708	Гулбахор	+998-90-260-76-99		gul@mail.ru	\N	\N	f	40	37	31	29	73	1	\N	11	1	58	\N
709	Бозоров Файзулла	+998-90-970-62-23		bozoro@mail.ru	\N	\N	f	114	42	31	29	73	1	\N	2	1	98	\N
710	Бобожонов	+998-90-568-66-58		bob@mail.ru	\N	\N	f	114	42	31	29	73	1	\N	1	1	98	\N
711	Эсанов Абдухалил	+998-90-388-96-59		esan@mail.ru	\N	\N	f	110	42	31	29	73	1	\N	1	1	96	\N
712	Эргашева Нилуфар	+998-93-656-88-55		sam@mail.ru	\N	\N	f	110	42	31	29	73	1	\N	9	1	240	\N
713	Ботир Баходирович	+998-90-943-65-46		abna@mail.ru	\N	\N	f	46	42	31	29	73	1	\N	1	2	181	\N
714	Кулдашев Абдукосим	+998-90-643-49-88		mal@maik.ru	\N	\N	f	46	42	31	29	73	1	\N	4	2	205	\N
715	Шокосим	+998-90-966-48-83		maf@mail.ru	\N	\N	f	46	42	31	29	73	1	\N	1	2	205	\N
716	Маллаев Хуршид	+998-90-872-56-56			\N	\N	f	62	59	35	30	73	1	\N	21	3	232	\N
717	Хайруллаев Бахтиёр	+998-88-674-72-27			\N	\N	f	62	59	35	30	73	1	\N	9	2	43	\N
718	Малохат Джураева	+998-90-934-54-68		mal@mail.ru	\N	\N	f	86	59	35	30	73	1	\N	17	3	5	\N
719	Зулхумар	+998-91-376-59-07		mai@mail.ru	\N	\N	f	85	55	35	30	73	1	\N	1	2	75	\N
720	Атабек	+998-93-205-52-32		ata@gmail.ru	\N	\N	f	85	55	35	30	73	1	\N	10	2	75	\N
721	Рахмонов Норпулат	+998-91-474-92-54			\N	\N	f	62	59	35	30	73	1	\N	12	2	37	\N
722	Икром Хаитов	+998-91-945-44-32			\N	\N	f	62	59	35	30	73	1	\N	2	2	171	\N
723	Нурбек Буриев	+998-99-666-84-08			\N	\N	f	62	59	35	30	73	1	\N	2	1	171	\N
724	ТохировСобир	+998-91-947-03-90			\N	\N	f	62	59	35	30	73	1	\N	7	2	171	\N
728	Гуллиев Сирожиддин	+998-91-472-83-72			\N	\N	f	62	59	35	30	73	1	\N	4	1	40	\N
729	Шониев Турақул	+998-91-956-11-77			\N	\N	f	62	59	35	30	73	1	\N	21	1	171	\N
730	Акбархон	+998-93-005-83-92			\N	\N	f	46	42	31	29	73	1	\N	1	2	46	\N
\.


--
-- Data for Name: doctor_category; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.doctor_category (id, name) FROM stdin;
1	А
2	Б
3	VIP
\.


--
-- Data for Name: doctor_fact; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.doctor_fact (id, fact, date, doctor_id, pharmacy_id, product_id, price, discount_price) FROM stdin;
111	10	2024-08-05 00:00:00	300	22	18	47500	18950
112	10	2024-08-05 00:00:00	302	22	12	72000	37500
118	65	2024-08-05 00:00:00	317	48	31	450000	180000
120	8	2024-08-05 00:00:00	342	32	13	85000	42500
121	5	2024-08-12 11:58:22.276844	357	113	30	75000	25000
122	5	2024-08-12 11:58:22.276844	357	113	19	65000	26500
123	5	2024-08-12 11:58:22.276844	357	113	12	72000	37500
124	5	2024-08-12 11:58:22.276844	357	113	24	72000	33280
125	5	2024-08-12 11:58:22.276844	357	113	18	47500	18950
126	5	2024-08-12 11:58:22.276844	357	113	25	155000	52600
127	3	2024-08-12 12:24:15.795271	357	113	10	130000	62000
113	50	2024-08-05 00:00:00	304	101	5	152600	70000
129	21	2024-08-13 02:35:16.521017	361	117	25	155000	52600
130	100	2024-08-13 02:35:16.521017	301	21	24	72000	33280
132	10	2024-08-13 02:35:16.521017	314	108	13	85000	42500
133	20	2024-08-13 02:35:16.521017	314	108	27	190000	94500
134	500	2024-08-13 10:07:30.072404	461	121	28	85000	37750
135	5	2024-08-13 12:09:01.313473	473	122	13	85000	42500
136	20	2024-08-13 12:09:01.313473	308	122	25	155000	52600
138	10	2024-08-13 12:09:01.313473	303	19	7	75000	33500
139	5	2024-08-13 12:09:01.313473	303	19	10	130000	62000
140	20	2024-08-13 12:09:01.313473	303	19	13	85000	42500
141	30	2024-08-13 12:09:01.313473	303	19	23	49500	21570
142	30	2024-08-13 12:09:01.313473	378	42	25	155000	52600
143	35	2024-08-13 12:09:01.313473	313	103	12	72000	37500
144	20	2024-08-13 12:09:01.313473	311	103	25	155000	52600
145	50	2024-08-13 12:09:01.313473	508	109	24	72000	33280
146	50	2024-08-13 12:09:01.313473	343	95	12	72000	37500
147	50	2024-08-13 12:09:01.313473	343	95	13	85000	42500
149	50	2024-08-13 12:09:01.313473	485	123	19	65000	26500
150	20	2024-08-14 11:51:29.13618	514	123	28	85000	37750
152	34	2024-08-14 11:51:29.13618	516	69	5	152600	70000
153	10	2024-08-14 11:51:29.13618	531	135	25	155000	52600
154	20	2024-08-15 11:23:50.502567	300	22	12	72000	37500
155	20	2024-08-15 11:23:50.502567	302	22	13	85000	42500
115	52	2024-08-05 00:00:00	310	91	12	72000	37500
116	36	2024-08-05 00:00:00	312	91	25	155000	52600
156	20	2024-08-15 11:23:50.502567	480	142	28	85000	37750
157	20	2024-08-15 11:23:50.502567	480	142	19	65000	26500
158	50	2024-08-15 11:23:50.502567	480	142	25	155000	52600
159	30	2024-08-15 11:23:50.502567	480	142	13	85000	42500
160	100	2024-08-15 11:23:50.502567	583	142	25	155000	52600
161	30	2024-08-21 07:39:51.728048	384	143	13	85000	42500
162	30	2024-08-21 07:39:51.728048	384	143	25	155000	52600
163	10	2024-08-21 07:39:51.728048	588	30	24	72000	33280
164	10	2024-08-21 07:39:51.728048	588	30	12	72000	37500
165	50	2024-08-21 07:39:51.728048	589	151	25	155000	52600
166	20	2024-08-21 07:39:51.728048	591	151	15	95000	48900
167	10	2024-08-21 07:39:51.728048	591	151	14	175000	89500
168	10	2024-08-21 07:39:51.728048	591	151	27	190000	94500
169	20	2024-08-21 07:39:51.728048	591	151	12	72000	37500
170	5	2024-08-21 07:39:51.728048	592	151	33	300000	220000
171	17	2024-08-22 05:40:04.679606	593	14	12	72000	37500
172	20	2024-08-22 05:40:04.679606	593	14	24	72000	33280
173	20	2024-08-22 05:40:04.679606	593	14	13	85000	42500
174	30	2024-08-22 05:40:04.679606	594	64	33	300000	220000
175	330	2024-08-22 05:40:04.679606	415	62	13	85000	42500
177	30	2024-08-22 11:35:58.380107	342	109	12	72000	37500
178	20	2024-08-22 11:35:58.380107	596	109	13	85000	42500
179	10	2024-08-23 04:46:18.265196	597	81	31	450000	180000
180	30	2024-08-23 04:46:18.265196	467	81	25	155000	52600
184	50	2024-08-23 04:46:18.265196	597	81	13	85000	42500
185	50	2024-08-23 04:46:18.265196	472	145	25	155000	52600
188	30	2024-08-23 10:32:41.503752	344	31	11	173000	75000
189	100	2024-08-23 10:32:41.503752	472	79	25	155000	52600
190	20	2024-08-23 11:35:41.159549	485	124	19	65000	26500
191	100	2024-08-23 11:35:41.159549	344	36	25	155000	52600
196	20	2024-08-26 05:57:51.337408	600	154	28	85000	37750
197	30	2024-08-26 05:57:51.337408	601	154	25	155000	52600
198	10	2024-08-26 05:57:51.337408	601	154	13	85000	42500
199	10	2024-08-26 05:57:51.337408	601	154	27	190000	94500
202	100	2024-08-26 05:57:51.337408	426	153	12	72000	37500
203	100	2024-08-26 05:57:51.337408	599	153	13	85000	42500
114	84	2024-08-05 00:00:00	309	91	12	72000	37500
205	20	2024-08-26 05:57:51.337408	532	146	24	72000	33280
206	20	2024-08-26 05:57:51.337408	378	42	13	85000	42500
207	20	2024-08-26 05:57:51.337408	606	158	24	72000	33280
208	20	2024-08-26 05:57:51.337408	473	14	13	85000	42500
218	50	2024-08-26 05:57:51.337408	611	71	13	85000	42500
137	240	2024-08-13 12:09:01.313473	304	19	25	155000	52600
214	30	2024-08-26 05:57:51.337408	531	163	25	155000	52600
176	10	2024-08-22 11:35:58.380107	571	144	24	72000	33280
204	20	2024-08-26 05:57:51.337408	590	91	25	155000	52600
232	200	2024-08-30 06:53:43.886427	409	120	24	72000	33280
226	30	2024-08-30 06:53:43.886427	616	164	13	85000	42500
227	30	2024-08-30 06:53:43.886427	621	164	12	72000	37500
233	200	2024-08-30 06:53:43.886427	409	120	20	60000	31200
131	500	2024-08-13 02:35:16.521017	409	120	12	72000	37500
234	300	2024-08-30 06:53:43.886427	409	120	25	155000	52600
195	30	2024-08-24 09:55:36.499061	531	26	25	155000	52600
235	20	2024-09-03 11:45:40.76649	602	32	24	72000	33280
236	5	2024-09-03 11:45:40.76649	601	157	25	155000	52600
237	5	2024-09-03 11:45:40.76649	601	157	13	85000	42500
238	5	2024-09-03 11:45:40.76649	601	157	27	190000	94500
239	20	2024-09-05 08:00:17.066985	531	21	25	155000	52600
248	5	2024-09-05 09:25:02.890199	643	174	31	325000	165000
258	23	2024-09-05 09:25:02.890199	590	91	12	72000	37500
256	57	2024-09-05 09:25:02.890199	649	21	24	72000	33280
260	50	2024-09-09 09:56:53.447359	601	154	25	155000	52600
261	10	2024-09-09 09:56:53.447359	651	21	27	190000	94500
262	10	2024-09-09 09:56:53.447359	650	21	27	190000	94500
128	10	2024-08-12 12:24:15.795271	311	92	25	155000	52600
268	10	2024-09-10 12:08:11.041645	531	135	25	155000	52600
269	400	2024-09-10 12:08:11.041645	461	121	28	85000	37750
263	170	2024-09-09 09:56:53.447359	317	50	25	155000	52600
257	42	2024-09-05 09:25:02.890199	351	91	12	72000	37500
244	20	2024-09-05 08:00:17.066985	531	24	25	155000	52600
267	40	2024-09-10 12:08:11.041645	577	35	27	190000	94500
148	50	2024-08-13 12:09:01.313473	474	123	25	155000	52600
151	50	2024-08-14 11:51:29.13618	474	124	25	155000	52600
259	50	2024-09-09 09:56:53.447359	450	72	25	155000	52600
282	16	2024-08-31 18:40:00	369	115	19	65000	26500
283	20	2024-08-19 17:22:00	302	21	19	65000	26500
284	100	2024-08-19 17:22:00	648	21	24	72000	33280
285	50	2024-08-19 08:50:00	301	22	24	72000	33280
286	22	2024-08-05 14:07:00	317	110	31	325000	165000
287	320	2024-08-12 10:52:00	317	110	25	155000	52600
288	140	2024-08-02 10:04:00	656	205	27	190000	94500
289	20	2024-08-12 10:04:00	658	207	27	190000	94500
362	100	2024-09-27 13:00:00	362	177	12	72000	37500
291	10	2024-09-13 11:48:00	659	178	30	75000	25000
292	10	2024-09-13 11:48:00	659	178	13	85000	42500
290	30	2024-08-31 10:04:00	657	206	27	190000	94500
293	15	2024-09-12 12:00:00	308	122	25	155000	52600
294	10	2024-09-12 12:30:00	357	113	30	75000	25000
295	10	2024-09-12 12:30:00	357	113	12	72000	37500
296	10	2024-09-12 13:00:00	626	169	25	155000	52600
300	20	2024-09-13 12:47:00	426	93	11	173000	75000
363	20	2024-09-27 13:00:00	362	177	31	325000	165000
304	11	2024-09-10 15:12:00	654	91	25	155000	52600
307	10	2024-09-11 15:12:00	613	173	25	155000	52600
255	50	2024-09-05 09:25:02.890199	648	21	24	72000	33280
308	75	2024-09-13 13:00:00	662	217	27	190000	94500
364	20	2024-09-27 13:00:00	362	177	37	450000	165000
312	15	2024-09-17 00:00:00	309	91	12	72000	37500
313	120	2024-09-18 10:41:00	304	19	25	155000	52600
303	21	2024-09-10 15:12:00	590	91	25	155000	52600
314	40	2024-09-18 11:19:00	313	103	12	72000	37500
316	30	2024-09-18 12:23:00	300	219	18	47500	18950
318	3	2024-08-30 17:18:00	317	220	20	60000	31200
365	20	2024-09-27 13:00:00	664	218	33	300000	150000
320	10	2024-09-19 00:00:00	300	22	18	47500	18950
321	10	2024-09-19 00:00:00	302	22	19	65000	26500
322	48	2024-09-19 00:00:00	622	22	38	120000	66000
323	48	2024-09-19 00:00:00	666	22	38	120000	66000
324	15	2024-09-19 00:00:00	300	22	12	72000	37500
319	100	2024-09-01 00:00:00	667	\N	27	190000	94500
328	5	2024-08-31 10:22:00	409	222	4	70000	30000
329	5	2024-08-31 10:22:00	409	222	11	173000	75000
330	9	2024-08-31 10:22:00	409	222	25	155000	52600
331	45	2024-09-20 12:33:00	599	153	13	85000	42500
332	20	2024-09-20 13:00:00	378	42	25	155000	52600
333	5	2024-09-20 14:17:00	420	221	31	325000	165000
334	10	2024-09-20 14:17:00	420	221	30	75000	25000
335	10	2024-09-21 18:00:00	369	115	25	155000	52600
336	110	2024-09-12 10:02:00	656	205	27	190000	94500
337	100	2024-09-24 12:38:00	300	224	21	55000	22340
311	35	2024-09-17 00:00:00	310	91	12	72000	37500
338	10	2024-09-09 12:46:00	668	172	24	72000	33280
339	2	2024-09-13 15:16:00	643	225	31	325000	165000
340	10	2024-09-13 15:16:00	643	225	12	72000	37500
347	20	2024-09-24 15:25:00	588	30	12	72000	37500
348	20	2024-09-24 15:25:00	588	30	24	72000	33280
366	40	2024-09-18 11:35:00	302	21	12	72000	37500
367	20	2024-09-18 11:35:00	300	21	12	72000	37500
368	50	2024-09-10 11:41:00	673	231	25	155000	52600
369	100	2024-09-21 11:49:00	474	123	25	155000	52600
341	10	2024-09-13 15:16:00	643	225	13	85000	42500
371	71	2024-09-23 14:19:00	485	231	25	155000	52600
299	40	2024-09-12 12:00:00	311	92	25	155000	52600
309	20	2024-09-17 15:00:00	655	216	19	65000	26500
357	16	2024-09-25 16:22:00	591	215	12	72000	37500
358	50	2024-09-26 16:30:00	684	151	12	72000	37500
359	20	2024-09-26 16:30:00	684	151	24	72000	33280
360	60	2024-09-26 16:30:00	589	151	25	155000	52600
361	10	2024-09-25 17:37:00	308	179	25	155000	52600
350	45	2024-09-06 12:27:00	669	161	12	72000	37500
351	45	2024-09-06 12:27:00	669	161	13	85000	42500
352	40	2024-09-06 12:27:00	670	161	27	190000	94500
355	40	2024-09-23 13:14:00	616	164	25	155000	52600
353	112	2024-09-23 13:14:00	616	164	13	85000	42500
354	100	2024-09-23 13:14:00	616	164	12	72000	37500
370	100	2024-09-21 11:57:00	486	231	25	155000	52600
281	100	2024-09-11 12:45:01.803637	472	79	25	155000	52600
372	50	2024-09-19 18:32:00	472	81	12	72000	37500
373	50	2024-09-19 18:32:00	472	81	13	85000	42500
374	120	2024-09-19 18:32:00	472	81	25	155000	52600
375	10	2024-09-12 16:32:00	675	196	25	155000	52600
376	20	2024-09-12 16:32:00	676	196	13	85000	42500
377	10	2024-09-25 16:34:00	674	154	12	72000	37500
378	20	2024-09-25 16:34:00	674	154	13	85000	42500
379	9	2024-09-20 16:43:00	601	175	25	155000	52600
380	5	2024-09-20 16:43:00	601	175	12	72000	37500
381	400	2024-10-03 12:56:00	461	121	28	85000	37750
382	10	2024-10-07 13:40:00	531	135	25	155000	52600
383	20	2024-10-08 13:44:00	531	26	25	155000	52600
384	20	2024-10-08 13:44:00	649	26	24	72000	33280
385	150	2024-10-03 14:08:00	688	193	13	85000	42500
386	120	2024-10-08 17:40:00	303	19	25	155000	52600
387	10	2024-10-03 17:56:00	685	14	19	65000	26500
388	30	2024-10-03 17:56:00	593	14	12	72000	37500
390	30	2024-10-03 17:56:00	473	14	13	85000	42500
391	10	2024-10-03 18:11:00	626	169	25	155000	52600
392	20	2024-10-04 18:25:00	308	17	25	155000	52600
393	20	2024-10-07 18:32:00	311	92	25	155000	52600
394	10	2024-10-08 18:36:00	590	91	25	155000	52600
395	30	2024-10-08 18:36:00	351	91	12	72000	37500
396	10	2024-10-04 18:43:00	690	160	24	72000	33280
399	10	2024-10-04 18:43:00	381	160	27	190000	94500
400	10	2024-10-04 18:43:00	378	160	13	85000	42500
401	14	2024-10-07 19:00:00	377	44	25	155000	52600
402	30	2024-10-08 19:08:00	378	42	13	85000	42500
403	15	2024-10-08 19:08:00	453	42	25	155000	52600
404	120	2024-10-08 19:10:00	317	50	25	155000	52600
405	20	2024-10-09 19:13:00	651	21	27	190000	94500
\.


--
-- Data for Name: doctor_monthly_plan; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.doctor_monthly_plan (id, date, product_id, doctor_id, monthly_plan, price, discount_price) FROM stdin;
618	2024-08-01 00:00:00	18	300	50	47500	18950
621	2024-08-01 00:00:00	13	301	150	85000	42500
622	2024-08-01 00:00:00	13	302	50	85000	42500
623	2024-08-01 00:00:00	12	302	10	72000	37500
624	2024-08-01 00:00:00	5	302	10	152600	70000
663	2024-08-01 00:00:00	25	344	100	155000	52600
664	2024-08-01 00:00:00	12	344	25	72000	37500
678	2024-08-12 04:30:39.211055	18	367	50	47500	18950
686	2024-08-12 12:24:15.793668	18	374	25	47500	18950
1347	2024-08-01 00:00:00	25	369	10	155000	52600
698	2024-08-12 12:24:15.793668	25	377	30	155000	52600
1357	2024-08-01 00:00:00	27	657	30	190000	94500
1359	2024-08-01 00:00:00	27	656	140	190000	94500
1366	2024-09-01 00:00:00	23	369	40	49500	21570
1374	2024-09-01 00:00:00	24	663	10	72000	33280
1386	2024-09-01 00:00:00	24	668	10	72000	33280
772	2024-08-13 02:35:16.519513	12	409	200	72000	37500
776	2024-08-13 02:35:16.519513	31	413	10	450000	180000
779	2024-08-13 02:35:16.519513	30	407	50	75000	25000
787	2024-08-13 02:35:16.519513	12	384	50	72000	37500
788	2024-08-13 02:35:16.519513	12	408	50	72000	37500
792	2024-08-13 02:35:16.519513	13	412	25	85000	42500
802	2024-08-13 02:35:16.519513	30	420	20	75000	25000
808	2024-08-13 02:35:16.519513	25	415	50	155000	52600
817	2024-08-13 02:35:16.519513	10	425	30	130000	62000
818	2024-08-13 02:35:16.519513	12	425	100	72000	37500
829	2024-08-13 02:35:16.519513	31	448	20	450000	180000
832	2024-08-13 02:35:16.519513	30	445	100	75000	25000
849	2024-08-13 02:35:16.519513	27	451	50	190000	94500
858	2024-08-13 02:35:16.519513	12	378	30	72000	37500
863	2024-08-13 02:35:16.519513	24	454	50	72000	33280
875	2024-08-13 10:07:30.070825	30	458	50	75000	25000
895	2024-08-13 10:07:30.070825	4	470	200	82000	37500
899	2024-08-13 10:07:30.070825	25	308	30	155000	52600
907	2024-08-13 12:09:01.311777	30	480	100	75000	25000
920	2024-08-13 12:09:01.311777	13	480	50	85000	42500
924	2024-08-13 12:09:01.311777	7	303	10	75000	33500
931	2024-08-13 12:09:01.311777	24	479	150	72000	33280
937	2024-08-13 12:09:01.311777	24	508	50	72000	33280
944	2024-08-14 11:51:29.134583	12	532	20	72000	37500
1394	2024-09-01 00:00:00	12	669	15	72000	37500
1396	2024-09-01 00:00:00	27	670	20	190000	94500
1405	2024-08-01 00:00:00	5	481	20	152600	70000
620	2024-08-01 00:00:00	12	301	50	72000	37500
972	2024-08-15 11:23:50.50085	12	513	30	72000	37500
978	2024-08-15 11:23:50.50085	26	579	50	118000	62000
979	2024-08-15 11:23:50.50085	30	474	50	75000	25000
981	2024-08-15 11:23:50.50085	13	483	100	85000	42500
988	2024-08-21 07:39:51.726568	12	588	10	72000	37500
989	2024-08-21 07:39:51.726568	25	589	50	155000	52600
997	2024-08-22 05:40:04.678233	12	593	17	72000	37500
666	2024-08-01 00:00:00	19	344	25	65000	26500
670	2024-08-01 00:00:00	13	342	50	85000	42500
671	2024-08-01 00:00:00	12	343	50	72000	37500
679	2024-08-12 04:30:39.211055	31	370	30	450000	180000
687	2024-08-12 12:24:15.793668	30	374	50	75000	25000
694	2024-08-12 12:24:15.793668	18	376	25	47500	18950
699	2024-08-12 12:24:15.793668	25	378	50	155000	52600
667	2024-08-01 00:00:00	12	339	50	72000	37500
668	2024-08-01 00:00:00	27	340	20	190000	94500
749	2024-08-13 02:35:16.519513	25	361	100	155000	52600
894	2024-08-13 10:07:30.070825	25	466	326	155000	52600
1417	2024-08-01 00:00:00	12	604	5	72000	37500
1427	2024-10-01 00:00:00	25	311	75	155000	52600
1430	2024-10-01 00:00:00	12	593	50	72000	37500
774	2024-08-13 02:35:16.519513	31	411	10	450000	180000
790	2024-08-13 02:35:16.519513	13	413	25	85000	42500
791	2024-08-13 02:35:16.519513	19	414	10	65000	26500
803	2024-08-13 02:35:16.519513	25	420	30	155000	52600
807	2024-08-13 02:35:16.519513	25	418	100	155000	52600
811	2024-08-13 02:35:16.519513	25	417	50	155000	52600
819	2024-08-13 02:35:16.519513	13	418	100	85000	42500
820	2024-08-13 02:35:16.519513	13	417	50	85000	42500
833	2024-08-13 02:35:16.519513	30	443	100	75000	25000
853	2024-08-13 02:35:16.519513	13	382	20	85000	42500
855	2024-08-13 02:35:16.519513	5	383	20	152600	70000
856	2024-08-13 02:35:16.519513	5	380	10	152600	70000
857	2024-08-13 02:35:16.519513	18	379	50	47500	18950
860	2024-08-13 02:35:16.519513	12	453	20	72000	37500
867	2024-08-13 02:35:16.519513	30	456	40	75000	25000
876	2024-08-13 10:07:30.070825	12	299	50	72000	37500
877	2024-08-13 10:07:30.070825	13	343	50	85000	42500
880	2024-08-13 10:07:30.070825	27	458	30	190000	94500
886	2024-08-13 10:07:30.070825	31	466	50	450000	180000
887	2024-08-13 10:07:30.070825	30	471	100	75000	25000
889	2024-08-13 10:07:30.070825	30	467	100	75000	25000
893	2024-08-13 10:07:30.070825	25	467	200	155000	52600
896	2024-08-13 10:07:30.070825	12	466	100	72000	37500
897	2024-08-13 10:07:30.070825	26	467	100	118000	62000
898	2024-08-13 10:07:30.070825	33	469	50	300000	220000
902	2024-08-13 10:07:30.070825	24	469	50	72000	33280
908	2024-08-13 12:09:01.311777	25	477	200	155000	52600
911	2024-08-13 12:09:01.311777	4	476	200	82000	37500
914	2024-08-13 12:09:01.311777	12	480	50	72000	37500
916	2024-08-13 12:09:01.311777	13	479	50	85000	42500
918	2024-08-13 12:09:01.311777	13	476	50	85000	42500
921	2024-08-13 12:09:01.311777	13	481	100	85000	42500
922	2024-08-13 12:09:01.311777	10	303	5	130000	62000
938	2024-08-13 12:09:01.311777	28	514	20	85000	37750
945	2024-08-14 11:51:29.134583	24	532	20	72000	33280
1450	2024-10-01 00:00:00	31	664	50	325000	165000
1480	2024-10-01 00:00:00	27	381	50	190000	94500
1481	2024-10-01 00:00:00	33	532	75	300000	150000
1502	2024-10-01 00:00:00	12	302	100	72000	37500
1526	2024-10-01 00:00:00	5	419	80	152600	70000
1527	2024-10-01 00:00:00	13	415	300	85000	42500
1528	2024-10-01 00:00:00	27	594	50	190000	94500
973	2024-08-15 11:23:50.50085	27	577	30	190000	94500
982	2024-08-15 11:23:50.50085	24	489	50	72000	33280
983	2024-08-15 11:23:50.50085	19	480	20	65000	26500
991	2024-08-21 07:39:51.726568	15	591	20	95000	48900
995	2024-08-21 07:39:51.726568	33	592	5	300000	220000
999	2024-08-22 05:40:04.678233	13	415	330	85000	42500
629	2024-08-01 00:00:00	13	303	100	85000	42500
630	2024-08-01 00:00:00	25	304	250	155000	52600
631	2024-08-01 00:00:00	25	305	250	155000	52600
632	2024-08-01 00:00:00	5	304	50	152600	70000
673	2024-08-01 00:00:00	25	322	100	155000	52600
688	2024-08-12 12:24:15.793668	12	373	50	72000	37500
1530	2024-10-01 00:00:00	28	415	50	85000	37750
692	2024-08-12 12:24:15.793668	30	376	50	75000	25000
1348	2024-09-01 00:00:00	28	461	400	85000	37750
1358	2024-08-01 00:00:00	27	658	30	190000	94500
1367	2024-09-01 00:00:00	12	472	300	72000	37500
780	2024-08-13 02:35:16.519513	25	384	100	155000	52600
781	2024-08-13 02:35:16.519513	25	407	50	155000	52600
785	2024-08-13 02:35:16.519513	4	412	50	82000	37500
793	2024-08-13 02:35:16.519513	13	411	50	85000	42500
795	2024-08-13 02:35:16.519513	26	410	50	118000	62000
796	2024-08-13 02:35:16.519513	27	413	25	190000	94500
799	2024-08-13 02:35:16.519513	24	408	50	72000	33280
804	2024-08-13 02:35:16.519513	13	420	20	85000	42500
810	2024-08-13 02:35:16.519513	25	426	20	155000	52600
812	2024-08-13 02:35:16.519513	30	422	50	75000	25000
815	2024-08-13 02:35:16.519513	4	419	50	82000	37500
821	2024-08-13 02:35:16.519513	26	423	50	118000	62000
822	2024-08-13 02:35:16.519513	27	423	50	190000	94500
1375	2024-09-01 00:00:00	38	622	48	120000	66000
834	2024-08-13 02:35:16.519513	30	441	50	75000	25000
836	2024-08-13 02:35:16.519513	25	447	250	155000	52600
839	2024-08-13 02:35:16.519513	4	441	100	82000	37500
854	2024-08-13 02:35:16.519513	13	383	10	85000	42500
861	2024-08-13 02:35:16.519513	25	453	30	155000	52600
864	2024-08-13 02:35:16.519513	31	458	50	450000	180000
865	2024-08-13 02:35:16.519513	30	455	30	75000	25000
866	2024-08-13 02:35:16.519513	30	299	30	75000	25000
868	2024-08-13 02:35:16.519513	25	459	100	155000	52600
870	2024-08-13 02:35:16.519513	4	457	50	82000	37500
872	2024-08-13 02:35:16.519513	4	456	50	82000	37500
878	2024-08-13 10:07:30.070825	13	457	42	85000	42500
890	2024-08-13 10:07:30.070825	30	466	100	75000	25000
628	2024-08-01 00:00:00	25	307	10	155000	52600
901	2024-08-13 10:07:30.070825	22	468	100	85000	37440
903	2024-08-13 10:07:30.070825	13	473	10	85000	42500
923	2024-08-13 12:09:01.311777	23	303	30	49500	21570
928	2024-08-13 12:09:01.311777	22	481	50	85000	37440
939	2024-08-13 12:09:01.311777	19	485	50	65000	26500
1376	2024-09-01 00:00:00	38	666	48	120000	66000
1377	2024-09-01 00:00:00	19	302	10	65000	26500
1378	2024-09-01 00:00:00	12	300	40	72000	37500
1387	2024-09-01 00:00:00	30	457	20	75000	25000
680	2024-08-12 04:30:39.211055	19	370	10	65000	26500
974	2024-08-15 11:23:50.50085	4	310	100	82000	37500
984	2024-08-15 11:23:50.50085	25	583	100	155000	52600
992	2024-08-21 07:39:51.726568	14	591	10	175000	89500
633	2024-08-01 00:00:00	5	308	100	152600	70000
634	2024-08-01 00:00:00	5	311	100	152600	70000
635	2024-08-01 00:00:00	5	312	1	152600	70000
638	2024-08-01 00:00:00	13	312	10	85000	42500
641	2024-08-01 00:00:00	19	313	50	65000	26500
642	2024-08-01 00:00:00	22	313	50	85000	37440
674	2024-08-12 04:30:39.211055	25	312	50	155000	52600
677	2024-08-12 04:30:39.211055	30	357	50	75000	25000
681	2024-08-12 11:58:22.275274	19	357	10	65000	26500
682	2024-08-12 11:58:22.275274	12	357	20	72000	37500
684	2024-08-12 11:58:22.275274	24	357	20	72000	33280
689	2024-08-12 12:24:15.793668	19	373	25	65000	26500
691	2024-08-12 12:24:15.793668	12	375	25	72000	37500
1395	2024-09-01 00:00:00	13	669	15	85000	42500
794	2024-08-13 02:35:16.519513	31	391	20	450000	180000
636	2024-08-01 00:00:00	12	309	100	72000	37500
805	2024-08-13 02:35:16.519513	31	417	25	450000	180000
806	2024-08-13 02:35:16.519513	31	419	25	450000	180000
809	2024-08-13 02:35:16.519513	12	426	20	72000	37500
1406	2024-08-01 00:00:00	23	478	1	49500	21570
825	2024-08-13 02:35:16.519513	31	440	20	450000	180000
946	2024-08-14 11:51:29.134583	25	531	50	155000	52600
826	2024-08-13 02:35:16.519513	31	441	20	450000	180000
835	2024-08-13 02:35:16.519513	30	440	50	75000	25000
838	2024-08-13 02:35:16.519513	4	440	100	82000	37500
852	2024-08-13 02:35:16.519513	27	382	10	190000	94500
862	2024-08-13 02:35:16.519513	24	453	10	72000	33280
869	2024-08-13 02:35:16.519513	4	455	50	82000	37500
879	2024-08-13 10:07:30.070825	27	459	20	190000	94500
885	2024-08-13 10:07:30.070825	31	470	50	450000	180000
904	2024-08-13 12:09:01.311777	31	481	50	450000	180000
909	2024-08-13 12:09:01.311777	25	481	100	155000	52600
910	2024-08-13 12:09:01.311777	25	480	100	155000	52600
913	2024-08-13 12:09:01.311777	12	477	100	72000	37500
915	2024-08-13 12:09:01.311777	12	478	50	72000	37500
1420	2024-09-01 00:00:00	33	664	20	300000	150000
1428	2024-10-01 00:00:00	25	590	75	155000	52600
947	2024-08-15 11:23:50.50085	22	311	30	85000	37440
1435	2024-10-01 00:00:00	24	593	30	72000	33280
961	2024-08-15 11:23:50.50085	12	300	20	72000	37500
1440	2024-10-01 00:00:00	31	312	10	325000	165000
1455	2024-10-01 00:00:00	25	304	250	155000	52600
637	2024-08-01 00:00:00	12	310	70	72000	37500
975	2024-08-15 11:23:50.50085	33	312	50	300000	220000
985	2024-08-15 11:23:50.50085	28	480	20	85000	37750
993	2024-08-21 07:39:51.726568	27	591	10	190000	94500
1002	2024-08-22 11:35:58.378749	13	596	20	85000	42500
523	2024-08-04 13:03:10.900793	31	80	20	450000	180000
527	2024-08-04 13:03:10.900793	33	80	20	300000	220000
643	2024-08-01 00:00:00	13	314	100	85000	42500
644	2024-08-01 00:00:00	27	314	50	190000	94500
683	2024-08-12 11:58:22.275274	18	357	20	47500	18950
690	2024-08-12 12:24:15.793668	13	375	50	85000	42500
693	2024-08-12 12:24:15.793668	13	376	25	85000	42500
695	2024-08-12 12:24:15.793668	13	344	25	85000	42500
752	2024-08-13 02:35:16.519513	24	301	100	72000	33280
1485	2024-10-01 00:00:00	25	691	100	155000	52600
1488	2024-10-01 00:00:00	31	692	150	325000	165000
1503	2024-10-01 00:00:00	13	302	100	85000	42500
1504	2024-10-01 00:00:00	13	300	100	85000	42500
770	2024-08-13 02:35:16.519513	25	409	400	155000	52600
773	2024-08-13 02:35:16.519513	31	410	10	450000	180000
778	2024-08-13 02:35:16.519513	30	384	50	75000	25000
783	2024-08-13 02:35:16.519513	4	410	50	82000	37500
784	2024-08-13 02:35:16.519513	4	411	50	82000	37500
798	2024-08-13 02:35:16.519513	33	411	20	300000	220000
813	2024-08-13 02:35:16.519513	4	424	50	82000	37500
814	2024-08-13 02:35:16.519513	4	422	50	82000	37500
827	2024-08-13 02:35:16.519513	31	445	20	450000	180000
830	2024-08-13 02:35:16.519513	30	448	100	75000	25000
837	2024-08-13 02:35:16.519513	25	448	250	155000	52600
847	2024-08-13 02:35:16.519513	26	448	50	118000	62000
745	2024-08-13 02:35:16.519513	25	388	40	155000	52600
1000	2024-08-22 05:40:04.678233	33	594	61	300000	220000
848	2024-08-13 02:35:16.519513	27	450	50	190000	94500
850	2024-08-13 02:35:16.519513	33	445	50	300000	220000
851	2024-08-13 02:35:16.519513	33	443	50	300000	220000
871	2024-08-13 02:35:16.519513	4	299	50	82000	37500
881	2024-08-13 10:07:30.070825	27	456	25	190000	94500
884	2024-08-13 10:07:30.070825	28	461	500	85000	37750
905	2024-08-13 12:09:01.311777	30	477	100	75000	25000
917	2024-08-13 12:09:01.311777	13	477	100	85000	42500
925	2024-08-13 12:09:01.311777	33	476	50	300000	220000
929	2024-08-13 12:09:01.311777	29	476	50	85000	39750
930	2024-08-13 12:09:01.311777	24	478	150	72000	33280
1349	2024-09-01 00:00:00	25	654	20	155000	52600
941	2024-08-14 11:51:29.134583	5	516	34	152600	70000
948	2024-08-15 11:23:50.50085	19	311	30	65000	26500
1407	2024-08-01 00:00:00	28	644	100	85000	37750
977	2024-08-15 11:23:50.50085	31	491	30	450000	180000
986	2024-08-15 11:23:50.50085	13	384	30	85000	42500
994	2024-08-21 07:39:51.726568	12	591	20	72000	37500
647	2024-08-01 00:00:00	12	318	100	72000	37500
648	2024-08-01 00:00:00	13	318	100	85000	42500
1368	2024-09-01 00:00:00	5	303	134	152600	70000
940	2024-08-13 12:09:01.311777	25	474	100	155000	52600
1080	2024-09-01 00:00:00	25	590	30	155000	52600
1379	2024-09-01 00:00:00	27	667	100	190000	94500
1360	2024-09-01 00:00:00	30	659	20	75000	25000
1388	2024-09-01 00:00:00	13	643	10	85000	42500
1397	2024-09-01 00:00:00	25	673	50	155000	52600
676	2024-08-12 04:30:39.211055	25	357	20	155000	52600
685	2024-08-12 11:58:22.275274	10	357	10	130000	62000
1421	2024-09-01 00:00:00	25	486	50	155000	52600
1431	2024-10-01 00:00:00	12	351	50	72000	37500
1436	2024-10-01 00:00:00	24	684	30	72000	33280
1438	2024-10-01 00:00:00	19	685	100	65000	26500
746	2024-08-13 02:35:16.519513	13	390	50	85000	42500
645	2024-08-01 00:00:00	25	317	400	155000	52600
1464	2024-10-01 00:00:00	29	306	88	85000	39750
775	2024-08-13 02:35:16.519513	31	412	10	450000	180000
777	2024-08-13 02:35:16.519513	31	384	10	450000	180000
786	2024-08-13 02:35:16.519513	4	413	50	82000	37500
797	2024-08-13 02:35:16.519513	27	407	25	190000	94500
800	2024-08-13 02:35:16.519513	4	416	10	82000	37500
801	2024-08-13 02:35:16.519513	31	416	5	450000	180000
816	2024-08-13 02:35:16.519513	4	415	50	82000	37500
828	2024-08-13 02:35:16.519513	31	447	20	450000	180000
831	2024-08-13 02:35:16.519513	30	447	100	75000	25000
675	2024-08-12 04:30:39.211055	25	311	80	155000	52600
841	2024-08-13 02:35:16.519513	12	447	100	72000	37500
843	2024-08-13 02:35:16.519513	13	441	50	85000	42500
859	2024-08-13 02:35:16.519513	4	380	30	82000	37500
874	2024-08-13 10:07:30.070825	30	459	50	75000	25000
882	2024-08-13 10:07:30.070825	27	455	25	190000	94500
888	2024-08-13 10:07:30.070825	30	468	100	75000	25000
900	2024-08-13 10:07:30.070825	22	471	100	85000	37440
906	2024-08-13 12:09:01.311777	30	481	100	75000	25000
912	2024-08-13 12:09:01.311777	10	481	20	130000	62000
919	2024-08-13 12:09:01.311777	13	478	50	85000	42500
926	2024-08-13 12:09:01.311777	19	477	100	65000	26500
927	2024-08-13 12:09:01.311777	22	480	50	85000	37440
936	2024-08-13 12:09:01.311777	12	313	46	72000	37500
942	2024-08-14 11:51:29.134583	24	80	50	72000	33280
971	2024-08-15 11:23:50.50085	19	405	40	65000	26500
980	2024-08-15 11:23:50.50085	12	482	100	72000	37500
987	2024-08-21 07:39:51.726568	24	588	10	72000	33280
996	2024-08-22 05:40:04.678233	24	593	20	72000	33280
998	2024-08-22 05:40:04.678233	13	593	20	85000	42500
1003	2024-08-23 04:46:18.263785	31	597	10	450000	180000
1075	2024-09-01 00:00:00	31	618	50	325000	165000
1005	2024-08-23 04:46:18.263785	13	597	50	85000	42500
1006	2024-08-23 04:46:18.263785	25	598	60	155000	52600
1007	2024-08-23 10:32:41.502373	11	344	30	173000	75000
1008	2024-08-23 10:32:41.502373	25	472	100	155000	52600
1009	2024-08-23 11:35:41.158042	13	599	100	85000	42500
1010	2024-08-24 09:55:36.497626	28	600	50	85000	37750
1011	2024-08-24 09:55:36.497626	25	601	50	155000	52600
1012	2024-08-24 09:55:36.497626	13	601	30	85000	42500
1013	2024-08-24 09:55:36.497626	27	601	20	190000	94500
1014	2024-08-26 05:57:51.336028	25	590	50	155000	52600
1076	2024-09-01 00:00:00	13	618	50	85000	42500
1015	2024-08-26 05:57:51.336028	24	602	10	72000	33280
1016	2024-08-26 05:57:51.336028	13	378	30	85000	42500
1017	2024-08-26 05:57:51.336028	24	606	20	72000	33280
1018	2024-08-26 05:57:51.336028	25	607	50	155000	52600
1077	2024-09-01 00:00:00	12	619	50	72000	37500
1022	2024-08-26 05:57:51.336028	4	608	10	82000	37500
1078	2024-09-01 00:00:00	13	619	50	85000	42500
1023	2024-08-26 05:57:51.336028	13	609	10	85000	42500
1024	2024-08-26 05:57:51.336028	12	610	10	72000	37500
1025	2024-08-26 05:57:51.336028	12	469	100	72000	37500
1026	2024-08-26 05:57:51.336028	13	469	100	85000	42500
1027	2024-08-26 05:57:51.336028	13	611	50	85000	42500
1028	2024-08-26 05:57:51.336028	13	612	100	85000	42500
1029	2024-08-26 05:57:51.336028	12	342	100	72000	37500
1030	2024-08-26 05:57:51.336028	24	571	10	72000	33280
1031	2024-08-26 05:57:51.336028	25	474	100	155000	52600
1032	2024-08-26 05:57:51.336028	24	370	30	72000	33280
1034	2024-08-26 05:57:51.336028	4	370	20	70000	30000
1033	2024-08-26 05:57:51.336028	30	370	20	75000	25000
1035	2024-08-15 00:00:00	25	80	70	155000	52600
1040	2024-09-01 00:00:00	12	339	50	72000	37500
1041	2024-09-01 00:00:00	25	317	200	155000	52600
1043	2024-09-01 00:00:00	12	362	100	72000	37500
1044	2024-09-01 00:00:00	13	362	100	85000	42500
1045	2024-09-01 00:00:00	27	360	200	190000	94500
1486	2024-10-01 00:00:00	12	360	200	72000	37500
1505	2024-10-01 00:00:00	5	589	100	152600	70000
1510	2024-10-01 00:00:00	31	696	30	325000	165000
1511	2024-10-01 00:00:00	30	697	100	75000	25000
1515	2024-10-01 00:00:00	12	699	60	72000	37500
1516	2024-10-01 00:00:00	13	699	60	85000	42500
1042	2024-09-01 00:00:00	25	361	100	155000	52600
1079	2024-09-01 00:00:00	25	619	50	155000	52600
1081	2024-09-01 00:00:00	25	311	50	155000	52600
1517	2024-10-01 00:00:00	13	698	60	85000	42500
1083	2024-09-01 00:00:00	25	308	20	155000	52600
1529	2024-10-01 00:00:00	33	417	60	300000	150000
1535	2024-10-01 00:00:00	25	607	200	155000	52600
1538	2024-10-01 00:00:00	5	411	70	152600	70000
1540	2024-10-01 00:00:00	11	706	50	173000	75000
646	2024-08-01 00:00:00	31	317	87	450000	180000
1350	2024-09-01 00:00:00	27	601	5	190000	94500
1064	2024-09-01 00:00:00	24	301	5	72000	33280
1125	2024-09-01 00:00:00	13	372	40	85000	42500
1126	2024-09-01 00:00:00	13	388	40	85000	42500
1135	2024-09-01 00:00:00	13	578	40	85000	42500
1361	2024-09-01 00:00:00	13	659	30	85000	42500
1088	2024-09-01 00:00:00	12	593	40	72000	37500
1369	2024-09-01 00:00:00	27	662	75	190000	94500
1092	2024-09-01 00:00:00	19	357	40	65000	26500
1066	2024-09-01 00:00:00	12	376	50	72000	37500
1101	2024-09-01 00:00:00	13	314	20	85000	42500
1068	2024-09-01 00:00:00	25	344	100	155000	52600
1070	2024-09-01 00:00:00	12	344	50	72000	37500
1071	2024-09-01 00:00:00	25	304	300	155000	52600
1072	2024-09-01 00:00:00	25	305	100	155000	52600
1073	2024-09-01 00:00:00	12	303	50	72000	37500
1074	2024-09-01 00:00:00	13	303	50	85000	42500
1086	2024-09-01 00:00:00	12	310	50	72000	37500
1087	2024-09-01 00:00:00	12	313	50	72000	37500
1111	2024-08-01 00:00:00	19	369	16	65000	26500
1090	2024-09-01 00:00:00	24	357	50	72000	33280
1389	2024-09-01 00:00:00	24	588	20	72000	33280
1093	2024-09-01 00:00:00	12	375	50	72000	37500
1094	2024-08-01 00:00:00	13	616	30	85000	42500
1095	2024-08-01 00:00:00	12	621	30	72000	37500
1099	2024-09-01 00:00:00	25	378	100	155000	52600
1100	2024-09-01 00:00:00	12	378	50	72000	37500
1512	2024-10-01 00:00:00	30	629	100	75000	25000
1103	2024-09-01 00:00:00	12	532	50	72000	37500
1104	2024-09-01 00:00:00	25	377	30	155000	52600
1105	2024-08-01 00:00:00	24	409	200	72000	33280
1106	2024-08-01 00:00:00	20	409	200	60000	31200
1380	2024-08-01 00:00:00	11	409	5	173000	75000
1108	2024-09-01 00:00:00	19	311	20	65000	26500
1112	2024-09-01 00:00:00	24	622	50	72000	33280
1113	2024-09-01 00:00:00	24	300	50	72000	33280
1114	2024-09-01 00:00:00	13	599	50	85000	42500
1115	2024-09-01 00:00:00	12	304	50	72000	37500
1116	2024-09-01 00:00:00	13	304	50	85000	42500
1381	2024-08-01 00:00:00	4	409	5	70000	30000
1118	2024-09-01 00:00:00	19	613	30	65000	26500
1119	2024-08-01 00:00:00	25	473	20	155000	52600
1120	2024-09-01 00:00:00	27	340	30	190000	94500
1133	2024-09-01 00:00:00	31	416	40	320000	165000
1123	2024-09-01 00:00:00	19	368	50	65000	26500
1513	2024-10-01 00:00:00	25	626	10	155000	52600
1127	2024-09-01 00:00:00	25	379	70	155000	52600
1129	2024-09-01 00:00:00	13	381	20	85000	42500
1128	2024-09-01 00:00:00	12	390	50	72000	37500
1398	2024-09-01 00:00:00	13	676	20	85000	42500
1131	2024-09-01 00:00:00	33	532	30	300000	150000
1134	2024-09-01 00:00:00	18	578	50	47500	18950
1136	2024-09-01 00:00:00	25	426	50	155000	52600
1139	2024-09-01 00:00:00	25	420	50	155000	52600
1140	2024-09-01 00:00:00	27	577	70	190000	94500
1062	2024-09-01 00:00:00	12	302	40	72000	37500
1410	2024-08-01 00:00:00	8	474	28	155000	52600
1168	2024-09-01 00:00:00	13	476	100	85000	42500
1422	2024-09-01 00:00:00	25	485	71	155000	52600
1433	2024-10-01 00:00:00	12	313	50	72000	37500
1434	2024-10-01 00:00:00	13	473	100	85000	42500
1437	2024-10-01 00:00:00	33	312	30	300000	150000
1171	2024-09-01 00:00:00	33	476	50	300000	150000
1441	2024-10-01 00:00:00	30	357	50	75000	25000
1146	2024-09-01 00:00:00	31	488	50	320000	165000
1147	2024-09-01 00:00:00	25	384	100	155000	52600
1148	2024-09-01 00:00:00	25	517	100	155000	52600
1149	2024-09-01 00:00:00	30	607	100	75000	25000
1150	2024-09-01 00:00:00	25	411	100	155000	52600
1151	2024-09-01 00:00:00	4	516	50	68992	30000
1152	2024-09-01 00:00:00	12	517	200	72000	37500
1153	2024-09-01 00:00:00	13	497	100	85000	42500
1154	2024-09-01 00:00:00	27	518	20	190000	94500
1467	2024-10-01 00:00:00	12	306	400	72000	37500
1157	2024-09-01 00:00:00	19	607	30	65000	26500
1487	2024-10-01 00:00:00	13	691	150	85000	42500
1159	2024-09-01 00:00:00	25	477	200	155000	52600
1160	2024-09-01 00:00:00	28	480	200	85000	37750
1162	2024-09-01 00:00:00	19	477	100	65000	26500
1164	2024-09-01 00:00:00	24	478	200	72000	33280
1166	2024-09-01 00:00:00	13	477	100	85000	42500
1508	2024-10-01 00:00:00	31	695	50	325000	165000
1522	2024-10-01 00:00:00	30	702	50	75000	25000
1531	2024-10-01 00:00:00	20	417	50	60000	31200
1176	2024-09-01 00:00:00	30	418	100	75000	25000
1178	2024-09-01 00:00:00	12	423	50	72000	37500
1179	2024-09-01 00:00:00	13	594	100	85000	42500
1180	2024-09-01 00:00:00	27	594	40	190000	94500
1183	2024-09-01 00:00:00	21	418	50	55000	22340
1181	2024-09-01 00:00:00	18	415	50	47500	18950
1175	2024-09-01 00:00:00	31	417	30	320000	165000
1177	2024-09-01 00:00:00	25	425	120	155000	52600
1065	2024-09-01 00:00:00	25	376	50	155000	52600
1182	2024-09-01 00:00:00	33	423	50	300000	150000
1184	2024-09-01 00:00:00	22	422	50	85000	37440
1069	2024-09-01 00:00:00	11	344	100	173000	75000
1061	2024-09-01 00:00:00	25	531	100	155000	52600
1121	2024-09-01 00:00:00	25	473	20	155000	52600
1138	2024-09-01 00:00:00	18	367	150	47500	18950
1532	2024-10-01 00:00:00	31	413	25	325000	165000
1084	2024-09-01 00:00:00	25	312	20	155000	52600
1539	2024-10-01 00:00:00	5	413	60	152600	70000
1165	2024-09-01 00:00:00	12	481	100	72000	37500
1542	2024-10-01 00:00:00	12	707	50	72000	37500
1549	2024-10-01 00:00:00	33	704	20	300000	150000
1085	2024-09-01 00:00:00	12	309	50	72000	37500
1555	2024-10-01 00:00:00	12	610	250	72000	37500
1560	2024-10-01 00:00:00	4	712	100	70000	30000
1163	2024-09-01 00:00:00	30	481	50	75000	25000
1161	2024-09-01 00:00:00	4	476	200	68992	30000
1563	2024-10-01 00:00:00	13	676	100	85000	42500
1567	2024-10-01 00:00:00	13	611	500	85000	42500
1571	2024-10-01 00:00:00	4	441	50	70000	30000
1587	2024-10-01 00:00:00	31	597	100	325000	165000
1595	2024-10-01 00:00:00	12	466	100	72000	37500
1063	2024-09-01 00:00:00	13	302	100	85000	42500
1132	2024-09-01 00:00:00	33	416	50	300000	150000
1616	2024-10-01 00:00:00	24	478	100	72000	33280
1186	2024-09-01 00:00:00	25	609	100	155000	52600
1362	2024-09-01 00:00:00	12	357	10	72000	37500
1370	2024-09-01 00:00:00	19	655	10	65000	26500
1382	2024-09-01 00:00:00	31	420	10	325000	165000
1390	2024-09-01 00:00:00	12	588	20	72000	37500
1185	2024-09-01 00:00:00	25	608	70	155000	52600
1189	2024-09-01 00:00:00	13	610	90	85000	42500
1399	2024-09-01 00:00:00	12	591	16	72000	37500
1400	2024-09-01 00:00:00	12	684	50	72000	37500
1411	2024-08-01 00:00:00	19	522	5	65000	26500
1351	2024-09-01 00:00:00	25	472	250	155000	52600
1423	2024-09-01 00:00:00	25	675	20	155000	52600
1442	2024-10-01 00:00:00	31	409	50	325000	165000
1444	2024-10-01 00:00:00	20	409	300	60000	31200
1447	2024-10-01 00:00:00	18	379	100	47500	18950
1466	2024-10-01 00:00:00	5	306	200	152600	70000
1469	2024-10-01 00:00:00	19	306	300	65000	26500
1470	2024-10-01 00:00:00	18	306	88	47500	18950
1472	2024-10-01 00:00:00	28	461	400	85000	37750
1474	2024-10-01 00:00:00	24	649	100	72000	33280
1475	2024-10-01 00:00:00	4	687	1000	70000	30000
1477	2024-10-01 00:00:00	13	688	150	85000	42500
1457	2024-10-01 00:00:00	25	361	100	155000	52600
1489	2024-10-01 00:00:00	5	378	50	152600	70000
1509	2024-10-01 00:00:00	31	628	20	325000	165000
1524	2024-10-01 00:00:00	25	703	100	155000	52600
1533	2024-10-01 00:00:00	30	704	50	75000	25000
1536	2024-10-01 00:00:00	25	384	100	155000	52600
1449	2024-10-01 00:00:00	25	453	25	155000	52600
1545	2024-10-01 00:00:00	13	518	100	85000	42500
1548	2024-10-01 00:00:00	27	708	20	190000	94500
1550	2024-10-01 00:00:00	25	610	200	155000	52600
1551	2024-10-01 00:00:00	25	669	100	155000	52600
1552	2024-10-01 00:00:00	5	608	150	152600	70000
1556	2024-10-01 00:00:00	13	608	200	85000	42500
1557	2024-10-01 00:00:00	13	669	200	85000	42500
1572	2024-10-01 00:00:00	25	474	200	155000	52600
1575	2024-10-01 00:00:00	5	474	100	152600	70000
1578	2024-10-01 00:00:00	12	474	300	72000	37500
1583	2024-10-01 00:00:00	19	485	50	65000	26500
1586	2024-10-01 00:00:00	24	490	100	72000	33280
1589	2024-10-01 00:00:00	25	466	300	155000	52600
1591	2024-10-01 00:00:00	25	467	100	155000	52600
1596	2024-10-01 00:00:00	13	469	100	85000	42500
1599	2024-10-01 00:00:00	22	468	100	85000	37440
1607	2024-10-01 00:00:00	12	480	50	72000	37500
1610	2024-10-01 00:00:00	13	476	50	85000	42500
1613	2024-10-01 00:00:00	19	480	50	65000	26500
1622	2024-10-01 00:00:00	12	342	100	72000	37500
1633	2024-10-01 00:00:00	26	378	10	118000	62000
1190	2024-09-01 00:00:00	13	616	150	85000	42500
1187	2024-09-01 00:00:00	12	617	100	72000	37500
1352	2024-09-01 00:00:00	25	409	300	155000	52600
1353	2024-09-01 00:00:00	18	409	200	47500	18950
1356	2024-09-01 00:00:00	33	409	50	300000	150000
1363	2024-09-01 00:00:00	30	357	10	75000	25000
1371	2024-08-01 00:00:00	20	317	3	60000	31200
1383	2024-09-01 00:00:00	30	420	10	75000	25000
1391	2024-09-01 00:00:00	11	652	60	173000	75000
1401	2024-09-01 00:00:00	24	684	20	72000	33280
1402	2024-09-01 00:00:00	25	589	60	155000	52600
1412	2024-09-01 00:00:00	37	362	20	450000	165000
1413	2024-08-01 00:00:00	11	412	30	173000	75000
1414	2024-08-01 00:00:00	10	384	10	130000	62000
1424	2024-09-01 00:00:00	12	674	10	72000	37500
1443	2024-10-01 00:00:00	12	409	500	72000	37500
1445	2024-10-01 00:00:00	25	409	500	155000	52600
1451	2024-10-01 00:00:00	25	303	250	155000	52600
1463	2024-10-01 00:00:00	25	307	200	155000	52600
1465	2024-10-01 00:00:00	22	306	88	85000	37440
1468	2024-10-01 00:00:00	13	306	400	85000	42500
1473	2024-10-01 00:00:00	25	531	100	155000	52600
1476	2024-10-01 00:00:00	30	686	1500	75000	25000
1483	2024-10-01 00:00:00	20	690	100	60000	31200
1484	2024-10-01 00:00:00	24	690	100	72000	33280
1490	2024-10-01 00:00:00	28	314	50	85000	37750
1499	2024-10-01 00:00:00	20	693	50	60000	31200
1501	2024-10-01 00:00:00	12	300	100	72000	37500
1507	2024-10-01 00:00:00	5	593	100	152600	70000
1514	2024-10-01 00:00:00	12	698	60	72000	37500
1520	2024-10-01 00:00:00	21	701	100	55000	22340
1534	2024-10-01 00:00:00	30	705	50	75000	25000
1543	2024-10-01 00:00:00	12	706	50	72000	37500
1544	2024-10-01 00:00:00	25	377	25	155000	52600
1553	2024-10-01 00:00:00	5	709	50	152600	70000
1559	2024-10-01 00:00:00	25	711	300	155000	52600
1561	2024-10-01 00:00:00	12	676	100	72000	37500
1566	2024-10-01 00:00:00	13	612	500	85000	42500
1568	2024-10-01 00:00:00	27	451	150	190000	94500
1570	2024-10-01 00:00:00	4	440	50	70000	30000
1574	2024-10-01 00:00:00	4	491	50	70000	30000
1577	2024-10-01 00:00:00	12	486	100	72000	37500
1579	2024-10-01 00:00:00	13	485	20	85000	42500
1582	2024-10-01 00:00:00	28	514	60	85000	37750
1584	2024-10-01 00:00:00	19	486	50	65000	26500
1588	2024-10-01 00:00:00	30	467	100	75000	25000
1592	2024-10-01 00:00:00	25	472	100	155000	52600
1603	2024-10-01 00:00:00	30	481	100	75000	25000
1604	2024-10-01 00:00:00	25	583	200	155000	52600
1606	2024-10-01 00:00:00	5	481	200	152600	70000
1609	2024-10-01 00:00:00	13	480	100	85000	42500
1611	2024-10-01 00:00:00	13	477	50	85000	42500
1614	2024-10-01 00:00:00	21	477	50	55000	22340
1617	2024-10-01 00:00:00	24	479	100	72000	33280
1620	2024-10-01 00:00:00	5	458	50	152600	70000
1624	2024-10-01 00:00:00	18	456	50	47500	18950
1627	2024-10-01 00:00:00	24	457	140	72000	33280
1628	2024-10-01 00:00:00	25	713	50	155000	52600
1629	2024-10-01 00:00:00	20	714	50	60000	31200
1630	2024-10-01 00:00:00	21	715	20	55000	22340
1631	2024-10-01 00:00:00	5	603	200	152600	70000
1188	2024-09-01 00:00:00	12	621	150	72000	37500
1191	2024-09-01 00:00:00	27	616	20	190000	94500
1415	2024-08-01 00:00:00	10	322	5	130000	62000
1193	2024-09-01 00:00:00	22	609	50	85000	37440
1354	2024-09-01 00:00:00	12	409	100	72000	37500
1195	2024-09-01 00:00:00	24	620	100	72000	33280
1304	2024-09-01 00:00:00	24	649	90	72000	33280
1199	2024-09-01 00:00:00	13	612	200	85000	42500
1200	2024-09-01 00:00:00	27	450	50	190000	94500
1201	2024-09-01 00:00:00	27	451	50	190000	94500
1206	2024-09-01 00:00:00	22	447	50	85000	37440
1364	2024-09-01 00:00:00	11	426	20	173000	75000
1212	2024-09-01 00:00:00	25	601	150	155000	52600
1214	2024-09-01 00:00:00	31	470	100	320000	165000
1215	2024-09-01 00:00:00	31	469	100	320000	165000
1418	2024-08-01 00:00:00	14	603	5	175000	89500
1372	2024-09-01 00:00:00	13	663	10	85000	42500
1222	2024-09-01 00:00:00	28	598	100	85000	37750
1384	2024-09-01 00:00:00	27	656	110	190000	94500
1224	2024-09-01 00:00:00	22	466	100	85000	37440
1225	2024-09-01 00:00:00	24	467	100	72000	33280
1226	2024-09-01 00:00:00	13	472	150	85000	42500
1227	2024-09-01 00:00:00	13	598	150	85000	42500
1229	2024-09-01 00:00:00	30	485	50	75000	25000
1230	2024-09-01 00:00:00	25	474	100	155000	52600
1231	2024-09-01 00:00:00	25	80	100	155000	52600
1392	2024-09-01 00:00:00	12	616	50	72000	37500
1209	2024-09-01 00:00:00	12	600	200	72000	37500
1239	2024-09-01 00:00:00	33	486	50	300000	150000
1240	2024-09-01 00:00:00	19	474	50	65000	26500
1241	2024-09-01 00:00:00	19	80	50	65000	26500
1210	2024-09-01 00:00:00	13	600	200	85000	42500
1478	2024-10-01 00:00:00	18	689	100	47500	18950
1403	2024-08-01 00:00:00	18	477	60	47500	18950
1419	2024-08-01 00:00:00	25	603	200	155000	52600
1247	2024-09-01 00:00:00	4	491	50	68992	30000
1248	2024-09-01 00:00:00	25	459	50	155000	52600
1249	2024-09-01 00:00:00	25	520	50	155000	52600
1250	2024-09-01 00:00:00	4	554	25	68992	30000
1251	2024-09-01 00:00:00	4	458	25	68992	30000
1254	2024-09-01 00:00:00	13	522	100	85000	42500
1255	2024-09-01 00:00:00	13	520	100	85000	42500
1258	2024-09-01 00:00:00	19	606	30	65000	26500
1259	2024-09-01 00:00:00	19	602	30	65000	26500
1260	2024-09-01 00:00:00	21	554	25	55000	22340
1261	2024-09-01 00:00:00	21	458	25	55000	22340
1425	2024-09-01 00:00:00	13	674	30	85000	42500
1213	2024-09-01 00:00:00	25	600	100	155000	52600
1446	2024-10-01 00:00:00	22	409	50	85000	37440
1267	2024-09-01 00:00:00	30	322	150	75000	25000
1268	2024-09-01 00:00:00	30	570	150	75000	25000
1458	2024-10-01 00:00:00	25	317	200	155000	52600
1271	2024-09-01 00:00:00	4	604	50	68992	30000
1273	2024-09-01 00:00:00	33	570	50	300000	150000
1274	2024-09-01 00:00:00	21	604	100	55000	22340
1281	2024-09-01 00:00:00	13	322	100	85000	42500
1471	2024-10-01 00:00:00	24	306	300	72000	33280
1482	2024-10-01 00:00:00	33	664	75	300000	150000
1491	2024-10-01 00:00:00	18	300	80	47500	18950
1493	2024-10-01 00:00:00	5	301	100	152600	70000
1196	2024-09-01 00:00:00	12	447	100	72000	37500
1292	2024-09-01 00:00:00	12	638	20	72000	37500
1293	2024-09-01 00:00:00	24	638	20	72000	33280
1495	2024-10-01 00:00:00	5	302	30	152600	70000
1295	2024-09-01 00:00:00	12	639	100	72000	37500
1296	2024-09-01 00:00:00	13	640	100	85000	42500
1294	2024-09-01 00:00:00	24	299	50	72000	33280
1299	2024-09-01 00:00:00	25	613	50	155000	52600
1300	2024-09-01 00:00:00	31	643	5	325000	165000
1496	2024-10-01 00:00:00	24	648	200	72000	33280
1301	2024-09-01 00:00:00	12	643	10	72000	37500
1302	2024-09-01 00:00:00	24	457	20	72000	33280
1498	2024-10-01 00:00:00	27	651	20	190000	94500
1497	2024-10-01 00:00:00	27	650	20	190000	94500
1500	2024-10-01 00:00:00	20	694	50	60000	31200
1506	2024-10-01 00:00:00	5	473	100	152600	70000
1269	2024-09-01 00:00:00	25	603	60	155000	52600
1282	2024-09-01 00:00:00	12	603	150	72000	37500
1280	2024-09-01 00:00:00	12	604	150	72000	37500
1272	2024-09-01 00:00:00	14	603	30	175000	89500
1277	2024-09-01 00:00:00	18	322	25	47500	18950
1275	2024-09-01 00:00:00	18	570	25	47500	18950
1278	2024-09-01 00:00:00	18	603	25	47500	18950
1276	2024-09-01 00:00:00	18	604	25	47500	18950
1286	2024-09-01 00:00:00	30	635	150	75000	25000
1518	2024-10-01 00:00:00	33	603	100	300000	150000
1521	2024-10-01 00:00:00	31	417	50	325000	165000
1285	2024-09-01 00:00:00	31	636	50	325000	165000
1289	2024-09-01 00:00:00	30	637	150	75000	25000
1198	2024-09-01 00:00:00	13	611	200	85000	42500
1202	2024-09-01 00:00:00	18	440	25	47500	18950
1203	2024-09-01 00:00:00	18	441	25	47500	18950
1204	2024-09-01 00:00:00	18	443	25	47500	18950
1205	2024-09-01 00:00:00	18	445	25	47500	18950
1306	2024-09-01 00:00:00	12	351	50	72000	37500
1307	2024-09-01 00:00:00	12	590	50	72000	37500
1252	2024-09-01 00:00:00	12	509	80	72000	37500
1523	2024-10-01 00:00:00	25	415	80	155000	52600
1208	2024-09-01 00:00:00	12	601	250	72000	37500
1525	2024-10-01 00:00:00	11	419	80	173000	75000
1211	2024-09-01 00:00:00	13	601	200	85000	42500
1256	2024-09-01 00:00:00	18	508	50	47500	18950
1257	2024-09-01 00:00:00	18	571	50	47500	18950
1264	2024-09-01 00:00:00	24	602	80	72000	33280
1228	2024-09-01 00:00:00	31	491	20	320000	165000
1233	2024-09-01 00:00:00	12	474	100	72000	37500
1232	2024-09-01 00:00:00	12	482	100	72000	37500
1235	2024-09-01 00:00:00	12	485	100	72000	37500
1234	2024-09-01 00:00:00	12	483	100	72000	37500
1236	2024-09-01 00:00:00	13	80	50	85000	42500
1218	2024-09-01 00:00:00	4	470	300	68992	30000
1246	2024-09-01 00:00:00	24	487	100	72000	33280
1216	2024-09-01 00:00:00	25	468	150	155000	52600
1253	2024-09-01 00:00:00	12	342	90	72000	37500
1290	2024-09-01 00:00:00	33	637	100	300000	150000
1305	2024-09-01 00:00:00	24	648	100	72000	33280
1355	2024-09-01 00:00:00	13	409	100	85000	42500
1308	2024-09-01 00:00:00	25	450	50	155000	52600
1309	2024-09-01 00:00:00	27	651	10	190000	94500
1310	2024-09-01 00:00:00	27	650	10	190000	94500
1365	2024-09-01 00:00:00	25	626	10	155000	52600
1270	2024-09-01 00:00:00	25	322	60	155000	52600
1311	2024-09-01 00:00:00	25	635	150	155000	52600
1312	2024-09-01 00:00:00	25	637	150	155000	52600
1315	2024-08-01 00:00:00	28	652	10	85000	37750
1314	2024-09-01 00:00:00	27	473	45	190000	94500
1317	2024-09-01 00:00:00	27	591	45	190000	94500
1318	2024-09-01 00:00:00	18	532	50	47500	18950
1319	2024-09-01 00:00:00	18	314	50	47500	18950
1320	2024-09-01 00:00:00	33	312	30	300000	150000
1321	2024-08-01 00:00:00	30	369	15	75000	25000
1322	2024-09-01 00:00:00	5	306	100	152600	70000
1323	2024-09-01 00:00:00	22	306	100	85000	37440
1324	2024-09-01 00:00:00	18	306	88	47500	18950
1325	2024-09-01 00:00:00	21	306	100	55000	22340
1326	2024-09-01 00:00:00	12	306	200	72000	37500
1327	2024-09-01 00:00:00	13	306	200	85000	42500
1328	2024-09-01 00:00:00	24	306	300	72000	33280
1329	2024-09-01 00:00:00	28	600	100	85000	37750
1330	2024-09-01 00:00:00	13	632	50	85000	42500
1331	2024-09-01 00:00:00	30	306	500	75000	25000
1332	2024-09-01 00:00:00	29	583	50	85000	39750
1333	2024-09-01 00:00:00	18	300	100	47500	18950
1334	2024-09-01 00:00:00	21	300	100	55000	22340
1336	2024-09-01 00:00:00	18	653	50	47500	18950
1337	2024-09-01 00:00:00	22	468	100	85000	37440
1339	2024-09-01 00:00:00	18	632	50	47500	18950
1340	2024-09-01 00:00:00	22	601	50	85000	37440
1373	2024-09-01 00:00:00	27	663	10	190000	94500
1385	2024-09-01 00:00:00	25	369	10	155000	52600
1341	2024-08-01 00:00:00	5	384	30	152600	70000
1393	2024-09-01 00:00:00	25	616	30	155000	52600
1404	2024-08-01 00:00:00	11	481	40	173000	75000
1408	2024-08-01 00:00:00	10	466	10	130000	62000
1416	2024-08-01 00:00:00	12	322	50	72000	37500
1426	2024-10-01 00:00:00	25	308	75	155000	52600
1432	2024-10-01 00:00:00	12	591	50	72000	37500
1316	2024-08-01 00:00:00	24	652	7	72000	33280
1343	2024-08-01 00:00:00	27	652	6	190000	94500
1439	2024-10-01 00:00:00	22	311	50	85000	37440
1448	2024-10-01 00:00:00	25	383	50	155000	52600
1346	2024-08-01 00:00:00	24	649	10	72000	33280
1452	2024-10-01 00:00:00	5	303	100	152600	70000
1345	2024-08-01 00:00:00	24	648	100	72000	33280
1344	2024-08-01 00:00:00	19	302	30	65000	26500
1453	2024-10-01 00:00:00	13	303	50	85000	42500
1454	2024-10-01 00:00:00	12	303	50	72000	37500
1479	2024-10-01 00:00:00	13	378	200	85000	42500
1492	2024-10-01 00:00:00	19	302	50	65000	26500
1494	2024-10-01 00:00:00	5	531	100	152600	70000
1429	2024-10-01 00:00:00	25	654	65	155000	52600
1519	2024-10-01 00:00:00	20	700	50	60000	31200
1537	2024-10-01 00:00:00	4	706	50	70000	30000
1541	2024-10-01 00:00:00	12	704	100	72000	37500
1546	2024-10-01 00:00:00	13	706	50	85000	42500
1547	2024-10-01 00:00:00	13	407	50	85000	42500
1554	2024-10-01 00:00:00	12	710	100	72000	37500
1558	2024-10-01 00:00:00	30	601	500	75000	25000
1562	2024-10-01 00:00:00	13	630	100	85000	42500
1564	2024-10-01 00:00:00	28	600	200	85000	37750
1565	2024-10-01 00:00:00	33	712	10	300000	150000
1569	2024-10-01 00:00:00	27	450	150	190000	94500
1573	2024-10-01 00:00:00	25	673	100	155000	52600
1576	2024-10-01 00:00:00	12	485	100	72000	37500
1580	2024-10-01 00:00:00	13	486	20	85000	42500
1581	2024-10-01 00:00:00	13	474	60	85000	42500
1585	2024-10-01 00:00:00	19	474	100	65000	26500
1590	2024-10-01 00:00:00	25	598	100	155000	52600
1593	2024-10-01 00:00:00	4	470	300	70000	30000
1594	2024-10-01 00:00:00	12	469	100	72000	37500
1597	2024-10-01 00:00:00	13	597	100	85000	42500
1598	2024-10-01 00:00:00	28	644	200	85000	37750
1600	2024-10-01 00:00:00	22	471	100	85000	37440
1601	2024-10-01 00:00:00	24	469	30	72000	33280
1605	2024-10-01 00:00:00	25	480	200	155000	52600
1608	2024-10-01 00:00:00	12	477	50	72000	37500
1612	2024-10-01 00:00:00	18	477	50	47500	18950
1615	2024-10-01 00:00:00	29	481	100	85000	39750
1618	2024-10-01 00:00:00	30	520	50	75000	25000
1619	2024-10-01 00:00:00	4	458	50	70000	30000
1621	2024-10-01 00:00:00	12	509	100	72000	37500
1623	2024-10-01 00:00:00	13	596	200	85000	42500
1625	2024-10-01 00:00:00	24	299	60	72000	33280
1626	2024-10-01 00:00:00	24	508	100	72000	33280
1632	2024-10-01 00:00:00	11	322	100	173000	75000
\.


--
-- Data for Name: doctor_plan; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.doctor_plan (id, description, theme, date, status, postpone, doctor_id, med_rep_id) FROM stdin;
279	.	креакард	2024-09-10 00:00:00	f	f	531	54
144	врач	крекард арливинэксипар	2024-08-13 09:07:21.385919	f	f	388	82
283	.	.	2024-09-10 13:00:00	f	f	317	85
285	.	.	2024-09-13 00:00:00	f	f	357	60
286	.	.	2024-09-13 00:00:00	f	f	409	86
288	.	.	2024-09-20 17:14:17.895441	f	f	656	116
290	.	фдп	2024-09-26 15:49:18.094627	f	f	426	82
292	Янги закуп	.	2024-06-10 13:00:00	f	f	409	86
294	КРЕАКАРД, ЭКСИПАР 0,4 келишув, эслатма	ташриф	2024-10-17 19:49:33.144851	f	f	409	86
296	Креакард Эксипар 0,4 договор	визит к врачу	2024-10-18 00:00:00	f	f	317	85
298	рабелазол эксипар	ташриф	2024-10-18 00:00:00	f	f	604	90
299	Апрозум эксипар	ташриф	2024-10-18 00:00:00	f	f	628	90
259	назначения	Эксипар 6	2024-08-27 11:47:47.666614	f	f	339	82
261	креакард	креакард	2024-08-27 11:49:33.077025	f	f	314	62
300	винкарел	везит	2024-10-18 00:00:00	f	f	361	85
301	м..	визит	2024-10-19 00:00:00	f	f	318	85
303	г.	визит	2024-10-19 00:00:00	f	f	362	85
305	к	визит	2024-10-18 06:50:57.822338	f	f	692	85
307	Креакард Эксипар 0,8 договор	ташриф	2024-10-18 10:06:35.795833	f	f	482	50
308	Эллеус Идрен договор	ташриф	2024-10-18 10:07:28.303142	f	f	80	50
145	эксипар	эксипар	2024-08-13 10:07:09.356031	f	f	390	82
136	фдп	фдп	2024-08-12 16:27:17.12693	f	f	304	53
137	фарм люкс ва меросда товар йук примой ололмайди	закуп винкорел и эксипар	2024-08-12 17:01:36.082374	f	f	367	82
138	нарх киммат	закуп эксипар и крекард	2024-08-12 17:03:23.21378	f	f	368	82
139	закуп хози килмаяпти беморлар йук	закуп крекард и эксипар	2024-08-12 17:04:32.821825	f	f	372	82
140	врач эксипар 30шт биоплюс аптекадан кетказди	эксипар	2024-08-12 17:08:42.190052	f	f	339	82
141	врач эритропен езвотти	эритропен	2024-08-12 17:09:40.52843	f	f	340	82
310	Диабертион	визит	2024-10-18 10:27:23.825055	f	f	645	49
312	договор	визит	2024-10-18 10:28:14.507103	f	f	597	49
314	50	креакард	2024-10-18 10:59:40.175734	f	f	378	62
316	100	винкорел	2024-10-18 11:00:24.101352	f	f	379	62
317	20	Эритропен	2024-10-18 11:00:40.361053	f	f	380	62
320	50	эксипар 6	2024-10-18 11:02:47.616933	f	f	382	62
321	20	эксипар 6	2024-10-18 11:03:15.175484	f	f	383	62
323	20	Эритропен 10	2024-10-18 11:05:07.237612	f	f	453	62
325	50	эксипар 6	2024-10-18 11:06:00.208367	f	f	663	62
326	100	эллеус	2024-10-18 11:06:22.342969	f	f	663	62
171	эксипар	эксипар винкорел	2024-08-14 15:29:08.323562	f	f	513	82
328	20	Эритропен 10	2024-10-18 11:07:18.921238	f	f	726	62
329	30	эксипар 6	2024-10-18 11:07:37.594107	f	f	726	62
174	..	..	2024-08-05 00:00:00	f	f	514	50
260	.	креакард	2024-08-27 11:48:16.774087	f	f	390	82
331	.	.	2024-10-18 11:07:57.32163	f	f	379	62
333	50	эллеус эксипар неоцинтил	2024-10-18 11:08:32.372069	f	f	690	62
334	60та	гепапротик	2024-10-18 11:09:22.333063	f	f	716	62
335	20	Апрозум	2024-10-18 11:09:49.337444	f	f	717	62
338	30	винкорел	2024-10-18 11:11:28.896711	f	f	728	62
339	Эксипар Креакард	ташриф	2024-10-18 11:55:44.301031	f	f	712	110
340	Эксипар	ташриф	2024-10-18 11:56:29.332377	f	f	601	110
341	Эксипар Креакард	тариф	2024-10-18 11:57:07.791841	f	f	600	110
343	Креакард	ташриф	2024-10-18 12:06:11.147059	f	f	669	114
344	креакард	ташриф	2024-10-18 12:06:34.203612	f	f	608	114
346	Эксипар	ташриф	2024-10-18 12:11:58.473567	f	f	441	43
347	Креакард	договор	2024-10-18 12:12:20.895257	f	f	443	43
348	Эксипар	ташриф	2024-10-18 12:12:35.313188	f	f	445	43
349	Kreakard	tashrif	2024-10-18 12:17:27.031928	f	f	384	40
352	Eksipar 0, 4	tasheif	2024-10-18 12:19:03.717161	f	f	706	40
354	Eritropen	tashrif	2024-10-18 12:24:10.200679	f	f	594	39
355	Eksipar 0,6	tashrif	2024-10-18 12:28:43.133783	f	f	415	39
356	.	tashrif	2024-10-18 12:32:29.012259	f	f	425	39
357	dogovor	tadhrif	2024-10-18 12:45:58.131078	f	f	520	46
358	dogovor Elleus	tashrif	2024-10-18 12:47:38.652368	f	f	457	46
359	Eksipar elleus	tashrif	2024-10-18 12:48:05.47514	f	f	523	46
362	.	.	2024-10-21 10:00:00	f	f	351	60
363	.	.	2024-10-21 10:00:00	f	f	624	86
365	.	.	2024-10-28 10:00:00	f	f	317	85
367	.....	.....	2024-10-18 15:28:19.371305	f	f	306	51
369	......	.....	2024-10-18 15:32:20.201358	f	f	444	51
370	......	рабелазол	2024-10-18 15:32:39.550849	f	f	687	51
373	.	эксипар	2024-10-23 13:02:00	f	f	654	60
375	.	.	2024-10-24 10:00:00	f	f	688	51
377	ост фдп зума 3шт	арлевин фдп зума	2024-10-19 20:21:23.07932	f	f	408	40
280	ygugv	yggg	2024-09-11 23:45:37.397609	f	f	369	80
282	Sudh	Hsh	2024-09-13 14:10:00	f	f	369	80
284	.	.	2024-09-13 00:00:00	f	f	304	53
287	6	эксипар	2024-09-20 12:32:37.344923	f	f	599	82
289	.	фдп 10	2024-09-26 15:38:33.248525	f	f	652	82
291	дог	гепапротек	2024-10-16 00:00:00	f	f	80	50
295	kreakard dogovor	tashrif	2024-10-18 00:00:00	f	f	718	86
297	Креакард Эксипар	тащриф	2024-10-18 00:00:00	f	f	603	90
302	т.	визит	2024-10-19 00:00:00	f	f	360	85
304	ц	визит	2024-10-20 00:00:00	f	f	691	85
262	креакард 30 дона	креакард	2024-08-27 00:00:00	f	f	531	54
255	ФДП	.	2024-08-23 15:29:47.146816	f	f	344	66
256	назначение фдп-5	фдп	2024-08-22 00:00:00	f	f	426	82
257	Эксипар 0,6	Эксипар	2024-08-16 00:00:00	f	f	599	82
258	Эксипар 0,4	Эксипар 0,4	2024-08-16 00:00:00	f	f	426	82
263	эксипар, креакард келишув	визит	2024-09-05 10:12:11.148499	f	f	629	90
264	эксипар, креакард буйича иски закуп келишув	визит	2024-09-05 10:13:44.063214	f	f	628	90
265	Неолайтон буйича келишув	визит	2024-09-05 10:17:46.317031	f	f	422	39
266	Креакард келишув	визит	2024-09-05 10:43:44.602995	f	f	631	110
267	Эксипар 0,4 буйича келишув	визит	2024-09-05 10:44:34.063852	f	f	630	110
268	эксипар 0,4 , 0,6	визит	2024-09-05 10:45:05.863859	f	f	632	110
269	креакард 30 дона	креакард	2024-09-05 13:32:57.621654	f	f	531	54
270	Медиком клиникада терапевт	Креакард, Идрен	2024-09-06 08:20:18.214359	f	f	613	60
271	договор эксипар	визит	2024-09-06 09:43:55.41148	f	f	417	39
272	договор креакард	визит	2024-09-06 09:44:39.652041	f	f	415	39
273	договор гепапротек	визит	2024-09-06 09:45:09.423733	f	f	419	39
274	kelushuv Eksipar, Kreakard	tashrif Xiva ekstrenniy	2024-09-06 09:45:55.874159	f	f	607	40
275	Эллеус	Эллеус	2024-09-06 13:14:45.171922	f	f	648	54
276	Эллеус	Эллеус	2024-09-06 13:15:12.998213	f	f	649	54
306	эксипар	ташриф	2024-10-18 09:04:39.016705	f	f	322	90
309	Креакард Эритропен 0,4 Ондасет	ташриф	2024-10-18 10:07:56.2634	f	f	483	50
311	договор	визит	2024-10-18 10:27:58.018012	f	f	647	49
313	договор	визит	2024-10-18 10:28:39.160228	f	f	644	49
315	30та	креакард	2024-10-18 11:00:02.361035	f	f	377	62
318	20	эритропен 4000	2024-10-18 11:01:22.87188	f	f	381	62
319	20та	Эритропен 10	2024-10-18 11:02:09.810093	f	f	382	62
322	30 та	Эритропен 10	2024-10-18 11:04:49.442841	f	f	383	62
324	100	винкорел	2024-10-18 11:05:35.803197	f	f	727	62
327	50та	гепапротик	2024-10-18 11:06:55.06589	f	f	664	62
330	50	винкорел	2024-10-18 11:07:53.993336	f	f	672	62
332	50	эллеус	2024-10-18 11:08:12.804222	f	f	689	62
336	30	эритропен10 эксипар 6 фдп зума	2024-10-18 11:10:07.274414	f	f	721	62
337	50	Фдп зума	2024-10-18 11:10:48.544453	f	f	724	62
342	Эксипар	ташриф	2024-10-18 12:05:41.094706	f	f	610	114
345	.	ташриф	2024-10-18 12:10:56.561938	f	f	440	43
350	Kreakard	tashrif	2024-10-18 12:17:56.392178	f	f	607	40
351	Eksipar 0,4	tashrif	2024-10-18 12:18:23.115098	f	f	516	40
353	эксипар	.	2024-10-18 00:00:00	f	f	649	54
360	.	.	2024-10-18 13:00:00	f	f	308	60
361	.	.	2024-10-21 09:00:00	f	f	311	60
364	.	.	2024-10-25 13:00:00	f	f	720	85
366	....	арливин	2024-10-18 15:27:27.662038	f	f	686	51
368	.....	крекард	2024-10-18 15:31:55.910086	f	f	307	51
371	......	Диабертон турбо	2024-10-18 15:33:08.557957	f	f	442	51
372	.	.	2024-10-18 15:32:00	f	f	301	54
374	.	.	2024-10-21 10:36:00	f	f	449	51
376	эксипар 0.4	эксипар	2024-10-19 20:20:04.835542	f	f	407	40
378	ост 25 шт	креакард	2024-10-19 20:23:14.488407	f	f	516	40
\.


--
-- Data for Name: doctor_postupleniya_fact; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.doctor_postupleniya_fact (id, fact, price, discount_price, date, doctor_id, product_id, fact_price) FROM stdin;
58	1	65000	26500	2024-08-13 12:09:01.316504	313	19	66976
74	5	300000	220000	2024-08-21 07:39:51.730796	592	33	1545600
75	50	155000	52600	2024-08-21 07:39:51.730796	589	25	7985600
76	10	190000	94500	2024-08-21 07:39:51.730796	591	27	1957760
77	10	175000	89500	2024-08-21 07:39:51.730796	591	14	1803200
78	20	95000	48900	2024-08-21 07:39:51.730796	591	15	1957760
82	1	65000	26500	2024-08-22 05:40:04.682391	370	19	0
30	5	75000	25000	2024-08-12 12:24:15.7984	357	30	399000
31	5	155000	52600	2024-08-12 12:24:15.7984	357	25	824600
32	5	72000	37500	2024-08-12 12:24:15.7984	357	12	383040
35	10	85000	42500	2024-08-13 02:35:16.523855	314	13	904400
36	20	190000	94500	2024-08-13 02:35:16.523855	314	27	4043200
37	21	155000	52600	2024-08-13 02:35:16.523855	361	25	3463320
41	50	152600	70000	2024-08-13 02:35:16.523855	304	5	8118300
42	500	85000	37750	2024-08-13 10:07:30.075593	461	28	45220000
43	30	49500	21570	2024-08-13 12:09:01.316504	303	23	1580040
46	10	75000	33500	2024-08-13 12:09:01.316504	303	7	798000
47	5	130000	62000	2024-08-13 12:09:01.316504	303	10	691600
51	5	65000	26500	2024-08-13 12:09:01.316504	357	19	345800
54	10	47500	18950	2024-08-13 12:09:01.316504	300	18	505400
55	10	72000	37500	2024-08-13 12:09:01.316504	302	12	766080
56	30	155000	52600	2024-08-13 12:09:01.316504	378	25	4947600
57	35	72000	37500	2024-08-13 12:09:01.316504	313	12	2681280
60	20	72000	37500	2024-08-15 11:23:50.505714	300	12	1532160
61	20	85000	42500	2024-08-15 11:23:50.505714	302	13	1808800
38	150	72000	33280	2024-08-13 02:35:16.523855	301	24	11491200
64	64	152600	70000	2024-08-15 11:23:50.505714	516	5	10391424
71	5	85000	42500	2024-08-15 11:23:50.505714	473	13	452200
72	36	155000	52600	2024-08-15 11:23:50.505714	312	25	5937120
73	20	72000	33280	2024-08-15 11:23:50.505714	532	24	1532160
52	25	72000	33280	2024-08-13 12:09:01.316504	357	24	1915200
79	17	72000	37500	2024-08-22 05:40:04.682391	593	12	1302336
80	20	85000	42500	2024-08-22 05:40:04.682391	593	13	1808800
85	30	85000	42500	2024-08-22 11:35:58.38285	384	13	2713200
87	10	72000	37500	2024-08-22 11:35:58.38285	588	12	766080
86	30	72000	33280	2024-08-22 11:35:58.38285	588	24	2298240
91	30	72000	37500	2024-08-22 11:35:58.38285	342	12	2298240
92	20	85000	42500	2024-08-22 11:35:58.38285	596	13	1808800
93	22	72000	37500	2024-08-22 11:35:58.38285	343	12	1774080
94	23	85000	42500	2024-08-22 11:35:58.38285	343	13	2189600
95	10	72000	33280	2024-08-22 11:35:58.38285	571	24	766080
63	50	72000	33280	2024-08-13 00:00:00	508	24	0
29	70	155000	52600	2024-08-08 10:41:00.536656	80	25	11544400
66	70	65000	26500	2024-08-15 11:23:50.505714	485	19	4841200
97	15	450000	180000	2024-08-23 10:32:41.506525	597	31	7182000
102	150	155000	52600	2024-08-23 10:32:41.506525	472	25	24738000
104	20	85000	37750	2024-08-26 05:57:51.340123	600	28	1751680
40	84	72000	37500	2024-08-13 02:35:16.523855	309	12	6435072
109	20	85000	42500	2024-08-26 05:57:51.340123	378	13	1808800
111	20	85000	42500	2024-08-26 05:57:51.340123	303	13	1808800
112	30	155000	52600	2024-08-26 05:57:51.340123	607	25	4947600
113	20	85000	42500	2024-08-26 05:57:51.340123	441	13	1751680
114	0	85000	42500	2024-08-26 05:57:51.340123	440	13	0
101	120	155000	52600	2024-08-23 10:32:41.506525	598	25	19790400
115	50	85000	42500	2024-08-26 05:57:51.340123	611	13	4379200
116	59	85000	42500	2024-08-26 05:57:51.340123	612	13	5167456
83	61	300000	220000	2024-08-22 05:40:04.682391	594	33	19471200
117	30	72000	37500	2024-08-30 06:53:43.889193	621	12	2298240
118	30	85000	42500	2024-08-30 06:53:43.889193	616	13	2713200
67	72	72000	37500	2024-08-15 11:23:50.505714	310	12	5515776
108	20	155000	52600	2024-08-26 05:57:51.340123	590	25	3298400
59	70	155000	52600	2024-08-14 11:51:29.139105	531	25	11544400
140	5	85000	37440	2024-09-10 12:08:11.044345	466	22	437920
141	5	85000	37440	2024-09-10 12:08:11.044345	468	22	437920
33	3	130000	62000	2024-08-12 12:24:15.7984	357	10	414960
50	5	47500	18950	2024-08-13 12:09:01.316504	357	18	301644
144	400	85000	37750	2024-09-10 12:08:11.044345	461	28	36176000
122	20	72000	33280	2024-09-03 11:45:40.769487	602	24	1532160
124	5	85000	42500	2024-09-03 11:45:40.769487	601	13	452200
125	5	190000	94500	2024-09-03 11:45:40.769487	601	27	1010800
126	10	190000	94500	2024-09-05 09:25:02.89298	594	27	2021600
128	57	72000	33280	2024-09-05 09:25:02.89298	649	24	4366656
130	23	72000	37500	2024-09-05 09:25:02.89298	590	12	1761984
131	5	300000	150000	2024-09-05 09:25:02.89298	423	33	1596000
132	10	190000	94500	2024-09-09 09:56:53.4503	651	27	2021600
133	10	190000	94500	2024-09-09 09:56:53.4503	650	27	2021600
137	10	155000	52600	2024-09-10 12:08:11.044345	426	25	1597120
136	6	72000	33280	2024-09-10 10:17:50.421268	652	24	445134
139	20	190000	94500	2024-09-10 12:08:11.044345	577	27	4256000
129	42	72000	37500	2024-09-05 09:25:02.89298	351	12	3111552
127	50	72000	33280	2024-09-05 00:00:00	648	24	3830400
142	100	155000	52600	2024-09-10 12:08:11.044345	466	25	15971200
143	10	155000	52600	2024-09-10 12:08:11.044345	369	25	1597120
152	170	155000	52600	2024-09-01 00:00:00	317	25	28036400
146	11	155000	52600	2024-09-01 00:00:00	654	25	1814120
148	100	72000	33280	2024-08-01 00:00:00	648	24	5862500
149	20	65000	26500	2024-08-01 00:00:00	302	19	1058520
150	50	155000	52600	2024-09-01 00:00:00	450	25	7985600
151	22	325000	165000	2024-08-01 00:00:00	317	31	7799792
155	15	155000	52600	2024-09-01 00:00:00	312	25	2473800
156	10	72000	37500	2024-09-01 00:00:00	357	12	766080
157	10	75000	25000	2024-09-01 00:00:00	357	30	798000
135	18	85000	37750	2024-09-10 10:17:50.421268	652	28	1576512
120	1	72000	37500	2024-08-15 00:00:00	339	12	74189
154	10	85000	42500	2024-08-15 00:00:00	659	13	904400
138	6	190000	94500	2024-08-15 00:00:00	340	27	1174656
34	30	155000	52600	2024-08-12 12:24:15.7984	311	25	13193600
70	20	155000	52600	2024-08-15 11:23:50.505714	308	25	3298400
121	50	155000	52600	2024-09-03 11:45:40.769487	531	25	8246000
147	21	155000	52600	2024-09-01 00:00:00	590	25	3463320
153	20	75000	25000	2024-09-01 00:00:00	659	30	1596000
90	20	72000	33280	2024-08-22 11:35:58.38285	479	24	1483780
100	105	85000	42500	2024-08-23 10:32:41.506525	597	13	9481920
69	80	85000	42500	2024-08-15 11:23:50.505714	480	13	7006720
65	50	85000	37750	2024-08-15 11:23:50.505714	514	28	4436320
110	240	155000	52600	2024-08-26 05:57:51.340123	304	25	39580800
98	122	155000	52600	2024-08-23 10:32:41.506525	467	25	19599440
84	200	155000	52600	2024-08-22 11:35:58.38285	384	25	32098640
103	30	155000	52600	2024-08-23 11:35:41.162535	474	25	4947600
68	150	155000	52600	2024-08-15 11:23:50.505714	480	25	23956800
89	0	65000	26500	2024-08-22 11:35:58.38285	480	19	0
88	20	85000	37750	2024-08-22 11:35:58.38285	480	28	1808800
106	35	155000	52600	2024-08-26 05:57:51.340123	601	25	5615960
107	15	85000	42500	2024-08-26 05:57:51.340123	601	13	1328040
105	15	190000	94500	2024-08-26 05:57:51.340123	601	27	2968560
99	346	155000	52600	2024-08-23 10:32:41.506525	466	25	55937392
158	10	155000	52600	2024-09-01 00:00:00	626	25	1649200
159	20	173000	75000	2024-09-01 00:00:00	426	11	3565180
160	4	130000	62000	2024-09-01 00:00:00	481	10	535808
161	40	155000	52600	2024-09-01 00:00:00	311	25	6596800
81	220	72000	37500	2024-08-22 05:40:04.682391	409	12	17660160
164	10	85000	37750	2024-08-01 00:00:00	652	28	875840
165	4	72000	33280	2024-08-01 00:00:00	652	24	296756
166	10	164920	\N	2024-09-01 00:00:00	613	25	1649200
167	320	155000	52600	2024-08-12 00:00:00	317	25	36349760
170	40	76608	\N	2024-09-01 00:00:00	313	12	3064320
172	15	76608	\N	2024-09-01 00:00:00	309	12	1149120
174	140	190000	94500	2024-08-11 00:00:00	656	27	23130520
175	0	90440	\N	2024-09-01 00:00:00	600	13	0
176	0	164920	\N	2024-09-01 00:00:00	600	25	0
181	10	50540	\N	2024-09-01 00:00:00	300	18	505400
182	10	69160	\N	2024-09-01 00:00:00	302	19	691600
183	48	127680	\N	2024-09-01 00:00:00	622	38	6128640
184	48	127680	\N	2024-09-01 00:00:00	666	38	6128640
251	5	133952	\N	2024-08-01 00:00:00	466	10	669760
186	50	76608	\N	2024-09-01 00:00:00	517	12	3830400
187	5	345800	\N	2024-09-01 00:00:00	416	31	1729000
188	20	164920	\N	2024-09-01 00:00:00	378	25	3298400
189	110	165000	\N	2024-09-01 00:00:00	656	27	18150000
190	100	58520	\N	2024-09-01 00:00:00	300	21	5852000
252	50	74189	\N	2024-08-01 00:00:00	469	12	3709450
173	35	76608	\N	2024-09-01 00:00:00	310	12	2681280
191	10	76608	\N	2024-09-01 00:00:00	668	24	766080
192	20	79800	\N	2024-09-01 00:00:00	457	30	1596000
193	10	76608	\N	2024-09-01 00:00:00	643	12	766080
194	10	90440	\N	2024-09-01 00:00:00	643	13	904400
196	20	76608	\N	2024-09-01 00:00:00	588	24	1532160
197	20	76608	\N	2024-09-01 00:00:00	588	12	1532160
180	100	175000	\N	2024-09-01 00:00:00	667	27	17500000
201	0	90440	\N	2024-09-01 00:00:00	610	13	0
202	100	87584	\N	2024-09-01 00:00:00	600	28	8758400
205	20	202160	\N	2024-09-01 00:00:00	670	27	4043200
206	50	76608	\N	2024-09-01 00:00:00	616	12	3830400
207	20	164920	\N	2024-09-01 00:00:00	616	25	3298400
208	56	90440	\N	2024-09-01 00:00:00	616	13	5064640
209	100	164920	\N	2024-09-01 00:00:00	474	25	16492000
237	119	87584	\N	2024-08-01 00:00:00	468	22	10422496
213	20	178259	\N	2024-09-01 00:00:00	652	11	3565180
214	10	164920	\N	2024-09-01 00:00:00	308	25	1649200
215	16	76608	\N	2024-09-01 00:00:00	591	12	1225728
216	50	74189	\N	2024-09-01 00:00:00	684	12	3709450
277	75	87584	\N	2024-10-01 00:00:00	688	13	6568800
218	60	159712	\N	2024-09-26 00:00:00	589	25	9582720
219	20	74189	\N	2024-09-26 00:00:00	684	24	1483780
168	20	69160	\N	2024-09-01 00:00:00	655	19	1383200
211	220	164920	\N	2024-09-01 00:00:00	472	25	36282400
221	50	90440	\N	2024-09-01 00:00:00	472	13	4522000
220	50	76608	\N	2024-09-01 00:00:00	472	12	3830400
195	2	345800	\N	2024-09-01 00:00:00	643	31	691600
222	0	159712	\N	2024-08-01 00:00:00	369	25	0
223	30	87584	\N	2024-08-01 00:00:00	476	29	2627520
224	59	48944	\N	2024-08-01 00:00:00	477	18	2887696
226	19	157239	\N	2024-08-01 00:00:00	481	5	2987541
227	24	178259	\N	2024-08-01 00:00:00	481	11	4278216
228	40	87584	\N	2024-08-01 00:00:00	476	13	3503360
229	10	74189	\N	2024-08-01 00:00:00	477	12	741890
230	20	87584	\N	2024-08-01 00:00:00	477	13	1751680
231	30	74189	\N	2024-08-01 00:00:00	480	12	2225670
232	10	159712	\N	2024-08-01 00:00:00	583	25	1597120
233	1	51005	\N	2024-08-01 00:00:00	478	23	51005
163	4	130000	62000	2024-08-01 00:00:00	481	10	535808
235	10	309120	\N	2024-08-01 00:00:00	469	33	3091200
236	100	87584	\N	2024-08-01 00:00:00	644	28	8758400
253	75	87584	\N	2024-08-01 00:00:00	469	13	6568800
234	17	87584	\N	2024-08-01 00:00:00	471	22	1488928
254	253	74189	\N	2024-08-01 00:00:00	482	12	18769817
255	4	309120	\N	2024-08-01 00:00:00	80	33	1236480
217	134	157239	\N	2024-09-01 00:00:00	303	5	21070026
257	23	74189	\N	2024-08-01 00:00:00	602	24	1706347
258	5	74189	\N	2024-08-01 00:00:00	299	12	370945
259	3	66976	\N	2024-08-01 00:00:00	522	19	200928
260	5	133952	\N	2024-08-01 00:00:00	425	10	669760
261	7	133952	\N	2024-08-01 00:00:00	384	10	937664
262	30	178259	\N	2024-08-01 00:00:00	412	11	5347770
263	5	76608	\N	2024-09-01 00:00:00	362	12	383040
264	20	478800	\N	2024-09-01 00:00:00	362	37	9576000
265	40	87584	\N	2024-09-01 00:00:00	302	13	3503360
266	5	74189	\N	2024-08-01 00:00:00	604	12	370945
267	4	180320	\N	2024-08-01 00:00:00	603	14	721280
268	170	159712	\N	2024-08-01 00:00:00	603	25	27151040
269	3	133952	\N	2024-08-01 00:00:00	322	10	401856
270	40	76608	\N	2024-09-01 00:00:00	302	12	3064320
185	35	76608	\N	2024-09-01 00:00:00	300	12	2681280
256	28	159712	\N	2024-08-01 00:00:00	474	8	4471936
271	10	74189	\N	2024-09-01 00:00:00	674	12	741890
272	10	164920	\N	2024-09-01 00:00:00	675	25	1649200
273	20	90440	\N	2024-09-01 00:00:00	676	13	1808800
123	74	155000	52600	2024-09-03 11:45:40.769487	601	25	11943680
274	5	76608	\N	2024-09-01 00:00:00	601	12	383040
275	221	90440	\N	2024-10-01 00:00:00	461	28	19987240
278	60	164920	\N	2024-10-01 00:00:00	303	25	9895200
281	30	90440	\N	2024-10-01 00:00:00	473	13	2713200
282	10	164920	\N	2024-10-01 00:00:00	626	25	1649200
286	30	76608	\N	2024-10-01 00:00:00	351	12	2298240
290	14	164920	\N	2024-10-01 00:00:00	377	25	2308880
279	60	69160	\N	2024-10-01 00:00:00	685	19	4149600
291	15	164920	\N	2024-10-01 00:00:00	453	25	2473800
276	30	164920	\N	2024-10-01 00:00:00	531	25	4947600
292	20	76608	\N	2024-10-01 00:00:00	649	24	1532160
285	30	164920	\N	2024-10-01 00:00:00	590	25	4947600
283	30	164920	\N	2024-10-01 00:00:00	308	25	4947600
296	90	164920	\N	2024-10-01 00:00:00	409	25	14842800
294	100	95200	\N	2024-10-01 00:00:00	691	13	9520000
288	20	202160	\N	2024-10-01 00:00:00	381	27	4043200
287	50	90440	\N	2024-10-01 00:00:00	378	13	4522000
225	50	74189	\N	2024-08-01 00:00:00	478	24	3757830
162	208	155000	52600	2024-08-01 00:00:00	409	25	34303360
280	69	76608	\N	2024-10-01 00:00:00	593	12	5285952
145	80	72000	37500	2024-08-01 00:00:00	466	12	6056070
289	40	76608	\N	2024-10-01 00:00:00	690	24	3064320
295	333	76608	\N	2024-10-01 00:00:00	409	12	25510464
284	48	164920	\N	2024-10-01 00:00:00	311	25	8072400
169	120	164920	\N	2024-09-01 00:00:00	304	25	19790400
203	65	76608	\N	2024-09-01 00:00:00	669	12	4979520
204	65	90440	\N	2024-09-01 00:00:00	669	13	5878600
297	1	67200	\N	2024-08-01 00:00:00	409	20	67200
179	64	80640	\N	2024-08-01 00:00:00	409	24	5160960
299	30	164920	\N	2024-10-01 00:00:00	474	25	4947600
300	100	87584	\N	2024-10-01 00:00:00	611	13	8758400
301	120	164920	\N	2024-10-01 00:00:00	361	25	19790400
302	20	69160	\N	2024-08-01 00:00:00	477	19	1383200
303	20	180028	\N	2024-08-01 00:00:00	658	27	3600560
304	20	76608	\N	2024-10-01 00:00:00	457	24	1532160
305	8	90440	\N	2024-10-01 00:00:00	596	13	723520
306	20	76608	\N	2024-10-01 00:00:00	342	12	1532160
308	10	125552	\N	2024-10-01 00:00:00	378	26	1255520
307	30	345800	\N	2024-10-01 00:00:00	664	31	10374000
309	50	319200	\N	2024-10-01 00:00:00	532	33	15960000
310	30	63840	\N	2024-10-01 00:00:00	690	20	1915200
311	60	164920	\N	2024-10-01 00:00:00	691	25	9895200
293	100	173600	\N	2024-10-01 00:00:00	317	25	17360000
312	330	90440	\N	2024-08-01 00:00:00	415	13	29845200
298	60	69160	\N	2024-10-01 00:00:00	485	19	4149600
313	30	164920	\N	2024-09-01 00:00:00	384	25	4947600
314	50	164920	\N	2024-09-01 00:00:00	673	25	8246000
\.


--
-- Data for Name: doctor_visit_info; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.doctor_visit_info (id, recept, data, doctor_id, product_id) FROM stdin;
\.


--
-- Data for Name: editable_plan_months; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.editable_plan_months (id, month, status, created_at, updated_at) FROM stdin;
1	1	f	2024-09-14 07:44:08.898668	2024-09-14 07:44:08.898668
2	2	f	2024-09-14 07:44:08.898668	2024-09-14 07:44:08.898668
3	3	f	2024-09-14 07:44:08.898668	2024-09-14 07:44:08.898668
4	4	f	2024-09-14 07:44:08.898668	2024-09-14 07:44:08.898668
5	5	f	2024-09-14 07:44:08.898668	2024-09-14 07:44:08.898668
6	6	f	2024-09-14 07:44:08.898668	2024-09-14 07:44:08.898668
7	7	f	2024-09-14 07:44:08.898668	2024-09-14 07:44:08.898668
11	11	f	2024-09-14 07:44:08.898668	2024-09-14 07:44:08.898668
12	12	f	2024-09-14 07:44:08.898668	2024-09-14 07:44:08.898668
8	8	t	2024-09-14 07:44:08.898668	2024-09-14 07:44:08.898668
9	9	t	2024-09-14 07:44:08.898668	2024-10-09 10:09:31.98478
10	10	t	2024-09-14 07:44:08.898668	2024-10-09 10:09:39.788654
\.


--
-- Data for Name: expense; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.expense (id, amount, author, description, date, category_id) FROM stdin;
\.


--
-- Data for Name: expense_category; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.expense_category (id, name) FROM stdin;
\.


--
-- Data for Name: hospital; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.hospital (id, company_name, company_address, inter_branch_turnover, bank_account_number, director, purchasing_manager, contact, med_rep_id, region_id) FROM stdin;
7	Кардио Сервиз Термиз	Термез	1	1	Жураев Чори	Жураев Чори	+998-94-200-38-24	86	1
8	New test hospital	Toshkent	09090	978989	Elmurod Otabekov	Olim	+998-98-989-90-90	80	1
9	test 4	Toshkent	2352532	3235	Olimjon	Renatjon	+998-09-099-89-89	80	1
11	Central Cardio Servis	Малая кольцевая 51	12345	1234	Рузиева Элизавета	Гульчехра	+998-93-318-32-32	82	1
5	New pharmacy	Toshkent olmazor dahasi	89787	89089	Otabek Bekmatov	Suyun Otabekov	+998-89-789-79-00	80	1
12	BEKE	Kashqadaryoz	0928934	9878974	Hoshim	Elbek	+998-98-798-09-09	80	1
13	Наманган Вилоят Тиббиёт Маркази	Наманган	1	1	Провизор	Провизор	+998-88-888-88-88	51	12
14	ЧК Неомед кардио	Ташкент, Чиланзарский район, ул. Арнасай, 71	4566	1233	ФАЙЗИЕВ ХАКИМ САНАЕВИЧ	Гульчехра	+998-90-934-98-37	82	1
15	ЧК Кардио стар плюс	Ташкент, ул. Серкуёш, 82	123456	123456	ФАЙЗИЕВ ХАКИМ САНАЕВИЧ	Гульчехра	+998-90-934-98-37	82	1
16	Elbek	Toshkent	432523	23525234	Dilmurod	Elbek	+998-97-384-39-43	80	1
17	New Iditarod farmacy	Navoiy	3453245	09809	Olim	Odilbek	+998-90-485-48-54	80	1
18	asdf	asdf	23423		asdfad	adsfadsf	+998-90-785-65-64	80	1
19	fasdfasdfasdfasdfadsfadsfasdfasdfasfsadfadf	asdfa	324234234234234234234		asdf	dasf	+998-89-767-85-56	80	1
21	Чимбай ТТБ	Чимбайский р-н	201301781		Мадреимов Ерназар Даулетназарович	Заведующий	+998-91-379-13-01	116	7
22	Нукус ШТБ	Нукус	204060084		Директор	Заведующий	+998-91-655-46-28	116	7
\.


--
-- Data for Name: hospital_bonus; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.hospital_bonus (id, date, amount, payed, product_quantity, hospital_id, product_id) FROM stdin;
\.


--
-- Data for Name: hospital_fact; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.hospital_fact (id, fact, price, discount_price, date, hospital_id, product_id) FROM stdin;
8	10	155000	52600	2024-07-31 07:49:41.781829	5	25
15	50	47500	18950	2024-08-26 05:57:51.390725	11	18
16	50	47500	18950	2024-08-26 05:57:51.390725	15	18
17	100	47500	18950	2024-08-26 05:57:51.390725	14	18
\.


--
-- Data for Name: hospital_monthly_plan; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.hospital_monthly_plan (id, monthly_plan, date, product_id, price, discount_price, hospital_id) FROM stdin;
10	10	2024-08-05 11:49:58.969528	25	155000	52600	9
11	100	2024-08-07 06:41:55.73204	18	47500	18950	11
12	100	2024-08-13 10:07:30.122625	30	75000	25000	13
13	200	2024-08-13 10:07:30.122625	12	72000	37500	13
14	200	2024-08-13 10:07:30.122625	13	85000	42500	13
15	200	2024-08-13 10:07:30.122625	25	155000	52600	13
16	200	2024-08-13 10:07:30.122625	24	72000	33280	13
17	200	2024-08-15 11:23:50.552394	26	118000	62000	13
\.


--
-- Data for Name: hospital_postupleniya_fact; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.hospital_postupleniya_fact (id, fact, price, discount_price, date, hospital_id, product_id, fact_price) FROM stdin;
\.


--
-- Data for Name: hospital_reservation; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.hospital_reservation (id, date, expire_date, discount, total_quantity, total_amount, total_payable, total_payable_with_nds, hospital_id, manufactured_company_id, payed, checked, invoice_number, profit, debt, date_implementation, prosrochenniy_debt, med_rep_id, bonus) FROM stdin;
30	2024-08-26 00:00:00	2024-09-25 05:57:51.385827	20	50	2375000	1900000	2128000	11	3	f	t	2699	2128000	0	2024-08-27 06:29:28.179221	f	86	t
32	2024-08-26 00:00:00	2024-09-25 05:57:51.385827	20	50	2375000	1900000	2128000	15	3	f	t	2700	2128000	0	2024-08-27 06:31:11.7408	f	86	t
31	2024-08-26 00:00:00	2024-09-25 05:57:51.385827	20	100	4750000	3800000	4256000	14	3	f	t	2702	4256000	0	2024-08-27 06:36:24.000386	f	86	t
33	2024-09-16 00:00:00	2024-10-16 12:51:47.652223	17.763	100	19000000	15625030	17500034	21	1	f	t	1041557	17500000	34	2024-09-19 09:05:58.355615	f	86	t
\.


--
-- Data for Name: hospital_reservation_payed_amounts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.hospital_reservation_payed_amounts (id, amount, description, date, reservation_id, total_sum, remainder_sum, bonus, quantity, product_id, bonus_discount, doctor_id, nds_sum, fot_sum, promo_sum, skidka_sum, pure_proceeds) FROM stdin;
13	2128000	.	2024-08-26 00:00:00	30	\N	\N	\N	\N	\N	\N	\N	228000	700000	600000	475000	2375000
14	2128000	.	2024-08-26 00:00:00	32	\N	\N	\N	\N	\N	\N	\N	228000	700000	600000	475000	2375000
15	4256000	.	2024-08-26 00:00:00	31	\N	\N	\N	\N	\N	\N	\N	456000	1400000	1200000	950000	4750000
16	3500000	Бонус	2024-09-16 00:00:00	33	\N	\N	t	\N	\N	20	667	375000	4600000	4000000	15875000	19000000
17	14000000	бонус	2024-09-16 00:00:00	33	\N	\N	t	\N	\N	20	667	1500000	4600000	4000000	6500000	19000000
\.


--
-- Data for Name: hospital_reservation_products; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.hospital_reservation_products (id, quantity, reservation_price, reservation_discount_price, product_id, reservation_id, not_payed_quantity) FROM stdin;
42	50	38000	18950	18	30	\N
43	100	38000	18950	18	31	\N
44	50	38000	18950	18	32	\N
45	100	156250	94500	27	33	\N
\.


--
-- Data for Name: incoming_balance_in_stock; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.incoming_balance_in_stock (id, date, description, wholesale_id, factory_id, pharmacy_id) FROM stdin;
45	2024-08-13 00:00:00		5	\N	78
46	2024-08-21 00:00:00		11	\N	151
43	2024-08-06 00:00:00		5	\N	32
44	2024-08-06 00:00:00		5	\N	61
47	2024-08-23 00:00:00		13	\N	31
48	2024-09-13 00:00:00		13	\N	93
49	2024-09-16 00:00:00		13	\N	115
50	2024-09-16 00:00:00		16	\N	219
51	2024-09-16 00:00:00		3	\N	220
52	2024-09-20 00:00:00		10	\N	222
53	2024-09-20 00:00:00		13	\N	153
54	2024-09-20 00:00:00		5	\N	115
55	2024-09-26 00:00:00		13	\N	230
56	2024-10-17 19:49:28.865601		2	\N	52
\.


--
-- Data for Name: incoming_stock_products; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.incoming_stock_products (id, quantity, stock_id, product_id) FROM stdin;
42	10	43	26
43	50	44	25
44	20	45	25
45	5	46	33
46	50	46	25
47	20	46	12
48	10	46	27
49	10	46	14
50	20	46	15
51	30	47	8
52	30	47	11
53	20	48	11
54	30	50	18
55	3	51	20
56	5	52	4
57	5	52	11
58	9	52	25
59	45	53	13
60	20	54	25
61	20	55	11
62	100	56	25
\.


--
-- Data for Name: manufactured_company; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.manufactured_company (id, name) FROM stdin;
1	ZUMA
2	SAMO
4	FAZO-LUXE
3	UZGERMED
6	HEARTLY
\.


--
-- Data for Name: medical_organization; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.medical_organization (id, name, address, latitude, longitude, region_id) FROM stdin;
14	РТМО Шайхантохур	Поликлиника Шохантаурского района, Джалолобад улица, Аклан, Аклан махалля, Шайхантахурский район, Ташкент, 100000, Узбекистан	41.321803141929735	69.21561866998674	1
1	Белогрик Больница	Beltepa, Beltepa Street, JARARIQ, Shayhantahur District, Tashkent, 100000, Uzbekistan	41.3409958	69.17370552546184	1
5	Oblastnaya Bolnitsa	Navoiy Qizilqum	37.771225946120694	-122.41176711378824	5
6	Obl Durdom	Sergeli shekilli	41.2345129	69.2159346	1
10	QKM	Qorakoʻl mchj	41.3336869	69.2456614	4
15	 "KARDIO SERVIS TERMIZ"	 Сурхандарьинская область, Термезский район, ССГ Пахтаабад, Qaxramon mahallasi	37.2524670478586	67.27890014648439	6
16	 Shumanay tumani tibbiyot birlashmasi	 Республика Каракалпакстан, Шуманайский район, ГРП Шуманай, Abay ko'chasi, 47-uy	0	0	7
17	 Qo'ng'irot tumani tibbiyot birlashmasi	Республика Каракалпакстан, Кунградский район, ГРП Кунград,Qoraqalpog'iston ko'chasi, 57-uy	0	0	7
18	Нукус РИКИАТМ	Республика Каракалпакстан, г. Нукус,K.Matkarimov ko‘chasi, 2-uy	0	0	7
20	Муйнак туман Тиббиёт Бирлашмаси	Республика Каракалпакстан, Муйнакский район, ГРП Муйнак, 1735222501, Ajiniyaz ko'chasi, 1-uy	0	0	7
21	Нукус шахар Тиббиёт Бирлашмаси	 Республика Каракалпакстан, г. Нукус, T.Shcherbekov ko‘chasi, 43-uy	0	0	7
23	Китаб туман Тиббиёт Бирлашмаси	Китабский район, ГРП Китаб,Katta yo'l ko'chasi, 123-uy	0	0	6
25	Шахрисабз Тез Тиббий Ёрдам	г.Шахрисабз, ул.Ипак Йули,100А	0	0	6
26	Шахрисабз туман Тиббиёт Бирлашмаси	Шахрисабзский район, ГП Чоршанбе.	0	0	6
27	Наманган Вилоят Кўп Тармокли Тиббиёт Бирлашмаси Маркази	г. Наманган,N.Namongoniy ko'chasi, 9-uy	0	0	12
28	Дангара тумани Марказий Шифохона	Дангара тумани	0	0	14
30	Дангара Куп Тармокли Марказий Поликлиника	Дангара тумани	0	0	14
31	Бешарик Куп Тармокли Поликлиника	Бешарик тумани	0	0	14
32	Коканд Тиббий Диагностика	Коканд, ул. Фурката, 28	0	0	14
33	1- Шахар Куп Тармокли Шифохона Наманган ш.	г.Наманган	0	0	12
34	Центр Кардиологии г.Намангана	г.Наманган	0	0	12
35	Халимахон Мед ХК	г.Наманган	0	0	12
36	Сино Шифо ХК	г.Наманган	0	0	12
37	Карши Вилоят Куп Тармокли Тиббиёт Бирлашмаси	г.Карши	0	0	6
44	Унгбоев ХК	г.Карши	0	0	6
45	ЧК Альфаганус	ул. Юкори Каракамыш, 2А, Юнусабадский район,	0	0	1
47	ЧК РеалМедикал	улица Талабалар, дом 65, Алмазарский район	0	0	1
48	ЧК МАА госпиталь	улица Фаробий, 356, Алмазарский район,	0	0	1
52	ЦРБ Берунийского района	район Беруний	0	0	3
58	Хорезмская Областная Больница	г.Ургенч, ул. Ю. БАБАДЖАНОВА, 1	0	0	3
59	Янгиарыкское РМО	Янгиарыкский р-н, ул. Узбекистанская, 1	0	0	3
62	Центральная больница г. Хива		0	0	3
42	Медцентр Абдумалик	Гулистан, Сырдарьинская область, 120100, Узбекистан	40.497280020797525	68.77182838079774	2
46	Областная государственная больница г.Гулистан	Областная поликлиника, улица Ибн Сино, 3 микрорайон, Гулистан, Сырдарьинская область, 120100, Узбекистан	40.52082976920697	68.76072416725204	2
43	Самира ХК		0	0	4
50	СЫРДАРЬИНСКАЯ ОБЛАСТНАЯ МНОГОПРОФИЛЬНАЯ БОЛЬНИЦА	улица Ибн Сино, 3 микрорайон, Гулистан, Сырдарьинская область, 120100, Узбекистан	40.521384357047005	68.7601446519737	2
53	ЦРБ г. Ургенч	Хорезмская областная больница, 2, улица Тараккиёт, Махалля №8 Гулшан, Ургенч, Ургенчский район, Хорезмская область, 220100, Узбекистан	41.56075548165411	60.633560742792106	3
55	ЦРБ Бекабадского района	Зафарабадский район, Бекабад, 702902, Узбекистан	40.23398524687539	69.24731966905021	2
56	КТМП Бекабадского р-на	Зафар, Бекабадский район, 110410, Узбекистан	40.38249655587417	69.23962881546798	2
22	 СП - 44 	Поликлиника №44, 13, Богкуча (Ц-27), Шайхантахурский район, Ташкент, 100000, Узбекистан	41.32660523173662	69.21772695211652	1
11	16-гор больница	Чиланзар, Малая кольцевая дорога, Чиланзар, Чиланзарский район, Ташкент, 100000, Узбекистан	41.26827538601156	69.21639919281007	1
40	Саховат ХК	г.Карши	0	0	6
29	РНЦЭНП	57а, Малая кольцевая дорога, Катта Казирабад махалля, Чиланзарский район, Ташкент, 100000, Узбекистан	41.26919065599722	69.21746953321117	1
60	ЦЕНТРАЛЬНАЯ БОЛЬНИЦА БОСТАНЛЫКСКОГО РАЙОНА	110700, Узбекистан, Ташкентская область, Город: Газалкент, ул. Ибн Сино, 2	0	0	2
65	ЦЕНТРАЛЬНАЯ ПОЛИКЛИНИКА КИБРАЙСКОГО РАЙОНА 	Узбекистан, Ташкентская область, Город: Кибрайский р-н, пгт Аргин, ул. Марказий	0	0	2
72	 6- Багдад Куп Тармокли Поликлиника 	Багдадский р-н	0	0	13
61	Районное медицинское объединение Кушкупирского района 		0	0	3
67	"ДИЛЧЕХРА" ЧАСТНАЯ КЛИНИКА	111700, Узбекистан, Ташкентская область, Город: Чирчик, пр-т Амира Темура, 138	0	0	2
63	ЧК Илхом Шифо		0	0	3
64	Кардиологический диспансер г. Ургенч		0	0	3
69	Каракалпакский Кардиологический Диспансер	Нукус, 25-й микрорайон, 2	0	0	7
66	Бухарское РМО	г.Бухара	0	0	4
68	Каракуль ТТБ	Каракуль р-н	0	0	4
70	Лор-Лазер ЧК	г.Наманган	0	0	12
71	Ортоклиника	Дангара р-н	0	0	13
73	Янкургон ТТБ	Янгикургон	0	0	14
74	ЦЕНТРАЛЬНАЯ БОЛЬНИЦА г.ЧИРЧИКА	111700, Узбекистан, Ташкентская область, Город: Чирчик, микр-н 9-й	0	0	2
75	Турткуль РМО	Турткуль р-н	0	0	7
76	Онкологический диспансер г.Нукус	г.Нукус	0	0	7
78	Центр гемодиализа г.Нукус	г.Нукус	0	0	7
79	Туберкулёзный Диспансер г.Китаб	г.Китаб	0	0	6
80	АНГРЕНСКАЯ ГОРОДСКАЯ ЦЕНТРАЛЬНАЯ БОЛЬНИЦА	110200, Узбекистан, Ташкентская область, Город: Ангрен, ул. Навои, 20	0	0	2
81	STAR MED CENTER" КЛИНИКА 	100097, Узбекистан, Город: Ташкент, Район: Чиланзарский, кв-л Чиланзар-6, 6/1	0	0	2
82	Шифокор Плюс	Алмалык, ул. Эхтиром, 1А	0	0	2
83	Шахрисабз Медикон ЧК	г.Шахрисабз	0	0	6
84	Асролов Лор Клиника	Китабский р-н	0	0	6
90	Китоб Тез Тиббиёт Ёрдам 	г.Китаб	0	0	6
91	Инфекционная больница г.Китаб	г.Китаб	0	0	6
92	Мед Экспресс ЧК	г.Коканд	0	0	14
93	Водий Мед ЧК	г.Коканд	0	0	14
94	Медикал Сервис ЧК	г.Коканд	0	0	14
95	1-Центральная Больница Бешарикского р-на	Бешарикский р-н	0	0	14
96	ХАТЫРЧИНСКОЕ РАЙОННОЕ МЕДИЦИНСКОЕ ОБЪЕДИНЕНИЕ	Навоийская область, Хатырчинский р-н, пос. КОРАЧА,	0	0	5
97	 Содик Камол Шифо ЧК	Namangan viloyati, Chortoq tumani, Pastki Peshqo'rg'on shaharchasi To`pqayrag`och MFY, Jahonbaxsh ko`chasi, 52-uy	0	0	12
98	НАВОИЙСКИЙ ОБЛАСТНОЙ МНОГОПРОФИЛЬНЫЙ МЕДИЦИНСКИЙ ЦЕНТР	Навоийская область, 210100, Навои, ул. АВЛОНИ, 16 А	51.50509635629854	-0.07690429687500001	5
99	Карши Вилоят Кардиология Маркази	г. Карши	41.3731945	69.3232432	6
100	Канликуль ТТБ	Канликульский р-н	0	0	7
101	Наманган Эндокринология ТТБ	г.Наманган	0	0	12
102	Арт Мед ЧК	г.Наманган	0	0	12
103	Наманган Онкология 	г.Наманган	0	0	12
104	Карши Вилоят Тез Тиббий Ёрдам	г.Карши	0	0	6
105	Ишонч клиникаси	карши город	38.85095586375385	65.78108084860395	6
107	Чоршанби Тез Тиббий Ёрдам	Чоршанби	41.299496	69.240073	6
109	Карши Темир Йул ТБ	г.Карши	41.3731779	69.3233086	6
110	Зармас ЧК	г.Каоши	41.373196	69.3232763	6
111	Ч/К Шифокор Плюс	ул.Эхтиром 1А	0	0	2
112	ЧК Элексир		0	0	1
113	Военный Госпиталь г.Бухара		0	0	4
114	Бухарская областная больница		51.503899621859325	-0.08383582843810579	4
115	РМО Наваий		0	0	5
116	Ч/К Орзу Медикал Янгибазар		0	0	2
117	Шахрисабз Кардиология	г.Шахрисабз	41.3731983	69.323261	6
119	ЧК Соглом Хаёт	ул. Чинар, Спутник-7, дом 9, Янгихаётский район	0	0	1
120	ЧК Офтоб мед	массив Себзар, 1, Алмазарский район, Ташкент	0	0	1
121	5-СП г.Бухара		0	0	4
123	Родильный комплекс Каганский район		0	0	4
124	Бухарская городская больница	ул.Бахауддина Накшбанда 156/1	0	0	4
125	ЧК Хасан Доктор	ул  Пахтачи 	0	0	1
133	Республиканская Клиническая Больница 1	Sodiq Azimov ko'chasi 74,	0	0	1
136	Род дом 3	ул. АБДУРАУФА ФИТРАТА, 94 А	0	0	1
137	ЧК Никамед Сервис	Фарғона Йўли 569	0	0	1
129	РЕСПУБЛИКАНСКИЙ СПЕЦИАЛИЗИРОВАННЫЙ НПМЦ ГЕМАТОЛОГИИ	Чиланзарский, ул. Арнасай (бывш. Пионерская), 16/1А	0	0	1
126	 СП - 48 	Abay kp'chasi	41.32315756475979	69.2535935396847	1
118	 ЧК Неомед кардио	ул. Катта Козиробод, 71	0	0	1
130	ЧК Shifo Medline	Jurjoniy ko'cha	41.301386555925674	69.17218674385931	1
131	Городская Клиническая больница № 4	Birlashgan ko'chasi 1,	0	0	1
135	 Городская клиническая больница № 3	Abdurauf Fitrat ko'chasi 27	0	0	1
128	Городская клиническая больница № 7	Юнусабадский район, ул. ГАЙРАТИ, 24	0	0	1
106	 ЧК Централ Кардио Сервис 	город Ташкент, ЧЧиланзарский район, 1726294, Kichik xalqa yo'li ko'chasi, 51-uy	0	0	1
108	 СП - 46 	поликлиника №46, Самарканд Дарваза улица, Зангиата махалля, Шайхантахурский район, Ташкент, 100000, Узбекистан	41.307995162541395	69.21787711924131	1
132	ТМА-3	Ташкентская медицинская академия, 103, Махтумкули улица, Яшнабадский район, Ташкент, 100047, Узбекистан	41.31054987937834	69.30315537508491	1
134	 ЧК Avisa Med Servis	Ависа Мед Сервис, 1A, Абдурауфа Фитрата улица, Мирабадский район, Ташкент, 100000, Узбекистан	41.27256131940174	69.30996274108864	1
138	ЧК Равнак	ул. Фаргона йули, дом 2, этаж 1	0	0	1
139	ЧК Эрамед 	улица Махтумкули 105	0	0	1
140	СП 30	Район: Яшнабадский, ул. Бирлашган, 8	0	0	1
142	СП 29	ул. ФАРГОНА ЙУЛИ, 543	0	0	1
141	СП 31	Тузель-1, Тузель (40 лет Победы), Яшнабадский район, Ташкент, 100000, Узбекистан	41.299746047994354	69.36188191713752	1
143	СП 28	пр-д 4-й Таларык, 2	0	0	1
144	РТМО Яшнаобод	ул. Махтумкули (бывш. Тараккиёт), 2	0	0	1
146	ЧК Нейросервис	ул. М.УЙГУР дом558 А	0	0	1
147	НИИМЭИЗ	ул. Заковат, 2,	0	0	1
13	 СП - 23	Поликлиника, Фархадская улица, Чиланзар-23, Учтепинский район, Ташкент, 100000, Узбекистан	41.28720716894895	69.18429312886911	1
150	СП - 40	Ibn Sino, Zangiota ko'chasi	41.33566932351393	69.16804363960267	1
127	ЖДБ	Центральная клиническая больница АО "Узбекистон темир йуллари", 12А, Эльбек улица, Авиагородок-22 массив, Яшнабадский район, Ташкент, 100000, Узбекистан	41.301084113143006	69.30387760000002	1
148	Heartly	Юнусабад, Юнусабадский район, Ташкент, 100000, Узбекистан	41.37379753798899	69.32326773845352	2
41	Ч/К Олтин Водий	Гулистан, Сырдарьинская область, 120100, Узбекистан	40.48950034306787	68.77366033834001	2
49	"SAYXUN MED SERVIS" КЛИНИКА	улица Сайхун, 2 микрорайон, Гулистан, Сырдарьинская область, 120100, Узбекистан	40.49769610819476	68.7674830997012	2
51	Хорезм Вилояти Куп Тармокли Тиббиёт Маркази	Хорезмская областная больница, 2, улица Тараккиёт, Махалля №8 Гулшан, Ургенч, Ургенчский район, Хорезмская область, 220100, Узбекистан	41.56078759316698	60.633550011027715	3
54	ЦРБ Элликкалинского р-на	Элликалинский районный узел электросвязи, 8, улица Шарафа Рашидова, Алишер Навоий махалля, Бустан, Элликкалинский район, Республика Каракалпакстан, 231600, Узбекистан	41.84384576155337	60.905003032947015	3
151	ГОРОДСКАЯ КЛИНИЧЕСКАЯ БОЛЬНИЦА №2 	41.297481, 69.345323	0	0	1
153	Консультативная - диагностическая поликлиника	ул Корасув 25	0	0	1
154	американ госпитал	юнусобод	41.37354860484077	69.3240612069802	1
57	Хорезмский филиал РНЦЭМП	Республиканский научный центр экстренной медицинской помощи Хорезмский филиал, улица Комилжона Атаниязова, "ЖИНГОВУЗ" район №25, Ургенч, Ургенчский район, Хорезмская область, 220100, Узбекистан	41.54603067218027	60.603622168821325	3
155	КБСМП	Жуковского улица	41.298950118175945	69.19087109543366	1
39	Миришкор ТТБ	Янги Миришкар, Миришкорский район, Кашкадарьинская область, 181000, Узбекистан	38.85802320399253	65.271577372403	6
156	Абдумалик ЧК	Гулистан, Сырдарьинская область, 120100, Узбекистан	40.49730449659822	68.77177476882936	16
157	ЧК Кук Сарой	ул. Фараби, дом 3Б	0	0	1
161	клинка	кора Сув	41.28573171501222	69.33756849458031	1
9	 ЧК Dusel Medical	Бешкайрагач улица, Бешкайрагач махалля, Учтепинский район, Ташкент, 100000, Узбекистан	41.31295138310032	69.15975093841554	1
149	 ЧК NS Medical	Xondamir mahalla	41.31218791669626	69.17835434589816	1
145	СП - 26	26 Семейная поликлиника, Усмана Зуфарова улица, Актепе, Учтепинский район, Ташкент, 100000, Узбекистан	41.31201025	69.18976204595307	1
8	Детская клиническая больница № 3 	Детская городская клиническая больница №3, Бешкайрагач улица, Бешкайрагач махалля, Учтепинский район, Ташкент, 100000, Узбекистан	41.3146969	69.1617323	1
160	Городская клиническая  больница № 1	Ko'kcha Darvaza	41.321119613559375	69.21989369706012	1
164	СП - 44	Toshko'cha, Tinchlik	41.326458302909785	69.21779877669978	1
163	ЧК Sabo Darmon	Nurafshon ko'cha	41.33057302047547	69.21690407860648	1
162	СП - 47	Samarqand Darvaza ko'chasi	41.31888491070936	69.24017342737984	1
158	ЧК Сити Мед	ул.Фаробий, 415	41.3498141840474	69.18852129982679	1
152	ЧК Альфа Диагностик	ул. Карасу, дом 4, Яшнабадский район,	0	0	1
165	Пахловон Клиника		0	0	6
166	NS Medical, 1 Gor bolnitsa	Ko'kcha Darvaza ko'chasi	41.32175657151221	69.21486271381998	1
167	Ахмад ЧК		0	0	7
168	РТМО	Ko'kcha Darvaza ko'chasi	41.321622831238656	69.2156054840846	1
169	ЧК Нейрофакс-Б	Улица Лутфий 26-1	0	0	1
170	ЧК Сино мед	Чиланзар-2, ул. Гагарина, 11	0	0	1
171	Карши ТТБ	карши	38.80337476625685	65.64636893068133	6
172	MedLine Shtab	Beshqayragoch ko'chasi	41.31509282720572	69.16150665166104	1
173	Медиком ЧК		0	0	6
174	Зафар. ЦРБ	Зафар	40.3808134	69.2412249	2
175	Нурафшон ТТБ	O'zbekiston, Toshkent viloyati, Shahar: Nurafshon, Shifokorlar ko'chasi	0	0	2
176	Охангарон ТТБ	Toshkent viloyati, Ohangaron tumani, Ohangaron shahri Nurobod mahallasi, Qalandarov ko'chasi	0	0	2
177	Хонабод КТМП		0	0	2
178	СП 25	Bag'bog ko'chasi	41.29215024869294	69.19096609868745	1
7	СП - 22		41.3159853712101	69.16487677640848	1
179	Neurofax Clinic	Ko'xna Cho'pon Ota ko'chasi	41.28979635790546	69.18953781450138	1
180	СП 24	Uchtepa tumani Chilonzor 11 mavzesi	41.27910541525182	69.18527066595283	1
181	Диагностика маркази г.Гулистан		0	0	2
182	Семя здоровья	Mahsud Shayxzoda ko'chasi	41.27903838982742	69.18860131634439	1
183	Neurological Clinic	Uchtepa tumani, Teppaqo'rg'on 11 mavze	41.27626116314164	69.18937171783271	1
184	СП 23 Журжоний	Jurjoniy ko'cha	41.30060359175464	69.17771000595091	1
185	Дангара КТМП		0	0	14
186	СП 26	Uchtepa tumani, Mergancha	41.3119728847515	69.1897901754571	1
187	Доктор Олим Мед клиникаси	Қарши	38.8794390455509	65.80698894751974	6
189	КБСМП Учтепа	Jukovski ko'chasi	41.29896102713877	69.19090008068332	1
190	КАРДИОДИСПАНСЕР г.ЖИЗЗАХ		0	0	17
191	Ч/К ЖИЗЗАХ ШИФО		0	0	17
192	РШТТЁМ Жиззах филиали		0	0	17
193	СП 40	Ibn Sino, Zangiota ko'chasi	41.33567300374986	69.1681582989861	1
194	Nevrologiya Ibn Sino	Ibn Sino, Zangiota ko'chasi	41.33660126445701	69.16799152231027	1
195	СП 41	Ipakchilik ko'chasi	41.3289376	69.1904514	1
196	Ibn Sino Medical	Ibn Sino ko'chasi	41.3424078	69.1770861	1
4	Республиканский специализированный центр хирургии им. В.В. Вахидова	Чиланзар, Малая кольцевая дорога, Чиланзар, Чиланзарский район, Ташкент, 100000, Узбекистан	51.50331771867245	-0.08115432324629303	1
38	ЧК КардиоСервис	2А, Арнасайская улица, Катта Казирабад махалля, Чиланзарский район, Ташкент, 100000, Узбекистан	41.26636013197219	69.21874645979581	1
197	Ас-Сихат	Бирлашган	41.2897037	69.3471022	1
198	Республиканский Специализированный Научно Практический Медицинский Центр Гематологии МЗ РУз	30, Чиланзар-2, Чиланзарский район, Ташкент, 100000, Узбекистан	41.27992698404157	69.22575473785402	1
199	Нуробод шахар шифохонаси		0	0	2
200	Shifo Medline	Jurjoniy ko'cha 16 uy	41.29980458552843	69.1729816986832	1
201	БУСТУНЛИК ТУМАН ТИББИЁТ БИРЛАШМАСИ		0	0	2
202	Health mother	Эшонгузар	0	0	1
203	Нео мед кардио	Ташкент, Чиланзарский район, ул. Арнасай, 71	0	0	1
204	ЧК Кардио Стар плюс	Ташкент, ул. Серкуёш, 82	0	0	1
205	РДМ ч/к	 Сырдарьинская область, Город: Гулистан, ул. Ибн Сино, микр-н 3-й, 21	0	0	16
206	Китоб туман Инфекционные Больница	Китоб туман	39.119362	66.8933435	6
207	ЯНГИАРИК ТУМАН ТТБ		0	0	3
208	ч/к ИБН СИНО		0	0	3
209	ч/к КАРДИОСЕРВИС 		0	0	5
210	ч/к НЕНВРОЦЕНТР		0	0	5
211	СИРДАРЁ ВИЛОЯТИ ОНКОЛОГИЯ ДИСПАНСЕРИ		0	0	16
212	Ташкентский областной эндокринологический диспансер	Ташкент, Новый Ташкентский район, населённый пункт махалли Хван Ман Гым	0	0	2
220	Городская Онкология г.Коканда	Коканд, Ферганская область, Узбекистан	40.52351433864821	70.94044455000002	14
221	1- Марказий Шифохона г.Коканд	Коканд, Ферганская область, Узбекистан	40.52351433864821	70.94044455000002	14
222	Канлыколь Районная Больница	Республика Каракалпакстан, Узбекистан	43.7738841	57.6234617	7
223	СП -27	ул. Фурката, 10А	0	0	1
224	Test mo	Beltepa, Beltepa Street, Beltepa mahalla, Shaykhantahur District, Tashkent, 100000, Uzbekistan	41.34096316151425	69.17335703283447	2
225	Остиё Люкс Клиника	Китаб, Китабский район, Кашкадарьинская область, 180700, Узбекистан	39.12606531754431	66.87446594238283	6
226	Тери таносил диспансери	карши город	38.89490387683513	65.7972192753739	6
227	Чимбай ТТБ	Чимбай, Чимбайский район, Республика Каракалпакстан, 231400, Узбекистан	42.928881664590364	59.778706449999994	7
228	Ишонч Клиника	Карши, Каршинский район, Кашкадарьинская область, 180000, Узбекистан	38.84452957839239	65.7961261	6
229	Кушкупыр ТТБ	Республика Каракалпакстан, Узбекистан	43.7738841	57.6234617	7
230	Нуриддин Клиника	Шахрисабз, Кашкадарьинская область, 180000, Узбекистан	39.06227166474751	66.83540970000001	6
231	Рахмонов Клиника	Карши	38.818991672704115	65.79262189827733	6
232	Жавохир мед клиника	карши	38.840972770278235	65.7772446921044	6
233	Пинток ЧК	НУКУС	51.505	-0.09	7
234	Ч/К Малхам	Хорезмская область, Узбекистан	41.27733084606503	61.249220600000015	3
235	Ч/К Аззамед	Хорезмская область, Узбекистан	41.27733084606503	61.249220600000015	3
236	Хараспский ЦРБ	Хазарасп, Хазараспский район, Хорезмская область, 220700, Узбекистан	41.30910150829053	61.09589665000002	3
237	Родилный комплекс РМО Багатского района	Багат, Багатский район, Хорезмская область, Узбекистан	41.35207214451295	60.80756664276124	3
238	ЦРБ г.Ургенч	Ургенч, Ургенчский район, Хорезмская область, 220100, Узбекистан	41.55526288137445	60.63032275000002	3
239	Ч/К Элит Лайф	Хорезмская область, Узбекистан	41.27733084606503	61.249220600000015	3
240	Городская больница г.Самарканд	Самарканд, Самаркандская область, 140000, Узбекистан	39.671435831175955	66.9410389	9
\.


--
-- Data for Name: notification; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.notification (id, author, theme, description, description2, date, unread, med_rep_id, region_manager_id, pharmacy_id, doctor_id, wholesale_id) FROM stdin;
\.


--
-- Data for Name: pharmacy; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pharmacy (id, company_name, contact1, contact2, email, latitude, longitude, address, bank_account_number, inter_branch_turnover, classification_of_economic_activities, "VAT_payer_code", pharmacy_director, discount, brand_name, med_rep_id, region_manager_id, ffm_id, product_manager_id, deputy_director_id, director_id, region_id) FROM stdin;
20	Хосиятли Фарм Сервис МЧЖ	 943033111			51.49521836024095	-0.04119873046875001	г. Наманган, Давлатободский район,2-kichik nohiya to'quvchi MFY hududida			47730		Юлдашев Гайбулло	0	Хосиятли Фарм Сервис МЧЖ	60	59	35	30	73	1	12
21	Папая Фармацеутикал МЧЖ	 5532066			0	0	г. Коканд, Zavqiyobod ko'chasi, 63-uy			47730		Алимов Дильмурод	0	Папая Фармацеутикал МЧЖ	54	36	35	30	73	1	14
22	Ал-Хикмат Шифо ХК	 912026629			51.52049881659712	-0.02674677851759455	 Ферганская область, Дангаринский район, ГП Дангара, Istiqlol ko'chasi, 22-uy			47730		Рахмонов Давлат	0	Ал-Хикмат Шифо ХК	54	36	35	30	73	1	13
23	Мумиё Оригинал МЧЖ	903098989			0	0	 Ферганская область, г. Коканд, A.Charxiy ko'chasi, 4-uy, 4-xonadon			47730		Мансурова Раъно	0	Мумиё Оригинал МЧЖ	54	36	35	30	73	1	14
24	ХИДОЯТ HУР ФАРМ ХК	5291282			51.50212450017365	-0.09508106744214208	Ферганская область, Бувайдинский район, ГП Ибрат, 1 Киловтепа кишлоги			47730		Ахмедов Баходир	0	ХИДОЯТ HУР ФАРМ ХК	54	36	35	30	73	1	14
25	Камола ХК				0	0	Ферганская область, Бувайдинский район, ГП Ибрат,  Янгикургон шахарчаси			47730		Сотволдиев Муротали	0	Камола ХК	54	36	35	30	73	1	14
26	Ибн Сино ХК	937729449			0	0	 Ферганская область, Бувайдинский район, ССГ Янгикурган, Yangiqo'rg'on ko'chasi			47730		Бурикузиев Илхомжон	0	Ибн Сино ХК	54	36	35	30	73	1	14
27	Азамат Барака Савдо	 672262691			0	0	 г. Гулистан, 4-mavze, 39-uy, 20-xonadon			47730		Мирзажанова Раъно	0	Азамат Барака Савдо	46	42	31	29	73	1	2
14	Кифти-Об Дори Дармон МЧЖ	 909473566			51.515095729563335	-0.10900497436523439	 Китабский район, ГРП Китаб,Katta yo'l ko'chasi, 251-uy			47730		Бобомуродов Хайрулла 	0		60	59	35	30	73	1	6
17	Тонг ХК	 987057900			0	0	 Китабский район, ГРП Китаб, General Jurabekov ko'chasi, 168a-uy			47730		Жабборов Рустам	0	Тонг ХК	60	59	35	30	73	1	6
19	Янгикургон Дори Дармон МЧЖ	 696323461			0	0	Наманганская область, Янгикурганский район, ГП Янгикурган,Furqat MFY, Zarkent ko'chasi, 2-uy					Абдуллаев Мухторжон	0	Янгикургон Дори Дармон МЧЖ	53	36	35	30	73	1	12
28	"AJU-BIZNES-STAR" xususiy korxonasi	972458242			0	0	Сырдарьинская область, г. Гулистан, 1724401, Do'stlik MFY, Turg'un Axmedov ko'chasi, 1 B-uy			47730		YO‘LDOSHEV AZIZBEK	0	"AJU-BIZNES-STAR" xususiy korxonasi	46	42	31	29	73	1	2
29	"GIYOH 25 YIL" mas`uliyati cheklangan jamiyati	 977749011			0	0	Сырдарьинская область, г. Янгиеp, 1724413, Bobur MFY, Bobur ko'chasi, 1-uy			47730		AXRORJON RUSTAMOV AXATQUL O‘G‘LI	0	"GIYOH 25 YIL" mas`uliyati cheklangan jamiyati	46	42	31	29	73	1	2
30	"ISTIQLOL FARM INVEST" mas‘uliyati cheklangan jamiyati	906808664			51.50495077292874	-0.09002473672116154	Сырдарьинская область, Сайхунабадский район, ССГ Иттифок, 1724216811, Shodlik MFY, Shifokorlar ko'chasi, 6-uy			47730		ХОЛБЕКОВ ШЕРАЛИ ТАШПУЛАТОВИЧ	0	"ISTIQLOL FARM INVEST" mas‘uliyati cheklangan jamiyati	46	42	31	29	73	1	2
31	Tosh-Po'lat Pharm				51.499980636437265	-0.11484146118164064	Кухна Чупанота МФЙ, 13 Мавзей, 9-уй,3-Хонадон	20208000905660488001		47730			0	Tosh-Po'lat Pharm	66	65	64	63	73	1	1
32	"ILHOMBEK PHARM MEDICAL" mas`uliyati cheklangan jamiyati	982609020			0	0	 Сырдарьинская область, г. Гулистан, ССГ Улугабад, 1724401807, Bog'dorchilik ko'chasi, 59-uy			 79994		Kodirov Shavkat Abduholiqovich 	0	"ILHOMBEK PHARM MEDICAL" mas`uliyati cheklangan jamiyati	46	42	31	29	73	1	2
34	"GULSHAN FAYZ NUR" mas‘uliyati cheklangan jamiyati				0	0	Сырдарьинская область, г. Гулистан, 1724401, Taraqqiyot MFY Shifokorlar ko'chasi, 28-uy			47730		BO'RONOVA DILOROM TOG'AYEVNA 	0	"GULSHAN FAYZ NUR" mas‘uliyati cheklangan jamiyati	46	42	31	29	73	1	2
35	"THANK-YOU"	946740600			0	0	Алмазарский район, 1726280, ABU BAKR SHOSHIY 1-TOR KO'CHASI, 1-UY	20208000905445145001		56100		 MAXMUDJON NAVRO‘ZOV BESHIMOVICH	0	"THANK-YOU"	82	65	64	63	73	1	1
36	 "MADINA SHIFO NUR"	 933782734			0	0	Сергелийский район, 1726283, 6-MAVZE, MEXRIGIYO KO'CHASI, 47-UY	20208000600308244001		47730		 ДАВРОНБЕКОВ ОТАБЕК СУЛТОНОВИЧ	0	 "MADINA SHIFO NUR"	66	65	64	63	73	1	1
37	Асмир-Фарм МЧЖ	 938376660			0	0	г. Наманган,Yangi Qurilish MFY, N.Ubaydullayev ko`chasi, 9/1-uy			47730		Махкамов Ибрагим	0	Асмир-Фарм МЧЖ	51	36	35	30	73	1	12
38	Хосиятли Фарм Сервис МЧЖ	943033111			0	0	. Наманган, Давлатободский район, 2-kichik nohiya to'quvchi MFY hududida			47730		Юлдашев Гайбулло	0	Хосиятли Фарм Сервис МЧЖ	51	36	35	30	73	1	12
39	Глобус Саноат Савдо МЧЖ	 941500777			51.49769640896799	-0.07585962476342357	г. Наманган,  Do'stlik shoh ko'chasi, 11-uy					Умаров Толиб	0	Глобус Саноат Савдо МЧЖ	51	36	35	30	73	1	12
40	Бек Шифо Фарм Мед МЧЖ	990074238			0	0	Касансайский район, ССГ Чиндавал, 1714207837, Ravot MFY, Jiyda ko'chasi			47730		Базаров Фарходжон	0		51	36	35	30	73	1	12
41	Физио Муолажа ХК	 3752230280			0	0	г. Карши, Nasaf ko'chasi, 160-uy					Эрназарова Насиба	0	Физио Муолажа ХК	62	59	35	30	73	1	6
42	Малхам-Файз-Дилхуш ХК	987769966			0	0	Шахрисабзский район, ССГ Хитай, Sho'rji qishlog'i					Джалилов Акромжон	0	Малхам-Файз-Дилхуш ХК	62	59	35	30	73	1	6
43	Файзли-Шифо-Фарм МЧЖ	907298155			0	0	 г. Карши,X.Bashir ko'chasi, 104-uy			47730		Давронов Шавкатжон	0	Файзли-Шифо-Фарм МЧЖ	62	59	35	30	73	1	6
44	Экскулизив Фарм Шифо ХК				0	0	г. Карши, Yangi tong ko'chasi, 8a-uy			47730		Кенжаев Эрназар	0	Экскулизив Фарм Шифо ХК	62	59	35	30	73	1	6
45	Чориев Уткир-Фарм ХК	919568041			51.49694833298257	-0.11705118262248737	г. Карши, 7-mitti tumani, 36-uy, 26-xonadon			47730		Хидиров Абдивали	0	Чориев Уткир-Фарм ХК	62	59	35	30	73	1	6
46	"AMPULA FARM" 	 983021166			0	0	Чиланзарский район, 1726294, Кichik Xalqa yo'li ko'chasi, 34-35-uylari			47730		 АБДУКОДИРОВ АБДУРАСУЛ	0	"AMPULA FARM"	66	65	64	63	73	1	1
47	Бахор фарм	917777147			0	0	Чиланзарский район, 1726294, Кichik Xalqa yo'li ko'chasi, 			47730		Мухаммаджон	0	1111	66	65	64	63	73	1	1
48	Пинток ХК	 614440486			0	0	Чимбайский район, ГРП Чимбай, Mamutov ko'chasi, r/u			47730		Даулетмуратов Рустем	0	Пинток ХК	85	55	35	30	73	1	7
49	Эдельвейс Фарм МЧЖ	933636363			0	0	г. Нукус, K.Kachakov ko'chasi, 1a-uy			47730		Тулентаева Нургуль	0	Эдельвейс Фарм МЧЖ	85	55	35	30	73	1	7
50	Зайнаб Динора МЧЖ	905938886			0	0	Турткульский район, ССГ Уллубаг, 173Ullubog' aholi punkti			47730		Маткаримов Атабек	0	Зайнаб Динора МЧЖ	85	55	35	30	73	1	7
51	Хожейли-Айдин Кол ХК	 615545533			0	0	Ходжейлийский район, ГРП Ходжейли,  Doslik ko'chasi, 12-uy			47730		Исакова Мубарак	0	Хожейли-Айдин Кол ХК	85	55	35	30	73	1	7
52	Доктор Адхам ХК	 914365456			0	0	г. Ургенч,Y.Bobojonov ko'chasi, 25-uy, 1-yo'lak			47730		Ахмедов Ахмаджон	0	Доктор Адхам ХК	90	37	31	29	73	1	3
53	Мансурбек Фармацеутикал МЧЖ	914313884			0	0	Ханкинский район, ССГ Сарыпаян,Paxtagul mahallasi			47730		Кураязова Нодира	0	Мансурбек Фармацеутикал МЧЖ	90	37	31	29	73	1	3
54	Миржалолбек Муштарибону МЧЖ	 914265808			0	0	Багатский район, ГП Багат, Al Xorazmiy ko'chasi			47730		Палванов Уткирбек	0	Миржалолбек Муштарибону МЧЖ	90	37	31	29	73	1	3
61	Бек Бой Ота ХК	956021978			0	0	Багатский район, ССГ Найман, Nurli Hayot mahallasi, Xiva ko'chasi, 27-uy			47730		Норматова Норгуль	0	Бек Бой Ота ХК	90	37	31	29	73	1	3
62	"JAMSHID" 	975100007			0	0	Хорезмская область, Ургенчский район, ССГ Караул, 1733217855, Yoshlik mahallasi, Ibn Sino ko'chasi, 2-uy			47730		САБИРОВ ДАВРОНБЕК	0	С-7	39	37	31	29	73	1	3
63	"AL-BARON-FARM" 	973554433			0	0	Берунийский район, ГРП Беруни, 1735207501, Sh.Abbos Vali ko'chasi, 84-uy			47730		SAPARBAYEV SUNDET GULIMBAYEVICH	0	"AL-BARON-FARM" 	39	37	31	29	73	1	3
64	"BOBURBEK SHIFOBAXSH"	974523752			0	0	Ургенчский район, ССГ Караман, 1733217844, O'rta bog' mahallasi, Al-Farobiy ko'chasi, 19-uy					 АДАМОВ ЭРКАБОЙ	0	"BOBURBEK SHIFOBAXSH"	39	37	31	29	73	1	3
65	 "XUDAYBERGEN RAMANOV"	 613598720			0	0	Элликкалинский район, ССГ Кырккыз, 1735250823, Baymurat aholi punkti			47730		 РАМАНОВ НУРНАЗАР ХУДАЙБЕРГЕНОВИЧ	0	 "XUDAYBERGEN RAMANOV"	39	37	31	29	73	1	3
66	"PULSPHARM 97" mas`uliyati cheklangan jamiyati	949109797			0	0	Ташкентская область, Бекабадский район, ГП Зафар, 1727220551, Guliston mahallasi, Toshkent ko`chasi			47730		SAIDABDULLAXON KAMOLXONOV MAXMUDXON-O‘G‘LI	0	"PULSPHARM 97" mas`uliyati cheklangan jamiyati	50	47	31	29	73	1	2
67	"MAVLUDAXON-XOJI-ONA" mas‘uliyati cheklangan jamiyati	 999991959			0	0	Ташкентская область, Бекабадский район, ГП Зафар, 1727220551, Farxod ko'chasi, 25-uy			47730		AKBARALIYEVA NODIRA XUDAYNAZAROVNA	0	"MAVLUDAXON-XOJI-ONA" mas‘uliyati cheklangan jamiyati	50	47	31	29	73	1	2
68	"ZULAYXA SAMIRA FARM"	 995406681			0	0	Ургенчский район, ССГ Гайбу, 1733217833, Chinabod ko'chasi, 2-uy, 4-yo'lak			47730		Madrimova Zulayxa Taxirdjanova	0	"ZULAYXA SAMIRA FARM"	40	37	31	29	73	1	3
69	 "ALOE-PLYUS "	975115040			0	0	 г. Ургенч, 1733401, Yu.Bobojonov ko'chasi,11-uy,1-yo'lak			47730		КУРБАНБАЕВ ХАМДАМ	0	 "ALOE-PLYUS "	40	37	31	29	73	1	3
73	Смарт Фарм-Бухара МЧЖ	907445656			0	0	г. Бухара,Alpomish kochasi, 16/2-uy, 24-xona			47730		Мухторов Голиб	0	Смарт Фарм-Бухара МЧЖ	43	42	31	29	73	1	4
74	Ильхом ХК	224-40-04 222-09-55			51.50299604211074	-0.08698940277099611	 г. Бухара, Алпомиш кучаси 5 б уй			47730		Юлдашева Гульнора	0	Ильхом ХК	43	42	31	29	73	1	4
70	 "KARDIOSHER"	 943155166			0	0	 г. Ургенч, 1733401, Tinchlik ko'chasi, 2/2-uy			47730		 YUSUPOVA KUVANCH OTABEKOVNA	0	 "KARDIOSHER"	40	37	31	29	73	1	3
71	Нигина Фарм Саноат МЧЖ	914443307			0	0	г. Бухара,B.Naqshband ko'chasi, 299/5-uy			47730		Жумаев Малик	0	Нигина Фарм Саноат МЧЖ	43	42	31	29	73	1	4
72	Фемили Фармаци ХК	 914128080			0	0	г. Бухара, Jo'bor ko'chasi, 51-uy			47730		Шарипов Феруз	0	Фемили Фармаци ХК	43	42	31	29	73	1	4
79	"228-SON DORIXONA" mas‘uliyati cheklangan jamiyati	 998418298			0	0	 Ташкентская область, г. Чиpчик, 1727419, M.Yusupov ko'chasi, 1-uy					ШАНАСИРОВА ГУЛЬНАРА КАЗАХБАЕВНА	0	"228-SON DORIXONA" mas‘uliyati cheklangan jamiyati	49	47	31	29	73	1	2
80	 "PLATINUM OPTIMA SERVICE" mas‘uliyati cheklangan jamiyati	 998774433			51.494746780341146	-0.10332066333611944	Ташкентская область, Кибрайский район, ГП Дурмон, 1727248565, Markaziy shoh ko'chasi, 238-uy			47730		Nasirov Aziz Ravshanovich	0		49	47	31	29	73	1	2
81	 "BO`STON-FARM" xususiy korxonasi	 707427213			0	0	Ташкентская область, Бостанлыкский район, ГП Собир Рахимов, 1727224566, Ibn Sino ko'chasi, 18-uy					ЮЛДАШЕВА ШАХНОЗА ХАБИБУЛЛАЕВ	0	 "BO`STON-FARM" xususiy korxonasi	49	47	31	29	73	1	2
85	Азиз М	+998-90-733-02-09			41.3732018	69.3232517	г.Карши	1	1	1		Аллаев Олим	0	Азиз М	86	59	35	30	73	1	6
86	МИТТИ Фарм Мед Сервис	+998-90-716-05-65			41.3731749	69.3232861	г.Карши	1	1	1		Акрам ака	0	МИТТИ Фарм Мед Серви	86	59	35	30	73	1	6
78	Олмосхон Темуршох Фарм МЧЖ	916940082			51.48030046642205	-0.09904861450195314	Дангаринский район, Городские поселки ,Istiqlol ko'chasi, 20-uy, 12-					Асланова Зиорат 	0		80	36	35	30	73	1	13
91	Статус Дармон Фарм МЧЖ	 901010300			0	0	 г. Шахрисабз, 1710405, Katta novqat ko'chasi					Мардонов Фаррухжон	0	Статус Дармон Фарм МЧЖ	60	59	35	30	73	1	6
93	 "FAYZ DIYOR FARM	1649999			51.50500286265417	-0.09003639221191408	Шайхантахурский район, 1726277, Бобур кучаси 3б-уй	20208000905181745001		47730		 MADJIDOV ABDURASUL	0	 "FAYZ DIYOR FARM	82	65	64	63	73	1	1
94	"ASHSHARIF FOR ALL" mas‘uliyati cheklangan jamiyati	994724213			51.508954805558666	-0.08854320138219186	Сырдарьинская область, г. Гулистан, 1724401, Namuna MFY			42990		ABDULXAEV SHARIF MAMADLAIKOVICH	0		46	42	31	29	73	1	2
95	"FIRDAVS BEK FAYOZ BEK FARM" mas`uliyati cheklangan jamiyati	 911020722			0	0	Сырдарьинская область, г. Гулистан, 1724401, 4-mavze, 64-uy, 82-xonadon			47730		SUYUNDIKOVA BARNO ABDUHAKIMOVNA	0		46	42	31	29	73	1	2
96	 "EKO FARM-S" mas`uliyati cheklangan jamiyati	915051919			0	0	Сырдарьинская область, г. Гулистан, 1724401, Namuna MFY, Xalqlar Do`stligi ko`chasi			 47730		JAXONGIR XOSHIMOV AXMADALI O‘G‘LI	0		46	42	31	29	73	1	2
97	"XURSHIDA-NUR-FARM" mas‘uliyati cheklangan jamiyati	902400505			0	0	Сырдарьинская область, г. Гулистан, 1724401, Taraqqiyot MFY, Sayxun ko'chasi, 10-uy			46460		ILHOMOVA XURSHIDA TO‘LQIN QIZI 	0		46	42	31	29	73	1	2
98	Био плюс фарм	+998903921711			0	0	Шайхонтохур , ул Гулобод			47730			0	Био плюс фарм	82	65	64	63	73	1	1
99	Наманган Вилоят Тиббиёт Маркази	+998 91 362 62 42			0	0	Наманган	1			1	Директор 	0	Наманган Вилоят Тиббиёт Маркази	51	36	35	30	73	1	12
100	Наманган Кардиология	+998 91 362 62 42			0	0	Наманган	1			1	Директор	0	Наманган Кардиология	51	36	35	30	73	1	12
101	Ором Шифо МЧЖ				0	0	Чартакский район, ГП Пастки Пешкургон, To`pqayrag`och MFY, Jaxonbaxsh ko`chasi, 10-uy					ABDULLAYEV ISMOILJON 	0	Ором Шифо МЧЖ	53	36	35	30	73	1	12
102	Мед Темур-Фарм МЧЖ				0	0	Шахрисабзский район, ГП Чоршанбе,  Chorshanbe mahallasi			47730			0	Мед Темур-Фарм МЧЖ	60	59	35	30	73	1	6
103	Уктам Нур Турдиали Ота ФХ	 919633970			0	0	Шахрисабзский район, ССГ Кунчикар, Yangiobod MFY, Saksonkapa qishlog'i			47730		МУСУРМОНОВ НУРАЛИ ТУРДИАЛИЕВИЧ	0	Уктам Нур Турдиали Ота ФХ	60	59	35	30	73	1	6
108	Пиковит МЧЖ	 987768688	 987768688		0	0	г. Карши, Islom Karimov ko'chasi, 89-uy			47730		MURODILLAYEV FARXOD	0	Пиковит МЧЖ	62	59	35	30	73	1	6
109	Нематов Ю	+998-90-105-07-01		nematpv@mail.ru	40.503656163814526	68.76808034732736	Гулистон	0000	0000	0000		Суннат	0	Нематов Ю	46	42	31	29	73	1	16
110	Нафиса Фарм Нукус ХК	 399-70-08			0	0	г. Нукус, А.Шамуратова кучаси 836 уй 			47730		АМИРОВ НАЖИП	0	Нафиса Фарм Нукус ХК	85	55	35	30	73	1	7
113	Фирдавс Фарм Таблетка ХК				51.504865960900254	-0.08269786834716798	 Qashqadaryo viloyati, Shahrisabz tumani,  Shakarteri QFY Big'mi qishlog'i, Big'mi mahallasi, 685-uy					Raupova Yulduz Numonovna	0	Фирдавс Фарм Таблетка ХК	60	59	35	30	73	1	6
116	KLPJ	+998-98-989-80-90			37.785834	-122.406417	Kogon	\N	8978989	\N	\N	Elmurood	0	SKPK	80	7	4	3	73	1	4
117	Саидамир Фарм МЧЖ	 949012515			51.55024846279614	-0.12034285653433009	Республика Каракалпакстан, Амударьинский район, ГРП Мангит, Madaniyat ko'chasi, 86-uy			47730		Matyakupov Otabek Radjapovich 	0	Саидамир Фарм МЧЖ	85	55	35	30	73	1	7
118	Аптека 999	+998-93-123-45-67			41.36871062500954	69.31600630052885	чилонзор 16	\N	234567890	\N	\N	Курбанов Абдумалик	0	Аптека 999	80	7	4	3	73	1	1
119	Аптека Сарвиноз	+998-90-123-45-67			41.3729617	69.3235486	чилонзор 16	\N	234567890	\N	\N	Кадыров Рустам	0	Аптека 7777	80	7	4	3	73	1	1
120	Кардио Сервис Термиз МЧЖ	 942003824			0	0	Сурхандарьинская область, Термезский район, ССГ Пахтаабад,Qaxramon mahallasi			86100		ЖУРАЕВ ЧАРИ БАЙМУРАТОВИЧ	0	Кардио Сервис Термиз МЧЖ	86	59	35	30	73	1	19
115	NEW HOSPITAL	+998-98-765-44-56			37.773645746077854	-122.40985022753911	Toshbuloq	\N		\N	\N	New zemed	0	New pharmacy	80	7	4	3	73	1	6
121	Ажинияз Каракалпак МЧЖ	 933672717			0	0	г. Нукус, 1735401, M.Jumanazarov ko'chasi, 72- uy			47730		КАЛЖАНОВА ЖУЛДЫЗ ЖАЛГАСОВНА	0	Ажинияз Каракалпак МЧЖ	104	55	35	30	73	1	7
122	Китоб Виолет МЧЖ				0	0	Китабский район, ГРП Китаб, G.Jo'rabek ko'chasi 180 uy			47730		 АШУРОВ ОТАБЕК ФОЗИЛОВИЧ	0	Китоб Виолет МЧЖ	60	59	35	30	73	1	6
124	Umarbek Lider Farm	998432231			51.50293259709163	-0.0665915242451387	Toshkent viloyati						0		50	47	31	29	73	1	2
125	"MADINA-FARM SINTEZ" mas‘uliyati cheklangan jamiyati	909245435			51.51002720570347	-0.0665915242451387	Бухарская область, г. Бухара, 1706401, Bog'i Amir ko'chasi, 29-uy			 79994		SHADMANOV YUNUS XOTAMOVICH	0		43	42	31	29	73	1	4
126	SAXOVAT UNIVERSAL FARM	970070688			0	0							0		100	47	31	29	73	1	1
135	Лаванда Мед Фарм МЧЖ	 900018700			0	0	 Ферганская область, Бувайдинский район, Yangiqo'rg'on qishlog'ida			47730		ASQAROVA NILUFARXON MANSURJON QIZI	0	Лаванда Мед Фарм МЧЖ	54	36	35	30	73	1	13
136	777 фарм	+998-71-271-54-47			41.2827776	69.1813035	чилонзор 23  42 уй	306429662	12345	1111		Хусан	0	7777 фарм	82	65	64	63	73	1	1
140	Мадина Фарм Сентез	+998-99-712-33-00			38.80304566842243	65.81141654279602	Қарши	\N	302488808	\N	\N	Даврон	0	Мадина фарм	62	59	35	30	73	1	6
142	Нуробод Фарм Агро ХК	6451095			0	0	Ташкентская область, Ахангаранский район, ГП Ен-арик, Корахитой кфй Енарик кишлоги 			47730		АБДУРАХМАНОВ БУНЁД МУМИНАЛИЕВИ	0	Нуробод Фарм Агро ХК	100	47	31	29	73	1	2
143	"МАЛАК ХОНИМ" МЧЖ	907131266			0	0	Жинговуз МФЙ, К.Отаниёзов кучаси, 1/3						0		40	37	31	29	73	1	3
144	"ЗИЛОЛ ХАЛОЛ"МЧЖ	971216766			0	0	Дустлик МФЙ, Миришкорлар кучаси, 171уй						0		46	42	31	29	73	1	2
145	"ДИАНА ФАРМ" ХК	946984526			0	0	Ташкентская область, г. Чиpчик, 1727419, 36-sonli Navruz mahallasi, Gulyayev ko'chasi			47730		ILYASOVA DIANA SULEYMANOVNA	0		49	47	31	29	73	1	2
146	Доктор Одил Мед Фарм ХК	+998 33 321 22 20			0	0	Розугар МФЙ, Ислом Каримов куч., д.381			47730		Директор	0	Доктор Одил Мед Фарм ХК	62	59	35	30	73	1	6
147	Доктор Одил Мед Фарм ХК	+998 33 321 22 20			0	0	Розугар МФЙ, Ислом Каримов куч., д.381			47730		Директор	0	Доктор Одил Мед Фарм ХК	62	59	35	30	73	1	6
148	Централ кардио сервис	+998-93-333-33-33			41.273512500435366	69.25167085700177	улица Кичик халка йули 51, Узбекистан	20208000800419102001	00440	47730		Рузметова	0	В/Б Централ Кардио Сервис	82	65	64	63	73	1	1
149	Мерос Фарм МЧЖ	 979140509			0	0	Самаркандская область, г. Самарканд, Beruniy ko'chasi, 1-uy, 5-xona			46460		ПУЛОТОВ СУХРОБ ШАВКАТОВИЧ	0	Мерос Фарм МЧЖ	60	59	35	30	73	1	6
151	Мирзохид Искандер ХК	 912179857			0	0	г. Шахрисабз,Tutzor mahallasi, Ipak yo'li ko'chasi, 108a-uy			47730		 ХУШВАКТОВ АБДУЖАМИЛ ТОШЕВИЧ	0	Мирзохид Искандер ХК	60	59	35	30	73	1	6
92	Абзалбек-Шифо  ХК	 914613334			41.389173242317945	69.22207712021827	Ташкент, 100000, Узбекистан			47730		Рахмонов Серабжон	0	Абзалбек-Шифо  ХК	60	59	35	30	73	1	1
154	ВАРРАНТИ ФАРМ	 907319111	\N	war@mail.ru	0	0	 Қуччи МФЙ 19 уй Қуччи МФЙ	\N	207173344	\N	\N	BARNAYEV JONIBEK TOYIROVICH 	0	WARRANTY FARM" MCHJ	110	42	31	29	73	1	5
153	 "MADINA SHIFO NUR 2"	+998933138050	\N	abf@mail.ru	0	0	Сергили 6 мерхие	\N	302938451	\N	\N	 ДАВРОНБЕКОВ ОТАБЕК СУЛТОНОВИЧ	0	 "MADINA SHIFO NUR"	82	65	64	63	73	1	1
156	Ботирбек Фарм	994773377	\N	botirbek@mail.ru	0	0	Сырдарьинская область, г. Гулистан, 1724401, U.Yusupov mahallasi, Ibn Sino ko'chasi, 16 A-uy	\N	204413481	\N	\N	Kuchimov Sirojiddin Mamatkulovich	0	Ботирбек Фарм	46	42	31	29	73	1	2
157	ОЛТИНСОЙ ЖАННАТ	942251594	\N	oltinsoy@mail.ru	0	0	Навоийская область, Хатырчинский район, ССГ Пулкан Шоир, 1712251851, Chilosh qishlog'i	\N	304581525	\N	\N	Yuldoshyev Oxunjon Farmon o'g'li	0	ОЛТИНСОЙ ЖАННАТ	110	42	31	29	73	1	5
158	ИСЛАМОБОД ФАЙЗ МАДАД ХК	949118282	\N	ISLAM/M@MAIL.RU	0	0	Сырдарьинская область, г. Гулистан, 1724401, Rudakiy ko'chasi, 25-uy	\N	304357106	\N	\N	AYUPOVA XURSANDOY KAHHORJON QIZI	0	ИСЛАМОБОД ФАЙЗ МАДАД ХК	46	42	31	29	73	1	2
159	ИНТЕРФАРМЕД	909637555	\N	inter@mail.ru	0	0	Хорезмская область, г. Хива, 1733406, Feruz ko'chasi, raqamsiz uy	\N	201243664	\N	\N	Kadirov Bekchonbay Atanazarovich 	0	"INTERFARMED" mas‘uliyati cheklangan jamiyati	40	37	31	29	73	1	3
160	Вамилан	+998-93-931-71-50			38.851762552529976	65.79911298791308	Карши	\N	302089813	\N	\N	Элёр Холмахматов	0	Вамилан Шифо фарм	62	59	35	30	73	1	6
161	ФАРРУХ - 95	956035177	\N	far95@mail.ru	0	0	Навоийская область, г. Навои, 1712401, X.Dustligi ko'chasi, 56-uy, 6-xonadon	\N	202619463	\N	\N	Xakimova Ra'no Kurbonovna	0	"ФАРРУХ-95" xususiy firmasi	114	42	31	29	73	1	5
162	ЭКСИМФАРМ	939602060	\N	exim@mail.ru	0	0	 Бухарская область, г. Каган, 1706403, Shifokorlar ko'chasi, 2-uy	\N	306996204	\N	\N	Muxsinov Farxod Mirjanovich	0	ЭКСИМФАРМ	43	42	31	29	73	1	4
123	Экономфарм МЧЖ	909781166			0	0	Ташкентская область, Бекабадский район, ГП Зафар, 1727220551, Bo'ston mahallasi, Ibn Sino ko'chasi			(47730)		BURIBOYEV ADXAMJON ABDUVALIYEVICH	0	Экономфарм МЧЖ	50	47	31	29	73	1	2
163	Мегафарм Медикал Трейд МЧЖ	944949939	\N	megapharm@mail.ru	0	0	 Ферганская область, Бувайдинский район, ССГ Янгикурган,Kelajak ko'chasi 	\N	307615534	\N	\N	 ЮЛДАШЕВ ДОНИЁРЖОН ДУМАНЖОНОВИЧ	0	Мегафарм Медикал Трейд МЧЖ	54	36	35	30	73	1	13
164	ХУЖАИ-ЖАХОН ГРАНД	985710050	\N	xojaui@mail.ru	0	0	Навоийская область, г. Навои, 1712401, Lochin MFY, I.Sino ko'chasi, 37 A-uy / I.Sino ko'chasi 37a-uy	\N	302807986	\N	\N	ORZIYEV AZMAT G'ULOMOVICH	0	"XUJAI-JAXON GRAND" mas‘uliyati cheklangan jamiyati	114	42	31	29	73	1	5
165	Шохрух Шохжахон Сарвар фарм	+998-97-803-03-68	+998-88-103-01-00		39.1193649	66.8933525	Китоб	205761303	01048	71264		Хидирали Шомиров Ганиевич	0	шохрух Шохжахон Сарвар	60	59	35	30	73	1	6
166	Меъёр-Сихат-Шифо МЧЖ	916912274	\N	meyorsihatshifo@mail.ru	0	0	Ферганская обл.,Бувайдийский р-н,Янгикургон КФЙ,ул.Келажак, 16	\N	303307223	\N	\N	Жалилов Зохиджон	0	Меъёр-Сихат-Шифо МЧЖ	54	36	35	30	73	1	13
167	Zuma Farm	+998-20-010-00-91			40.43749454847332	70.60420843447096	Buvayda t-ni	\N	303307223	\N	\N	Jalilov Zokhid	0	Me'yor Sihat Shifo	54	36	35	30	73	1	13
168	Китоб шифо нур фарм	+998-97-723-33-96			39.1187336	66.8909456	Китоб туман	307692109	01048	40519144		Шокирова Дилфуза	0	Китоб Шифо Нур Фарм	60	59	35	30	73	1	6
169	Бинафша	+998-91-469-82-81			39.1196617	66.8903167	Китоб туман	17102328	17414024	71212		Ражабов Гайриддин Магрибович	0	Бинафша	60	59	35	30	73	1	6
170	ОДИНА ФАРМ	958600294	\N	odina@mail.ru	0	0	Sirdaryo viloyati, Guliston sh. Taraqqiyot MFY, Nurli kelajak 3-tor ko'chasi, 1122-uy	\N	310513993	\N	\N	ESHNIYOZOV ABDUQODIR ABDURASULOVICH 	0	ОДИНА ФАРМ	46	42	31	29	73	1	16
171	"SAIDAKMAL PHARM" mas‘uliyati cheklangan jamiyati	 900052226	\N	saidakmal@mail.ru	0	0	Навоийская область, Карманинский район, ГП Кармана, 1712234551, Navro`z ko`chasi, 31-uy	\N	 307426025	\N	\N	Hayitov Sherali Izzatulloyevich	0	Saidakmal farm	114	42	31	29	73	1	5
172	"SAV MEGA PHARM 2021" mas‘uliyati cheklangan jamiyati	 999191619	\N	savmega@mail.ru	0	0	Сырдарьинская область, г. Гулистан, 1724401, Beruniy ko'chasi, 1-A uy	\N	308086844	\N	\N	 XUDAYKULOV SARVAR SABIROVICH	0	"SAV MEGA PHARM 2021" mas‘uliyati cheklangan jamiyati	46	42	31	29	73	1	16
173	Орзигул фарм савдо	+998-91-639-44-64			39.092848	66.8263576	Шахрисабз	01947	304577781	083960		Султанов Ойбек	0	Орзигул фарм савдо	60	59	35	30	73	1	6
174	"OG'ALAR BIZNES PHARM" mas‘uliyati cheklangan jamiyati	994774040	\N	ogalar@mail.ru	0	0	город Ташкент, Юнусабадский район, 1726266, 19-MAVZE, DEXQONOBOD KO'CHASI	\N	306711764	\N	\N	 XAYDAROV ISLOMJON G‘AYRATJON O‘G‘LI	0	ОГАЛАР БИЗНЕС ФАРМ	46	42	31	29	73	1	16
175	"ШАХЗОД" mas‘uliyati cheklangan jamiyati	0000	\N	shaxzodf@mail.ru	0	0	Навоийская область, Учкудукский район, ГРП Учкудук, 1712248501, Mustaqillik MFY, A.Temur ko'chasi, 24-uy, 24-xonadon	\N	202974783	\N	\N	Norqulov Jasur Yoqubovich	0	"ШАХЗОД" mas‘uliyati cheklangan jamiyati	110	42	31	29	73	1	5
176	"DINARA FARM" хусусий корхонаси	998914280322	\N	dinara@mail.ru	0	0	Хорезмская область, Ургенчский район, ССГ Караул, 1733217855, Ибн-Сино кучаси 12/1-уй	\N	 302735744	\N	\N	САТЛИКОВ ЖАЛАЛАДДИН	0	"DINARA FARM" хусусий корхонаси	39	37	31	29	73	1	3
178	амирбек рухшона фп	+998-95-194-42-52			41.3227723	69.2198152	Самарканд дарвоща 2/2	\N	303328933	\N	\N	шомуродов шахбоз	0	Амирбек рухшона фарм	82	65	64	63	73	1	1
179	Мубина ЭКО фарм	+998-90-675-37-37			39.1186873	66.890633	Китоб	3077711904	00913	23340718		Шарифов Мусурмон Нарзинвич	0	Мубина ЭКО Фарм	60	59	35	30	73	1	6
183	Ната Вигор Фарм	+998-90-012-00-99	+998-12-345-67-78	natavigorpharm@mail.ru	41.281443322699694	69.18939593578196	Yunusobod tumani 11-MAVZE	\N	309263308	\N	\N	PULATOV SHOHRUHMIRZO FAXRIDINOVICH	0	Ната Вигор Фарм	82	65	64	63	73	1	1
181	 "KAFOLAT FARM SERVIS" mas‘uliyati cheklangan jamiyati	 913389111	\N	kafolat@mail.ru	0	0	Навоийская область, Хатырчинский район, ССГ Бахчакалан, 1712251824, Bog'chakalon MFY, Bog'chakalon qishloq, 47-uy	\N	204985713	\N	\N	XAMROYEV OTABEK XOLMAMATOVICH	0	 "KAFOLAT FARM SERVIS" mas‘uliyati cheklangan jamiyati	110	42	31	29	73	1	5
184	Соглом яхши	+998-98-308-51-21		info@mail.ru	41.19713066321978	69.23416001353851	Mirzo Ulug'bek tumani Qorasu 6-mavzesi, 11-uy	\N	207189370	\N	\N	MAXMUDOV ILXOM KOSIMOVICH	0	Соглом Яхши	82	65	64	63	73	1	1
182	Оптовая аптека К.Б	939876543	\N	1@mail.ru	0	0	Таш.обл	\N	123123	\N	\N	Каршиев Бобомурод	0	Оптовая аптека К.Б	100	47	31	29	73	1	2
185	Сарвиноз медикал групп	+998-90-336-66-96			41.31034524860965	69.3028565203256	Taraqqiyot 2-tor ko'chasi, 25-uy, 11-xona	\N	303337431	\N	\N	TILAKOV JASURBEK RUSTAMOVICH	0	Сарвиноз медикал групп	82	65	64	63	73	1	1
180	Генезис Трейд	+998-93-123-12-34			41.37276046732327	69.32223286111346	ул. Икбол, 14, Юнусабадский район, Ташкент	\N	123	\N	\N	Кадиров	0	Генезис Трейд	82	65	64	63	73	1	1
186	Синтез Фарм Люкс	917750033	\N	sintez@mail.ru	0	0	 Ташкентская область, г. Чиpчик, 1727419, X.A.Yassaviy ko'chasi, 8-uy, 1A-xonadon	\N	305092871	\N	\N	 СЕЙТИСЛЯМОВ АЛИМ МУФРЕТОВИЧ	0	Синтез Фарм Люкс	49	47	31	29	73	1	2
187	Азимжон Нозим Фарм	951959055	\N	azv@mail.ru	0	0	Ташкентская область, г. Чиpчик, 1727419, A.Navoiy shoh ko'chasi, 309-uy, 1-xonado	\N	 303843824	\N	\N	 ШАМСИЕВ ЖАМШИД ЭРГАШЕВИЧ	0	Азимжон Нозим Фарм	49	47	31	29	73	1	2
188	Жалолиддин Нур Бизнес	983131000	\N	m_dikus_m@inbox.ru	0	0	Toshkent viloyati, Chirchiq sh. Madaniyat ko'chasi, 29-uy, 16-xonadon	\N	303496948	\N	\N	RASULMATOV KAMOLIDDIN ORTIKOVICH 	0	Жалолиддин Нур Бизнес	49	47	31	29	73	1	2
191	Дармон Мед Фарм	 997290410	\N	akromov@mail.ru	0	0	Toshkent viloyati, Chinoz tumani, Chinoz shahri Xo'ja mahallasi, Beruniy ko'chasi, 11-uy	\N	309623475	\N	\N	AKRAMOV ABDUSHUKUR GAFAROVICH ceo	0	"AAA DARMON MED FARM" mas`uliyati cheklangan jamiyati	49	47	31	29	73	1	2
193	Беш Юлдуз Мед Фарм МЧЖ	975202036	\N	5yulduz@mail.ru	41.0548360024717	71.63631084999999	г. Наманган,Nuriddin Ubaydullayev ko'chasi, 7-uy	\N	305947960	\N	\N	 TOHIRJANOV BOSITXON JAMOLIDDIN O‘G‘LI	0	Беш Юлдуз Мед Фарм МЧЖ	51	36	35	30	73	1	12
195	Мадина Ташкент Абдурауф	000000	\N	madina@mail.ru	0	0	Юнусабад	\N	000000	\N	\N	Саидкомил Саидахмадович Тошпулатов	0	Мадина Ташкент Абдурауф	50	47	31	29	73	1	2
189	Мадина Ташкент Салима	000000	\N	madina@mail.ru	0	0	Юнусабад	\N	000000	\N	\N	Саидкомил Саидахмадович Тошпулатов	0	Мадина Ташкент Салима	49	47	31	29	73	1	1
190	САМ ФАРМ САЛИМА	 977008948	\N	samfarm@gmail.com	0	0	Toshkent shahri, Yashnobod tumani Mumtoz MFY, Mumtoz ko'chasi, 5-uy	\N	308077333 	\N	\N	Саидкомил Саидахмадович Тошпулатов	0	САМ ФАРМ САЛИМА	49	47	31	29	73	1	1
192	Нодирабегим 	000000	\N	nodi@mail.ru	0	0	Юнусабад	\N	000000	\N	\N	Саидкомил Саидахмадович Тошпулатов	0	Нодирабегим Зам Зам	50	47	31	29	73	1	2
194	САМ ФАРМ АБДУРАУФ	000000	\N	sam@mail.ru	0	0	Юнусабад	\N	000000	\N	\N	Саидкомил Саидахмадович Тошпулатов	0	САМ ФАРМ АБДУРАУФ	50	47	31	29	73	1	2
196	"DAVLATBEK-IMPEKS" хусусий дорихонаси	 672-67-53	\N	dav@mail.ru	0	0	 Самаркандская область, Нарпайский район, ГРП Акташ, 1718218501, Зирабулок кучаси,130	\N	 205145894	\N	\N	 ТЕМУРОВА ФОТИМА БАХТИЁРОВНА	0	"DAVLATBEK-IMPEKS" хусусий дорихонаси	110	42	31	29	73	1	9
197	"OZODA NAFIS SAVDO" mas‘uliyati cheklangan jamiyati	933354242	\N	ozo@mail.ru	0	0	Самаркандская область, Нарпайский район, ГРП Акташ, 1718218501, Zirabuloq ko'chasi, 2 a-uy	\N	301898417	\N	\N	 РУСТАМОВ ИКРОМ НОРКУЛОВИЧ	0	"OZODA NAFIS SAVDO" mas‘uliyati cheklangan jamiyati	110	42	31	29	73	1	9
198	САМ ФАРМ БОБОМУРОД	000000	\N	sam@mail.ru	0	0	Юнусабад	\N	000000	\N	\N	Саидкомил Саидахмадович Тошпулатов	0	САМ ФАРМ БОБОМУРОД	100	47	31	29	73	1	2
199	"LUCK BRANCH STAR" mas`uliyati cheklangan jamiyati	 974043030	\N	luch@mail.ru	0	0	Toshkent viloyati, Yangiyo'l shahri Samarqand ko'chasi, 189 а-uy	\N	302329569	\N	\N	 ERNAZAROV SHOXRUX BAXTIYOROVICH 	0	"LUCK BRANCH STAR" mas`uliyati cheklangan jamiyati	100	47	31	29	73	1	2
200	"SHARH-5" mas‘uliyati cheklangan jamiyati	 888777711	\N	noaa7077@mail.ru	51.51101277815347	-0.16839981079101565	 Toshkent viloyati, Olmaliq sh. Ulug'bek Ko'chasi, 82-uy, 2-xonadon	\N	308145407 	\N	\N	TOJIMUROTOV ABROR ABDUXALIL O‘G‘LI 	0	"SHARH-5" mas‘uliyati cheklangan jamiyati	100	47	31	29	73	1	9
201	"ELNUR MALHAM" mas`uliyati cheklangan jamiyati	 993388161	\N	BAHRIDDIN@MAIL.RU	0	0	Samarqand viloyati, Narpay tumani, Oqtosh shahri Yangiobod mahallasi	\N	309183605	\N	\N	 TURDIYEV BAXRIDDIN GANIYEVICH	0	"ELNUR MALHAM" mas`uliyati cheklangan jamiyati	110	42	31	29	73	1	9
202	"ASIA GROUP PHARM" mas`uliyati cheklangan jamiyati	 981150149	\N	example@gmail.com	0	0	 Toshkent shahri, Sirg'ali tumani 8-mavze, 18B-uy	\N	305197645	\N	\N	 XUSHBOQOV SALIMJON G‘OZIBOY O‘G‘LI	0	"ASIA GROUP PHARM" mas`uliyati cheklangan jamiyati	100	47	31	29	73	1	1
203	Рахмонов Нурбек Насимович	+998-91-463-40-50			39.1145133	66.91133	Китоб	300613842	49322100	339267		Рахмонов Нурбек Насимович	0	Рахмонов Нурбек Насимович	60	59	35	30	73	1	6
204	Китоб Илхом фарм	+998-97-587-07-41			39.1143489	66.9114173	Китоб	301167123	32024636	01772		Холматов Саидкул Алламуратович	0	Китоб Илхом фарм	60	59	35	30	73	1	6
205	Нукус ШТБ	 942003824	\N	guzal@mail.ru	0	0	Нукус	\N	3020152587	\N	\N	Директор	0	Нукус ШТБ	116	55	35	30	73	1	7
206	Шуманай Районная Больница	 933672717	\N	megapharm@mail.ru	42.45654091411644	59.61148950000001	Республика Каракалпакстан	\N	3020152587	\N	\N	Директор	0	Шуманай Районная Больница	116	55	35	30	73	1	7
208	"OZODBEK-YAN-FARM" xususiy korxonasi	902425254, 3673504999	\N	ozodbek@mail.ru	0	0	Sirdaryo viloyati, Yangiyer sh. Bobur ko'chasi	\N	205253673	\N	\N	 KUNDUZOV SHUXRAT TURSUNBOYEVICH	0	"OZODBEK-YAN-FARM" xususiy korxonasi	46	42	31	29	73	1	16
209	САМ ФАРМ ФЕРУЗА	000000	\N	azav@mail.ru	0	0	Юнусабад	\N	000000	\N	\N	Саидкомил Саидахмадович Тошпулатов	0	САМ ФАРМ ФЕРУЗА	46	42	31	29	73	1	16
210	ЗЕБИНИСО АББОС	935025013	\N	mov@mail.ru	0	0	Хорезмская область	\N	000000	\N	\N	Куриязова Зебинисо	0	ЗЕБИНИСО АББОС	40	37	31	29	73	1	3
211	ЗЕБИНИСО  ШИФО	 941163014	\N	ozimbay65@umail.uz	0	0	Xorazm viloyati, Xonqa tumani, Xonqa shaharchasi Imorat ko'chasi, 13-uy	\N	203028684	\N	\N	 XAJIYEV OZIMBAY SATIMOVICH 	0	"ZEBINISO SHIFO" oilaviy korxonasi	90	37	31	29	73	1	3
212	Test	+99895555555	\N	test@gmail.com	41.34164915242109	69.17642255456533	Test Address	\N	1231231	\N	\N	Eshmat	0	Test brand	40	37	31	29	73	1	14
213	Орие-Мехр МЧЖ	 915216494	\N	oriyo-mehr@mail.ru	39.643238836436524	66.94639205932619	Самаркандская область, г. Самарканд, A.Temur ko'chasi, 184-uy	\N	 205137001	\N	\N	 ТУРДАЛИЕВ ДЖАВАТ БАХОДИРОВИЧ	0	Орие-Мехр МЧЖ	53	36	35	30	73	1	9
214	Кадр ХК	 912110400	\N	qadr@mail.ru	39.06227166474751	66.83540970000001	Кашкадарьинская область, г. Шахрисабз,Shodiyona ko'chasi, 27-uy	\N	203117558	\N	\N	 ОСТОНОВ ОЙБЕК ЭРКИНОВИЧ	0	Кадр ХК	60	59	35	30	73	1	6
217	Кунград Рай.Больница	 915216494	\N	qungrad@mail.ru	43.04626388331385	58.84603310000001	Кунградский р-н	\N	200384317	\N	\N	Директор	0	Кунград Рай.Больница	116	55	35	30	73	1	7
216	Жаннат Шифо Дори-Дармон	+998-97-775-96-98			39.1092783	66.8644233	Китоб	\N	309236252	\N	\N	Уринов Мехрож	0	Жаннат Шифо Дори-Дармон	60	59	35	30	73	1	6
215	Эконом Фарм Груп	+998-91-320-05-50			39.0423645	66.8251502	Шахрисабз	\N	304908874	\N	\N	Феруз Фармонов	0	Эконом фарм	60	59	35	30	73	1	6
218	Резалют Мед Фарм Савдо	+998-91-956-17-02			38.89014242217052	65.80356269654992	Қарши	\N	303132276	\N	\N	Уйғун ака	0	Резалют мед фарм	62	59	35	30	73	1	6
219	Биг Фемили Шамсиева Ф.	+998-91-203-88-85			40.51886370792194	70.9449238282861	Коканд	\N		\N	\N	Директор	0	Биг Фемили Шамсиева Ф.	54	36	35	30	73	1	14
220	Мерос Фарм Худ-ва Гулаим	+998-90-700-73-94			42.425533316757935	59.59826960070883	Каракалпакстан	\N		\N	\N	Директор	0	Мерос Фарм Худ-ва Гулаим	85	55	35	30	73	1	7
207	Канлыколь ТТБ	 933672717	\N	megapharm@mail.ru	42.45654091411644	59.61148950000001	Республика Каракалпакстан	\N	3052567847	\N	\N	Директор	0	Канлыколь ТТБ	116	55	35	30	73	1	7
221	Саба фармед	+998-97-718-48-98			41.33080304160376	69.21671304334411	нурафшон кучаси 74/4	\N	306859674	\N	\N	жуманиезов Улугбек	0	Саба фармед	82	65	64	63	73	1	1
155	Мермарфарм	9015689525	\N	mermarpharm@mail.ru	41.2902835	60.5428537	Хорезмская область, Узбекистан	\N	309384814	\N	\N	Директор	0	Мермарфарм	40	37	31	29	73	1	3
222	Мадина ФС Халилова Ю.	 915216494	\N	madina@mail.ru	37.9520843	67.1265996	Сурхандарьинская обл.	\N	302548854	\N	\N	Директор	0	Мадина ФС Халилова Ю.	86	59	35	30	73	1	19
223	Опт.аптека Халимова З.	+998 33 321 22 20	\N	opt@mail.ru	51.503169680658665	-0.21783828735351565	Кашкадарьинская область, г. Шахрисабз,Shodiyona ko'chasi, 27-uy	\N	2038899887	\N	\N	Директор	0	Опт.аптека Халимова З.	62	59	35	30	73	1	6
224	Коканд Плюс Медикал ХК	 944980300	\N	kpm@mail.ru	40.52351433864821	70.94044455000002	Ферганская область, г. Коканд, 1730405, Guzar ko'chasi, 112-uy	\N	300285714	\N	\N	НИГМАТОВ АБДУЛХАМИД АДХАМОВИЧ	0	Коканд Плюс Медикал	54	36	35	30	73	1	14
225	"ШИФОБАХШ" хусусий дорихонаси	 262636	\N	shifov@mail.ru	40.5224262587814	68.77251975000003	Sirdaryo viloyati, Guliston sh. Абу Али Ибн Сино кучаси	\N	202123820	\N	\N	YULDASHEV KAMBARALI XXX ceo	0	"ШИФОБАХШ" хусусий дорихонаси	46	42	31	29	73	1	16
226	"NABIJON SHIFO FARM" xususiy korxonasi	993108206	\N	nabi_bazarov@mail.ru	39.671435831175955	66.9410389	Samarqand viloyati, Narpay tumani, Oqtosh shahri Yangiobod mahallasi	\N	000000	\N	\N	 BAZAROV NABIJON KUCHKAROVICH 	0	"NABIJON SHIFO FARM" xususiy korxonasi	110	42	31	29	73	1	9
227	"ASADBEK FARM OQ-OLTIN" mas`uliyati cheklangan jamiyati	 931574488	\N	ziyoda1988@mail.uz	42	64	Navoiy viloyati, Xatirchi tumani, Olchinobod QFY Fidokor MFY, Fidokor ko‘chasi, r/s-uy	\N	310853974 	\N	\N	NAZAROVA ZIYODA MUZAFFAROVNA	0	"ASADBEK FARM OQ-OLTIN" mas`uliyati cheklangan jamiyati	110	42	31	29	73	1	5
228	Мадина Ташкент Бобомурод	000000	\N	mad@mail.ru	41.290189952618555	69.32373046477882	Юнусабад	\N	000000	\N	\N	Саидкомил Саидахмадович Тошпулатов	0	Мадина Ташкент Бобомурод	100	47	31	29	73	1	1
229	Мирзохид Искандар ХК	 912179857	\N	mirzoxid@mail.ru	39.06227166474751	66.83540970000001	г. Шахрисабз, Tutzor mahallasi, Ipak yo'li ko'chasi, 108a-uy	\N	202526041	\N	\N	 ХУШВАКТОВ АБДУЖАМИЛ ТОШЕВИЧ	0	Мирзохид Искандар ХК	62	59	35	30	73	1	6
230	Исмоил медикал	909730603	\N	1@mail.ru	51.67896870677015	-0.8509240508151784	Toshkent shahri, Chilonzor tumani Kichik xalqa yo'li ko'chasi, 36-uy	\N	303735371	\N	\N	Миржалалова Адиба	0	Исмоил медикал	82	65	64	63	73	1	1
177	Ажинияз Нукус МЧЖ	 933672717	\N	ajiniyaz@mail.ru	43.7738841	57.6234617	Республика Каракалпакстан, Узбекистан	\N	300519942	\N	\N	КАЛЖАНОВА ЖУЛДЫЗ ЖАЛГАСОВНА	0	Ажинияз Нукус МЧЖ	85	55	35	30	73	1	7
231	"НОЛДИРАБЕГИМ " mas‘uliyati cheklangan jamiyati	 999991959	\N	nodirabegim@mail.ru	40.22082380610203	69.25264220000004	Ташкентская область, Бекабадский район, ГП Зафар, 1727220551, Guliston mahallasi, Ibn Sino ko'chasi, 26 A-uy	\N	 200557432	\N	\N	AKBARALIYEVA NODIRA XUDOYNAZAROVNA	0	"НОЛДИРАБЕГИМ " mas‘uliyati cheklangan jamiyati	50	47	31	29	73	1	2
232	"SILVER FARMATSY" mas'uliyati cheklangan jamiyati	994079070	\N	silverrasmatsy@umail.uz	41.4755193454986	69.58365330000001	 Toshkent viloyati, Chirchiq sh. Gulyayev ko'chasi, 6a-uy	\N	 305127976	\N	\N	 BABADJANOVA LIDIYA KARIMOVNA	0	"SILVER FARMATSY" mas'uliyati cheklangan jamiyati	49	47	31	29	73	1	2
233	Ислом Фарм Медикал	907201413	\N	AKRAM@INBOX.UZ	38.82807631564662	65.81899459999998	 Qashqadaryo viloyati, Qarshi sh. Jayxun ko'chasi	\N	307164241	\N	\N	 SAIDOV FARRUX PO‘LATOVICH 	0	Ислом Фарм Медикал	62	59	35	30	73	1	6
234	Жасмин Улугбек фарм	+998-90-007-81-25			41.27196533758315	69.20790392894041	Наккошлик кучаси 1уй	\N	207172939	\N	\N	Турдиев Жусурбек	0	Жасмин Улугбек Фарм	82	65	64	63	73	1	1
235	Физио Фарм ХК	907201410	\N	AKRAM@INBOX.UZ	38.83008001147299	65.78699111938478	Roguzar MFY, Jayxun ko'chasi, 1-uy	\N	311166199	\N	\N	Гаппаров Умиджон	0	Физио Фарм ХК	62	59	35	30	73	1	6
236	Мехригие Сухроб	+998-93-684-41-82		meh@mail.ru	39.77396291327194	64.42538036235486	Бухарская область, г. Бухара, 1706401, Orifon ko'chasi, 3-muyulish, 10-uy	\N	200861902	\N	\N	Дехканов Собир	0	Мехригул Сухроб	43	42	31	29	73	1	4
237	Фарм Сервис	+998-99-802-87-90		farm@mail.ru	41.471862617097756	69.5840594935259	Ташкентская область, г. Чиpчик, 1727419, Ayniy ko'chasi, 40-uy	\N	304301183	\N	\N	Акрамов Ахрор	0	Фарм Сервис	49	47	31	29	73	1	2
238	Фито Фарм	+998-79-223-60-65			41.00957820684992	69.1170107898149	Навоийская область, г. Навои, 1712401, Islom Karimov ko'chasi, 52A-uy	\N	205126427	\N	\N	Ярмухаммедов Санжар	0	Фито Фарм Лек	110	42	31	29	73	1	5
239	Гента Фарм	907251413	\N	raxmanov@mail.ru	51.505	-0.09	 Qashqadaryo viloyati, Qarshi sh. Jayxun ko'chasi	\N	201436835	\N	\N	Директор	0	Гента Фарм	86	59	35	30	73	1	6
240	АБЗАЛ ФАРМ	+998-98-311-07-78		abzal@mail.ru	41.042268765369904	69.35786676723589	Ташкентская область, г Нурафшан, 1727401, 233 уй	\N	305835887	\N	\N	Мусаев АБЗАЛ Аскарович	0	АБЗАЛ ФАРМ	100	47	31	29	73	1	2
241	Перизат-2000 ХК	+998 90 700 73 94	\N	perizat@mail.ru	43.7738841	57.6234617	Каракалпакстан, г. Нукус,Ulli jipek joli ko'chasi, 1a-uy	\N	 203491973	\N	\N	 УЛЬПЕТОВА ТАЗАХАН	0	Перизат-2000 ХК	85	55	35	30	73	1	7
242	экомед кардио	+998-97-314-72-05			41.28963097131065	69.2757208163023	Карши	\N	306616858	\N	\N	Фаррух Рахимов	0	экомед кардио	62	59	35	30	73	1	6
243	Сумуруз Андиз	+998-97-385-61-16			39.048335	66.834595	Шахрисабз	\N	204818404	\N	\N	Курбонов Шавкат	0	Сумуруз Андиз	60	59	35	30	73	1	6
244	Азиза Фарм	905884581	\N	aziza@mail.ru	37.9520843	67.1265996	Сурхандарья	\N	305898774	\N	\N	Азиз	0	Азиза Фарм	86	59	35	30	73	1	19
\.


--
-- Data for Name: pharmacy_doctor; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pharmacy_doctor (doctor_id, pharmacy_id) FROM stdin;
300	22
301	21
302	22
303	19
304	19
304	101
305	101
306	99
307	100
308	20
308	17
308	14
309	91
310	91
311	92
311	14
312	102
312	91
313	14
317	110
318	48
322	52
344	31
344	36
339	98
340	93
342	32
343	95
357	113
314	108
361	117
369	119
369	118
409	120
384	68
461	121
473	122
308	122
379	41
377	44
378	42
379	45
380	108
383	108
382	108
311	103
313	103
370	78
508	109
514	123
485	123
516	69
531	135
532	146
367	148
308	149
480	142
583	142
384	143
588	30
589	151
591	151
592	151
593	14
594	64
415	62
571	144
342	109
596	109
597	81
467	81
466	81
472	79
472	145
597	145
598	145
598	81
485	124
599	153
426	153
531	26
600	154
601	154
590	91
602	156
600	157
601	157
606	158
473	14
607	159
608	161
609	161
610	161
441	162
531	163
469	80
611	71
612	71
616	164
621	164
602	32
531	21
531	24
638	97
640	162
639	162
450	162
610	171
299	172
299	170
643	174
457	174
594	176
648	21
649	21
351	91
450	72
651	21
650	21
317	50
600	181
601	181
632	181
369	78
369	115
370	115
652	180
302	21
388	183
340	184
652	185
577	35
613	173
654	91
656	205
657	206
658	207
301	22
659	178
426	93
626	169
303	213
662	217
655	216
300	219
317	220
666	22
622	22
409	222
420	221
300	21
300	224
668	172
643	225
457	225
616	161
669	161
670	161
675	196
676	196
583	198
480	198
481	198
477	198
480	199
477	199
478	199
480	228
477	228
478	228
479	228
476	228
481	228
481	200
308	179
652	230
591	215
684	151
362	177
466	189
469	189
467	189
644	189
468	190
466	190
597	190
602	209
602	96
664	218
522	208
384	210
412	210
322	211
604	211
603	211
673	231
474	123
486	231
485	231
472	232
472	81
612	72
674	154
601	175
674	175
649	26
688	193
685	14
690	160
381	160
378	160
453	42
317	48
691	48
378	233
\.


--
-- Data for Name: pharmacy_fact; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pharmacy_fact (id, quantity, date, monthly_plan, doctor_id, product_id, pharmacy_id) FROM stdin;
168	50	2024-08-12 04:30:39.251304	50	304	5	101
169	18	2024-08-12 11:58:22.326478	50	312	25	91
170	5	2024-08-12 11:58:22.326478	50	357	30	113
171	5	2024-08-12 11:58:22.326478	10	357	19	113
172	5	2024-08-12 11:58:22.326478	20	357	12	113
173	5	2024-08-12 11:58:22.326478	20	357	24	113
174	5	2024-08-12 11:58:22.326478	20	357	18	113
175	5	2024-08-12 11:58:22.326478	20	357	25	113
176	3	2024-08-12 12:24:15.837712	10	357	10	113
177	3	2024-08-12 12:24:15.837712	10	357	10	113
178	20	2024-08-12 12:24:15.837712	50	311	25	92
179	21	2024-08-13 02:35:16.56022	100	361	25	117
180	100	2024-08-13 02:35:16.56022	100	301	24	21
181	200	2024-08-13 02:35:16.56022	200	409	12	120
182	47	2024-08-13 02:35:16.56022	100	309	12	91
183	10	2024-08-13 02:35:16.56022	100	314	13	108
184	20	2024-08-13 02:35:16.56022	50	314	27	108
185	500	2024-08-13 10:07:30.114076	500	461	28	121
186	5	2024-08-13 12:09:01.358402	10	473	13	122
187	20	2024-08-13 12:09:01.358402	30	308	25	122
188	120	2024-08-13 12:09:01.358402	250	304	25	19
189	10	2024-08-13 12:09:01.358402	10	303	7	19
190	5	2024-08-13 12:09:01.358402	5	303	10	19
191	20	2024-08-13 12:09:01.358402	100	303	13	19
192	30	2024-08-13 12:09:01.358402	30	303	23	19
193	30	2024-08-13 12:09:01.358402	50	378	25	42
194	35	2024-08-13 12:09:01.358402	46	313	12	103
195	20	2024-08-13 12:09:01.358402	50	311	25	103
196	50	2024-08-13 12:09:01.358402	50	508	24	109
197	50	2024-08-13 12:09:01.358402	50	343	12	95
198	50	2024-08-13 12:09:01.358402	50	343	13	95
200	50	2024-08-13 12:09:01.358402	50	485	19	123
201	20	2024-08-14 11:51:29.177458	20	514	28	123
203	34	2024-08-14 11:51:29.177458	70	516	5	69
204	10	2024-08-14 11:51:29.177458	10	531	25	135
205	20	2024-08-15 11:23:50.543949	20	300	12	22
206	20	2024-08-15 11:23:50.543949	50	302	13	22
207	32	2024-08-15 11:23:50.543949	70	310	12	91
208	20	2024-08-15 11:23:50.543949	20	480	28	142
209	20	2024-08-15 11:23:50.543949	20	480	19	142
210	50	2024-08-15 11:23:50.543949	100	480	25	142
211	30	2024-08-15 11:23:50.543949	50	480	13	142
212	100	2024-08-15 11:23:50.543949	100	583	25	142
213	30	2024-08-21 07:39:51.766803	30	384	13	143
214	30	2024-08-21 07:39:51.766803	100	384	25	143
215	10	2024-08-21 07:39:51.766803	10	588	24	30
216	10	2024-08-21 07:39:51.766803	10	588	12	30
217	50	2024-08-21 07:39:51.766803	50	589	25	151
218	20	2024-08-21 07:39:51.766803	20	591	15	151
219	10	2024-08-21 07:39:51.766803	10	591	14	151
220	10	2024-08-21 07:39:51.766803	10	591	27	151
221	20	2024-08-21 07:39:51.766803	20	591	12	151
222	5	2024-08-21 07:39:51.766803	5	592	33	151
224	17	2024-08-22 05:40:04.718187	17	593	12	14
225	20	2024-08-22 05:40:04.718187	20	593	24	14
226	20	2024-08-22 05:40:04.718187	20	593	13	14
227	20	2024-08-22 05:40:04.718187	50	311	25	92
228	30	2024-08-22 05:40:04.718187	30	594	33	64
229	330	2024-08-22 05:40:04.718187	330	415	13	62
230	0	2024-08-22 11:35:58.418879	10	571	24	144
231	30	2024-08-22 11:35:58.418879	0	342	12	109
232	20	2024-08-22 11:35:58.418879	20	596	13	109
233	10	2024-08-23 04:46:18.303644	10	597	31	81
234	30	2024-08-23 04:46:18.303644	200	467	25	81
238	50	2024-08-23 04:46:18.303644	50	597	13	81
239	50	2024-08-23 04:46:18.303644	0	472	25	145
242	30	2024-08-23 10:32:41.542732	30	344	11	31
244	100	2024-08-23 10:32:41.542732	100	472	25	79
246	20	2024-08-23 11:35:41.198726	50	485	19	124
247	100	2024-08-23 11:35:41.198726	100	344	25	36
251	10	2024-08-24 09:55:36.547117	50	531	25	26
252	20	2024-08-26 05:57:51.376778	50	600	28	154
253	30	2024-08-26 05:57:51.376778	50	601	25	154
254	10	2024-08-26 05:57:51.376778	30	601	13	154
255	10	2024-08-26 05:57:51.376778	20	601	27	154
258	100	2024-08-26 05:57:51.376778	20	426	12	153
259	100	2024-08-26 05:57:51.376778	100	599	13	153
260	10	2024-08-26 05:57:51.376778	50	590	25	91
261	18	2024-08-26 05:57:51.376778	100	309	12	91
262	20	2024-08-26 05:57:51.376778	20	532	24	146
263	20	2024-08-26 05:57:51.376778	30	378	13	42
264	20	2024-08-26 05:57:51.376778	20	606	24	158
265	20	2024-08-26 05:57:51.376778	10	473	13	14
272	120	2024-08-26 05:57:51.376778	250	304	25	19
274	30	2024-08-26 05:57:51.376778	50	531	25	163
278	50	2024-08-26 05:57:51.376778	50	611	13	71
282	10	2024-08-26 05:57:51.376778	10	571	24	144
283	10	2024-08-29 10:25:24.451674	50	590	25	91
291	30	2024-08-30 06:53:43.92577	30	616	13	164
292	30	2024-08-30 06:53:43.92577	30	621	12	164
297	200	2024-08-30 06:53:43.92577	200	409	24	120
298	200	2024-08-30 06:53:43.92577	200	409	20	120
299	300	2024-08-30 06:53:43.92577	200	409	12	120
300	300	2024-08-30 06:53:43.92577	400	409	25	120
302	20	2024-08-30 06:53:43.92577	50	531	25	26
303	20	2024-09-03 11:45:40.812014	100	602	24	32
304	5	2024-09-03 11:45:40.812014	150	601	25	157
305	5	2024-09-03 11:45:40.812014	500	601	13	157
306	5	2024-09-03 11:45:40.812014	20	601	27	157
307	20	2024-09-05 08:00:17.108568	200	531	25	21
312	10	2024-09-05 08:00:17.108568	200	531	25	24
316	5	2024-09-05 09:25:02.931301	5	643	31	174
326	50	2024-09-05 09:25:02.931301	50	648	24	21
327	57	2024-09-05 09:25:02.931301	57	649	24	21
328	23	2024-09-05 09:25:02.931301	25	351	12	91
329	23	2024-09-05 09:25:02.931301	25	590	12	91
330	50	2024-09-09 09:56:53.48952	50	450	25	72
331	50	2024-09-09 09:56:53.48952	150	601	25	154
332	10	2024-09-09 09:56:53.48952	10	651	27	21
333	10	2024-09-09 09:56:53.48952	10	650	27	21
334	50	2024-09-09 09:56:53.48952	200	317	25	50
338	100	2024-09-10 12:08:11.081189	100	648	24	21
339	20	2024-09-10 12:08:11.081189	70	577	27	35
340	10	2024-09-10 12:08:11.081189	100	531	25	135
341	400	2024-09-10 12:08:11.081189	400	461	28	121
353	100	2024-09-11 12:45:01.844764	100	648	24	21
354	50	2024-09-11 12:45:01.844764	150	472	25	79
355	16	2024-08-31 18:40:00	16	369	19	115
356	20	2024-08-19 17:22:00	30	302	19	21
357	100	2024-08-19 17:22:00	100	648	24	21
358	50	2024-08-19 08:50:00	100	301	24	22
359	22	2024-08-05 14:07:00	87	317	31	110
360	320	2024-08-12 10:52:00	400	317	25	110
361	140	2024-08-02 10:04:00	140	656	27	205
362	20	2024-08-12 10:04:00	30	658	27	207
363	30	2024-08-31 10:04:00	30	657	27	206
365	10	2024-09-13 11:48:00	30	659	30	178
366	10	2024-09-13 11:48:00	30	659	13	178
367	15	2024-09-12 12:00:00	20	308	25	122
368	10	2024-09-12 12:30:00	10	357	30	113
369	10	2024-09-12 12:30:00	10	357	12	113
370	10	2024-09-12 13:00:00	10	626	25	169
373	20	2024-09-12 12:00:00	50	311	25	92
374	20	2024-09-13 12:47:00	20	426	11	93
377	10	2024-09-10 15:12:00	20	590	25	91
378	1	2024-09-10 15:12:00	20	590	25	91
379	11	2024-09-10 15:12:00	20	654	25	91
380	134	2024-09-16 14:18:00	134	303	5	213
382	10	2024-09-11 15:12:00	50	613	25	173
383	75	2024-09-13 13:00:00	75	662	27	217
384	10	2024-09-17 15:00:00	10	655	19	216
385	5	2024-09-17 00:00:00	20	590	25	91
386	5	2024-09-17 00:00:00	10	309	25	91
387	15	2024-09-17 00:00:00	50	310	12	91
388	15	2024-09-17 00:00:00	50	309	12	91
389	120	2024-09-18 10:41:00	300	304	25	19
390	40	2024-09-18 11:19:00	50	313	12	103
391	60	2024-09-18 11:35:00	100	302	12	21
392	30	2024-09-18 12:23:00	100	300	18	219
394	3	2024-08-30 17:18:00	3	317	20	220
395	10	2024-09-19 00:00:00	100	300	18	22
396	10	2024-09-19 00:00:00	10	302	19	22
397	48	2024-09-19 00:00:00	48	622	38	22
398	48	2024-09-19 00:00:00	48	666	38	22
399	15	2024-09-19 00:00:00	40	300	12	22
403	5	2024-08-31 10:22:00	5	409	4	222
404	5	2024-08-31 10:22:00	5	409	11	222
405	9	2024-08-31 10:22:00	400	409	25	222
406	120	2024-09-20 12:31:00	200	317	25	50
407	45	2024-09-20 12:33:00	50	599	13	153
408	20	2024-09-20 13:00:00	100	378	25	42
409	5	2024-09-20 14:17:00	10	420	31	221
410	10	2024-09-20 14:17:00	10	420	30	221
411	10	2024-09-21 18:00:00	10	369	25	115
412	110	2024-09-12 10:02:00	110	656	27	205
413	100	2024-09-24 12:38:00	100	300	21	224
414	20	2024-09-24 12:40:00	50	310	12	91
415	19	2024-09-24 12:40:00	50	351	12	91
416	10	2024-09-09 12:46:00	10	668	24	172
417	2	2024-09-13 15:16:00	5	643	31	225
418	10	2024-09-13 15:16:00	10	643	12	225
419	10	2024-09-13 15:16:00	10	643	13	225
425	20	2024-09-24 15:25:00	20	588	12	30
426	20	2024-09-24 15:25:00	20	588	24	30
433	15	2024-09-06 12:27:00	15	669	12	161
434	15	2024-09-06 12:27:00	15	669	13	161
435	15	2024-09-06 12:27:00	15	669	12	161
436	15	2024-09-06 12:27:00	15	669	13	161
437	20	2024-09-06 12:27:00	20	670	27	161
438	56	2024-09-23 13:14:00	150	616	13	164
439	50	2024-09-23 13:14:00	50	616	12	164
440	20	2024-09-23 13:14:00	30	616	25	164
441	20	2024-09-26 14:14:00	50	311	25	92
442	10	2024-09-25 14:29:00	100	531	25	24
443	20	2024-09-26 15:05:00	70	577	27	35
444	10	2024-09-25 15:12:00	10	655	19	216
446	16	2024-09-25 16:22:00	16	591	12	215
447	50	2024-09-26 16:30:00	50	684	12	151
448	20	2024-09-26 16:30:00	20	684	24	151
449	60	2024-09-26 16:30:00	60	589	25	151
450	10	2024-09-25 17:37:00	20	308	25	179
452	15	2024-09-06 12:27:00	15	669	12	161
453	15	2024-09-06 12:27:00	15	669	13	161
454	20	2024-09-06 12:27:00	20	670	27	161
455	20	2024-09-23 13:14:00	30	616	25	164
456	56	2024-09-23 13:14:00	150	616	13	164
457	50	2024-09-23 13:14:00	50	616	12	164
458	100	2024-09-27 13:00:00	100	362	12	177
459	20	2024-09-27 13:00:00	20	362	31	177
460	20	2024-09-27 13:00:00	20	362	37	177
461	20	2024-09-27 13:00:00	20	664	33	218
462	20	2024-09-18 11:35:00	20	302	12	21
463	20	2024-09-18 11:35:00	40	302	12	21
464	20	2024-09-18 11:35:00	40	300	12	21
465	50	2024-09-10 11:41:00	50	673	25	231
466	100	2024-09-21 11:49:00	100	474	25	123
467	50	2024-09-21 11:57:00	50	486	25	231
468	71	2024-09-23 14:19:00	71	485	25	231
469	50	2024-09-21 11:57:00	50	486	25	231
470	50	2024-09-13 18:28:00	150	472	25	79
471	50	2024-09-19 18:32:00	300	472	12	81
472	50	2024-09-19 18:32:00	150	472	13	81
473	120	2024-09-19 18:32:00	150	472	25	81
474	50	2024-09-12 15:15:00	50	450	25	72
475	10	2024-09-12 16:32:00	20	675	25	196
476	20	2024-09-12 16:32:00	20	676	13	196
477	10	2024-09-25 16:34:00	10	674	12	154
478	20	2024-09-25 16:34:00	30	674	13	154
479	9	2024-09-20 16:43:00	150	601	25	175
480	5	2024-09-20 16:43:00	250	601	12	175
481	400	2024-10-03 12:56:00	400	461	28	121
482	10	2024-10-07 13:40:00	100	531	25	135
483	20	2024-10-08 13:44:00	100	531	25	26
484	20	2024-10-08 13:44:00	100	649	24	26
485	150	2024-10-03 14:08:00	150	688	13	193
486	120	2024-10-08 17:40:00	250	303	25	19
487	10	2024-10-03 17:56:00	100	685	19	14
488	30	2024-10-03 17:56:00	50	593	12	14
489	30	2024-10-03 17:56:00	50	313	12	14
490	30	2024-10-03 17:56:00	100	473	13	14
491	10	2024-10-03 18:11:00	10	626	25	169
492	20	2024-10-04 18:25:00	75	308	25	17
493	20	2024-10-07 18:32:00	75	311	25	92
494	10	2024-10-08 18:36:00	75	590	25	91
495	30	2024-10-08 18:36:00	50	351	12	91
496	10	2024-10-04 18:43:00	100	690	24	160
499	10	2024-10-04 18:43:00	50	381	27	160
500	10	2024-10-04 18:43:00	200	378	13	160
501	14	2024-10-07 19:00:00	25	377	25	44
502	30	2024-10-08 19:08:00	200	378	13	42
503	15	2024-10-08 19:08:00	25	453	25	42
504	120	2024-10-08 19:10:00	200	317	25	50
505	20	2024-10-09 19:13:00	20	651	27	21
\.


--
-- Data for Name: pharmacy_hot_sale; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pharmacy_hot_sale (id, amount, date, product_id, pharmacy_id) FROM stdin;
52	100	2024-08-15 11:23:50.542649	25	142
53	10	2024-08-22 11:35:58.417558	24	144
28	0	2024-07-31 09:53:53.614068	25	100
29	0	2024-07-31 09:53:53.614068	12	99
30	0	2024-07-31 09:53:53.614068	13	99
31	0	2024-07-31 09:53:53.614068	26	99
32	0	2024-07-31 09:53:53.614068	11	100
33	0	2024-07-31 09:53:53.614068	5	19
54	34	2024-08-23 04:46:18.302376	25	81
56	59	2024-08-26 05:57:51.374329	13	71
57	10	2024-08-26 05:57:51.374329	24	144
72	4	2024-09-12 13:06:50.402417	19	115
\.


--
-- Data for Name: pharmacy_plan; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pharmacy_plan (id, description, theme, date, status, postpone, pharmacy_id, med_rep_id) FROM stdin;
36	закуп	закуп	2024-07-30 09:47:09.155572	f	f	91	60
43	нимадир	киринг малумот олинг	2024-07-30 14:36:19.325784	f	f	78	80
46	закуп	закуп	2024-07-30 16:52:03.629602	f	f	21	54
47	креакард	креакард	2024-07-30 17:00:59.777383	f	f	21	54
49	идрен	идрен	2024-07-31 09:23:03.852628	f	f	22	54
39		креакард	2024-07-30 11:25:00	t	f	92	60
42		креакард	2024-07-08 11:33:00	t	f	17	60
41		креакард	2024-07-30 11:28:00	t	f	92	60
37		эритропен	2024-07-30 11:21:00	t	f	14	60
50		закуп	2024-07-31 12:44:00	t	f	99	51
51		креакард	2024-07-31 14:27:00	t	f	100	51
52		FDP 5	2024-07-31 16:30:00	t	f	19	53
53		эксипар и креакард	2024-07-31 16:31:00	t	f	19	53
54		креакард	2024-07-31 16:32:00	t	f	101	53
38		эксипар и креакард	2024-07-30 11:22:00	t	f	14	60
55		креакард	2024-07-31 17:34:00	t	f	92	60
56		эксипар	2024-07-31 17:59:00	t	f	102	60
58	эритропен	эритропен	2024-07-31 09:30:00	f	f	103	60
88		креакард	2024-08-08 17:03:00	t	f	91	60
89		закуп	2024-08-08 17:11:00	t	f	113	60
60	фдп 5	фдп 5	2024-01-08 14:35:00	f	f	101	53
61		креакард	2024-08-01 14:36:00	t	f	101	53
63	balans	kirish	2024-08-01 16:10:28.049696	f	f	35	82
66	креакард	краекард	2024-08-05 09:24:30.479167	f	f	36	66
67	выписка	креакард	2024-07-30 09:26:00	t	f	36	66
68		креакард	2024-07-30 09:58:00	t	f	17	60
92		креакард	2024-08-08 17:47:00	t	f	92	60
94		креакард	2024-08-07 10:21:00	t	f	117	85
69		Винкорел эксипар 6мл	2024-08-05 16:09:00	t	f	22	54
70		эксипар 6	2024-08-05 16:55:00	t	f	22	54
71		ерр	2024-08-06 11:25:00	t	f	32	46
73		эксипар 6	2024-08-06 11:54:00	t	f	91	60
113		закуп	2024-08-14 13:29:00	t	f	103	60
76	das	Kiring	2024-08-06 15:40:12.493574	f	f	52	90
77	dasda	dasas	2024-08-06 15:21:11.442886	f	f	61	90
78		апрозум	2024-08-06 15:56:00	t	f	110	85
79		fdp	2024-08-06 16:15:00	t	f	101	53
82		креакард	2024-08-06 17:00:00	t	f	91	60
97		эллеус	2024-08-12 11:26:00	t	f	21	54
99		эксипар 4	2024-08-12 11:59:00	t	f	120	86
100		эксипар	2024-08-12 12:24:00	t	f	91	60
102		закуп	2024-08-02 12:43:00	t	f	108	62
103		диабертион	2024-08-13 16:11:00	t	f	121	104
104		закуп	2024-08-13 17:09:00	t	f	122	60
105		закуп	2024-08-13 17:34:00	t	f	19	53
111		креакард	2024-08-14 12:25:00	t	f	42	62
115		...	2024-08-02 16:21:00	t	f	109	46
117		..	2024-08-12 16:27:00	t	f	95	46
118		..	2024-08-05 16:45:00	t	f	123	50
119		..	2024-08-07 16:53:00	t	f	124	50
120		..	2024-08-06 17:41:00	t	f	69	40
124		.	2024-08-14 14:36:00	t	f	135	54
127		.	2024-08-16 12:48:00	t	f	22	54
129		.	2024-08-19 11:21:00	t	f	91	60
135		..	2024-08-19 11:28:00	t	f	142	100
138		..	2024-08-19 12:41:00	t	f	143	40
141		..	2024-08-20 16:52:00	t	f	30	46
142		.	2024-08-08 09:58:00	t	f	151	60
143		.	2024-08-21 10:53:00	t	f	14	60
144		.	2024-08-22 11:19:00	t	f	92	60
145		...	2024-08-20 15:31:00	t	f	64	39
146		..	2024-08-21 15:34:00	t	f	62	39
148		bbn	2024-08-19 16:42:00	t	f	144	46
149		...	2024-08-19 17:09:00	t	f	109	46
155		..	2024-08-21 15:10:00	t	f	81	49
151		..	2024-08-05 14:20:00	t	f	81	49
152		...	2024-08-07 14:27:00	t	f	81	49
153		..	2024-08-14 15:03:00	t	f	81	49
154		..	2024-08-20 15:08:00	t	f	145	49
157		ФДП	2024-08-23 15:30:00	t	f	31	66
156		..	2024-08-08 15:20:00	t	f	79	49
130		.	2024-08-20 15:17:00	t	f	146	62
158		..	2024-08-23 17:12:00	t	f	124	50
159		креакард	2024-08-23 17:55:00	t	f	36	66
160	.	эксипар 6	2024-08-23 18:17:00	t	f	153	82
162		.	2024-08-22 09:35:00	t	f	26	54
163		..	2024-08-22 10:58:00	t	f	154	110
164		..	2024-08-23 11:00:00	t	f	154	110
165	,	Эксипар	2024-08-26 10:59:02.034105	f	f	153	82
166		Эксипар	2024-08-16 11:08:00	t	f	153	82
167		.	2024-08-22 11:16:00	t	f	91	60
168		.	2024-08-26 12:54:00	t	f	42	62
171		..	2024-08-26 15:56:00	t	f	158	46
169		.	2024-08-22 12:57:00	t	f	14	60
172	.	эритропен	2024-08-27 11:48:48.996133	f	f	93	82
173		..	2024-08-27 14:12:00	t	f	161	114
175		..	2024-08-27 17:26:00	t	f	162	43
176		.	2024-08-28 11:16:00	t	f	19	53
177		.	2024-08-27 11:46:00	t	f	163	54
179		..	2024-08-28 12:17:00	t	f	80	49
180		..	2024-08-28 12:47:00	t	f	71	43
181		.	2024-08-29 15:35:00	t	f	91	60
182		..	2024-08-29 11:49:00	t	f	164	114
183		.	2024-08-29 12:49:00	t	f	120	86
184		.	2024-08-30 12:55:00	t	f	120	86
185		.	2024-08-30 15:36:00	t	f	26	54
186		.	2024-09-05 11:59:00	t	f	32	46
187		.	2024-09-05 12:21:00	t	f	157	110
188		креакард	2024-09-05 13:32:00	t	f	21	54
189		креакард	2024-09-05 13:32:00	t	f	24	54
192		.	2024-09-05 13:42:00	t	f	97	46
193		.	2024-09-05 15:35:00	t	f	162	43
194		.	2024-09-06 10:56:00	t	f	174	46
195		.	2024-09-06 10:47:00	t	f	21	54
196		.	2024-09-06 10:50:00	t	f	21	54
197		эксипар 4	2024-09-06 12:21:00	t	f	91	60
199	.	.	2024-09-09 15:37:00	t	f	72	43
198		.	2024-09-09 15:36:00	t	f	154	110
200		эритропен 10000	2024-09-06 16:35:00	t	f	21	54
201		креакард	2024-09-09 16:49:00	t	f	50	85
202		.	2024-09-10 11:55:00	t	f	181	110
206	.	.	2024-08-06 15:09:00	f	f	68	40
95		креакард	2024-08-12 10:52:00	t	f	110	85
207	.	.	2024-08-27 15:31:00	f	f	159	40
208	.	.	2024-08-28 15:54:00	f	f	62	39
211		загруз эритр 10 тыс -20 шт	2024-09-10 09:28:00	t	f	35	82
209		идрен и эллеус	2024-08-19 17:22:00	t	f	21	54
212		креакард	2024-09-10 12:26:00	t	f	135	54
213	.	диабертион	2024-11-09 15:32:00	f	f	121	104
214	.	.	2024-09-11 14:39:31.133332	f	f	196	110
215	.	диабертион	2024-11-09 15:32:00	f	f	121	104
217	.	.	2024-09-11 14:45:23.244611	f	f	197	110
216		диабертион	2024-09-11 14:40:00	t	f	121	104
218		креакард	2024-09-10 15:12:00	t	f	91	60
219		креакард	2024-09-11 15:12:00	t	f	173	60
220	.	.	2024-09-11 16:46:21.499761	f	f	201	110
221		.	2024-09-11 16:51:00	t	f	79	49
222	hgv	hvb	2024-09-12 13:00:00	f	f	115	80
225		hsh	2024-08-31 18:40:00	t	f	115	80
226		эллеус	2024-08-19 08:50:00	t	f	22	54
204		апрозума	2024-08-05 14:07:00	t	f	110	85
227		.	2024-08-02 10:04:00	t	f	205	116
229		.	2024-08-12 10:04:00	t	f	207	116
228		.	2024-08-31 10:04:00	t	f	206	116
230	договор	Арлевин и эксипар	2024-09-13 11:48:00	t	f	178	82
231		креакард	2024-09-12 12:00:00	t	f	122	60
234		.	2024-09-12 12:30:00	t	f	113	60
235		.	2024-09-12 13:00:00	t	f	169	60
236		ФДП-10	2024-09-13 12:47:00	t	f	93	82
233		.	2024-09-12 12:00:00	t	f	92	60
237	.	.	2024-08-01 12:50:00	f	f	200	100
238		Ych	2024-09-13 14:00:00	t	f	115	80
239		.	2024-09-16 14:18:00	t	f	213	53
242		закуп	2024-09-13 13:00:00	t	f	217	116
240		идрен	2024-09-17 15:00:00	t	f	216	60
241		.	2024-09-17 00:00:00	t	f	91	60
243		.	2024-09-18 10:41:00	t	f	19	53
244		.	2024-09-18 11:19:00	t	f	103	60
245		.	2024-09-18 11:35:00	t	f	21	54
246		.	2024-09-18 12:23:00	t	f	219	54
248		.	2024-08-30 17:18:00	t	f	220	85
249		закуп	2024-09-19 00:00:00	t	f	22	54
250	.	.	2024-09-17 12:00:00	f	f	155	40
251	.	.	2024-09-20 10:22:22.138512	f	f	222	86
252		.	2024-08-31 10:22:00	t	f	222	86
253		.	2024-09-20 12:31:00	t	f	50	85
254		эксипар 6	2024-09-20 12:33:00	t	f	153	82
255		.	2024-09-20 13:00:00	t	f	42	62
257	.	.	2024-09-05 14:15:00	f	f	80	49
258		загруз	2024-09-20 14:17:00	t	f	221	82
259		hfsdhfd	2024-09-21 18:00:00	t	f	115	80
261		.	2024-09-12 10:02:00	t	f	205	116
266		.	2024-09-24 12:38:00	t	f	224	54
267		.	2024-09-24 12:40:00	t	f	91	60
268		.	2024-09-09 12:46:00	t	f	172	46
269		.	2024-09-13 15:16:00	t	f	225	46
270		.	2024-09-24 15:25:00	t	f	30	46
302		.	2024-10-03 12:56:00	t	f	121	104
273		продажа	2024-09-24 16:12:00	t	f	178	82
304		.	2024-10-07 13:40:00	t	f	135	54
277		.	2024-09-26 14:14:00	t	f	92	60
279		.	2024-09-25 14:29:00	t	f	24	54
280		бронь	2024-09-26 15:05:00	t	f	35	82
281		.	2024-09-25 15:12:00	t	f	216	60
282		фдп10	2024-09-26 15:14:00	t	f	230	82
283	.	.	2024-09-12 15:26:00	f	f	101	53
284		.	2024-09-25 16:22:00	t	f	215	60
285		.	2024-09-26 16:30:00	t	f	151	60
286		.	2024-09-25 17:37:00	t	f	179	60
275		.	2024-09-06 12:27:00	t	f	161	114
276	.	.	2024-09-23 13:14:00	t	f	164	114
287	.	.	2024-09-25 11:56:00	f	f	161	114
288		.	2024-09-27 13:00:00	t	f	177	85
289		.	2024-09-27 13:00:00	t	f	218	62
290	.	.	2024-09-10 11:41:00	t	f	231	50
291	.	.	2024-09-21 11:49:00	t	f	123	50
293	.	.	2024-09-23 14:19:00	t	f	231	50
292		.	2024-09-21 11:57:00	t	f	231	50
294	.	.	2024-09-13 18:28:00	t	f	79	49
295	.	.	2024-09-19 18:32:00	t	f	81	49
296	.	.	2024-09-19 18:53:00	f	f	232	49
298		.	2024-09-12 15:15:00	t	f	72	43
299		.	2024-09-12 16:32:00	t	f	196	110
300		.	2024-09-25 16:34:00	t	f	154	110
301		.	2024-09-20 16:43:00	t	f	175	110
305		.	2024-10-08 13:44:00	t	f	26	54
306		.	2024-10-03 14:08:00	t	f	193	51
307		.	2024-10-08 17:40:00	t	f	19	53
309		.	2024-10-03 17:56:00	t	f	14	60
310		.	2024-10-03 18:11:00	t	f	169	60
311		.	2024-10-04 18:25:00	t	f	17	60
312		.	2024-10-07 18:32:00	t	f	92	60
313		.	2024-10-08 18:36:00	t	f	91	60
314		.	2024-10-04 18:43:00	t	f	160	62
315		.	2024-10-07 19:00:00	t	f	44	62
316		.	2024-10-08 19:08:00	t	f	42	62
317		.	2024-10-08 19:10:00	t	f	50	85
318		.	2024-10-09 19:13:00	t	f	21	54
319	.	.	2024-10-07 19:23:00	f	f	21	54
320	.	.	2024-10-11 05:53:00	f	f	203	60
321	.	.	2024-10-11 04:55:00	f	f	48	85
322	,	креакард	2024-10-16 11:00:00	f	f	232	49
323	.	.	2024-10-17 16:20:25.431363	f	f	42	62
324	ост текшириш	ташриф	2024-10-18 20:48:00	f	f	52	90
325	закруска	ташриф	2024-10-18 20:51:00	f	f	54	90
326	загруска	ташриф	2024-10-18 20:55:00	f	f	211	90
327	п	остатки	2024-10-18 21:15:00	f	f	48	85
328	текшириш	остатки	2024-10-18 10:10:12.18695	f	f	231	50
329	текшириш	остатки	2024-10-18 10:10:32.593021	f	f	123	50
330	олиш	остатка	2024-10-18 11:57:28.160214	f	f	201	110
331	.	остатка	2024-10-18 12:07:53.398271	f	f	161	114
332	текшири	остатки	2024-10-18 12:09:48.21988	f	f	164	114
333	.	договор	2024-10-18 12:12:57.960928	f	f	71	43
334	.	остатка	2024-10-18 12:13:12.035117	f	f	72	43
335	olish	ostatka	2024-10-18 12:19:23.899913	f	f	69	40
336	ostatka	dogovo	2024-10-18 12:19:44.816515	f	f	159	40
337	dogovor	ostatka	2024-10-18 12:33:34.122793	f	f	62	39
338	dogovor	ostatka	2024-10-18 12:34:52.632056	f	f	64	39
339	dogovor	ostatka	2024-10-18 12:35:07.450077	f	f	176	39
340	.	.	2024-10-18 00:00:00	f	f	86	86
344	.	.	2024-10-23 09:00:00	f	f	120	86
345	.	.	2024-10-18 13:29:00	f	f	243	60
346	.	.	2024-10-22 10:00:00	f	f	244	86
350	.	.	2024-10-21 13:00:00	f	f	43	62
351	.	.	2024-10-23 10:00:00	f	f	160	62
341	tek	ostatka	2024-10-18 12:48:35.564264	f	f	32	46
342	.	.	2024-10-18 12:48:55.82911	f	f	225	46
343	.	закуп	2024-10-21 13:02:00	f	f	239	86
347	.	.	2024-10-22 13:00:00	f	f	110	85
348	.	.	2024-10-24 10:00:00	f	f	177	85
349	.	.	2024-10-21 13:00:00	f	f	43	62
352	.	.	2024-10-18 13:00:00	f	f	37	51
353	.....	.....	2024-10-18 15:29:11.714606	f	f	99	51
354	.....	.....	2024-10-18 15:30:18.267562	f	f	99	51
355	.....	крекард	2024-10-18 15:30:41.927264	f	f	100	51
356	.....	.....	2024-10-18 15:31:02.935364	f	f	99	51
357	.....	.....	2024-10-18 15:31:33.693643	f	f	39	51
358	.....	Диабертон турбо	2024-10-18 15:33:26.314761	f	f	38	51
\.


--
-- Data for Name: pharmacy_plan_attached_product; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pharmacy_plan_attached_product (id, doctor_name, doctor_speciality, product_name, compleated, plan_id) FROM stdin;
\.


--
-- Data for Name: product_category; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.product_category (id, name) FROM stdin;
2	Кардиогруппа
1	Гастроэнтнрология
5	Тромбоэмболия
6	гормон - регулятор эритроцитов
7	гепатопротектор
8	метаболик
9	аминокислоты
3	НПВС
4	ангиопротектор
10	противорвотное
11	гемостатик
12	диуретик
13	Церебровазодилатирующее средство
\.


--
-- Data for Name: product_expenses; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.product_expenses (id, marketing_expense, salary_expenses, date, product_id) FROM stdin;
1	1000	2500	2024-07-29 07:38:49.30123	17
2	20000	22000	2024-07-29 07:38:49.30123	30
3	1000	2500	2024-07-29 07:38:49.30123	16
4	60000	75000	2024-07-29 13:29:43.644289	33
5	60000	75000	2024-07-29 13:29:43.644289	33
6	60000	75000	2024-07-29 13:29:43.644289	33
7	95000	97000	2024-07-29 13:29:43.644289	6
8	12000	12000	2024-07-29 13:29:43.644289	36
9	19000	19000	2024-07-29 13:29:43.644289	7
10	35000	42000	2024-07-29 13:29:43.644289	14
11	20000	26000	2024-07-30 06:40:42.904867	30
12	20000	26000	2024-07-30 06:40:42.904867	30
13	17000	20000	2024-09-03 11:45:40.744127	24
14	17000	20000	2024-09-03 11:45:40.744127	24
15	20000	18000	2024-09-03 11:45:40.744127	24
16	17000	18000	2024-09-03 11:45:40.744127	24
17	20000	20000	2024-09-15 20:04:37.143079	4
\.


--
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.products (id, name, price, discount_price, man_company_id, category_id, marketing_expenses, salary_expenses, is_exist) FROM stdin;
26	ЭКСИПАР 8000/0,8мл №5	118000	62000	1	5	25000	25000	\N
12	ЭКСИПАР 4000/0,4мл №1	72000	37500	1	5	16000	16000	\N
9	ТЕНОЗУМ	120000	49700	1	3	30000	34000	\N
13	ЭКСИПАР 6000/0,6мл №1	85000	42500	1	5	20000	20000	\N
18	ВИНКОРЕЛ 5х5	47500	18950	3	13	12000	14000	t
27	Эритропен 10 000/1мл №1	190000	94500	1	6	40000	46000	\N
30	Арлевин 100 мл №1	75000	25000	1	8	20000	26000	t
28	Диабертион амп 5х5	85000	37750	3	8	21000	22000	t
7	Диабертион турбо 50 мл №1	75000	33500	1	8	19000	19000	t
19	ИДРЕН	65000	26500	3	8	16000	19000	t
15	ЭРИТРОПЕН 2000/0,5мл №2	95000	48900	1	6	20000	21500	\N
10	ТОРАСЕМИД	130000	62000	1	12	30000	30000	t
11	ФДП ZUMA 10	173000	75000	1	2	45000	45000	t
20	НЕОЦИНТИЛ	60000	31200	3	2	13000	13000	\N
17	Мистер Бинт Нестерил	6500	5000	4	1	1000	2500	t
21	НЕОСПАГИН	55000	22340	3	2	13000	17000	\N
22	НООЦЕБ	85000	37440	3	2	20000	23000	\N
23	РЕВМИЛ	49500	21570	3	3	12000	13500	\N
16	Мистер Бинт Стерил	7200	0	4	1	1000	2500	t
29	ОНДАСЕТ 2х5	85000	39750	3	10	20000	21000	t
14	ЭРИТРОПЕН 4000/0,5мл №1	175000	89500	1	6	35000	42000	t
8	НЕОЛАЙТОН ЗУМА	155000	52600	1	1	50000	45000	t
36	Амитаргин 100мл	54000	27200	1	8	12000	12000	t
6	АДЕЗУМА	360000	150000	1	7	95000	97000	t
5	ФДП ZUMA 5	152600	70000	1	2	35000	40000	t
25	КРЕАКАРД	155000	52600	1	2	50000	45000	t
33	Гепапротек 10 мл №10	300000	150000	3	7	60000	75000	t
35	Тиостан 10мл №10	75000	37500	3	3	0	0	f
24	ЭЛЛЕУС	72000	33280	3	4	17000	18000	t
31	Апрозум 5х5	325000	165000	1	11	60000	100000	t
4	РАБЕЛАЗОЛ	70000	30000	1	1	20000	20000	t
38	Л- Лизес	120000	66000	3	13	0	0	t
37	Апрозум по 504 000	450000	165000	1	7	0	0	t
39	эксипар	78848	50000	1	5	0	0	t
40	Эксипар 6000/0,6 мл №1	70400	19	1	5	0	0	t
\.


--
-- Data for Name: region; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.region (id, name) FROM stdin;
2	Ташкентская область
3	Хорезмская область
4	Бухарская область
5	Навоийская область
6	Кашкадарьинская область
7	Каракалпакстан
8	Долина
9	Самарканд
11	Turkiston
1	Ташкент
12	Наманган
13	Фергана
14	Коканд
15	РУз
16	Сирдарё
17	Джиззак
19	Сурхандарьинская область
18	Андижан
\.


--
-- Data for Name: remainder_sum_from_reservation; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.remainder_sum_from_reservation (id, amonut, date, pharmacy_id, wholesale_id, reservation_invoice_number) FROM stdin;
\.


--
-- Data for Name: report_factory_warehouse; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.report_factory_warehouse (id, date, quantity, factory_id, product_id) FROM stdin;
30	2024-07-29 00:00:00	3000	1	25
31	2024-07-29 00:00:00	1200	1	26
32	2024-07-29 00:00:00	2000	1	12
33	2024-07-29 00:00:00	500	1	31
34	2024-07-29 00:00:00	45	1	14
35	2024-07-29 00:00:00	1000	1	10
36	2024-07-29 00:00:00	2000	1	13
37	2024-07-29 00:00:00	175	1	11
38	2024-07-29 00:00:00	69	1	5
39	2024-07-29 00:00:00	10	1	7
40	2024-07-29 00:00:00	211	1	27
41	2024-07-29 00:00:00	500	1	30
42	2024-07-29 00:00:00	55	1	15
43	2024-07-29 00:00:00	953	3	24
44	2024-07-29 00:00:00	591	3	29
45	2024-07-29 00:00:00	139	3	18
46	2024-07-29 00:00:00	322	3	19
47	2024-07-29 00:00:00	1520	3	33
48	2024-07-29 00:00:00	774	3	28
49	2024-07-29 00:00:00	239	3	20
50	2024-07-29 00:00:00	603	3	22
51	2024-07-29 00:00:00	30	3	23
52	2024-07-29 00:00:00	76	3	35
53	2024-08-01 00:00:00	100	1	5
54	2024-08-04 00:00:00	10000	3	24
55	2024-08-13 00:00:00	500	1	8
56	2024-08-13 00:00:00	347	1	8
57	2024-08-13 00:00:00	160	1	14
58	2024-08-13 00:00:00	302	1	15
59	2024-08-13 00:00:00	450	1	11
60	2024-08-13 00:00:00	200	1	5
61	2024-08-13 00:00:00	250	3	18
62	2024-08-13 00:00:00	1250	3	19
63	2024-08-13 00:00:00	431	3	22
64	2024-08-13 00:00:00	350	3	23
65	2024-08-13 00:00:00	60	3	28
66	2024-08-13 00:00:00	100	3	28
67	2024-08-13 00:00:00	100	1	12
68	2024-08-13 00:00:00	100	1	15
69	2024-08-14 00:00:00	21	1	4
70	2024-08-15 00:00:00	10000	1	25
71	2024-08-15 00:00:00	10000	1	12
72	2024-08-15 00:00:00	10000	1	13
73	2024-08-15 00:00:00	10	1	7
74	2024-08-15 00:00:00	1000	1	30
75	2024-08-15 00:00:00	500	1	5
76	2024-08-23 00:00:00	11	3	21
77	2024-08-23 00:00:00	45	3	21
78	2024-08-23 00:00:00	55	1	4
79	2024-08-23 00:00:00	128	3	20
80	2024-08-26 00:00:00	1200	1	4
81	2024-08-26 00:00:00	100	3	18
82	2024-08-26 00:00:00	78	3	20
83	2024-09-03 00:00:00	200	1	11
84	2024-09-03 00:00:00	200	1	7
85	2024-09-03 00:00:00	200	3	18
86	2024-09-03 00:00:00	200	3	28
87	2024-09-03 00:00:00	200	3	18
88	2024-09-03 00:00:00	200	3	23
89	2024-09-05 00:00:00	500	1	27
90	2024-09-05 00:00:00	1000	3	19
91	2024-09-05 00:00:00	400	3	28
92	2024-09-09 00:00:00	15	3	18
93	2024-09-09 00:00:00	200	3	18
94	2024-09-16 00:00:00	96	3	38
95	2024-09-20 00:00:00	500	1	27
96	2024-09-20 00:00:00	1000	3	21
97	2024-09-24 00:00:00	1000	3	28
98	2024-09-26 00:00:00	20	1	37
99	2024-10-08 22:22:53.223235	500	3	18
100	2024-10-14 17:54:28.150898	50	3	20
101	2024-10-17 10:22:34.001172	19	1	39
102	2024-10-17 10:22:34.001172	19	1	40
\.


--
-- Data for Name: reservation; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.reservation (id, date, expire_date, discount, discountable, total_quantity, total_amount, total_payable, pharmacy_id, manufactured_company_id, checked, total_payable_with_nds, invoice_number, profit, debt, date_implementation, returned_price, prosrochenniy_debt, med_rep_id, bonus, description, reailized_debt) FROM stdin;
520	2024-10-17 10:22:34.027787	2024-11-16 10:22:34.027834	0	t	40	2880000	2880000	91	1	f	3225600	1326	0	3225600	2024-10-17 10:22:34.02782	0	f	\N	t	\N	0
233	2024-08-26 00:00:00	2024-09-25 05:57:51.370763	5	f	200	23350000	22182500	80	1	t	24844400	1625	24844400	0	2024-08-29 05:58:05.079082	0	f	60	t	\N	0
512	2024-10-15 07:30:10.6233	2024-11-14 07:30:10.623358	5	t	8	680000	646000	32	1	t	723520	1906	723520	0	2024-10-15 13:10:14.666049	0	f	\N	t	\N	0
517	2024-10-15 16:44:11.436294	2024-11-14 16:44:11.436344	5	t	60	9300000	8835000	117	1	t	9895200	1928	9895200	0	2024-10-16 13:36:56.75064	0	f	\N	t	\N	0
294	2024-09-05 00:00:00	2024-10-05 09:25:02.924812	5	f	10	1550000	1472500	169	1	t	1649200	1702	1649200	0	2024-09-12 07:30:28.211821	0	f	60	t	\N	0
315	2024-09-09 00:00:00	2024-10-09 09:56:53.482849	5	f	20	3100000	2945000	92	1	t	3298400	1705	3298400	0	2024-09-12 07:20:31.114139	0	f	60	t	\N	0
284	2024-09-05 00:00:00	2024-10-05 09:25:02.924812	5	t	50	7750000	7362500	50	1	t	8246000	2758	8246000	0	2024-09-09 04:39:21.86493	0	f	60	t	\N	0
438	2024-09-26 00:00:00	2024-10-26 12:30:20.476545	5	t	120	16200000	15390000	177	1	t	17236800	1838	9959040	7277760	2024-09-27 12:00:29.034296	0	f	60	t	\N	0
136	2024-08-13 00:00:00	2024-09-12 12:09:01.352712	5	t	20	3100000	2945000	124	1	t	3298400	1476	3298400	0	2024-08-07 00:00:00	0	f	60	t	\N	0
232	2024-08-26 00:00:00	2024-09-25 05:57:51.370763	5	f	30	4650000	4417500	163	1	t	4947600	1603	4947600	0	2024-08-28 06:56:38.870415	0	f	60	t	\N	0
349	2024-08-11 00:00:00	2024-10-11 12:45:01.837999	15.4	f	20	3800000	3214800	207	1	t	3600576	1033982	3600560	16	2024-08-12 00:00:00	0	f	60	t	\N	0
103	2024-08-06 00:00:00	2024-09-05 10:08:26.746355	5	f	30	4650000	4417500	108	1	t	4947600	1451	4947600	0	2024-08-13 05:14:39.31172	0	f	60	t	\N	0
110	2024-08-12 00:00:00	2024-09-11 12:24:15.832412	5	f	20	3100000	2945000	92	1	t	3298400	1478	3298400	0	2024-08-08 00:00:00	0	f	60	t	\N	0
109	2024-08-12 00:00:00	2024-09-11 12:24:15.832412	5	f	3	390000	370500	113	1	t	414960	1479	414960	0	2024-08-08 00:00:00	0	f	60	t	\N	0
124	2024-08-13 00:00:00	2024-09-12 12:09:01.352712	5	f	15	1400000	1330000	19	1	t	1489600	1516	1489600	0	2024-08-13 12:41:00.140173	0	f	60	t	\N	0
175	2024-08-15 00:00:00	2024-09-14 11:23:50.538632	5	f	30	9000000	8550000	64	3	t	9576000	2596	9576000	0	2024-08-20 09:28:27.653273	0	f	60	t	\N	0
292	2024-09-05 00:00:00	2024-10-05 09:25:02.924812	5	t	10	1900000	1805000	176	1	t	2021600	1681	2021600	0	2024-09-09 05:04:06.166974	0	f	60	t	\N	0
398	2024-09-20 00:00:00	2024-10-20 05:14:24.357011	5	t	126	11460000	10887000	164	1	t	12193440	1793	12193440	0	2024-09-23 06:05:14.347531	0	f	60	t	\N	0
383	2024-09-16 00:00:00	2024-10-16 12:51:47.634796	5	f	20	3100000	2945000	42	1	t	3298400	1781	3298400	0	2024-09-20 06:48:57.575011	0	f	60	t	\N	0
374	2024-09-16 00:00:00	2024-10-16 12:51:47.634796	5	t	40	3710000	3524500	91	1	t	3947440	1738	3947440	0	2024-09-17 11:40:27.894766	0	f	60	t	\N	0
261	2024-09-03 00:00:00	2024-10-03 11:45:40.804792	5	t	40	2880000	2736000	103	1	t	3064320	1746	3064320	0	2024-09-18 06:23:46.271943	0	f	60	t	\N	0
392	2024-09-19 00:00:00	2024-10-19 10:13:49.011493	5	f	20	1500000	1425000	97	1	f	1596000	1265	0	1596000	2024-09-19 10:13:49.011475	0	f	60	t	\N	0
346	2024-09-11 00:00:00	2024-10-11 12:45:01.837999	5	t	10	1550000	1472500	157	1	t	1649200	1697	1649200	0	2024-09-12 10:13:55.413725	0	f	60	t	\N	0
399	2024-09-20 00:00:00	2024-10-20 05:14:24.357011	5	t	10	650000	617500	204	3	f	691600	1270	0	691600	2024-09-20 05:14:24.356991	0	f	60	t	\N	0
403	2024-09-20 00:00:00	2024-10-20 05:14:24.357011	5	t	100	5500000	5225000	224	3	t	5852000	3042	5852000	0	2024-09-24 06:37:31.676234	0	f	60	t	\N	0
323	2024-09-10 00:00:00	2024-10-10 10:17:50.452601	5	f	30	4650000	4417500	159	1	t	4947600	1807	4947600	0	2024-09-24 06:28:18.58865	0	f	60	t	\N	4947600
386	2024-09-16 00:00:00	2024-10-16 12:51:47.634796	5	f	20	1440000	1368000	30	3	t	1532160	3041	1532160	0	2024-09-24 06:40:14.99451	0	f	60	t	\N	0
285	2024-09-05 00:00:00	2024-10-05 09:25:02.924812	5	t	50	6155000	5847250	161	1	t	6548920	1675	6548920	0	2024-09-12 09:48:28.979496	0	f	60	t	\N	0
155	2024-08-14 00:00:00	2024-09-13 11:51:29.172194	5	t	10	1550000	1472500	135	1	t	1649200	1546	1649200	0	2024-08-14 12:28:14.401169	0	f	60	t	\N	0
182	2024-08-15 00:00:00	2024-09-14 11:23:50.538632	5	t	60	7200000	6840000	143	1	t	7660800	1556	7660800	0	2024-08-19 00:00:00	0	f	60	t	\N	0
194	2024-08-15 00:00:00	2024-09-14 11:23:50.538632	5	t	10	720000	684000	144	3	t	766080	2519	766080	0	2024-08-19 00:00:00	0	f	60	t	\N	0
108	2024-08-12 00:00:00	2024-09-11 11:58:22.321342	5	f	15	922500	876375	113	3	t	981540	2375	981540	0	2024-08-08 00:00:00	0	f	60	t	\N	0
157	2024-08-14 00:00:00	2024-09-13 11:51:29.172194	5	f	40	3140000	2983000	22	1	t	3340960	1549	3340960	0	2024-08-16 06:09:33.245467	0	f	60	t	\N	0
161	2024-08-14 00:00:00	2024-09-13 11:51:29.172194	5	f	50	3600000	3420000	22	3	t	3830400	2550	3830400	0	2024-08-19 06:03:45.957029	0	f	60	t	\N	0
133	2024-08-13 00:00:00	2024-09-12 12:09:01.352712	5	t	30	4578000	4349100	68	1	t	4870992	1463	4870980	12	2024-08-06 00:00:00	0	f	60	t	\N	0
132	2024-08-13 00:00:00	2024-09-12 12:09:01.352712	5	t	34	5188400	4928980	69	1	t	5520458	1459	5520444	14	2024-08-06 00:00:00	0	f	60	t	\N	0
122	2024-08-13 00:00:00	2024-09-12 10:07:30.108919	5	f	25	3525000	3348750	122	1	t	3750600	1510	3750600	0	2024-08-13 12:07:08.755344	0	f	60	t	\N	0
228	2024-08-26 00:00:00	2024-09-25 05:57:51.370763	5	t	60	9300000	8835000	81	1	t	9895200	1612	9895200	0	2024-08-28 05:16:55.381537	0	f	60	t	\N	0
186	2024-08-15 00:00:00	2024-09-14 11:23:50.538632	5	f	20	1440000	1368000	146	3	t	1532160	2546	1532160	0	2024-08-20 10:20:08.441725	0	f	60	t	\N	0
446	2024-09-26 00:00:00	2024-10-26 12:30:20.476545	0	f	330	51150000	51150000	232	1	f	57288000	1297	0	57288000	2024-09-26 12:30:20.476526	0	f	60	t	\N	0
521	2024-10-17 10:22:34.027787	2024-11-16 10:22:34.027834	0	f	10	3000000	3000000	242	3	f	3360000	1327	0	3360000	2024-10-17 10:22:34.02782	0	f	\N	t	\N	0
214	2024-08-26 00:00:00	2024-09-25 05:57:51.370763	5	f	15	2150000	2042500	157	1	t	2287600	1141	2287600	0	2024-09-10 06:45:04.762823	0	f	60	t	\N	0
458	2024-10-02 00:00:00	2024-11-01 13:24:50.913168	5	t	10	1550000	1472500	179	1	t	1649200	1930	1649200	0	2024-10-16 13:39:14.035184	0	f	60	t	\N	0
378	2024-09-16 00:00:00	2024-10-16 12:51:47.634796	5	t	60	4320000	4104000	21	1	t	4596480	1744	4596480	0	2024-09-18 06:38:36.222442	0	f	60	t	\N	0
518	2024-10-15 16:44:11.436294	2024-11-14 16:44:11.436344	5	t	100	8500000	8075000	240	1	t	9044000	1936	0	9044000	2024-10-16 14:41:16.346332	0	f	\N	t	\N	0
286	2024-09-05 00:00:00	2024-10-05 09:25:02.924812	5	t	46	3312000	3146400	91	1	t	3523968	1676	3523968	0	2024-09-09 04:37:31.669261	0	f	60	t	\N	0
441	2024-09-26 00:00:00	2024-10-26 12:30:20.476545	5	f	20	1440000	1368000	144	3	f	1532160	1292	0	1532160	2024-09-30 00:00:00	0	f	60	t	\N	0
445	2024-09-26 00:00:00	2024-10-26 12:30:20.476545	0	f	50	7750000	7750000	231	1	t	8680000	1296	0	8680000	2024-09-30 12:46:55.93548	0	f	60	t	\N	0
287	2024-09-05 00:00:00	2024-10-05 09:25:02.924812	5	t	10	1550000	1472500	135	1	t	1649200	1685	1649200	0	2024-09-11 07:30:10.770595	0	f	60	t	\N	0
227	2024-08-26 00:00:00	2024-09-25 05:57:51.370763	5	t	120	18600000	17670000	19	1	t	19790400	1611	19790400	0	2024-08-28 05:15:11.704902	0	f	60	t	\N	0
505	2024-10-11 14:48:56.458817	2024-11-10 14:48:56.458863	5	f	50	3250000	3087500	203	3	t	3458000	1323	3458000	0	2024-10-14 15:59:49.526031	0	f	60	t	\N	0
503	2024-10-11 14:48:56.458817	2024-11-10 14:48:56.458863	53.916	t	200	31000000	14286041	79	1	t	16000366	1904	0	16000366	2024-10-15 13:08:34.515069	0	f	60	t	\N	0
251	2024-09-03 00:00:00	2024-10-03 11:45:40.804792	5	t	20	1440000	1368000	32	3	t	1532160	2750	1532160	0	2024-09-05 04:39:13.553307	0	f	60	t	\N	0
102	2024-08-06 00:00:00	2024-09-05 10:08:26.746355	5	f	50	7630000	7248500	101	1	t	8118320	1462	8118300	20	2024-08-12 09:34:15.176328	0	f	60	t	\N	0
134	2024-08-13 00:00:00	2024-09-12 12:09:01.352712	5	t	50	7750000	7362500	123	1	t	8246000	1471	8246000	0	2024-08-07 00:00:00	0	f	60	t	\N	0
121	2024-08-13 00:00:00	2024-09-12 10:07:30.108919	5	f	500	42500000	40375000	121	3	t	45220000	2466	45220000	0	2024-08-13 11:14:15.256782	0	f	60	t	\N	0
196	2024-08-21 00:00:00	2024-09-20 07:39:51.761825	5	t	37	2924000	2777800	14	1	t	3111136	1577	3111136	0	2024-08-21 15:00:51.055653	0	f	60	t	\N	0
96	2024-08-06 00:00:00	2024-09-05 06:30:13.067283	5	f	39	2808000	2667600	91	1	t	2987712	1457	2987712	0	2024-08-05 00:00:00	0	f	60	t	\N	0
181	2024-08-15 00:00:00	2024-09-14 11:23:50.538632	5	t	10	720000	684000	30	3	t	766080	2603	766080	0	2024-08-20 12:51:37.768334	0	f	60	t	\N	0
114	2024-08-13 00:00:00	2024-09-12 02:35:16.555097	5	f	21	3255000	3092250	117	1	t	3463320	1475	3463320	0	2024-08-07 00:00:00	0	f	60	t	\N	0
179	2024-08-15 00:00:00	2024-09-14 11:23:50.538632	5	t	10	720000	684000	30	1	t	766080	1564	766080	0	2024-08-20 05:32:47.27426	0	f	60	t	\N	0
176	2024-08-15 00:00:00	2024-09-14 11:23:50.538632	5	f	20	1440000	1368000	32	3	t	1532160	2602	1532160	0	2024-08-20 09:22:00.118894	0	f	60	t	\N	0
89	2024-08-05 00:00:00	2024-09-04 07:36:09.450702	5	f	10	475000	451250	22	3	t	505400	2329	505400	0	2024-08-02 00:00:00	0	f	60	t	\N	0
144	2024-08-13 00:00:00	2024-09-12 12:09:01.352712	5	f	18	2790000	2650500	91	1	t	2968560	1485	2968560	0	2024-08-08 00:00:00	0	f	60	t	\N	0
209	2024-08-26 00:00:00	2024-09-25 05:57:51.370763	5	f	28	2846000	2703700	91	1	t	3028144	1580	3028144	0	2024-08-22 00:00:00	0	f	60	t	\N	0
206	2024-08-24 00:00:00	2024-09-23 09:55:36.540515	8	t	50	7400000	6808000	154	1	t	7624960	1579	7624960	0	2024-08-26 05:30:01.971444	0	f	60	t	\N	0
104	2024-08-06 00:00:00	2024-09-05 10:08:26.746355	5	f	18	2790000	2650500	91	1	t	2968560	1460	2968560	0	2024-08-06 00:00:00	0	f	60	t	\N	0
119	2024-08-13 00:00:00	2024-09-12 02:35:16.555097	0	f	200	14400000	14400000	120	1	t	16128000	1488	16128000	0	2024-08-13 07:02:48.379038	0	f	60	t	\N	0
236	2024-08-26 00:00:00	2024-09-25 05:57:51.370763	5	t	31	9300000	8835000	62	3	t	9895200	2714	9895200	0	2024-08-29 06:03:37.224284	0	f	60	t	\N	0
234	2024-08-26 00:00:00	2024-09-25 05:57:51.370763	5	t	20	3100000	2945000	92	1	t	3298400	1632	3298400	0	2024-08-29 07:38:50.529979	0	f	60	t	\N	0
375	2024-09-16 00:00:00	2024-10-16 12:51:47.634796	22.462	f	35	6650000	5156277	217	1	t	5775030	1250	5775035	-5	2024-09-17 11:57:39.975337	0	f	60	t	\N	0
239	2024-08-30 00:00:00	2024-09-29 06:53:43.919603	5	f	60	4710000	4474500	164	1	t	5011440	1631	5011440	0	2024-08-29 00:00:00	0	f	60	t	\N	0
217	2024-08-26 00:00:00	2024-09-25 05:57:51.370763	0	t	20	3100000	3100000	158	1	t	3472000	1604	0	3472000	2024-08-30 07:06:51.480396	0	f	60	t	\N	0
117	2024-08-13 00:00:00	2024-09-12 02:35:16.555097	5	f	100	7200000	6840000	21	3	t	7660800	2436	7660800	0	2024-08-13 06:28:40.440584	0	f	60	t	\N	0
107	2024-08-12 00:00:00	2024-09-11 11:58:22.321342	5	f	15	1510000	1434500	113	1	t	1606640	1480	1606640	0	2024-08-08 00:00:00	0	f	60	t	\N	0
123	2024-08-13 00:00:00	2024-09-12 12:09:01.352712	18.194	t	50	3600000	2945016	109	3	t	3298450	2330	3298450	0	2024-08-13 12:42:08.152987	0	f	60	t	\N	0
92	2024-08-05 00:00:00	2024-09-04 11:49:58.956045	5	f	10	720000	684000	22	1	t	766080	1452	766080	0	2024-08-02 00:00:00	0	f	60	t	\N	0
168	2024-08-15 00:00:00	2024-09-14 11:23:50.538632	5	f	50	3860000	3667000	109	1	t	4107040	1550	4107040	0	2024-08-19 07:10:46.230348	0	f	60	t	\N	0
98	2024-08-06 00:00:00	2024-09-05 06:30:13.067283	0	f	100	7850000	7850000	95	1	t	8792000	1505	3963680	4828320	2024-08-14 04:13:06.274093	0	f	60	t	\N	0
141	2024-08-13 00:00:00	2024-09-12 12:09:01.352712	5	t	30	4650000	4417500	42	1	t	4947600	1529	4947600	0	2024-08-14 06:25:55.755657	0	f	60	t	\N	0
170	2024-08-15 00:00:00	2024-09-14 11:23:50.538632	5	t	32	2304000	2188800	91	1	t	2451456	1557	2451456	0	2024-08-19 07:09:50.665343	0	f	60	t	\N	0
522	2024-10-17 10:22:34.027787	2024-11-16 10:22:34.027834	5	t	19	1337600	1270720	238	1	t	1423206	1935	0	1423206	2024-10-16 00:00:00	0	f	\N	t	\N	0
513	2024-10-15 07:30:10.6233	2024-11-14 07:30:10.623358	53.80645	t	250	38750000	17900001	67	1	t	20048001	1918	0	20048001	2024-10-15 12:57:38.261561	0	f	\N	t	\N	0
126	2024-08-13 00:00:00	2024-09-12 12:09:01.352712	5	f	30	1485000	1410750	19	3	t	1580040	2465	1580040	0	2024-08-13 12:40:47.32081	0	f	60	t	\N	0
130	2024-08-13 00:00:00	2024-09-12 12:09:01.352712	5	t	70	4950000	4702500	123	3	t	5266800	2351	5266800	0	2024-08-05 00:00:00	0	f	60	t	\N	0
131	2024-08-13 00:00:00	2024-09-12 12:09:01.352712	5	t	10	4500000	4275000	81	1	t	4788000	1453	4788000	0	2024-08-05 00:00:00	0	f	60	t	\N	0
151	2024-08-13 00:00:00	2024-09-12 12:09:01.352712	5	t	50	4250000	4037500	81	1	t	4522000	1547	4522000	0	2024-08-14 12:25:26.569112	0	f	60	t	\N	0
135	2024-08-13 00:00:00	2024-09-12 12:09:01.352712	5	t	52	8060000	7657000	81	1	t	8575840	1472	8575840	0	2024-08-07 00:00:00	0	f	60	t	\N	0
127	2024-08-13 00:00:00	2024-09-12 12:09:01.352712	5	t	100	15500000	14725000	79	1	t	16492000	1483	16492000	0	2024-08-13 12:48:49.135694	0	f	60	t	\N	0
178	2024-08-15 00:00:00	2024-09-14 11:23:50.538632	5	t	65	11550000	10972500	81	1	t	12289200	1568	12289200	0	2024-08-21 05:40:29.570316	0	f	60	t	\N	0
299	2024-09-05 00:00:00	2024-10-05 09:25:02.924812	5	t	400	34000000	32300000	121	3	t	36176000	2795	36176000	0	2024-09-11 09:54:49.305025	0	f	60	t	\N	0
497	2024-10-08 22:22:53.249053	2024-11-07 22:22:53.249104	0	t	200	24000000	24000000	48	1	t	26880000	1321	26880000	0	2024-10-11 13:36:45.021241	0	f	60	t	\N	0
171	2024-08-15 00:00:00	2024-09-14 11:23:50.538632	8	t	180	25800000	23736000	142	1	t	26584320	1560	26584320	0	2024-08-19 12:57:40.124059	0	f	60	t	\N	0
225	2024-08-26 00:00:00	2024-09-25 05:57:51.370763	8	t	20	1700000	1564000	162	1	t	1751680	1602	1751680	0	2024-08-27 12:34:24.671723	0	f	60	t	\N	0
243	2024-08-30 00:00:00	2024-09-29 06:53:43.919603	5	f	20	3100000	2945000	26	1	t	3298400	1660	3298400	0	2024-08-30 10:45:10.949318	0	f	60	t	\N	0
267	2024-09-05 00:00:00	2024-10-05 09:25:02.924812	5	f	50	3600000	3420000	21	3	t	3830400	2751	3830400	0	2024-09-06 03:47:16.730424	0	f	60	t	\N	0
271	2024-09-05 00:00:00	2024-10-05 09:25:02.924812	5	t	57	4104000	3898800	21	3	t	4366656	2752	4366656	0	2024-09-05 12:04:48.215251	0	f	60	t	\N	0
293	2024-09-05 00:00:00	2024-10-05 09:25:02.924812	5	t	5	1500000	1425000	176	3	t	1596000	2761	1596000	0	2024-09-09 07:51:21.071726	0	f	60	t	\N	0
249	2024-09-03 00:00:00	2024-10-03 11:45:40.804792	5	f	20	3100000	2945000	21	1	t	3298400	1666	3298400	0	2024-09-05 06:06:11.563704	0	f	60	t	\N	0
330	2024-09-10 00:00:00	2024-10-10 12:08:11.074948	5	f	30	3250000	3087500	196	1	t	3458000	1706	3458000	0	2024-09-12 07:26:35.603037	0	f	60	t	\N	0
274	2024-09-05 00:00:00	2024-10-05 09:25:02.924812	5	t	20	3800000	3610000	21	1	t	4043200	1673	4043200	0	2024-09-06 09:28:55.697701	0	f	60	t	\N	0
348	2024-08-11 00:00:00	2024-10-11 12:45:01.837999	18.7	f	30	5700000	4634100	206	1	t	5190192	1663	5190210	-18	2024-08-31 00:00:00	0	f	60	t	\N	0
324	2024-09-10 00:00:00	2024-10-10 10:17:50.452601	0	f	20	3800000	3800000	35	1	t	4256000	1694	4256000	0	2024-09-10 00:00:00	0	f	60	t	\N	0
367	2024-09-16 00:00:00	2024-10-16 06:06:47.867066	5	t	220	26450000	25127500	81	1	t	28142800	1759	28142800	0	2024-09-20 09:18:57.150452	0	f	60	t	\N	0
174	2024-08-15 00:00:00	2024-09-14 11:23:50.538632	5	t	60	4440000	4218000	142	3	t	4724160	2551	4724160	0	2024-08-19 09:16:45.196213	0	f	60	t	\N	0
376	2024-09-16 00:00:00	2024-10-16 12:51:47.634796	22.462	f	5	950000	736611	217	1	t	825004	1251	825005	-1	2024-09-17 11:57:28.737712	0	f	60	t	\N	0
389	2024-09-19 00:00:00	2024-10-19 10:13:49.011493	5	t	39	2808000	2667600	91	1	t	2987712	1804	2987712	0	2024-09-24 06:27:05.318245	0	f	60	t	\N	0
305	2024-09-09 00:00:00	2024-10-09 09:56:53.482849	8	f	50	7750000	7130000	154	1	t	7985600	1689	7985600	0	2024-09-10 00:00:00	0	f	60	t	\N	0
370	2024-09-16 00:00:00	2024-10-16 12:51:47.634796	5	f	15	1080000	1026000	22	1	t	1149120	1757	1149120	0	2024-09-19 10:15:26.384321	0	f	60	t	\N	0
364	2024-09-16 00:00:00	2024-10-16 06:06:47.867066	5	t	10	650000	617500	216	3	t	691600	2946	691600	0	2024-09-17 12:13:45.186364	0	f	60	t	\N	0
406	2024-09-20 00:00:00	2024-10-20 05:14:24.357011	5	f	120	18600000	17670000	19	1	f	19790400	1234	0	19790400	2024-09-20 05:14:24.356991	0	f	60	t	\N	0
314	2024-09-09 00:00:00	2024-10-09 09:56:53.482849	5	t	20	1470000	1396500	113	1	t	1564080	1704	1564080	0	2024-09-12 07:32:10.945939	0	f	60	t	\N	0
347	2024-08-11 00:00:00	2024-10-11 12:45:01.837999	22.36	f	140	26600000	20652240	205	1	t	23130509	1456	23130520	-11	2024-08-02 00:00:00	0	f	60	t	\N	0
390	2024-09-19 00:00:00	2024-10-19 10:13:49.011493	5	t	20	3100000	2945000	17	1	f	3298400	1264	0	3298400	2024-09-19 10:13:49.011475	0	f	60	t	\N	0
400	2024-09-20 00:00:00	2024-10-20 05:14:24.357011	22.4624	f	110	20900000	16205358	205	1	t	18150001	1271	18150000	1	2024-09-12 00:00:00	0	f	60	t	\N	0
401	2024-09-20 00:00:00	2024-10-20 05:14:24.357011	5	t	50	3250000	3087500	203	3	f	3458000	1272	0	3458000	2024-09-20 05:14:24.356991	0	f	60	t	\N	0
321	2024-09-09 00:00:00	2024-10-09 09:56:53.482849	10.72	f	65	30139200	26908278	110	1	t	30137272	1450	0	30137272	2024-09-23 10:33:25.469934	0	f	60	t	\N	0
408	2024-09-24 00:00:00	2024-10-24 09:50:26.02088	5	f	42	3720000	3534000	225	1	t	3958080	1716	3958080	0	2024-09-13 00:00:00	0	f	60	t	\N	0
273	2024-09-05 00:00:00	2024-10-05 09:25:02.924812	5	t	10	720000	684000	172	3	t	766080	2748	766080	0	2024-09-09 04:38:25.827656	0	f	60	t	\N	0
387	2024-09-16 00:00:00	2024-10-16 12:51:47.634796	5	f	20	1440000	1368000	30	1	t	1532160	1806	1532160	0	2024-09-24 06:39:41.035039	0	f	60	t	\N	0
333	2024-09-10 00:00:00	2024-10-10 12:08:11.074948	5	f	50	7750000	7362500	79	1	t	8246000	1707	8246000	0	2024-09-12 07:20:02.660544	0	f	60	t	\N	0
412	2024-09-24 00:00:00	2024-10-24 09:50:26.02088	5	t	20	3100000	2945000	92	1	t	3298400	1824	3298400	0	2024-09-26 09:11:41.940405	0	f	60	t	\N	0
523	2024-10-17 10:22:34.027787	2024-11-16 10:22:34.027834	5	t	5	1625000	1543750	241	1	t	1729000	1929	0	1729000	2024-10-17 18:59:31.72175	0	f	\N	t	\N	0
514	2024-10-15 07:30:10.6233	2024-11-14 07:30:10.623358	53.80645	t	300	46500000	21480000	237	1	t	24057601	1916	0	24057601	2024-10-15 14:21:40.948222	0	f	\N	t	\N	0
200	2024-08-22 00:00:00	2024-09-21 11:35:58.413885	5	t	30	4650000	4417500	124	1	t	4947600	1593	4947600	0	2024-08-23 05:22:25.954981	0	f	60	t	\N	0
240	2024-08-30 00:00:00	2024-09-29 06:53:43.919603	0	f	600	68100000	68100000	120	1	t	76272000	1158	72128560	4143440	2024-08-30 07:51:49.1865	0	f	60	t	\N	0
237	2024-08-26 00:00:00	2024-09-25 05:57:51.370763	0	f	400	26400000	26400000	120	3	t	29568000	2735	5228160	24339840	2024-08-29 07:44:00.76124	0	f	60	t	\N	0
201	2024-08-23 00:00:00	2024-09-22 04:46:18.298695	5	t	20	1300000	1235000	124	3	t	1383200	2640	1383200	0	2024-08-23 07:36:20.231309	0	f	60	t	\N	0
183	2024-08-15 00:00:00	2024-09-14 11:23:50.538632	5	t	50	7750000	7362500	145	1	t	8246000	1567	8246000	0	2024-08-20 07:20:26.996312	0	f	60	t	\N	0
226	2024-08-26 00:00:00	2024-09-25 05:57:51.370763	8	t	109	9265000	8523800	71	1	t	9546656	1613	9546656	0	2024-08-28 05:11:43.726836	0	f	60	t	\N	0
125	2024-08-13 00:00:00	2024-09-12 12:09:01.352712	5	f	140	20300000	19285000	19	1	t	21599200	1515	21599200	0	2024-08-13 12:40:53.817926	0	f	60	t	\N	0
414	2024-09-24 00:00:00	2024-10-24 09:50:26.02088	5	t	10	1550000	1472500	24	1	t	1649200	1813	1649200	0	2024-09-26 09:31:52.833492	0	f	60	t	\N	0
359	2024-09-16 00:00:00	2024-10-16 06:06:47.867066	5	t	16	1152000	1094400	215	1	t	1225728	1812	1225728	0	2024-09-25 00:00:00	0	f	60	t	\N	0
478	2024-10-08 22:22:53.249053	2024-11-07 22:22:53.249104	5	t	50	3600000	3420000	103	1	f	3830400	1315	0	3830400	2024-10-08 22:22:53.249089	0	f	60	t	\N	0
479	2024-10-08 22:22:53.249053	2024-11-07 22:22:53.249104	8	f	150	12750000	11730000	193	1	t	13137600	1856	6568800	6568800	2024-10-09 15:23:07.55154	0	f	60	t	\N	0
475	2024-10-03 23:09:31.308372	2024-11-02 23:09:31.308428	5	t	120	18600000	17670000	19	1	t	19790400	1881	9895200	9895200	2024-10-08 13:01:26.504084	0	f	60	t	\N	0
496	2024-10-08 22:22:53.249053	2024-11-07 22:22:53.249104	5	t	20	3100000	2945000	14	1	t	3298400	1320	3298400	0	2024-10-11 11:48:07.815627	0	f	60	t	\N	0
492	2024-10-08 22:22:53.249053	2024-11-07 22:22:53.249104	5	t	10	1550000	1472500	17	1	t	1649200	1890	1649200	0	2024-10-11 08:23:04.520815	0	f	60	t	\N	0
484	2024-10-08 22:22:53.249053	2024-11-07 22:22:53.249104	5	t	10	850000	807500	160	1	t	904400	1867	904400	0	2024-10-09 18:49:55.402373	0	f	60	t	\N	0
483	2024-10-08 22:22:53.249053	2024-11-07 22:22:53.249104	5	t	10	1900000	1805000	160	1	t	2021600	1868	2021600	0	2024-10-09 18:49:57.459112	0	f	60	t	\N	0
482	2024-10-08 22:22:53.249053	2024-11-07 22:22:53.249104	5	t	10	720000	684000	160	3	t	766080	3123	766080	0	2024-10-09 18:50:00.890912	0	f	60	t	\N	0
473	2024-10-03 23:09:31.308372	2024-11-02 23:09:31.308428	5	t	20	3100000	2945000	26	1	t	3298400	1877	3298400	0	2024-10-08 12:39:14.02764	0	f	60	t	\N	0
480	2024-10-08 22:22:53.249053	2024-11-07 22:22:53.249104	5	t	10	650000	617500	14	3	t	691600	3117	691600	0	2024-10-03 00:00:00	0	f	60	t	\N	0
471	2024-10-03 23:09:31.308372	2024-11-02 23:09:31.308428	5	t	20	1440000	1368000	26	3	t	1532160	3136	1532160	0	2024-10-08 11:31:43.97935	0	f	60	t	\N	0
470	2024-10-03 23:09:31.308372	2024-11-02 23:09:31.308428	5	f	60	4710000	4474500	14	1	t	5011440	1854	5011440	0	2024-10-09 17:54:06.480324	0	f	60	t	\N	0
481	2024-10-08 22:22:53.249053	2024-11-07 22:22:53.249104	0	f	18	2790000	2790000	92	1	t	3124800	98988	3124800	0	2024-10-14 12:09:18.437222	0	f	60	t	\N	0
502	2024-10-11 14:48:56.458817	2024-11-10 14:48:56.458863	5	t	10	650000	617500	124	3	t	691600	3252	691600	0	2024-10-14 10:37:01.236259	0	f	60	t	\N	0
489	2024-10-08 22:22:53.249053	2024-11-07 22:22:53.249104	5	f	20	6000000	5700000	41	3	f	6384000	1318	0	6384000	2024-10-08 22:22:53.249089	0	f	60	t	\N	0
488	2024-10-08 22:22:53.249053	2024-11-07 22:22:53.249104	0	t	9	1575000	1575000	215	1	f	1764000	1317	0	1764000	2024-10-08 22:22:53.249089	0	f	60	t	\N	0
491	2024-10-08 22:22:53.249053	2024-11-07 22:22:53.249104	0	t	20	6000000	6000000	41	3	f	6720000	1319	0	6720000	2024-10-08 22:22:53.249089	0	f	60	t	\N	0
501	2024-10-11 14:48:56.458817	2024-11-10 14:48:56.458863	5	t	30	4650000	4417500	124	1	t	4947600	1902	4947600	0	2024-10-14 12:13:21.283397	0	f	60	t	\N	0
472	2024-10-03 23:09:31.308372	2024-11-02 23:09:31.308428	8	t	100	8500000	7820000	71	1	t	8758400	1879	8758400	0	2024-10-08 12:34:24.29007	0	f	60	t	\N	0
500	2024-10-11 14:48:56.458817	2024-11-10 14:48:56.458863	5	t	10	1900000	1805000	234	1	t	2021600	1894	0	2021600	2024-10-11 16:37:45.083686	0	f	60	t	\N	0
476	2024-10-03 23:09:31.308372	2024-11-02 23:09:31.308428	5	t	120	18600000	17670000	50	1	t	19790400	1882	19790400	0	2024-10-08 13:06:25.400261	0	f	60	t	\N	0
490	2024-10-08 22:22:53.249053	2024-11-07 22:22:53.249104	0	f	100	7200000	7199998	21	3	f	8064000	1363	0	8064000	2024-10-10 00:00:00	0	f	60	t	\N	0
504	2024-10-11 14:48:56.458817	2024-11-10 14:48:56.458863	5	t	30	2920000	2774000	214	1	f	3106880	1322	0	3106880	2024-10-11 14:48:56.458848	0	f	60	t	\N	0
511	2024-10-14 17:54:28.178023	2024-11-13 17:54:28.178084	5	t	20	1440000	1368000	144	3	t	1532160	3282	1532160	0	2024-10-15 11:27:54.739513	0	f	60	t	\N	0
516	2024-10-15 16:44:11.436294	2024-11-14 16:44:11.436344	5	t	130	9360000	8892000	239	1	t	9959040	1922	4060224	5898816	2024-10-15 19:55:40.162294	0	f	\N	t	\N	0
510	2024-10-14 17:54:28.178023	2024-11-13 17:54:28.178084	5	t	20	1440000	1368000	144	1	t	1532160	1913	1532160	0	2024-10-15 13:48:18.109958	0	f	60	t	\N	0
509	2024-10-14 17:54:28.178023	2024-11-13 17:54:28.178084	5	t	39	2808000	2667600	91	1	t	2987712	1908	2987712	0	2024-10-15 13:52:49.892737	0	f	60	t	\N	0
507	2024-10-14 17:54:28.178023	2024-11-13 17:54:28.178084	5	t	70	11080000	10526000	233	1	t	11789120	1911	11789120	0	2024-10-15 13:54:42.992466	0	f	60	t	\N	0
462	2024-10-03 23:09:31.308372	2024-11-02 23:09:31.308428	5	f	10	3250000	3087500	41	1	t	3458000	1914	3458000	0	2024-10-15 13:50:43.382877	0	f	60	t	\N	0
515	2024-10-15 07:30:10.6233	2024-11-14 07:30:10.623358	0	t	15	1125000	1125000	113	1	t	1260000	1325	0	1260000	2024-10-15 17:54:25.707077	0	f	\N	t	\N	0
469	2024-10-03 23:09:31.308372	2024-11-02 23:09:31.308428	5	t	20	3100000	2945000	17	1	t	3298400	1869	3298400	0	2024-10-04 00:00:00	0	f	60	t	\N	0
485	2024-10-08 22:22:53.249053	2024-11-07 22:22:53.249104	32.8549	f	20	3800000	2551513	21	1	t	2857695	1888	0	2857695	2024-10-11 08:24:21.195078	0	f	60	t	\N	0
244	2024-09-03 00:00:00	2024-10-03 11:45:40.804792	5	f	10	1550000	1472500	24	1	t	1649200	1668	1649200	0	2024-09-05 06:08:45.956751	0	f	60	t	\N	0
281	2024-09-05 00:00:00	2024-10-05 09:25:02.924812	5	t	10	1550000	1472500	173	1	t	1649200	1696	1649200	0	2024-09-11 10:17:49.589675	0	f	60	t	\N	0
322	2024-09-09 00:00:00	2024-10-09 09:56:53.482849	2.6	f	22	7150000	6964100	110	1	t	7799792	1458	7799792	0	2024-08-05 00:00:00	0	f	60	t	\N	0
256	2024-09-03 00:00:00	2024-10-03 11:45:40.804792	5	t	15	2150000	2042500	157	1	t	2287600	1667	2287600	0	2024-09-05 06:42:20.719356	0	f	60	t	\N	0
440	2024-09-26 00:00:00	2024-10-26 12:30:20.476545	5	f	20	6000000	5700000	218	3	t	6384000	3072	0	6384000	2024-09-27 14:21:45.107511	0	f	60	t	\N	0
432	2024-09-26 00:00:00	2024-10-26 12:30:20.476545	5	f	70	5495000	5220250	161	1	f	5846680	1289	0	5846680	2024-09-26 00:00:00	0	f	60	t	\N	0
337	2024-09-11 00:00:00	2024-10-11 12:45:01.837999	5	f	120	18600000	17670000	19	1	t	19790400	1743	19790400	0	2024-09-18 05:40:43.622079	0	f	60	t	\N	9895200
388	2024-09-16 00:00:00	2024-10-16 12:51:47.634796	5	f	15	2375000	2256250	221	1	t	2527000	1782	2527000	0	2024-09-20 06:50:11.367732	0	f	60	t	\N	0
477	2024-10-08 22:22:53.249053	2024-11-07 22:22:53.249104	5	t	20	3100000	2945000	92	1	t	3298400	1874	3298400	0	2024-10-09 18:30:32.547597	0	f	60	t	\N	0
506	2024-10-11 14:48:56.458817	2024-11-10 14:48:56.458863	0	f	20	6000000	6000000	235	3	f	6720000	1324	0	6720000	2024-10-11 14:48:56.458848	0	f	60	t	\N	0
474	2024-10-03 23:09:31.308372	2024-11-02 23:09:31.308428	5	t	40	3710000	3524500	91	1	t	3947440	1880	3947440	0	2024-10-08 12:48:56.171302	0	f	60	t	\N	0
306	2024-09-09 00:00:00	2024-10-09 09:56:53.482849	8	f	50	7750000	7130000	72	1	t	7985600	1688	7985600	0	2024-09-12 09:54:44.186128	0	f	60	t	\N	0
394	2024-09-20 00:00:00	2024-10-20 05:14:24.357011	5	f	10	650000	617500	14	3	f	691600	1268	0	691600	2024-09-20 05:14:24.356991	0	f	60	t	\N	0
372	2024-09-16 00:00:00	2024-10-16 12:51:47.634796	5	f	116	12645000	12012750	22	3	t	13454280	2975	13454280	0	2024-09-19 04:27:19.35557	0	f	60	t	\N	0
468	2024-10-03 23:09:31.308372	2024-11-02 23:09:31.308428	5	f	20	2750000	2612500	108	1	t	2926000	1311	2926000	0	2024-10-14 12:10:15.973401	0	f	60	t	\N	0
402	2024-09-20 00:00:00	2024-10-20 05:14:24.357011	5	t	20	3100000	2945000	103	1	f	3298400	1273	0	3298400	2024-09-20 05:14:24.356991	0	f	60	t	\N	0
301	2024-09-09 00:00:00	2024-10-09 09:56:53.482849	5	t	22	3410000	3239500	91	1	t	3628240	1687	3628240	0	2024-09-10 00:00:00	0	f	60	t	\N	0
391	2024-09-19 00:00:00	2024-10-19 10:13:49.011493	5	f	50	3600000	3420000	155	1	t	3830400	1733	3830400	0	2024-09-19 13:07:47.38715	0	f	60	t	\N	0
328	2024-09-10 00:00:00	2024-10-10 12:08:11.074948	5	t	15	2325000	2208750	122	1	t	2473800	1703	2473800	0	2024-09-12 07:28:11.394663	0	f	60	t	\N	0
421	2024-09-24 00:00:00	2024-10-24 09:50:26.02088	5	t	15	2220000	2109000	173	3	f	2362080	1284	0	2362080	2024-09-24 09:50:26.020859	0	f	60	t	\N	0
397	2024-09-20 00:00:00	2024-10-20 05:14:24.357011	5	t	100	15500000	14725000	123	1	t	16492000	1789	16492000	0	2024-09-23 06:05:16.691212	0	f	60	t	\N	0
345	2024-09-11 00:00:00	2024-10-11 12:45:01.837999	5	t	50	7750000	7362500	79	1	t	8246000	1715	8246000	0	2024-09-13 05:44:20.886733	0	f	60	t	\N	0
411	2024-09-24 00:00:00	2024-10-24 09:50:26.02088	5	f	20	3800000	3610000	35	1	f	4043200	1278	0	4043200	2024-09-24 09:50:26.020859	0	f	60	t	\N	0
413	2024-09-24 00:00:00	2024-10-24 09:50:26.02088	8	t	100	8500000	7820000	154	3	t	8758400	3050	8758400	0	2024-09-25 05:29:48.581087	0	f	60	t	\N	0
459	2024-10-02 00:00:00	2024-11-01 13:24:50.913168	5	t	50	3250000	3087500	123	3	t	3458000	3122	3458000	0	2024-10-17 19:59:27.161392	0	f	60	t	\N	3458000
385	2024-09-16 00:00:00	2024-10-16 12:51:47.634796	5	t	120	18600000	17670000	50	1	t	19790400	1777	19790400	0	2024-09-20 06:45:45.750995	0	f	60	t	\N	9070600
464	2024-10-03 23:09:31.308372	2024-11-02 23:09:31.308428	5	f	5	950000	902500	93	1	f	1010800	1307	0	1010800	2024-10-03 23:09:31.308412	0	f	60	t	\N	0
420	2024-09-24 00:00:00	2024-10-24 09:50:26.02088	5	t	25	2420000	2299000	173	1	f	2574880	1283	0	2574880	2024-09-24 09:50:26.020859	0	f	60	t	\N	0
424	2024-09-25 00:00:00	2024-10-25 11:29:44.144536	5	t	50	6350000	6032500	108	1	f	6756400	1286	0	6756400	2024-09-25 11:29:44.144519	0	f	60	t	\N	0
416	2024-09-24 00:00:00	2024-10-24 09:50:26.02088	8	t	30	2420000	2226400	154	1	t	2493568	1815	2493570	-2	2024-09-25 10:55:20.406489	0	f	60	t	\N	0
310	2024-09-09 00:00:00	2024-10-09 09:56:53.482849	5	t	10	1550000	1472500	179	1	t	1649200	1811	1649200	0	2024-09-26 11:18:08.582771	0	f	60	t	\N	0
465	2024-10-03 23:09:31.308372	2024-11-02 23:09:31.308428	5	f	14	2170000	2061500	44	1	t	2308880	1875	2308880	0	2024-10-09 19:01:57.527421	0	f	60	t	\N	0
377	2024-09-16 00:00:00	2024-10-16 12:51:47.634796	22.462	f	35	6650000	5156277	217	1	t	5775030	1252	5775035	-5	2024-09-17 11:57:23.714586	0	f	60	t	\N	0
430	2024-09-26 00:00:00	2024-10-26 12:30:20.476545	5	t	200	15700000	14915000	80	1	t	16704800	1816	0	16704800	2024-09-25 00:00:00	0	f	60	t	\N	0
407	2024-09-24 00:00:00	2024-10-24 09:50:26.02088	5	t	10	650000	617500	216	3	t	691600	3049	691600	0	2024-09-25 05:25:56.654922	0	f	60	t	\N	0
428	2024-09-26 00:00:00	2024-10-26 09:56:59.738609	8	f	110	12900000	11868000	151	1	t	13292160	1481	13292170	-10	2024-09-26 11:44:13.481329	0	f	60	t	\N	0
429	2024-09-26 00:00:00	2024-10-26 09:56:59.738609	8	f	20	1440000	1324800	151	3	t	1483776	3063	1483780	-4	2024-09-26 11:44:06.858509	0	f	60	t	\N	0
466	2024-10-03 23:09:31.308372	2024-11-02 23:09:31.308428	5	f	45	4875000	4631250	42	1	t	5187000	1878	5187000	0	2024-10-08 12:56:23.84486	0	f	60	t	\N	0
449	2024-10-02 00:00:00	2024-10-26 12:30:20.476545	5	t	400	34000000	32300000	121	3	t	36176000	3120	19987240	16188760	2024-10-09 13:27:47.819782	0	f	60	t	\N	0
450	2024-10-02 00:00:00	2024-10-26 12:30:20.476545	5	t	10	1550000	1472500	135	1	t	1649200	1872	1649200	0	2024-10-07 00:00:00	0	f	60	t	\N	0
453	2024-10-02 00:00:00	2024-10-26 12:30:20.476545	5	t	10	1550000	1472500	169	1	t	1649200	1853	1649200	0	2024-10-09 18:12:54.940998	0	f	60	t	\N	0
313	2024-09-09 00:00:00	2024-10-09 09:56:53.482849	5	f	20	1600000	1520000	178	1	t	1702400	1701	1702400	0	2024-09-12 07:35:12.602402	0	f	60	t	\N	0
335	2024-09-11 00:00:00	2024-10-11 12:45:01.837999	27.3	f	120	8500000	6179500	21	3	t	6921040	2549	6921020	20	2024-08-19 00:00:00	0	f	60	t	\N	0
320	2024-08-09 00:00:00	2024-10-09 09:56:53.482849	34.565	t	320	49600000	32455760	110	1	t	36350450	1489	36349760	690	2024-08-12 00:00:00	0	f	60	t	\N	0
351	2024-09-11 00:00:00	2024-10-11 12:45:01.837999	5	t	14	1755000	1667250	175	1	t	1867320	1776	1867320	0	2024-09-20 06:47:30.51025	0	f	60	t	\N	0
203	2024-08-24 00:00:00	2024-09-23 09:55:36.540515	8	t	20	1700000	1564000	154	3	t	1751680	2635	1751680	0	2024-08-26 05:27:31.998235	0	f	60	t	\N	0
415	2024-09-24 00:00:00	2024-10-24 09:50:26.02088	5	t	100	7850000	7457500	161	1	t	8352400	1814	8352400	0	2024-09-25 10:56:27.628728	0	f	60	t	\N	8352400
431	2024-09-26 00:00:00	2024-10-26 12:30:20.476545	5	t	50	7750000	7362500	192	1	t	8246000	1686	8246000	0	2024-09-27 06:29:52.485618	0	f	60	t	\N	8246000
207	2024-08-24 00:00:00	2024-09-23 09:55:36.540515	49.04	f	200	15700000	8000720	153	1	t	8960806	1134	0	8960806	2024-08-01 00:00:00	0	f	60	t	\N	0
216	2024-08-26 00:00:00	2024-09-25 05:57:51.370763	0	t	20	1440000	1440000	158	3	t	1612800	2672	0	1612800	2024-08-30 07:06:42.759184	0	f	60	t	\N	0
238	2024-08-29 00:00:00	2024-09-28 10:25:24.445142	5	f	30	2990000	2840500	91	1	t	3181360	1633	3181360	0	2024-08-29 10:36:51.105319	0	f	60	t	\N	0
208	2024-08-26 00:00:00	2024-09-25 05:57:51.370763	66.013	f	100	15500000	5267985	36	1	t	5900144	1135	0	5900144	2024-08-26 06:30:56.310442	0	f	60	t	\N	0
167	2024-08-15 00:00:00	2024-09-14 11:23:50.538632	5	t	20	3100000	2945000	92	1	t	3298400	1576	3298400	0	2024-08-21 09:34:55.838112	0	f	60	t	\N	0
180	2024-08-15 00:00:00	2024-09-14 11:23:50.538632	5	f	10	1550000	1472500	26	1	t	1649200	1578	1649200	0	2024-08-22 06:34:33.134223	0	f	60	t	\N	0
143	2024-08-13 00:00:00	2024-09-12 12:09:01.352712	5	t	55	5620000	5339000	103	1	t	5979680	1528	5979680	0	2024-08-14 06:30:21.843336	0	f	60	t	\N	0
195	2024-08-21 00:00:00	2024-09-20 07:39:51.761825	5	t	20	1440000	1368000	14	3	t	1532160	2625	1532160	0	2024-08-21 12:51:37.427306	0	f	60	t	\N	0
224	2024-08-26 00:00:00	2024-09-25 05:57:51.370763	5	t	30	4650000	4417500	159	1	t	4947600	1608	4947600	0	2024-08-27 11:37:12.127238	0	f	60	t	\N	0
191	2024-08-15 00:00:00	2024-09-14 11:23:50.538632	5	t	20	1700000	1615000	42	1	t	1808800	1600	1808800	0	2024-08-26 04:50:14.126919	0	f	60	t	\N	0
120	2024-08-13 00:00:00	2024-09-12 02:35:16.555097	5	f	47	3384000	3214800	91	1	t	3600576	1506	3600576	0	2024-08-13 07:21:52.89503	0	f	60	t	\N	0
508	2024-10-14 17:54:28.178023	2024-11-13 17:54:28.178084	5	t	110	18960000	18012000	233	3	t	20173440	3283	20173440	0	2024-10-15 15:31:31.706253	0	f	60	t	\N	0
185	2024-08-15 00:00:00	2024-09-14 11:23:50.538632	5	f	330	28050000	26647500	62	1	t	29845200	1569	29845200	0	2024-08-21 05:42:48.205746	0	f	60	t	\N	29845200
\.


--
-- Data for Name: reservation_payed_amounts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.reservation_payed_amounts (id, amount, description, date, reservation_id, product_id, doctor_id, total_sum, remainder_sum, quantity, bonus, nds_sum, fot_sum, promo_sum, skidka_sum, pure_proceeds, month_number) FROM stdin;
335	0	.	2024-10-14 17:54:28.174207	240	12	409	30960760	120720	0	t	0	0	0	0	0	8
339	3447360	Платинум Оптима Сервис-19.09.2024 г. 23.09.2024 г. 25.09.2024 г. 27.09.2024 г. 03.10.2024 г. 07.10.2024 г. 08.10.2024 г. 	2024-10-14 17:54:28.174207	233	12	466	15800000	79400	45	t	369360	720000	720000	162000	3240000	8
346	8740760	Оплата 28.08.2024 г.	2024-10-15 07:30:10.619542	233	25	466	91293200	82169400	53	t	936510	2385000	2650000	410750	8215000	8
354	1255520	14.10.2024 г поступление 	2024-10-15 07:30:10.619542	507	26	378	8171520	0	10	t	134520	250000	250000	59000	1180000	10
358	1915200	100% 14.10.2024 предоплата болган 	2024-10-15 15:30:13.523455	508	20	690	20173440	0	30	t	205200	390000	390000	90000	1800000	10
363	13888000	Оплата - 100% 16.10.2024 г.	2024-10-15 16:44:11.432603	497	25	317	21889600	4800	80	t	1488000	3600000	4000000	0	12400000	10
367	4947600	.	2024-10-17 23:12:27.097443	323	25	384	4947600	0	30	t	0	0	0	0	0	9
368	9895200	.	2024-10-17 23:12:27.097443	337	25	304	9895200	0	60	t	0	0	0	0	0	9
47	399000	,	2024-08-12 00:00:00	107	30	357	1606640	0	5	\N	42750	130000	100000	18750	375000	\N
48	824600	,	2024-08-12 00:00:00	107	25	357	1606640	0	5	\N	88350	225000	250000	38750	775000	\N
49	383040	,	2024-08-12 00:00:00	107	12	357	1606640	0	5	\N	41040	80000	80000	18000	360000	\N
336	30840040	.	2024-10-14 17:54:28.174207	240	25	409	30960760	120720	187	t	3304290	8415000	9350000	1449250	28985000	8
341	824600	ОЛТИНСОЙ ЖАННАТ опл-29.08.2024 г	2024-10-15 07:30:10.619542	214	25	601	2287600	0	5	t	88350	225000	250000	38750	775000	8
348	1532160	100% оплата боган 	2024-10-15 07:30:10.619542	511	24	457	1532160	0	20	t	164160	360000	340000	72000	1440000	10
355	6916000	14.10.2024 г поступление 	2024-10-15 07:30:10.619542	507	31	664	8171520	0	20	t	741000	2000000	1200000	325000	6500000	10
359	2298240	100% 14.10.2024 предоплата болган 	2024-10-15 15:30:13.523455	508	24	690	20173440	0	30	t	246240	540000	510000	108000	2160000	10
364	7996800	Оплата - 100% 16.10.2024 г.	2024-10-15 16:44:11.432603	497	13	691	21889600	4800	84	t	856800	1680000	1680000	0	7140000	10
369	9070600	..	2024-10-17 23:12:27.097443	385	25	317	9070600	0	55	t	0	0	0	0	0	9
371	4522000	Закрыто.	2024-10-17 23:12:27.097443	415	13	669	8352400	0	50	t	0	0	0	0	0	9
372	8246000	Закрыто	2024-10-17 23:12:27.097443	431	25	673	8246000	0	50	t	0	0	0	0	0	9
156	3298400	....	2024-08-30 00:00:00	234	25	311	3298400	0	20	t	353400	900000	1000000	155000	3100000	\N
337	4522000	Платинум Оптима Сервис-19.09.2024 г. 23.09.2024 г. 25.09.2024 г. 27.09.2024 г. 03.10.2024 г. 07.10.2024 г. 08.10.2024 г. 	2024-10-14 17:54:28.174207	233	13	597	15800000	79400	50	t	484500	1000000	1000000	212500	4250000	8
340	9895200	Янгикургон Дори-Дармон поступление-17.09.2024 г.	2024-10-14 17:54:28.174207	227	25	304	9895200	0	60	t	1060200	2700000	3000000	465000	9300000	8
342	452200	ОЛТИНСОЙ ЖАННАТ опл-29.08.2024 г	2024-10-15 07:30:10.619542	214	13	601	2287600	0	5	t	48450	100000	100000	21250	425000	8
344	3600560	Канлыколь рай.больница оплата 17.09.2024 г	2024-10-15 07:30:10.619542	349	27	658	3600576	16	20	t	385774	920000	800000	585214	3800000	8
347	383040	Оплата 28.08.2024 г.	2024-10-15 07:30:10.619542	233	12	466	91293200	82169400	5	t	41040	80000	80000	18000	360000	8
349	723520	100% оплата боган 	2024-10-15 07:30:10.619542	512	13	596	723520	0	8	t	77520	160000	160000	34000	680000	10
350	1532160	100% оплата боган 	2024-10-15 07:30:10.619542	510	12	342	1532160	0	20	t	164160	320000	320000	72000	1440000	10
356	0	14.10.2024 г поступление 	2024-10-15 07:30:10.619542	507	13	378	8171520	0	0	t	0	0	0	0	0	10
360	4060224	.	2024-10-15 16:44:11.432603	516	12	409	4060224	0	53	t	435024	848000	848000	190800	3816000	10
365	29845200	......provedeno	2024-10-17 19:49:28.873155	185	13	415	29845200	0	330	t	0	0	0	0	0	8
370	3830400	Закрыто.	2024-10-17 23:12:27.097443	415	12	669	8352400	0	50	t	0	0	0	0	0	9
263	1225728	.	2024-09-26 00:00:00	359	12	591	12257280	11031552	16	t	131328	256000	256000	57600	1152000	\N
264	1483780	.	2024-09-26 00:00:00	429	24	684	14837800	13354020	20	t	158976	360000	340000	115196	1440000	\N
265	3709450	.	2024-09-26 00:00:00	428	12	684	132921600	119629430	50	t	397441	800000	800000	287991	3600000	\N
266	9582720	.	2024-09-26 00:00:00	428	25	589	132921600	119629430	60	t	1026720	2700000	3000000	744000	9300000	\N
50	414960	.	2024-08-12 00:00:00	109	10	357	414960	0	3	\N	44460	90000	90000	19500	390000	\N
51	3298400	.	2024-08-12 00:00:00	110	25	311	3298400	0	20	\N	353400	900000	1000000	155000	3100000	\N
52	904400	.	2024-08-13 00:00:00	103	13	314	4947600	0	10	\N	96900	200000	200000	42500	850000	\N
53	4043200	.	2024-08-13 00:00:00	103	27	314	4947600	0	20	\N	433200	920000	800000	190000	3800000	\N
54	3463320	.	2024-08-13 00:00:00	114	25	361	3463320	0	21	\N	371070	945000	1050000	162750	3255000	\N
55	7660800	.	2024-08-13 00:00:00	117	24	301	7660800	0	100	\N	820800	1800000	1700000	360000	7200000	\N
57	3600576	.	2024-08-13 00:00:00	120	12	309	3600576	0	47	\N	385776	752000	752000	169200	3384000	\N
58	8118300	.	2024-08-13 00:00:00	102	5	304	8118320	20	50	\N	869818	2000000	1750000	381518	7630000	\N
59	45220000	.	2024-08-13 00:00:00	121	28	461	45220000	0	500	\N	4845000	11000000	10500000	2125000	42500000	\N
60	1580040	.	2024-08-13 00:00:00	126	23	303	1580040	0	30	\N	169290	405000	360000	74250	1485000	\N
61	8246000	1	2024-08-13 00:00:00	134	25	80	8246000	0	50	\N	883500	2250000	2500000	387500	7750000	\N
62	3298400	1	2024-08-13 00:00:00	136	25	80	3298400	0	20	\N	353400	900000	1000000	155000	3100000	\N
65	798000	.	2024-08-13 00:00:00	124	7	303	1489600	0	10	\N	85500	190000	190000	37500	750000	\N
66	691600	.	2024-08-13 00:00:00	124	10	303	1489600	0	5	\N	74100	150000	150000	32500	650000	\N
267	691600	.	2024-09-26 00:00:00	407	19	655	6916000	6224400	10	t	74100	190000	160000	32500	650000	\N
268	3753792	/	2024-09-26 00:00:00	367	12	472	278853120	250967808	49	t	402192	784000	784000	176400	3528000	\N
269	4341120	/	2024-09-26 00:00:00	367	13	472	278853120	250967808	48	t	465120	960000	960000	204000	4080000	\N
69	252700	.	2024-08-13 00:00:00	108	18	357	981540	0	5	\N	27075	70000	60000	11875	237500	\N
70	345800	.	2024-08-13 00:00:00	108	19	357	981540	0	5	\N	37050	95000	80000	16250	325000	\N
71	383040	.	2024-08-13 00:00:00	108	24	357	981540	0	5	\N	41040	90000	85000	18000	360000	\N
73	3298450	1	2024-08-13 00:00:00	123	24	299	3298450	0	50	\N	353405	900000	850000	654955	3600000	\N
74	505400	1	2024-08-13 00:00:00	89	18	300	505400	0	10	\N	54150	140000	120000	23750	475000	\N
75	766080	.	2024-08-13 00:00:00	92	12	302	766080	0	10	\N	82080	160000	160000	36000	720000	\N
76	4947600	.	2024-08-13 00:00:00	141	25	378	4947600	0	30	\N	530100	1350000	1500000	232500	4650000	\N
77	3298400	.	2024-08-13 00:00:00	143	25	311	5979680	0	20	\N	353400	900000	1000000	155000	3100000	\N
78	2681280	.	2024-08-13 00:00:00	143	12	313	5979680	0	35	\N	287280	560000	560000	126000	2520000	\N
80	1649200	.	2024-08-14 00:00:00	155	25	531	1649200	0	10	\N	176700	450000	500000	77500	1550000	\N
82	1532160	.	2024-08-15 00:00:00	157	12	300	3340960	0	20	\N	164160	320000	320000	72000	1440000	\N
83	1808800	.	2024-08-15 00:00:00	157	13	302	3340960	0	20	\N	193800	400000	400000	85000	1700000	\N
84	3830400	1	2024-08-15 00:00:00	161	24	301	3830400	0	50	\N	410400	900000	850000	180000	3600000	\N
85	4870980	1	2024-08-15 00:00:00	133	5	516	4870992	12	30	\N	521891	1200000	1050000	228911	4578000	\N
86	0	1	2024-08-15 00:00:00	133	5	516	24	24	0	\N	0	0	0	0	0	\N
87	0	1	2024-08-15 00:00:00	155	25	531	1650000	1650000	0	\N	0	0	0	0	0	\N
88	5520444	1	2024-08-15 00:00:00	132	5	516	5522160	1716	34	\N	591476	1360000	1190000	259432	5188400	\N
89	1808800	1	2024-08-15 00:00:00	130	28	514	5266800	0	20	\N	193800	440000	420000	85000	1700000	\N
90	3458000	1	2024-08-15 00:00:00	130	19	485	5266800	0	50	\N	370500	950000	800000	162500	3250000	\N
91	1455552	.	2024-08-15 00:00:00	96	12	309	2987712	1532160	19	\N	155952	304000	304000	68400	1368000	\N
92	1532160	.	2024-08-15 00:00:00	96	12	310	3064852	1532692	20	\N	164160	320000	320000	72000	1440000	\N
93	10381280	1	2024-08-15 00:00:00	171	25	480	13500000	491200	65	\N	1112280	2925000	3250000	806000	10075000	\N
94	2627520	1	2024-08-15 00:00:00	171	13	480	13500000	491200	30	\N	281520	600000	600000	204000	2550000	\N
95	2451456	.	2024-08-15 00:00:00	170	12	310	2451456	0	32	\N	262656	512000	512000	115200	2304000	\N
96	3298400	.	2024-08-15 00:00:00	122	25	308	3750600	0	20	\N	353400	900000	1000000	155000	3100000	\N
97	452200	.	2024-08-15 00:00:00	122	13	473	3750600	0	5	\N	48450	100000	100000	21250	425000	\N
98	2968560	.	2024-08-15 00:00:00	104	25	312	2968560	0	18	\N	318060	810000	900000	139500	2790000	\N
99	2968560	.	2024-08-15 00:00:00	144	25	312	2968560	0	18	\N	318060	810000	900000	139500	2790000	\N
100	1532160	.	2024-08-15 00:00:00	186	24	532	1532160	0	20	\N	164160	360000	340000	72000	1440000	\N
101	1532160	.	2024-08-21 00:00:00	195	24	357	1532160	0	20	\N	164160	360000	340000	72000	1440000	\N
102	1302336	.	2024-08-22 00:00:00	196	12	593	3140000	28864	17	\N	139536	272000	272000	61200	1224000	\N
103	1808800	.	2024-08-22 00:00:00	196	13	593	3140000	28864	20	\N	193800	400000	400000	85000	1700000	\N
104	4999680	точку	2024-08-22 00:00:00	119	12	409	5000000	320	62	\N	535680	992000	992000	0	4464000	\N
105	6128640	нукта	2024-08-22 00:00:00	119	12	409	6128640	0	76	\N	656640	1216000	1216000	0	5472000	\N
106	3298400	.	2024-08-22 00:00:00	167	25	311	3298400	0	20	\N	353400	900000	1000000	155000	3100000	\N
107	1649200	.	2024-08-22 00:00:00	180	25	531	1649200	0	10	\N	176700	450000	500000	77500	1550000	\N
108	9576000	.	2024-08-22 00:00:00	175	33	594	9576000	0	30	\N	1026000	2250000	1800000	450000	9000000	\N
109	4947600	.	2024-08-22 00:00:00	182	25	384	7660800	0	30	\N	530100	1350000	1500000	232500	4650000	\N
110	2713200	.	2024-08-22 00:00:00	182	13	384	7660800	0	30	\N	290700	600000	600000	127500	2550000	\N
111	766080	.	2024-08-22 00:00:00	181	24	588	766080	0	10	\N	82080	180000	170000	36000	720000	\N
112	766080	.	2024-08-22 00:00:00	179	12	588	766080	0	10	\N	82080	160000	160000	36000	720000	\N
113	1532160	.	2024-08-22 00:00:00	176	24	588	1532160	0	20	\N	164160	360000	340000	72000	1440000	\N
117	2298240	.	2024-08-22 00:00:00	168	12	342	4107040	0	30	\N	246240	480000	480000	108000	2160000	\N
118	1808800	.	2024-08-22 00:00:00	168	13	596	4107040	0	20	\N	193800	400000	400000	85000	1700000	\N
119	1774080	.	2024-08-22 00:00:00	98	12	343	4000000	36320	22	\N	190080	352000	352000	0	1584000	\N
120	2189600	.	2024-08-22 00:00:00	98	13	343	4000000	36320	23	\N	234600	460000	460000	0	1955000	\N
121	766080	.	2024-08-22 00:00:00	194	24	571	766080	0	10	\N	82080	180000	170000	36000	720000	\N
125	1383200	.	2024-08-23 00:00:00	201	19	485	1383200	0	20	\N	148200	380000	320000	65000	1300000	\N
127	4788000	.	2024-08-23 00:00:00	131	31	597	4788000	0	10	\N	513000	1000000	600000	-1025000	3250000	\N
128	3628240	.	2024-08-23 00:00:00	135	25	467	3628240	0	22	\N	388740	990000	1100000	170500	3410000	\N
129	4947600	.	2024-08-23 00:00:00	135	25	466	4947600	0	30	\N	530100	1350000	1500000	232500	4650000	\N
130	4522000	.	2024-08-23 00:00:00	151	13	597	4522000	0	50	\N	484500	1000000	1000000	212500	4250000	\N
131	9895200	.	2024-08-23 00:00:00	178	25	598	12289200	0	60	\N	1060200	2700000	3000000	465000	9300000	\N
132	2394000	.	2024-08-23 00:00:00	178	31	597	12289200	0	5	\N	256500	500000	300000	-512500	1625000	\N
133	16492000	.	2024-08-23 00:00:00	127	25	472	16492000	0	100	\N	1767000	4500000	5000000	775000	15500000	\N
134	8246000	.	2024-08-23 00:00:00	183	25	472	8246000	0	50	\N	883500	2250000	2500000	387500	7750000	\N
136	1751680	.	2024-08-26 00:00:00	203	28	600	1751680	0	20	t	187680	440000	420000	136000	1700000	\N
137	1957760	.	2024-08-26 00:00:00	206	27	601	7624960	0	10	t	209760	460000	400000	152000	1900000	\N
138	4791360	.	2024-08-26 00:00:00	206	25	601	7624960	0	30	t	513360	1350000	1500000	372000	4650000	\N
139	875840	.	2024-08-26 00:00:00	206	13	601	7624960	0	10	t	93840	200000	200000	68000	850000	\N
140	1378944	.	2024-08-26 00:00:00	209	12	309	3028144	0	18	t	147744	288000	288000	64800	1296000	\N
141	1649200	.	2024-08-26 00:00:00	209	25	590	3028144	0	10	t	176700	450000	500000	77500	1550000	\N
142	1808800	.	2024-08-26 00:00:00	191	13	378	1808800	0	20	t	193800	400000	400000	85000	1700000	\N
143	4999680	.	2024-08-26 00:00:00	119	12	409	4999680	0	62	t	535680	992000	992000	0	4464000	\N
144	19790400	.	2024-08-26 00:00:00	125	25	304	21599200	0	120	t	2120400	5400000	6000000	930000	18600000	\N
145	1808800	.	2024-08-26 00:00:00	125	13	303	21599200	0	20	t	193800	400000	400000	85000	1700000	\N
146	4947600	.	2024-08-26 00:00:00	224	25	607	4947600	0	30	t	530100	1350000	1500000	232500	4650000	\N
147	1751680	.	2024-08-26 00:00:00	225	13	441	1751680	0	20	t	187680	400000	400000	136000	1700000	\N
148	0	HJHJ	2024-08-26 00:00:00	225	13	440	100	100	0	t	0	0	0	0	0	\N
149	0	KJKJ	2024-08-26 00:00:00	225	13	440	200	200	0	f	0	0	0	0	0	\N
150	9895200	.	2024-08-26 00:00:00	227	25	304	9895200	0	60	t	1060200	2700000	3000000	465000	9300000	\N
151	4947600	.	2024-08-26 00:00:00	232	25	531	4947600	0	30	t	530100	1350000	1500000	232500	4650000	\N
152	9895200	.	2024-08-26 00:00:00	228	25	598	9895200	0	60	t	1060200	2700000	3000000	465000	9300000	\N
153	4379200	.	2024-08-26 00:00:00	226	13	611	4379200	0	50	t	469200	1000000	1000000	340000	4250000	\N
154	5167456	/	2024-08-26 00:00:00	226	13	612	5167456	0	59	t	553656	1180000	1180000	401200	5015000	\N
155	9895200	.	2024-08-26 00:00:00	236	33	594	10000000	104800	31	t	1060200	2325000	1860000	465000	9300000	\N
157	2298240	Бажарилди	2024-08-30 00:00:00	239	12	621	5012000	560	30	t	246240	480000	480000	108000	2160000	\N
158	2713200	Бажарилди	2024-08-30 00:00:00	239	13	616	5012000	560	30	t	290700	600000	600000	127500	2550000	\N
159	1532160	.	2024-08-30 00:00:00	238	12	310	3181360	0	20	t	164160	320000	320000	72000	1440000	\N
160	1649200	.	2024-08-30 00:00:00	238	25	590	3181360	0	10	t	176700	450000	500000	77500	1550000	\N
161	3298400	.	2024-08-30 00:00:00	243	25	531	3298400	0	20	t	353400	900000	1000000	155000	3100000	\N
162	3298400	.	2024-09-03 00:00:00	249	25	531	3298400	0	20	t	353400	900000	1000000	155000	3100000	\N
163	1649200	.	2024-09-03 00:00:00	244	25	531	1650000	800	10	t	176700	450000	500000	77500	1550000	\N
164	1532160	.	2024-09-03 00:00:00	251	24	602	1532160	0	20	t	164160	360000	340000	72000	1440000	\N
165	824600	.	2024-09-03 00:00:00	256	25	601	2287600	0	5	t	88350	225000	250000	38750	775000	\N
166	452200	.	2024-09-03 00:00:00	256	13	601	2287600	0	5	t	48450	100000	100000	21250	425000	\N
167	1010800	.	2024-09-03 00:00:00	256	27	601	2287600	0	5	t	108300	230000	200000	47500	950000	\N
168	2021600	.	2024-09-05 00:00:00	292	27	594	2021600	0	10	t	216600	460000	400000	95000	1900000	\N
169	3830400	.	2024-09-05 00:00:00	267	24	648	3830400	0	50	t	410400	900000	850000	180000	3600000	\N
170	4366656	.	2024-09-05 00:00:00	271	24	649	4366656	0	57	t	467856	1026000	969000	205200	4104000	\N
171	1761984	.	2024-09-05 00:00:00	286	12	351	1761984	0	23	t	188784	368000	368000	82800	1656000	\N
172	1761984	.	2024-09-05 00:00:00	286	12	590	1761984	0	23	t	188784	368000	368000	82800	1656000	\N
173	1596000	.	2024-09-05 00:00:00	293	33	423	1596000	0	5	t	171000	375000	300000	75000	1500000	\N
174	2021600	.	2024-09-09 00:00:00	274	27	651	2021600	0	10	t	216600	460000	400000	95000	1900000	\N
175	2021600	.	2024-09-09 00:00:00	274	27	650	2021600	0	10	t	216600	460000	400000	95000	1900000	\N
177	4256000	.	2024-09-10 00:00:00	324	27	577	4256000	0	20	t	456000	920000	800000	0	3800000	\N
178	1649200	.	2024-09-10 00:00:00	287	25	531	1649200	0	10	t	176700	450000	500000	77500	1550000	\N
179	36176000	.	2024-09-10 00:00:00	299	28	461	36176000	0	400	t	3876000	8800000	8400000	1700000	34000000	\N
180	1814120	.	2024-09-11 00:00:00	301	25	654	1814120	0	11	t	194370	495000	550000	85250	1705000	\N
181	1814120	.	2024-09-11 00:00:00	301	25	590	1814120	0	11	t	194370	495000	550000	85250	1705000	\N
184	7985600	.	2024-09-11 00:00:00	306	25	450	7985600	0	50	t	855600	2250000	2500000	620000	7750000	\N
186	7799792	.	2024-09-12 00:00:00	322	31	317	7799792	0	22	f	835692	2200000	1320000	185900	7150000	\N
188	798000	.	2024-09-13 00:00:00	313	30	659	1702400	0	10	t	85500	260000	200000	37500	750000	\N
189	904400	.	2024-09-13 00:00:00	313	13	659	1702400	0	10	t	96900	200000	200000	42500	850000	\N
190	2473800	.	2024-09-13 00:00:00	328	25	312	2473800	0	15	t	265050	675000	750000	116250	2325000	\N
191	766080	.	2024-09-13 00:00:00	314	12	357	1564080	0	10	t	82080	160000	160000	36000	720000	\N
192	798000	.	2024-09-13 00:00:00	314	30	357	1564080	0	10	t	85500	260000	200000	37500	750000	\N
193	1649200	.	2024-09-13 00:00:00	294	25	626	1649200	0	10	t	176700	450000	500000	77500	1550000	\N
194	3298400	.	2024-09-13 00:00:00	315	25	311	3298400	0	20	t	353400	900000	1000000	155000	3100000	\N
195	3463320	.	2024-09-13 00:00:00	240	25	409	5000000	4520	21	t	371070	945000	1050000	162750	3255000	\N
196	1532160	.	2024-09-13 00:00:00	240	12	409	5000000	4520	20	t	164160	320000	320000	72000	1440000	\N
197	8246000	.	2024-09-13 00:00:00	284	25	317	8246000	0	50	t	883500	2250000	2500000	387500	7750000	\N
198	1649200	.	2024-09-16 00:00:00	281	25	613	1649200	0	10	t	176700	450000	500000	77500	1550000	\N
182	5862500	.	2024-08-19 00:00:00	335	24	648	6921040	20	100	f	628125	1800000	1700000	1965625	7200000	\N
187	36349760	.	2024-08-12 00:00:00	320	25	317	36349760	0	320	t	3894617	14400000	16000000	17144857	49600000	\N
199	691600	.	2024-09-16 00:00:00	364	19	655	691600	0	10	t	74100	190000	160000	32500	650000	\N
200	9895200	.	2024-09-16 00:00:00	337	25	304	10000000	104800	60	t	1060200	2700000	3000000	465000	9300000	\N
201	3064320	.	2024-09-16 00:00:00	261	12	313	3064320	0	40	t	328320	640000	640000	144000	2880000	\N
203	1649200	.	2024-09-16 00:00:00	374	25	590	2798320	0	10	t	176700	450000	500000	77500	1550000	\N
204	1149120	.	2024-09-16 00:00:00	374	12	309	2798320	0	15	t	123120	240000	240000	54000	1080000	\N
205	0	.	2024-09-16 00:00:00	374	25	590	1149120	0	0	t	0	0	0	0	0	\N
206	1149120	.	2024-09-16 00:00:00	374	12	310	1149120	0	15	t	123120	240000	240000	54000	1080000	\N
185	23130520	.	2024-08-11 00:00:00	347	27	657	23130520	0	140	f	2478270	6440000	5600000	5947750	26600000	\N
207	0	Test	2024-09-16 00:00:00	330	13	600	1	1	0	f	0	0	0	0	0	\N
208	0	Test	2024-09-16 00:00:00	330	25	600	1	1	0	t	0	0	0	0	0	\N
209	0	Test	2024-09-16 00:00:00	330	25	601	2	2	0	t	0	0	0	0	0	\N
214	4999680	.	2024-09-16 00:00:00	237	24	409	5000000	320	62	t	535680	1116000	1054000	0	4464000	\N
215	505400	.	2024-09-19 00:00:00	372	18	300	7325640	0	10	t	54150	140000	120000	23750	475000	\N
216	691600	.	2024-09-19 00:00:00	372	19	302	7325640	0	10	t	74100	190000	160000	32500	650000	\N
217	6128640	.	2024-09-19 00:00:00	372	38	622	7325640	0	48	t	656640	0	0	288000	5760000	\N
218	0	.	2024-09-19 00:00:00	372	19	302	6128640	0	0	t	0	0	0	0	0	\N
219	6128640	.	2024-09-19 00:00:00	372	38	666	6128640	0	48	t	656640	0	0	288000	5760000	\N
220	0	.	2024-09-19 00:00:00	372	18	300	6128640	0	0	t	0	0	0	0	0	\N
221	1149120	.	2024-09-19 00:00:00	370	12	300	1149120	0	15	t	123120	240000	240000	54000	1080000	\N
222	3830400	.	2024-09-19 00:00:00	391	12	517	3840000	9600	50	t	410400	800000	800000	180000	3600000	\N
223	0	Test	2024-09-19 00:00:00	391	12	517	9600	9600	0	t	0	0	0	0	0	\N
224	798000	.	2024-09-20 00:00:00	388	30	659	25270000	22743000	10	t	85500	260000	200000	37500	750000	\N
225	1729000	.	2024-09-20 00:00:00	388	31	416	25270000	22743000	5	t	185250	500000	300000	81250	1625000	\N
226	10719800	.	2024-09-20 00:00:00	385	25	317	107904000	97184200	65	t	1148550	2925000	3250000	503750	10075000	\N
227	3298400	.	2024-09-20 00:00:00	383	25	378	32984000	29685600	20	t	353400	900000	1000000	155000	3100000	\N
228	18150000	20 % от суммы с/ф	2024-09-20 00:00:00	400	27	656	181500000	163350000	110	t	1944643	5060000	4400000	4694643	20900000	\N
229	5852000	.	2024-09-20 00:00:00	403	21	300	58520000	52668000	100	t	627000	1700000	1300000	275000	5500000	\N
232	1532160	,	2024-09-24 00:00:00	389	12	310	15321600	13789440	20	t	164160	320000	320000	72000	1440000	\N
233	766080	.	2024-09-24 00:00:00	273	24	668	7660800	6894720	10	t	82080	180000	170000	36000	720000	\N
234	1596000	.	2024-09-24 00:00:00	408	30	457	39580800	35968520	20	t	171000	520000	400000	75000	1500000	\N
235	766080	.	2024-09-24 00:00:00	408	12	643	39580800	35968520	10	t	82080	160000	160000	36000	720000	\N
236	904400	.	2024-09-24 00:00:00	408	13	643	39580800	35968520	10	t	96900	200000	200000	42500	850000	\N
237	345800	.	2024-09-24 00:00:00	408	31	643	39580800	35968520	1	t	37050	100000	60000	16250	325000	\N
238	1532160	/	2024-09-24 00:00:00	386	24	588	15321600	13789440	20	t	164160	360000	340000	72000	1440000	\N
239	1532160	/	2024-09-24 00:00:00	387	12	588	15321600	13789440	20	t	164160	320000	320000	72000	1440000	\N
183	1058520	.	2024-08-19 00:00:00	335	19	302	6921040	20	20	f	113413	380000	320000	354893	1300000	\N
243	0	Test	2024-09-24 00:00:00	403	21	300	52668000	52668000	0	t	0	0	0	0	0	\N
245	8758400	.	2024-09-24 00:00:00	413	28	600	87590000	78831600	100	t	938400	2200000	2100000	680000	8500000	\N
246	1149120	/	2024-09-24 00:00:00	285	12	669	65489200	58940280	15	t	123120	240000	240000	54000	1080000	\N
247	1356600	/	2024-09-24 00:00:00	285	13	669	65489200	58940280	15	t	145350	300000	300000	63750	1275000	\N
248	4043200	/	2024-09-24 00:00:00	285	27	670	65489200	58940280	20	t	433200	920000	800000	190000	3800000	\N
249	0	Test	2024-09-24 00:00:00	408	30	457	35968520	35968520	0	t	0	0	0	0	0	\N
250	3830400	/	2024-09-24 00:00:00	398	12	616	121934400	109740960	50	t	410400	800000	800000	180000	3600000	\N
251	3298400	/	2024-09-24 00:00:00	398	25	616	121934400	109740960	20	t	353400	900000	1000000	155000	3100000	\N
252	5064640	/	2024-09-24 00:00:00	398	13	616	121934400	109740960	56	t	542640	1120000	1120000	238000	4760000	\N
253	16492000	/	2024-09-24 00:00:00	397	25	474	164920000	148428000	100	t	1767000	4500000	5000000	775000	15500000	\N
255	8246000	/	2024-09-24 00:00:00	333	25	472	82460000	74214000	50	t	883500	2250000	2500000	387500	7750000	\N
256	8246000	/	2024-09-24 00:00:00	345	25	472	82460000	74214000	50	t	883500	2250000	2500000	387500	7750000	\N
257	7985600	/	2024-09-24 00:00:00	305	25	601	79856000	71870400	50	t	855600	2250000	2500000	620000	7750000	\N
258	1649200	.	2024-09-25 00:00:00	346	25	601	16492000	14842800	10	t	176700	450000	500000	77500	1550000	\N
259	0	Test	2024-09-25 00:00:00	408	31	643	35968520	35968520	0	t	0	0	0	0	0	\N
260	3298400	.	2024-09-25 00:00:00	412	25	311	32984000	29685600	20	t	353400	900000	1000000	155000	3100000	\N
261	1649200	.	2024-09-25 00:00:00	414	25	531	16492000	14842800	10	t	176700	450000	500000	77500	1550000	\N
262	1649200	.	2024-09-26 00:00:00	310	25	308	16492000	14842800	10	t	176700	450000	500000	77500	1550000	\N
270	19790400	/	2024-09-26 00:00:00	367	25	472	278853120	250967808	120	t	2120400	5400000	6000000	930000	18600000	\N
271	0	.	2024-09-26 00:00:00	367	12	472	251058248	250967808	0	t	0	0	0	0	0	\N
272	90440	.	2024-09-26 00:00:00	367	13	472	251058248	250967808	1	t	9690	20000	20000	4250	85000	\N
273	90440	/	2024-09-26 00:00:00	367	13	472	250967809	250800761	1	t	9690	20000	20000	4250	85000	\N
274	76608	/	2024-09-26 00:00:00	367	12	472	250967809	250800761	1	t	8208	16000	16000	3600	72000	\N
275	1455552	.	2024-09-26 00:00:00	389	12	351	15244992	13789440	19	t	155952	304000	304000	68400	1368000	\N
276	345800	/	2024-09-26 00:00:00	408	31	643	36314320	35968520	1	t	37050	100000	60000	16250	325000	\N
277	383040	.	2024-09-26 00:00:00	438	12	362	10000000	40960	5	t	41040	80000	80000	18000	360000	\N
278	9576000	.	2024-09-26 00:00:00	438	37	362	10000000	40960	20	t	1026000	0	0	450000	9000000	\N
279	3064320	.	2024-09-26 00:00:00	378	12	302	3064320	0	40	t	328320	640000	640000	144000	2880000	\N
280	1532160	.	2024-09-26 00:00:00	378	12	300	1532160	0	20	t	164160	320000	320000	72000	1440000	\N
281	741890	/	2024-10-03 23:09:31.304459	416	12	674	2493570	0	10	t	79488	160000	160000	57598	720000	\N
282	1751680	/	2024-10-03 23:09:31.304459	416	13	674	2493570	0	20	t	187680	400000	400000	136000	1700000	\N
283	1649200	/	2024-10-03 23:09:31.304459	330	25	675	3458002	2	10	t	176700	450000	500000	77500	1550000	\N
284	1808800	/	2024-10-03 23:09:31.304459	330	13	676	3458002	2	20	t	193800	400000	400000	85000	1700000	\N
285	1484280	.	2024-10-03 23:09:31.304459	351	25	601	1867320	0	9	t	159030	405000	450000	69750	1395000	\N
286	383040	.	2024-10-03 23:09:31.304459	351	12	601	1867320	0	5	t	41040	80000	80000	18000	360000	\N
287	19987240	.	2024-10-08 22:22:53.245591	449	28	461	20000000	12760	221	t	2141490	4862000	4641000	939250	18785000	\N
288	1649200	/	2024-10-08 22:22:53.245591	450	25	531	1650000	800	10	t	176700	450000	500000	77500	1550000	\N
289	6568800	.	2024-10-08 22:22:53.245591	479	13	688	6600000	31200	75	t	703800	1500000	1500000	510000	6375000	\N
290	9895200	.	2024-10-08 22:22:53.245591	475	25	303	10000000	104800	60	t	1060200	2700000	3000000	465000	9300000	\N
291	691600	.	2024-10-08 22:22:53.245591	480	19	685	695000	3400	10	t	74100	190000	160000	32500	650000	\N
292	2298240	.	2024-10-08 22:22:53.245591	470	12	593	5011440	0	30	t	246240	480000	480000	108000	2160000	\N
293	2713200	.	2024-10-08 22:22:53.245591	470	13	473	5011440	0	30	t	290700	600000	600000	127500	2550000	\N
294	1649200	.	2024-10-08 22:22:53.245591	453	25	626	1649200	0	10	t	176700	450000	500000	77500	1550000	\N
295	3298400	.	2024-10-08 22:22:53.245591	469	25	308	3298400	0	20	t	353400	900000	1000000	155000	3100000	\N
296	3298400	.	2024-10-08 22:22:53.245591	477	25	311	3298400	0	20	t	353400	900000	1000000	155000	3100000	\N
297	1649200	.	2024-10-08 22:22:53.245591	474	25	590	3948000	560	10	t	176700	450000	500000	77500	1550000	\N
298	2298240	.	2024-10-08 22:22:53.245591	474	12	351	3948000	560	30	t	246240	480000	480000	108000	2160000	\N
299	904400	.	2024-10-08 22:22:53.245591	484	13	378	904400	0	10	t	96900	200000	200000	42500	850000	\N
300	2021600	.	2024-10-08 22:22:53.245591	483	27	381	2021600	0	10	t	216600	460000	400000	95000	1900000	\N
301	766080	.	2024-10-08 22:22:53.245591	482	24	690	766080	0	10	t	82080	180000	170000	36000	720000	\N
302	2308880	.	2024-10-08 22:22:53.245591	465	25	377	2308880	0	14	t	247380	630000	700000	108500	2170000	\N
303	2713200	.	2024-10-08 22:22:53.245591	466	13	378	5187000	0	30	t	290700	600000	600000	127500	2550000	\N
304	2473800	.	2024-10-08 22:22:53.245591	466	25	453	5187000	0	15	t	265050	675000	750000	116250	2325000	\N
305	3298400	.	2024-10-08 22:22:53.245591	473	25	531	3298400	0	20	t	353400	900000	1000000	155000	3100000	\N
306	1532160	.	2024-10-08 22:22:53.245591	471	24	649	1532160	0	20	t	164160	360000	340000	72000	1440000	\N
307	3472000	.	2024-10-08 22:22:53.245591	497	25	317	5000000	4800	20	t	372000	900000	1000000	0	3100000	\N
308	1523200	.	2024-10-08 22:22:53.245591	497	13	691	5000000	4800	16	t	163200	320000	320000	0	1360000	\N
309	3298400	.	2024-10-08 22:22:53.245591	496	25	590	3298400	0	20	t	353400	900000	1000000	155000	3100000	\N
310	1649200	.	2024-10-08 22:22:53.245591	492	25	308	1649200	0	10	t	176700	450000	500000	77500	1550000	\N
311	21450240	.	2024-10-08 22:22:53.245591	240	12	409	36349800	56760	280	t	2298240	4480000	4480000	1008000	20160000	\N
312	14842800	.	2024-10-08 22:22:53.245591	240	25	409	36349800	56760	90	t	1590300	4050000	4500000	697500	13950000	\N
313	67200	.	2024-10-08 22:22:53.245591	237	20	409	228800	320	1	t	7200	13000	13000	0	60000	\N
314	161280	.	2024-10-08 22:22:53.245591	237	24	409	228800	320	2	t	17280	36000	34000	0	144000	\N
315	3124800	.	2024-10-11 14:48:56.455541	481	25	311	3124800	0	18	t	334800	810000	900000	0	2790000	\N
316	2021600	.	2024-10-11 14:48:56.455541	468	27	381	2926000	0	10	t	216600	460000	400000	95000	1900000	\N
317	904400	.	2024-10-11 14:48:56.455541	468	13	378	2926000	0	10	t	96900	200000	200000	42500	850000	\N
318	691600	..	2024-10-11 14:48:56.455541	502	19	485	700000	8400	10	t	74100	190000	160000	32500	650000	\N
319	4947600	....	2024-10-11 14:48:56.455541	501	25	474	4947600	0	30	t	530100	1350000	1500000	232500	4650000	\N
320	8758400	..	2024-10-11 14:48:56.455541	472	13	611	8758400	0	100	t	938400	2000000	2000000	680000	8500000	\N
321	19790400	...	2024-10-11 14:48:56.455541	476	25	361	19790400	0	120	t	2120400	5400000	6000000	930000	18600000	\N
322	5190210	.	2024-10-11 14:48:56.455541	348	27	657	5190210	0	30	t	556094	1380000	1200000	1065884	5700000	\N
323	5775035	.	2024-10-11 14:48:56.455541	377	27	662	5775035	0	35	t	618754	1610000	1400000	1493719	6650000	\N
324	825005	.	2024-10-11 14:48:56.455541	376	27	662	825005	0	5	t	88393	230000	200000	213388	950000	\N
325	5775035	.	2024-10-11 14:48:56.455541	375	27	662	5775035	0	35	t	618754	1610000	1400000	1493719	6650000	\N
326	3458000	.	2024-10-11 14:48:56.455541	505	19	685	3458000	0	50	t	370500	950000	800000	162500	3250000	\N
327	13575520	,,	2024-10-11 14:48:56.455541	171	25	480	14066720	491200	85	t	1454520	3825000	4250000	1054000	13175000	\N
328	0	,,	2024-10-11 14:48:56.455541	171	13	476	14066720	491200	0	t	0	0	0	0	0	\N
332	1532160	...	2024-10-14 16:53:02.588049	174	24	478	4724160	0	20	t	164160	360000	340000	72000	1440000	8
333	1808800	...	2024-10-14 16:53:02.588049	174	28	480	4724160	0	20	t	193800	440000	420000	85000	1700000	8
334	1383200	...	2024-10-14 16:53:02.588049	174	19	477	4724160	0	20	t	148200	380000	320000	65000	1300000	8
338	7751240	Платинум Оптима Сервис-19.09.2024 г. 23.09.2024 г. 25.09.2024 г. 27.09.2024 г. 03.10.2024 г. 07.10.2024 г. 08.10.2024 г. 	2024-10-14 17:54:28.174207	233	25	466	15800000	79400	47	t	830490	2115000	2350000	364250	7285000	8
343	1010800	ОЛТИНСОЙ ЖАННАТ опл-29.08.2024 г	2024-10-15 07:30:10.619542	214	27	601	2287600	0	5	t	108300	230000	200000	47500	950000	8
345	0	Оплата 28.08.2024 г.	2024-10-15 07:30:10.619542	233	13	597	91293200	82169400	0	t	0	0	0	0	0	8
351	3458000	100% оплата болган	2024-10-15 07:30:10.619542	462	31	664	3458000	0	10	t	370500	1000000	600000	162500	3250000	10
352	2987712	100% оплата боган	2024-10-15 07:30:10.619542	509	12	593	2987712	0	39	t	320112	624000	624000	140400	2808000	10
353	3617600	,,,	2024-10-15 07:30:10.619542	507	13	378	11789120	0	40	t	387600	800000	800000	170000	3400000	10
357	15960000	100% 14.10.2024 предоплата болган 	2024-10-15 15:30:13.523455	508	33	532	20173440	0	50	t	1710000	3750000	3000000	750000	15000000	10
361	9895200	14.10.2024 поступление болган	2024-10-15 16:44:11.432603	517	25	691	9895200	0	60	t	1060200	2700000	3000000	465000	9300000	10
362	1649200	14.10.2024 поступление боган 1 650 000	2024-10-15 16:44:11.432603	458	25	311	1649200	0	10	t	176700	450000	500000	77500	1550000	10
366	3458000	.....	2024-10-17 19:49:28.873155	459	19	485	3458000	0	50	t	0	0	0	0	0	10
\.


--
-- Data for Name: reservation_products; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.reservation_products (id, quantity, product_id, reservation_id, reservation_price, reservation_discount_price, not_payed_quantity) FROM stdin;
202	20	25	143	164920	52600	0
203	35	12	143	76608	37500	0
219	20	12	157	76608	37500	0
151	50	5	102	162366.40000000002	70000	0
179	500	28	121	90440	37750	0
171	21	25	114	164920	52600	0
175	100	24	117	76608	33280	0
178	47	12	120	76608	37500	0
220	20	13	157	90440	42500	0
187	30	23	126	52668	21570	0
157	5	30	107	79800	25000	0
158	5	25	107	164920	52600	0
159	5	12	107	76608	37500	0
163	3	10	109	138320	62000	0
164	20	25	110	164920	52600	0
234	30	12	168	76608	37500	0
152	10	13	103	90440.00000000001	42500	0
153	20	27	103	202160.00000000003	94500	0
196	50	25	134	164920	52600	0
235	20	13	168	90440	42500	0
312	100	25	233	164920	52600	0
145	50	12	98	80640.00000000001	37500	28
238	32	12	170	76608	37500	0
324	300	25	240	173600	52600	2
198	20	25	136	164920	52600	0
183	10	7	124	79800	33500	0
184	5	10	124	138320	62000	0
264	20	24	195	76608	33280	0
160	5	18	108	50540	18950	0
161	5	19	108	69160	26500	0
162	5	24	108	76608	33280	0
182	50	24	123	65969	33280	0
546	50	12	428	74189	37500	0
134	10	18	89	50540.00000000001	18950	0
137	10	12	92	76608.00000000001	37500	0
146	50	13	98	95200.00000000001	42500	27
263	10	24	194	76608	33280	0
199	30	25	141	164920	52600	0
547	60	25	428	159712	52600	0
319	200	20	237	67200	31200	199
226	50	24	161	76608	33280	0
180	20	25	122	164920	52600	0
181	5	13	122	90440	42500	0
154	18	25	104	164920.00000000003	52600	0
204	18	25	144	164920	52600	0
257	20	24	186	76608	33280	0
195	30	5	133	162366	70000	0
216	10	25	155	164920	52600	0
194	34	5	132	162366	70000	0
191	20	28	130	90440	37750	0
192	50	19	130	69160	26500	0
143	39	12	96	76608.00000000001	37500	0
265	17	12	196	76608	37500	0
266	20	13	196	90440	42500	0
233	20	25	167	164920	52600	0
250	10	25	180	164920	52600	0
244	30	33	175	319200	220000	0
252	30	25	182	164920	52600	0
253	30	13	182	90440	42500	0
251	10	24	181	76608	33280	0
249	10	12	179	76608	37500	0
245	20	24	176	76608	33280	0
272	20	19	201	69160	26500	0
193	10	31	131	478800	180000	0
197	52	25	135	164920	52600	0
211	50	13	151	90440	42500	0
247	60	25	178	164920	52600	0
248	5	31	178	478800	180000	0
188	100	25	127	164920	52600	0
254	50	25	183	164920	52600	0
271	30	25	200	164920	52600	0
296	20	24	216	80640	33280	20
318	200	24	237	80640.00000000001	33280	136
276	20	28	203	87584	37750	0
281	10	27	206	195776	94500	0
279	30	25	206	159712	52600	0
280	10	13	206	87584	42500	0
285	18	12	209	76608	37500	0
286	10	25	209	164920	52600	0
260	20	13	191	90440	42500	0
177	200	12	119	80640	37500	0
282	100	12	207	41095	37500	100
283	100	13	207	48514	42500	100
284	100	25	208	59001	52600	100
297	20	25	217	173600.00000000003	52600	20
185	120	25	125	164920	52600	0
186	20	13	125	90440	42500	0
306	60	25	228	164920	52600	0
595	10	27	468	202160	94500	0
302	30	25	224	164920	52600	0
303	20	13	225	87584	42500	0
304	109	13	226	87584	42500	0
311	30	25	232	164920	52600	0
317	31	33	236	319200	220000	0
321	10	25	238	164920	52600	0
315	20	25	234	164920	52600	0
323	30	13	239	90440	42500	0
320	20	12	238	76608	37500	0
322	30	12	239	76608	37500	0
596	10	13	468	90440	42500	0
566	20	33	440	319200	150000	20
329	20	25	243	164920	52600	0
605	120	25	476	164920	52600	0
239	150	25	171	159712	52600	0
575	330	25	446	173600.00000000003	52600	330
256	330	13	185	90440	42500	0
240	30	13	171	87584	42500	0
243	20	24	174	76608	33280	0
551	50	25	431	164920	52600	0
241	20	28	174	90440	37750	0
330	10	25	244	164920	52600	0
313	50	12	233	76608	37500	0
587	10	31	462	345800	165000	0
305	120	25	227	164920	52600	0
337	20	24	251	76608	33280	0
292	5	25	214	164920	52600	0
293	5	13	214	90440	42500	0
604	120	25	475	164920	52600	60
609	30	12	470	76608.00000000001	\N	0
325	300	12	240	80640	37500	0
294	5	27	214	202160	94500	0
599	20	24	471	76608	33280	0
314	50	13	233	90440	42500	0
580	10	25	453	164920	52600	0
579	10	25	450	164920	52600	0
614	10	27	483	202160	94500	0
613	10	24	482	76608	33280	0
590	14	25	465	164920	52600	0
615	10	13	484	90440	42500	0
364	20	27	274	202160	94500	0
335	20	25	249	164920	52600	0
402	10	25	310	164920	52600	0
467	16	12	359	76608	37500	0
411	20	25	315	164920	52600	0
373	50	25	284	164920	52600	0
342	5	25	256	164920	52600	0
343	5	13	256	90440	42500	0
344	5	27	256	202160	94500	0
600	100	13	472	87584	42500	0
490	60	12	378	76608	37500	0
475	50	12	367	76608	37500	0
457	30	27	348	173007	94500	0
622	100	24	490	80642	33280	100
489	35	27	377	165001	94500	0
548	20	24	429	74189	33280	0
488	5	27	376	165001	94500	0
630	10	27	500	202160	94500	10
487	35	27	375	165001	94500	0
592	15	25	466	164920	52600	0
653	60	25	517	164920	52600	0
637	50	19	505	69160	26500	0
585	10	25	458	164920	52600	0
499	20	24	386	76608	33280	0
651	15	30	515	84000.00000000001	25000	15
476	50	13	367	90440	42500	0
242	20	19	174	69160	26500	0
436	100	24	335	58625	33280	0
437	20	19	335	52926	26500	0
606	20	25	477	164920	52600	0
610	30	13	470	90440.00000000001	\N	0
477	120	25	367	164920	52600	0
375	15	13	285	90440	42500	0
376	20	27	285	202160	94500	0
511	100	25	397	164920	52600	0
380	10	27	292	202160	94500	0
356	50	24	267	76608	33280	0
362	57	24	271	76608	33280	0
377	46	12	286	76608	37500	0
504	39	12	389	76608	37500	0
458	20	27	349	180028	94500	0
381	5	33	293	319200	150000	0
647	20	24	511	76608	33280	0
642	50	33	508	319200	150000	0
643	30	20	508	63840	31200	0
644	30	24	508	76608	33280	0
591	30	13	466	90440	42500	0
649	250	25	513	80194	52600	250
633	200	25	503	80003	52600	200
486	30	12	374	76608	37500	0
372	10	25	281	164920	52600	0
552	35	12	432	76608	37500	35
553	35	13	432	90440	42500	35
455	10	25	346	164920	52600	0
659	5	31	523	345800.00000000006	165000	5
567	20	24	441	76608	33280	20
657	10	33	521	336000.00000000006	150000	10
420	30	25	323	164920	52600	0
440	120	25	337	164920	52600	0
456	140	27	347	165218	94500	0
497	120	25	385	164920	52600	0
429	10	25	330	164920	52600	0
421	20	27	324	212800.00000000003	94500	0
378	10	25	287	164920	52600	0
428	20	13	330	90440	42500	0
459	9	25	351	164920	52600	0
623	9	14	488	196000.00000000003	\N	9
374	15	12	285	76608	37500	0
386	400	28	299	90440	37750	0
454	50	25	345	164920	52600	0
460	5	12	351	76608	37500	0
394	50	25	305	159712	52600	0
390	22	25	301	164920	52600	0
395	50	25	306	159712	52600	0
616	20	27	485	142886	94500	20
419	22	31	322	354536	165000	0
417	320	25	320	113593	52600	0
418	65	31	321	413974	165000	65
407	10	30	313	79800	25000	0
408	10	13	313	90440	42500	0
426	15	25	328	164920	52600	0
409	10	12	314	76608	37500	0
410	10	30	314	79800	25000	0
382	10	25	294	164920	52600	0
498	96	38	372	127680	\N	0
481	10	18	372	50540	18950	0
485	10	25	374	164920	52600	0
495	20	25	383	164920	52600	0
472	10	19	364	69160	26500	0
350	40	12	261	76608	37500	0
482	10	19	372	69160	26500	0
500	20	12	387	76608	37500	0
502	5	31	388	345800	165000	0
479	15	12	370	76608	37500	0
505	20	25	390	164920	52600	20
507	20	30	392	79800	25000	20
506	50	12	391	76608	37500	0
501	10	30	388	79800	25000	0
509	10	19	394	69160	26500	10
434	50	25	333	164920	52600	0
363	10	24	273	76608	33280	0
625	10	25	492	164920	52600	0
523	10	19	407	69160	26500	0
516	110	27	400	165000	94500	0
515	10	19	399	69160	26500	10
517	50	19	401	69160	26500	50
527	2	31	408	345800	165000	0
518	20	25	402	164920	52600	20
522	120	25	406	164920	52600	120
549	100	12	430	76608	37500	100
550	100	13	430	90440	42500	100
612	18	25	481	173600.00000000003	52600	0
632	10	19	502	69160	26500	0
631	30	25	501	164920	52600	0
525	10	12	408	76608	37500	0
526	10	13	408	90440	42500	0
638	20	33	506	336000.00000000006	150000	20
519	100	21	403	58520	22340	0
530	20	27	411	202160	94500	20
564	100	12	438	76608	37500	95
532	100	28	413	87584	37750	0
565	20	37	438	478800	165000	0
524	20	30	408	79800	25000	0
574	50	25	445	173600.00000000003	52600	50
538	10	30	420	79800	25000	10
539	10	12	420	76608	37500	10
540	5	27	420	202160	94500	5
541	5	33	421	319200	150000	5
542	10	24	421	76608	33280	10
513	50	12	398	76608	37500	0
514	20	25	398	164920	52600	0
512	56	13	398	90440	42500	0
544	30	13	424	90440	42500	30
545	20	27	424	202160	94500	20
531	20	25	412	164920	52600	0
533	10	25	414	164920	52600	0
634	10	12	504	76608	37500	10
589	5	27	464	202160	94500	5
536	10	12	416	74189	37500	0
537	20	13	416	87584	42500	0
635	5	25	504	164920	52600	5
636	15	15	504	101080	48900	15
648	8	13	512	90440	42500	0
646	20	12	510	76608	37500	0
645	39	12	509	76608	37500	0
578	400	28	449	90440	37750	179
607	50	12	478	76608	37500	50
608	150	13	479	87584	42500	75
611	10	19	480	69160	26500	0
597	20	25	469	164920	52600	0
602	10	25	474	164920	52600	0
603	30	12	474	76608	37500	0
601	20	25	473	164920	52600	0
621	20	33	489	319200	150000	20
624	20	33	491	336000.00000000006	150000	20
650	300	25	514	80193	52600	300
627	20	25	496	164920	52600	0
640	10	26	507	125552	62000	0
641	20	31	507	345800	165000	0
639	40	13	507	90440	42500	0
652	130	12	516	76608	37500	77
654	100	13	518	90440	42500	100
628	100	25	497	173600.00000000003	52600	0
629	100	13	497	95200.00000000001	42500	0
656	40	12	520	80640.00000000001	37500	40
658	19	40	522	74906	19	19
586	50	19	459	69160	26500	0
534	50	12	415	76608	37500	0
535	50	13	415	90440	42500	0
\.


--
-- Data for Name: speciality; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.speciality (id, name) FROM stdin;
4	Невропатолог
3	Терапевт
5	Онколог
1	Кардиолог
2	Реаниматолог
6	Гинеколог
7	Хирург
8	Эндокринолог
9	Гастроэнтеролог
10	Инфекционист
11	Нефролог
12	Гематолог
13	Неонатолог
14	Травматолог
15	Ревматолог
17	Фтизиатр
18	Провизор
19	Нейрохирург
20	Директор
21	Главный врач
22	Сосудистый хирург
23	Кардиохирург
\.


--
-- Data for Name: user_login_monitoring; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_login_monitoring (id, login_date, logout_date, duration, user_id, location, latitude, longitude) FROM stdin;
1	2024-09-15 09:58:26	2024-09-15 09:58:49	0:0:23	80	string	string	string
2	2024-09-16 19:42:00.628743	\N	\N	80	\N	41.3336974	69.2456931
4	2024-09-17 09:22:21.83319	\N	\N	80	\N	41.2596505	69.2240872
5	2024-09-17 09:24:11.678882	\N	\N	80	\N	41.2596505	69.2240872
3	2024-09-16 19:44:18.062091	2024-09-17 04:22:56	8:38:37	80	\N	41.3336974	69.2456931
6	2024-09-17 09:38:11.993967	\N	\N	80	\N	41.2345413	69.2159747
7	2024-09-17 09:39:00.587974	\N	\N	80	\N	41.2345413	69.2159747
9	2024-09-17 09:54:12.227489	\N	\N	116	\N	37.785834	-122.406417
8	2024-09-17 09:52:26.841423	2024-09-17 09:53:47.003158	0:1:20	116	\N	37.785834	-122.406417
10	2024-09-17 12:57:06.549159	\N	\N	116	\N	37.785834	-122.406417
11	2024-09-17 15:00:15.624861	\N	\N	116	\N	37.785834	-122.406417
12	2024-09-17 15:00:21.756934	\N	\N	116	\N	37.785834	-122.406417
13	2024-09-17 15:00:33.423313	\N	\N	116	\N	37.785834	-122.406417
14	2024-09-17 15:07:28.256709	\N	\N	116	\N	37.785834	-122.406417
15	2024-09-17 15:09:35.182999	\N	\N	116	\N	37.785834	-122.406417
17	2024-09-17 15:17:49.691269	\N	\N	116	\N	37.785834	-122.406417
16	2024-09-17 15:11:51.283039	2024-09-17 15:13:35.663484	0:1:44	116	\N	37.785834	-122.406417
19	2024-09-17 17:11:59.988224	\N	\N	116	\N	41.3725202	69.3210911
20	2024-09-17 17:11:59.980446	\N	\N	116	\N	41.3725202	69.3210911
21	2024-09-17 17:11:59.967939	\N	\N	116	\N	41.3725202	69.3210911
22	2024-09-17 17:12:00.005824	\N	\N	116	\N	41.3725202	69.3210911
23	2024-09-17 17:12:00.018328	\N	\N	116	\N	41.3725202	69.3210911
24	2024-09-17 17:12:00.016978	\N	\N	116	\N	41.3725202	69.3210911
25	2024-09-17 17:12:00.069616	\N	\N	116	\N	41.3725202	69.3210911
26	2024-09-17 17:12:00.108402	\N	\N	116	\N	41.3725202	69.3210911
28	2024-09-17 17:16:02.484969	\N	\N	60	\N	41.3731929	69.3235887
27	2024-09-17 17:13:10.478123	2024-09-17 17:15:40.013805	0:2:29	60	\N	41.3731929	69.3235887
29	2024-09-18 16:12:01.851816	2024-09-18 16:12:18.98849	0:0:17	80	\N	41.3731703	69.3233894
18	2024-09-17 16:00:54.135151	2024-09-17 16:45:11.322665	0:44:17	80	\N	41.2345413	69.2159669
32	2024-09-18 22:14:40.832473	\N	\N	80	\N	41.33368590974108	69.24564383008554
33	2024-09-18 22:14:52.556284	\N	\N	80	\N	41.33368822239295	69.24565262335653
34	2024-09-18 22:22:50.073514	\N	\N	80	\N	41.333686828433834	69.2456479372487
35	2024-09-18 22:22:57.406034	\N	\N	80	\N	41.33368673289356	69.24564752805344
36	2024-09-18 22:24:03.027066	\N	\N	80	\N	41.33368673289348	69.24564752805307
37	2024-09-19 10:36:52.727751	\N	\N	62	\N	41.3722897	69.3214636
30	2024-09-18 16:12:33.82204	2024-09-18 17:56:08.652438	1:43:34	80	\N	41.3731703	69.3233894
39	2024-09-19 19:57:02.917097	\N	\N	80	\N	41.33365673412802	69.24570479950663
40	2024-09-19 19:57:07.7433	\N	\N	80	\N	41.333656734177666	69.24570479941762
42	2024-09-19 19:59:33.83444	\N	\N	80	\N	41.33367131802303	69.24567813179674
41	2024-09-19 19:58:06.37341	2024-09-19 19:58:25.839773	0:0:19	80	\N	41.333656734185865	69.24570479940294
43	2024-09-19 19:59:36.791292	\N	\N	80	\N	41.33367131803316	69.24567813177907
44	2024-09-19 20:25:37.080442	\N	\N	80	\N	41.33364782052566	69.24568764099556
45	2024-09-19 20:25:40.664481	\N	\N	80	\N	41.33364782056629	69.24568764096298
46	2024-09-19 20:29:36.884839	\N	\N	80	\N	41.333663982312146	69.24567454741467
48	2024-09-19 21:25:02.725484	\N	\N	80	\N	41.333674692127076	69.24566610460661
47	2024-09-19 20:29:36.931504	2024-09-19 20:29:47.111124	0:0:10	80	\N	41.333663982312146	69.24567454741467
49	2024-09-20 17:59:29.907957	\N	\N	54	\N	41.3732073	69.3236112
50	2024-09-20 17:59:29.904475	\N	\N	54	\N	41.3732073	69.3236112
51	2024-09-20 17:59:29.915173	\N	\N	54	\N	41.3732073	69.3236112
52	2024-09-20 17:59:29.906817	\N	\N	54	\N	41.3732073	69.3236112
53	2024-09-20 17:59:29.936077	\N	\N	54	\N	41.3732073	69.3236112
38	2024-09-19 10:38:46.209434	2024-09-19 11:34:02.861909	0:55:16	54	\N	41.3722897	69.3214636
55	2024-09-21 16:51:19.943903	\N	\N	54	\N	41.2328947	69.1961166
56	2024-09-21 16:51:19.963256	\N	\N	54	\N	41.2328947	69.1961166
57	2024-09-21 16:51:19.97441	\N	\N	54	\N	41.2328947	69.1961166
58	2024-09-21 16:51:19.966888	\N	\N	54	\N	41.2328947	69.1961166
59	2024-09-21 16:51:19.982277	\N	\N	54	\N	41.2328947	69.1961166
54	2024-09-20 17:59:30.283822	2024-09-20 18:01:30.625986	0:2:0	54	\N	41.3732073	69.3236112
60	2024-09-21 16:51:20.297215	2024-09-21 17:16:37.444254	0:25:17	54	\N	41.232901	69.1960997
62	2024-09-22 14:08:42.115322	\N	\N	80	\N	37.785834	-122.406417
63	2024-09-22 14:08:46.179287	\N	\N	80	\N	37.785834	-122.406417
64	2024-09-22 14:28:52.012882	\N	\N	80	\N	37.785834	-122.406417
65	2024-09-22 14:33:34.079593	\N	\N	80	\N	37.785834	-122.406417
66	2024-09-24 14:03:30.878017	\N	\N	80	\N	37.785834	-122.406417
68	2024-09-24 14:04:55.182751	\N	\N	80	\N	37.785834	-122.406417
67	2024-09-24 14:03:43.978935	2024-09-24 14:04:36.89537	0:0:52	80	\N	37.785834	-122.406417
69	2024-09-24 14:04:58.401887	\N	\N	80	\N	37.785834	-122.406417
70	2024-09-24 14:06:02.878947	\N	\N	80	\N	37.785834	-122.406417
71	2024-09-24 14:06:04.831202	\N	\N	80	\N	37.785834	-122.406417
72	2024-09-24 14:16:30.547483	\N	\N	46	\N	41.37308	69.3229883
31	2024-09-18 20:43:36.637915	2024-09-18 21:59:34.745648	1:15:58	80	\N	41.3337038	69.2456918
74	2024-09-24 14:32:13.663115	2024-09-24 14:34:01.76352	0:1:48	80	\N	41.2345505	69.2159859
75	2024-09-24 14:34:08.924049	2024-09-24 14:34:17.910758	0:0:8	80	\N	41.2345505	69.2159859
76	2024-09-24 14:34:26.215653	2024-09-24 14:34:34.581575	0:0:8	80	\N	41.2345505	69.2159859
77	2024-09-24 14:34:41.267174	2024-09-24 14:35:01.270831	0:0:20	80	\N	41.2345505	69.2159859
79	2024-09-24 14:36:34.763825	\N	\N	80	\N	37.785834	-122.406417
80	2024-09-24 14:36:36.736334	\N	\N	80	\N	37.785834	-122.406417
81	2024-09-24 14:36:38.738782	\N	\N	80	\N	37.785834	-122.406417
83	2024-09-24 14:40:30.909719	\N	\N	80	\N	37.785834	-122.406417
82	2024-09-24 14:39:12.564223	2024-09-24 14:40:21.4631	0:1:8	80	\N	37.785834	-122.406417
84	2024-09-24 17:05:00.998766	\N	\N	114	\N	41.3732024	69.3232656
73	2024-09-24 14:16:30.897424	2024-09-24 16:33:06.26059	2:16:35	46	\N	41.37308	69.3229883
85	2024-09-24 17:05:01.167981	2024-09-24 17:14:57.504808	0:9:56	114	\N	41.3732024	69.3232656
87	2024-09-25 09:00:06.977355	\N	\N	80	\N	41.2345505	69.2159804
78	2024-09-24 14:35:09.641089	2024-09-24 14:41:39.028437	0:6:29	80	\N	41.2345505	69.2159859
88	2024-09-25 10:49:47.77361	\N	\N	80	\N	41.23441776641027	69.21577570146817
89	2024-09-25 10:49:51.130295	\N	\N	80	\N	41.234406532294216	69.2157586520818
90	2024-09-25 11:13:12.118792	\N	\N	114	\N	41.3731987	69.3232655
86	2024-09-24 17:21:09.177434	2024-09-24 18:16:28.085089	0:55:18	114	\N	41.3732024	69.3232656
92	2024-09-25 15:04:48.270875	\N	\N	50	\N	41.3731994	69.3232573
91	2024-09-25 11:13:12.528546	2024-09-25 15:04:46.996871	3:51:34	114	\N	41.3731987	69.3232655
93	2024-09-25 15:04:48.76163	2024-09-25 15:18:08.087098	0:13:19	50	\N	41.3731994	69.3232573
95	2024-09-26 11:10:30.066795	\N	\N	110	\N	41.373204	69.3232605
94	2024-09-25 17:07:03.702379	2024-09-25 17:39:29.256584	0:32:25	110	\N	41.3731997	69.3232546
97	2024-09-26 11:57:32.031881	\N	\N	100	\N	41.3731938	69.323257
96	2024-09-26 11:10:30.469206	2024-09-26 11:53:03.871715	0:42:33	110	\N	41.373204	69.3232605
99	2024-09-26 12:14:50.60428	\N	\N	90	\N	41.3731938	69.323257
98	2024-09-26 11:57:33.984869	2024-09-26 12:12:24.758328	0:14:50	100	\N	41.3731938	69.323257
100	2024-09-26 12:14:52.56965	2024-09-26 12:19:23.38488	0:4:30	90	\N	41.3731938	69.323257
102	2024-09-27 10:14:44.141802	\N	\N	80	\N	37.785834	-122.406417
103	2024-09-27 10:55:40.770942	\N	\N	80	\N	37.785834	-122.406417
104	2024-09-27 10:58:50.452621	\N	\N	80	\N	37.785834	-122.406417
105	2024-09-27 11:16:25.744872	\N	\N	100	\N	41.3731903	69.3232578
101	2024-09-26 14:06:37.634093	2024-09-26 14:31:08.453703	0:24:30	100	\N	41.373213	69.3232616
106	2024-09-27 11:16:26.189575	2024-09-27 11:17:08.794038	0:0:42	100	\N	41.3731903	69.3232578
108	2024-09-27 12:14:39.392172	\N	\N	80	\N	41.3731153	69.3234889
61	2024-09-21 17:18:50.402132	2024-09-21 18:50:10.954083	1:31:20	80	\N	41.2328962	69.1961082
110	2024-09-27 14:16:25.241647	\N	\N	100	\N	41.3731803	69.3232638
107	2024-09-27 11:48:54.767438	2024-09-27 12:13:49.541422	0:24:54	114	\N	41.3731903	69.3232578
112	2024-09-27 15:07:28.01516	\N	\N	49	\N	41.3731878	69.3232583
111	2024-09-27 14:16:25.72539	2024-09-27 14:56:27.060895	0:40:1	100	\N	41.3731803	69.3232638
114	2024-09-27 16:28:32.889186	\N	\N	80	\N	37.785834	-122.406417
115	2024-09-27 16:30:24.539751	\N	\N	80	\N	37.785834	-122.406417
116	2024-09-27 17:35:06.936454	\N	\N	80	Tashkent, Yangi Sergeli street	37.785834	-122.406417
117	2024-09-27 17:38:07.470841	\N	\N	80	Tashkent, Yangi Sergeli street	37.785834	-122.406417
118	2024-09-27 17:38:41.42745	\N	\N	80	Tashkent, Yangi Sergeli street	37.785834	-122.406417
119	2024-09-27 17:43:20.698815	\N	\N	80	Tashkent, Yangi Sergeli street	37.785834	-122.406417
120	2024-09-27 17:43:46.2127	\N	\N	80	Tashkent, Yangi Sergeli street	37.785834	-122.406417
121	2024-09-27 17:49:27.02863	\N	\N	80	Tashkent, Yangi Sergeli street	37.785834	-122.406417
122	2024-09-27 17:49:49.973651	\N	\N	80	Tashkent, Yangi Sergeli street	37.785834	-122.406417
123	2024-09-27 18:03:27.412919	\N	\N	50	\N	41.3731833	69.3232519
113	2024-09-27 15:07:29.975894	2024-09-27 17:00:06.567237	1:52:36	49	\N	41.3731878	69.3232583
124	2024-09-27 18:03:29.346922	2024-09-27 18:04:57.896368	0:1:28	50	\N	41.3731833	69.3232519
126	2024-09-27 18:14:07.656318	\N	\N	80	Tashkent, Yangi Sergeli street	37.785834	-122.406417
125	2024-09-27 18:07:35.348183	2024-09-27 18:19:17.293894	0:11:41	46	\N	41.3731833	69.3232519
127	2024-09-27 18:22:33.445669	2024-09-27 18:39:42.674442	0:17:9	49	\N	41.3731833	69.3232519
129	2024-09-27 18:49:00.564502	\N	\N	80	CA, Powell St	37.785834	-122.406417
130	2024-09-27 18:52:54.90808	\N	\N	80	CA, Powell St	41.234397	69.215854
131	2024-09-27 18:54:57.301564	\N	\N	80	CA, Powell St	41.234397	69.215854
132	2024-09-27 18:55:14.405177	\N	\N	80	CA, Powell St	41.234397	69.215854
133	2024-09-27 18:58:34.631396	\N	\N	80	Toshkent, 66M8+W7F	41.2345347	69.2159891
134	2024-09-27 19:00:11.672876	\N	\N	80	Toshkent, 66M8+W7F	41.2345347	69.2159891
128	2024-09-27 18:42:09.813773	2024-09-27 18:51:21.802441	0:9:11	40	\N	41.3731937	69.3232569
137	2024-09-27 19:10:29.558354	\N	\N	80	Tashkent, Yangi Sergeli street	37.785834	-122.406417
138	2024-09-27 19:13:21.248977	\N	\N	80	Tashkent, 66M8+W7F	41.2345357	69.2159788
136	2024-09-27 19:00:40.830121	2024-09-27 19:11:37.367629	0:10:56	80	Toshkent, 66M8+W7F	41.2345347	69.2159891
140	2024-09-28 09:51:09.11713	\N	\N	80	Tashkent, Yangi Sergeli street	37.785834	-122.406417
141	2024-09-28 09:52:29.789218	\N	\N	80	Tashkent, Yangi Sergeli street	37.785834	-122.406417
142	2024-09-28 09:53:35.801879	\N	\N	80	Tashkent, 66M8+W7F	41.2345517	69.2160342
139	2024-09-27 19:14:30.599999	2024-09-27 19:32:56.035208	0:18:25	80	Tashkent, 66M8+W7F	41.2345357	69.2159788
143	2024-09-28 09:57:12.731388	\N	\N	80	Tashkent, Uzbekistan	41.2345517	69.2160342
145	2024-09-28 15:26:12.623819	\N	\N	80	Tashkent, 86V8+JF	41.2345323	69.2159883
144	2024-09-28 10:00:36.357841	2024-09-28 10:13:04.232869	0:12:27	80	Tashkent, 86V8+JF	41.2345517	69.2160342
146	2024-09-28 15:27:24.82456	\N	\N	80	Toshkent Viloyati, Unnamed Road	41.2345323	69.2159883
148	2024-09-28 15:36:00.409038	\N	\N	80	Toshkent Viloyati, Bekobod tumani , 	41.2345323	69.2159883
147	2024-09-28 15:29:54.181799	2024-09-28 15:32:54.697833	0:3:0	80	Toshkent Viloyati, Unnamed Road	41.2345323	69.2159883
149	2024-09-28 15:39:04.774265	\N	\N	80	Toshkent Viloyati, Bekobod tumani , 	41.2345388	69.2159837
150	2024-09-28 15:39:36.371011	\N	\N	80	Toshkent Viloyati, Bekobod tumani , 	41.2345388	69.2159837
151	2024-09-28 15:42:07.180588	\N	\N	80	Tashkent,  , 	41.2345388	69.2159837
152	2024-09-28 15:47:20.073493	\N	\N	80	Tashkent,  , 	41.2345388	69.2159837
153	2024-09-28 15:49:42.668644	\N	\N	80	Tashkent,  , 	41.2345388	69.2159837
155	2024-09-28 15:57:37.32874	\N	\N	80	Tashkent Region,  , 	41.221472	69.191167
154	2024-09-28 15:51:27.728383	2024-09-28 15:52:52.519972	0:1:24	80	Tashkent,  , 	41.2345388	69.2159837
156	2024-09-28 15:59:34.944483	\N	\N	80	Toshkent,  , 	41.244976	69.177729
157	2024-09-28 16:01:35.925333	\N	\N	80	Tashkent Region, Yangiyul District , 	41.128317	69.051864
158	2024-09-28 16:05:54.70566	\N	\N	80	Tashkent Region, Yangiyul District , 	41.128317	69.051864
159	2024-09-28 16:07:32.49013	2024-09-28 16:14:45.428227	0:7:12	80	Tashkent Region, Yangiyul District , 	41.128317	69.051864
161	2024-09-28 16:20:20.718776	\N	\N	80	Ташкентская область, Янгиюльский район , 	41.128317	69.051864
160	2024-09-28 16:15:59.642167	2024-09-28 16:16:08.367085	0:0:8	80	Toshkent Viloyati, Yangiyo‘l tumani , 	41.128317	69.051864
162	2024-09-28 16:21:11.308574	\N	\N	80	Tashkent,  , 	41.2345188	69.2159895
163	2024-09-28 16:25:14.361476	\N	\N	80	Tashkent,  , 	41.2345188	69.2159895
164	2024-09-28 16:31:20.07136	\N	\N	80	Tashkent,  , 	41.2345188	69.2159895
165	2024-09-28 16:33:58.506585	\N	\N	80	Tashkent,  , 	41.2345188	69.2159895
166	2024-09-28 16:36:11.189316	\N	\N	80	Ташкентская область, Янгиюльский район , 	41.128317	69.051864
167	2024-09-28 16:39:41.904609	\N	\N	80	Ташкентская область, Янгиюльский район , 	41.128317	69.051864
168	2024-09-28 16:40:33.926306	\N	\N	80	Toshkent Viloyati, Yangiyo‘l tumani , 	41.138317	69.051864
169	2024-09-28 16:42:21.763675	\N	\N	80	Toshkent Viloyati, Yangiyo‘l tumani , 	41.138317	69.051864
170	2024-09-28 16:43:29.045867	\N	\N	80	Toshkent Viloyati, Yangiyo‘l tumani , 	41.128317	69.051864
171	2024-09-28 16:50:25.225663	\N	\N	80	2–16 Ellis St, Union Square, Сан-Франциско, Сан-Франциско, CA, Соединённые Штаты Америки	37.785834	-122.406417
172	2024-09-28 16:51:11.606705	\N	\N	80	Gulobod ko'chasi, Янгиюл, Ташкент, O‘zbekiston	41.128317	69.051864
173	2024-09-30 10:16:34.658824	\N	\N	46	\N	41.3731958	69.3232526
135	2024-09-27 19:00:34.264037	2024-09-27 19:27:48.331565	0:27:14	90	\N	41.3731937	69.3232569
175	2024-09-30 11:36:02.546511	\N	\N	50	\N	41.3730433	69.3230533
176	2024-09-30 11:36:02.535367	\N	\N	50	\N	41.3730433	69.3230533
177	2024-09-30 11:36:02.54101	\N	\N	50	\N	41.3730433	69.3230533
178	2024-09-30 11:36:02.578503	\N	\N	50	\N	41.3730433	69.3230533
179	2024-09-30 11:36:02.554866	\N	\N	50	\N	41.3730433	69.3230533
109	2024-09-27 12:15:08.87667	2024-09-27 12:18:48.707114	0:3:39	114	\N	41.3731153	69.3234889
180	2024-09-30 11:36:02.550198	\N	\N	50	\N	41.3730433	69.3230533
183	2024-09-30 11:36:02.551804	\N	\N	50	\N	41.3730433	69.3230533
185	2024-09-30 11:36:02.574264	\N	\N	50	\N	41.3730433	69.3230533
181	2024-09-30 11:36:02.557002	\N	\N	50	\N	41.3730433	69.3230533
186	2024-09-30 11:36:02.665591	\N	\N	50	\N	41.3730433	69.3230533
188	2024-09-30 11:36:02.548011	\N	\N	50	\N	41.3730433	69.3230533
182	2024-09-30 11:36:02.541481	\N	\N	50	\N	41.3730433	69.3230533
187	2024-09-30 11:36:02.589487	\N	\N	50	\N	41.3730433	69.3230533
184	2024-09-30 11:36:02.553244	\N	\N	50	\N	41.3730433	69.3230533
243	2024-10-17 19:47:03.226836	\N	\N	86	\N	41.3140918	69.3057388
174	2024-09-30 10:16:35.208536	2024-09-30 10:32:55.77499	0:16:20	46	\N	41.3731958	69.3232526
189	2024-09-30 11:36:14.280266	\N	\N	50	\N	41.3730433	69.3230533
191	2024-09-30 11:47:26.38316	\N	\N	50	\N	41.3731932	69.3235809
190	2024-09-30 11:36:16.271975	2024-09-30 11:45:58.929615	0:9:42	50	\N	41.3730433	69.3230533
193	2024-09-30 17:12:36.290012	\N	\N	50	\N	41.3731803	69.3232561
192	2024-09-30 11:47:26.784724	2024-09-30 14:54:51.155855	3:7:24	50	\N	41.3731932	69.3235809
194	2024-09-30 17:12:36.664879	2024-09-30 17:48:31.847736	0:35:55	50	\N	41.3731803	69.3232561
197	2024-10-01 13:14:43.44399	\N	\N	49	\N	41.2276007	69.2007732
196	2024-09-30 21:56:04.713812	2024-09-30 21:58:44.963414	0:2:40	49	\N	41.2329216	69.1961728
195	2024-09-30 18:19:50.51063	2024-09-30 19:13:13.531071	0:53:23	49	\N	41.373181	69.3232558
199	2024-10-04 15:13:02.180403	2024-10-04 16:17:01.962999	1:3:59	43	\N	41.3731914	69.323256
201	2024-10-04 16:54:31.54173	\N	\N	110	\N	41.3731989	69.3235417
198	2024-10-01 13:14:45.184664	2024-10-01 13:14:46.319251	0:0:1	49	\N	41.2276007	69.2007732
200	2024-10-04 16:31:34.829532	2024-10-04 17:09:39.713843	0:38:4	110	\N	41.3731922	69.3232585
204	2024-10-09 16:48:45.790296	\N	\N	80	2–16 Ellis St, Union Square, Сан-Франциско, Сан-Франциско, CA, Соединённые Штаты Америки	37.785834	-122.406417
205	2024-10-09 17:43:10.145888	\N	\N	114	\N	41.3731804	69.323259
203	2024-10-07 10:51:48.195475	2024-10-07 12:49:06.405942	1:57:18	114	\N	41.3729623	69.3231015
206	2024-10-09 17:59:24.727984	2024-10-09 18:10:19.044164	0:10:54	90	\N	41.3731804	69.323259
208	2024-10-09 18:50:02.588704	\N	\N	40	\N	41.3731804	69.323259
207	2024-10-09 18:24:14.372301	2024-10-09 18:37:48.549774	0:13:34	39	\N	41.3731804	69.323259
209	2024-10-09 19:07:35.147296	\N	\N	114	\N	41.3731804	69.323259
210	2024-10-09 19:13:37.257707	2024-10-09 19:24:10.646796	0:10:33	110	\N	41.3731804	69.323259
211	2024-10-09 19:24:39.563392	2024-10-09 19:40:52.373582	0:16:12	43	\N	41.3731804	69.323259
212	2024-10-09 20:18:01.118905	2024-10-09 20:18:50.429178	0:0:49	50	\N	41.3731875	69.3232579
213	2024-10-09 20:30:44.054943	2024-10-09 20:38:24.479409	0:7:40	49	\N	41.3731875	69.3232579
214	2024-10-09 20:38:57.909849	2024-10-09 20:42:00.134566	0:3:2	100	\N	41.3731875	69.3232579
216	2024-10-10 10:50:44.431509	\N	\N	90	\N	41.3731935	69.3232405
215	2024-10-09 20:46:49.328849	2024-10-09 21:18:07.459243	0:31:18	46	\N	41.3731875	69.3232579
218	2024-10-15 09:31:52.330586	\N	\N	46	\N	41.3095365	69.3432648
217	2024-10-10 10:50:44.808574	2024-10-10 10:56:56.013231	0:6:11	90	\N	41.3731935	69.3232405
220	2024-10-15 09:35:58.068894	\N	\N	43	\N	41.2963091	69.3515171
219	2024-10-15 09:31:52.776727	2024-10-15 09:32:06.901423	0:0:14	46	\N	41.3095365	69.3432648
222	2024-10-15 09:50:20.730652	\N	\N	49	\N	41.2239091	69.3639999
221	2024-10-15 09:35:58.067831	2024-10-15 09:45:10.851007	0:9:12	43	\N	41.2963091	69.3515171
224	2024-10-15 10:03:23.224519	\N	\N	110	\N	41.1381819	69.3181112
225	2024-10-15 10:03:23.236362	\N	\N	110	\N	41.1381819	69.3181112
223	2024-10-15 09:50:21.168921	2024-10-15 09:56:52.086717	0:6:30	49	\N	41.2239091	69.3639999
226	2024-10-15 10:03:44.631355	\N	\N	114	\N	41.1352125	69.3151314
228	2024-10-15 10:06:25.31428	\N	\N	110	\N	41.0898064	69.3255609
227	2024-10-15 10:03:45.567886	2024-10-15 10:03:53.184381	0:0:7	114	\N	41.1352125	69.3151314
230	2024-10-15 20:22:22.643775	\N	\N	110	\N	41.2676194	69.2643632
231	2024-10-15 20:22:22.640624	\N	\N	110	\N	41.2676194	69.2643632
232	2024-10-15 20:22:22.642231	\N	\N	110	\N	41.2676194	69.2643632
234	2024-10-15 20:22:22.64687	\N	\N	110	\N	41.2676194	69.2643632
235	2024-10-15 20:22:22.645565	\N	\N	110	\N	41.2676194	69.2643632
236	2024-10-15 20:22:22.648207	\N	\N	110	\N	41.2676194	69.2643632
244	2024-10-17 20:35:14.181776	\N	\N	85	\N	41.3141074	69.3058314
245	2024-10-17 20:35:14.179411	\N	\N	85	\N	41.3141074	69.3058314
246	2024-10-17 20:35:14.182036	\N	\N	85	\N	41.3141074	69.3058314
247	2024-10-17 20:35:16.142726	\N	\N	85	\N	41.3141074	69.3058314
202	2024-10-04 16:54:32.809577	2024-10-04 16:56:07.696809	0:1:34	110	\N	41.3731989	69.3235417
237	2024-10-16 13:52:25.907817	\N	\N	110	\N	41.3732017	69.3232685
229	2024-10-15 10:06:26.041645	2024-10-15 10:12:05.020509	0:5:38	110	\N	41.0898064	69.3255609
239	2024-10-16 14:25:21.306644	\N	\N	100	\N	41.3731992	69.3232596
238	2024-10-16 13:52:27.861259	2024-10-16 13:55:26.817152	0:2:58	110	\N	41.3732017	69.3232685
241	2024-10-17 19:38:34.666661	\N	\N	100	\N	41.3140556	69.3058271
240	2024-10-16 14:25:21.650852	2024-10-16 14:31:32.823293	0:6:11	100	\N	41.3731992	69.3232596
248	2024-10-17 20:35:18.143208	\N	\N	85	\N	41.3141074	69.3058314
249	2024-10-17 20:35:50.718555	\N	\N	85	\N	41.3141074	69.3058314
250	2024-10-17 20:35:54.707794	\N	\N	85	\N	41.3141074	69.3058314
251	2024-10-17 20:35:52.713865	\N	\N	85	\N	41.3141074	69.3058314
252	2024-10-17 20:42:59.382961	\N	\N	90	\N	41.3140317	69.3058201
254	2024-10-17 20:47:30.075317	\N	\N	85	\N	41.3141074	69.3058314
255	2024-10-17 20:47:48.065503	\N	\N	85	\N	41.3141074	69.3058314
256	2024-10-17 20:47:46.073286	\N	\N	85	\N	41.3141074	69.3058314
257	2024-10-17 20:47:50.083137	\N	\N	85	\N	41.3141074	69.3058314
259	2024-10-17 20:48:02.095368	\N	\N	85	\N	41.3141074	69.3058314
260	2024-10-17 20:48:00.068328	\N	\N	85	\N	41.3141074	69.3058314
258	2024-10-17 20:47:52.065781	2024-10-17 20:48:00.686167	0:0:8	85	\N	41.3141074	69.3058314
261	2024-10-17 20:48:47.056749	2024-10-17 20:49:28.20769	0:0:41	85	\N	41.3141074	69.3058314
253	2024-10-17 20:43:01.33948	2024-10-17 20:49:13.400584	0:6:12	90	\N	41.3140317	69.3058201
264	2024-10-17 20:48:47.057181	\N	\N	85	\N	41.3141074	69.3058314
263	2024-10-17 20:49:59.768192	2024-10-17 20:50:23.095648	0:0:23	90	\N	41.31404	69.3058025
266	2024-10-17 21:13:17.05283	\N	\N	85	\N	41.3141074	69.3058314
262	2024-10-17 20:48:47.057018	2024-10-17 20:57:15.541587	0:8:28	85	\N	41.3141074	69.3058314
268	2024-10-17 21:21:02.912469	\N	\N	85	\N	41.3142388	69.3058605
267	2024-10-17 21:14:13.984673	2024-10-17 21:20:55.758249	0:6:41	85	\N	41.3141074	69.3058314
270	2024-10-18 06:46:45.776162	\N	\N	85	\N	41.3142241	69.3058681
271	2024-10-18 06:46:46.017274	\N	\N	85	\N	41.3142241	69.3058681
269	2024-10-17 21:21:03.257021	2024-10-18 06:46:36.826943	9:25:33	85	\N	41.3142388	69.3058605
272	2024-10-18 06:46:45.775445	\N	\N	85	\N	41.3142241	69.3058681
274	2024-10-18 06:47:58.249992	\N	\N	85	\N	41.3142282	69.3058535
275	2024-10-18 06:47:58.244135	\N	\N	85	\N	41.3142282	69.3058535
273	2024-10-18 06:46:55.225662	2024-10-18 06:47:49.318074	0:0:54	85	\N	41.3142328	69.3058548
277	2024-10-18 08:14:44.404934	\N	\N	85	\N	41.3142299	69.3058359
276	2024-10-18 06:47:58.412764	2024-10-18 08:14:39.187457	1:26:40	85	\N	41.3142282	69.3058535
265	2024-10-17 20:50:29.677281	2024-10-17 21:12:52.889564	0:22:23	90	\N	41.31404	69.3058025
278	2024-10-18 09:04:28.04897	2024-10-18 09:06:32.309824	0:2:4	90	\N	41.2707142	69.264683
279	2024-10-18 09:06:37.685468	2024-10-18 09:07:32.625501	0:0:54	90	\N	41.2707142	69.264683
280	2024-10-18 09:07:38.042667	2024-10-18 09:08:12.379148	0:0:34	90	\N	41.2707142	69.264683
242	2024-10-17 19:38:56.406016	2024-10-18 09:59:21.785397	14:20:25	86	\N	41.3140556	69.3058271
281	2024-10-18 09:08:17.641831	2024-10-18 09:08:58.788513	0:0:41	90	\N	41.2707142	69.264683
283	2024-10-18 09:09:13.635786	\N	\N	90	\N	41.270676	69.264844
282	2024-10-18 09:09:04.23267	2024-10-18 09:09:08.240244	0:0:4	90	\N	41.270676	69.264844
284	2024-10-18 09:59:20.897222	\N	\N	50	\N	41.3731936	69.3232662
285	2024-10-18 09:59:22.876314	\N	\N	50	\N	41.3731936	69.3232662
287	2024-10-18 11:33:48.132402	\N	\N	100	\N	41.3693164	69.3249643
233	2024-10-15 20:22:22.635066	2024-10-15 20:23:08.19569	0:0:45	110	\N	41.2676194	69.2643632
288	2024-10-18 11:33:48.573098	\N	\N	100	\N	41.3693164	69.3249643
289	2024-10-18 11:42:55.704355	\N	\N	110	\N	41.3732034	69.3232661
286	2024-10-18 10:11:21.663988	2024-10-18 11:33:49.101983	1:22:27	49	\N	41.3731936	69.3232662
291	2024-10-18 12:05:41.818915	\N	\N	114	\N	41.3732037	69.3232589
292	2024-10-18 12:05:41.820078	\N	\N	114	\N	41.3732037	69.3232589
290	2024-10-18 11:42:55.910783	2024-10-18 11:45:08.065454	0:2:12	110	\N	41.3732034	69.3232661
294	2024-10-18 12:10:55.767922	\N	\N	43	\N	41.3731889	69.3232504
293	2024-10-18 12:05:42.827684	2024-10-18 12:09:17.811176	0:3:34	114	\N	41.3732037	69.3232589
296	2024-10-18 12:14:31.339245	\N	\N	40	\N	41.3731914	69.3232568
295	2024-10-18 12:10:56.136863	2024-10-18 12:11:07.307592	0:0:11	43	\N	41.3731889	69.3232504
298	2024-10-18 12:18:17.627161	\N	\N	60	\N	41.3733718	69.324222
299	2024-10-18 12:18:52.576915	\N	\N	60	\N	41.3733771	69.324244
300	2024-10-18 12:20:44.983283	\N	\N	39	\N	41.3731928	69.3232684
297	2024-10-18 12:14:31.655468	2024-10-18 12:20:43.855383	0:6:12	40	\N	41.3731914	69.3232568
303	2024-10-18 12:40:44.692004	\N	\N	46	\N	41.3732059	69.3232579
301	2024-10-18 12:20:45.468903	2024-10-18 12:36:22.577611	0:15:37	39	\N	41.3731928	69.3232684
302	2024-10-18 12:40:44.369003	2024-10-18 12:40:45.010448	0:0:0	46	\N	41.3732059	69.3232579
304	2024-10-18 14:10:37.251879	\N	\N	80	66M8+W7F, Тоshkent, Toshkent, Oʻzbekiston	41.2345439	69.2161476
305	2024-10-18 14:36:50.986419	\N	\N	60	\N	41.373038	69.3233741
306	2024-10-18 15:10:17.21329	2024-10-18 15:11:53.653667	0:1:36	51	XJX3+P22, Namangan, Namangan District, Namangan Region, Oʻzbekiston	40.9994608	71.6021375
308	2024-10-18 15:27:52.2197	\N	\N	51	XJW2+8HX, Namangan, Наманган тумани, Namangan viloyati, Oʻzbekiston	40.9962928	71.6016914
307	2024-10-18 15:22:58.17481	2024-10-18 15:25:56.144207	0:2:57	51	XJX3+P22, Namangan, Namangan District, Namangan Region, Oʻzbekiston	40.9994607	71.6021448
\.


--
-- Data for Name: user_product_plan; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_product_plan (id, amount, current_amount, date, product_id, med_rep_id, plan_month, price, discount_price) FROM stdin;
211	20	20	2024-07-29 13:29:43.656437	10	82	2024-07-30 00:00:00	130000	62000
582	30	30	2024-08-13 02:35:16.511164	5	62	2024-08-13 00:00:00	152600	70000
218	50	50	2024-07-29 13:29:43.656437	26	66	2024-07-30 00:00:00	118000	62000
219	20	20	2024-07-29 13:29:43.656437	10	66	2024-07-30 00:00:00	130000	62000
222	50	50	2024-07-29 13:29:43.656437	29	66	2024-07-30 00:00:00	85000	39750
531	200	0	2024-08-12 04:30:39.202846	4	39	2024-08-12 00:00:00	82000	37500
822	285	0	2024-09-16 12:51:47.584962	27	116	2024-09-17 00:00:00	190000	94500
816	10	0	2024-09-13 06:20:00.107924	30	60	2024-09-13 00:00:00	75000	25000
507	200	200	2024-08-12 04:30:39.202846	4	53	2024-08-12 00:00:00	82000	37500
508	100	100	2024-08-12 04:30:39.202846	12	53	2024-08-12 00:00:00	72000	37500
205	50	50	2024-07-29 13:29:43.656437	30	60	2024-07-30 00:00:00	75000	29000
487	100	50	2024-08-12 04:30:39.202846	30	60	2024-08-12 00:00:00	75000	25000
835	1	0	2024-09-26 12:30:20.415993	23	100	2024-08-27 00:00:00	49500	21570
251	50	0	2024-07-30 09:31:31.045248	29	54	2024-07-30 00:00:00	85000	39750
546	50	50	2024-08-12 04:30:39.202846	26	90	2024-08-12 00:00:00	118000	62000
561	200	200	2024-08-12 04:30:39.202846	30	102	2024-08-12 00:00:00	75000	25000
564	100	100	2024-08-12 04:30:39.202846	12	102	2024-08-12 00:00:00	72000	37500
246	300	0	2024-07-30 09:31:31.045248	25	54	2024-07-30 00:00:00	155000	52600
565	100	100	2024-08-12 04:30:39.202846	13	102	2024-08-12 00:00:00	85000	42500
254	100	0	2024-07-30 09:31:31.045248	11	51	2024-07-31 00:00:00	173000	75000
566	50	50	2024-08-12 04:30:39.202846	26	102	2024-08-12 00:00:00	118000	62000
214	50	0	2024-07-29 13:29:43.656437	29	82	2024-07-30 00:00:00	85000	39750
301	50	0	2024-07-31 07:01:58.399984	5	53	2024-07-31 00:00:00	152600	70000
249	100	0	2024-07-30 09:31:31.045248	18	54	2024-07-30 00:00:00	47500	18950
278	50	50	2024-07-30 09:31:31.045248	26	39	2024-07-31 00:00:00	118000	62000
229	100	100	2024-07-30 06:40:42.916593	27	90	2024-07-30 00:00:00	190000	94500
300	550	0	2024-07-31 07:01:58.399984	25	53	2024-07-31 00:00:00	155000	52600
221	50	50	2024-07-29 13:29:43.656437	19	66	2024-07-30 00:00:00	65000	26500
216	100	100	2024-07-29 13:29:43.656437	12	66	2024-07-30 00:00:00	72000	37500
220	100	100	2024-07-29 13:29:43.656437	18	66	2024-07-30 00:00:00	47500	18950
288	20	20	2024-07-30 09:31:31.045248	10	50	2024-07-31 00:00:00	130000	62000
291	30	30	2024-07-30 09:31:31.045248	27	50	2024-07-31 00:00:00	190000	94500
293	20	20	2024-07-30 09:31:31.045248	29	50	2024-07-31 00:00:00	85000	39750
260	50	0	2024-07-30 09:31:31.045248	18	46	2024-07-31 00:00:00	47500	18950
261	50	0	2024-07-30 09:31:31.045248	19	46	2024-07-31 00:00:00	65000	26500
268	100	0	2024-07-30 09:31:31.045248	19	40	2024-07-31 00:00:00	65000	26500
256	200	0	2024-07-30 09:31:31.045248	26	51	2024-07-31 00:00:00	118000	62000
325	50	50	2024-08-01 05:04:01.168448	31	66	2024-08-01 00:00:00	450000	180000
380	30	0	2024-08-01 05:04:01.168448	10	39	2024-08-01 00:00:00	130000	62000
533	50	0	2024-08-12 04:30:39.202846	26	39	2024-08-12 00:00:00	118000	62000
379	50	0	2024-08-01 05:04:01.168448	27	39	2024-08-01 00:00:00	190000	94500
331	50	50	2024-08-01 05:04:01.168448	33	66	2024-08-01 00:00:00	300000	220000
842	30	0	2024-09-26 12:30:20.415993	11	40	2024-08-27 00:00:00	173000	75000
828	1	1	2024-09-19 10:13:48.963076	11	80	2024-09-19 00:00:00	173000	75000
829	5	0	2024-09-19 10:13:48.963076	11	86	2024-08-20 00:00:00	173000	75000
607	300	5	2024-08-26 05:57:51.327947	24	54	2024-09-28 00:00:00	450000	165000
262	200	200	2024-07-30 09:31:31.045248	24	46	2024-07-31 00:00:00	72000	33280
381	100	50	2024-08-01 05:04:01.168448	5	53	2024-08-01 00:00:00	152600	70000
512	300	300	2024-08-12 04:30:39.202846	30	86	2024-08-12 00:00:00	75000	25000
399	100	50	2024-08-01 11:41:47.912153	18	54	2024-08-01 00:00:00	47500	18950
395	150	140	2024-08-01 11:41:47.912153	5	54	2024-08-01 00:00:00	152600	70000
791	300	0	2024-09-09 09:56:53.434255	25	115	2024-09-10 00:00:00	155000	52600
547	50	50	2024-08-12 04:30:39.202846	27	90	2024-08-12 00:00:00	190000	94500
560	50	50	2024-08-12 04:30:39.202846	31	102	2024-08-12 00:00:00	450000	180000
385	500	0	2024-08-01 10:05:00.529811	25	53	2024-08-01 00:00:00	155000	52600
562	300	300	2024-08-12 04:30:39.202846	25	102	2024-08-12 00:00:00	155000	52600
257	200	200	2024-07-30 09:31:31.045248	25	46	2024-07-31 00:00:00	155000	52600
463	100	100	2024-08-02 05:46:04.624128	30	62	2024-08-02 00:00:00	75000	25000
351	200	38	2024-08-01 05:04:01.168448	13	46	2024-08-01 00:00:00	85000	42500
534	200	0	2024-08-12 04:30:39.202846	4	43	2024-08-12 00:00:00	82000	37500
352	100	0	2024-08-01 05:04:01.168448	27	46	2024-08-01 00:00:00	190000	94500
553	200	0	2024-08-12 04:30:39.202846	12	100	2024-08-12 00:00:00	72000	37500
556	120	0	2024-08-12 04:30:39.202846	19	100	2024-08-12 00:00:00	65000	26500
343	300	100	2024-08-01 05:04:01.168448	12	51	2024-08-01 00:00:00	72000	37500
554	500	100	2024-08-12 04:30:39.202846	13	100	2024-08-12 00:00:00	85000	42500
558	50	0	2024-08-12 04:30:39.202846	29	100	2024-08-12 00:00:00	85000	39750
557	100	0	2024-08-12 04:30:39.202846	22	100	2024-08-12 00:00:00	85000	37440
798	400	0	2024-09-10 12:08:11.029197	28	104	2024-09-11 00:00:00	85000	37750
559	300	0	2024-08-12 04:30:39.202846	24	100	2024-08-12 00:00:00	72000	33280
421	200	145	2024-08-01 11:41:47.912153	12	90	2024-08-01 00:00:00	72000	37500
809	50	50	2024-09-11 12:45:01.790506	31	116	2024-08-12 00:00:00	325000	165000
812	100	100	2024-09-11 12:45:01.790506	12	116	2024-08-12 00:00:00	72000	37500
606	100	0	2024-08-26 05:57:51.327947	13	54	2024-09-28 00:00:00	450000	165000
347	100	0	2024-08-01 05:04:01.168448	25	46	2024-08-01 00:00:00	155000	52600
630	0	0	2024-08-29 10:25:24.399416	19	66	2024-09-29 00:00:00	450000	165000
357	130	0	2024-08-01 05:04:01.168448	13	40	2024-08-01 00:00:00	85000	42500
464	200	120	2024-08-02 05:46:04.624128	25	62	2024-08-02 00:00:00	155000	52600
276	100	100	2024-07-30 09:31:31.045248	12	39	2024-07-31 00:00:00	72000	37500
626	100	0	2024-08-29 10:25:24.399416	11	66	2024-09-29 00:00:00	450000	165000
624	50	0	2024-08-29 10:25:24.399416	31	66	2024-09-29 00:00:00	450000	165000
628	100	0	2024-08-29 10:25:24.399416	13	66	2024-09-29 00:00:00	450000	165000
489	200	200	2024-08-12 04:30:39.202846	4	85	2024-08-12 00:00:00	82000	37500
516	200	200	2024-08-12 04:30:39.202846	4	62	2024-08-12 00:00:00	82000	37500
510	200	50	2024-08-12 04:30:39.202846	4	60	2024-08-12 00:00:00	82000	37500
353	110	-10	2024-08-01 05:04:01.168448	24	46	2024-08-01 00:00:00	72000	33280
459	500	100	2024-08-02 05:46:04.624128	25	86	2024-08-02 00:00:00	155000	52600
253	1000	400	2024-07-30 09:31:31.045248	25	51	2024-07-31 00:00:00	155000	52600
868	50	0	2024-10-08 22:22:53.185305	31	86	2024-10-09 00:00:00	325000	165000
869	300	0	2024-10-08 22:22:53.185305	20	86	2024-10-09 00:00:00	60000	31200
340	100	1000	2024-08-01 05:04:01.168448	30	51	2024-08-01 00:00:00	75000	25000
302	200	200	2024-07-31 07:37:44.51395	12	51	2024-07-31 00:00:00	72000	37500
255	200	200	2024-07-30 09:31:31.045248	13	51	2024-07-31 00:00:00	85000	42500
350	200	440	2024-08-01 05:04:01.168448	24	51	2024-08-01 00:00:00	72000	33280
864	50	0	2024-10-08 22:22:53.185305	5	62	2024-10-09 00:00:00	152600	70000
862	100	0	2024-10-08 22:22:53.185305	25	62	2024-10-09 00:00:00	155000	52600
874	50	0	2024-10-08 22:22:53.185305	12	53	2024-10-09 00:00:00	72000	37500
877	150	0	2024-10-08 22:22:53.185305	31	85	2024-10-09 00:00:00	325000	165000
881	200	0	2024-10-08 22:22:53.185305	25	51	2024-10-09 00:00:00	155000	52600
887	88	0	2024-10-08 22:22:53.185305	29	51	2024-10-09 00:00:00	85000	39750
886	300	0	2024-10-08 22:22:53.185305	19	51	2024-10-09 00:00:00	65000	26500
883	400	0	2024-10-08 22:22:53.185305	12	51	2024-10-09 00:00:00	72000	37500
865	50	0	2024-10-08 22:22:53.185305	28	62	2024-10-09 00:00:00	85000	37750
905	500	0	2024-10-08 22:22:53.185305	30	110	2024-10-09 00:00:00	75000	25000
915	50	0	2024-10-08 22:22:53.185305	31	90	2024-10-09 00:00:00	325000	165000
422	200	200	2024-08-01 11:41:47.912153	13	90	2024-08-01 00:00:00	85000	42500
423	100	100	2024-08-01 11:41:47.912153	33	90	2024-08-01 00:00:00	300000	220000
454	50	50	2024-08-02 05:46:04.624128	24	85	2024-08-02 00:00:00	72000	33280
823	3	0	2024-09-16 12:51:47.584962	20	85	2024-08-19 00:00:00	60000	31200
513	200	195	2024-08-12 04:30:39.202846	4	86	2024-08-12 00:00:00	82000	37500
845	10	10	2024-10-08 22:22:53.185305	25	80	2024-10-08 00:00:00	155000	52600
460	200	200	2024-08-02 05:46:04.624128	12	86	2024-07-02 00:00:00	72000	37500
448	100	100	2024-08-02 05:46:04.624128	30	85	2024-07-02 00:00:00	75000	25000
450	200	200	2024-08-02 05:46:04.624128	30	85	2024-08-02 00:00:00	75000	25000
792	10	0	2024-09-09 09:56:53.434255	28	82	2024-08-10 00:00:00	85000	37750
217	100	100	2024-07-29 13:29:43.656437	13	66	2024-07-30 00:00:00	85000	42500
329	100	0	2024-08-01 05:04:01.168448	13	66	2024-08-01 00:00:00	85000	42500
514	50	50	2024-08-12 04:30:39.202846	26	86	2024-08-12 00:00:00	118000	62000
515	50	50	2024-08-12 04:30:39.202846	31	62	2024-08-12 00:00:00	450000	180000
271	100	100	2024-07-30 09:31:31.045248	12	43	2024-07-31 00:00:00	72000	37500
830	50	40	2024-09-20 05:14:24.308522	25	80	2024-09-21 00:00:00	155000	52600
418	100	100	2024-08-01 11:41:47.912153	31	90	2024-08-01 00:00:00	450000	180000
419	500	500	2024-08-01 11:41:47.912153	30	90	2024-08-01 00:00:00	75000	25000
212	100	100	2024-07-29 13:29:43.656437	18	82	2024-07-30 00:00:00	47500	18950
290	150	150	2024-07-30 09:31:31.045248	13	50	2024-07-31 00:00:00	85000	42500
467	100	100	2024-08-02 05:46:04.624128	18	62	2024-08-02 00:00:00	47500	18950
473	50	50	2024-08-05 07:36:09.406116	18	62	2024-07-05 00:00:00	47500	18950
474	50	50	2024-08-05 07:36:09.406116	24	62	2024-07-05 00:00:00	72000	33280
506	100	100	2024-08-12 04:30:39.202846	30	53	2024-08-12 00:00:00	75000	25000
204	50	50	2024-07-29 13:29:43.656437	31	60	2024-07-30 00:00:00	450000	180000
509	50	50	2024-08-12 04:30:39.202846	31	60	2024-08-12 00:00:00	450000	180000
197	300	300	2024-07-29 13:29:43.656437	25	60	2024-07-30 00:00:00	155000	52600
563	200	200	2024-08-12 04:30:39.202846	4	102	2024-08-12 00:00:00	82000	37500
503	200	190	2024-08-12 04:30:39.202846	4	82	2024-08-12 00:00:00	82000	37500
529	50	0	2024-08-12 04:30:39.202846	31	39	2024-08-12 00:00:00	450000	180000
530	50	0	2024-08-12 04:30:39.202846	30	39	2024-08-12 00:00:00	75000	25000
532	100	0	2024-08-12 04:30:39.202846	12	39	2024-08-12 00:00:00	72000	37500
817	80	0	2024-09-13 06:20:00.107924	11	82	2024-09-13 00:00:00	173000	75000
415	50	0	2024-08-01 11:41:47.912153	33	50	2024-08-01 00:00:00	300000	220000
810	100	100	2024-09-11 12:45:01.790506	30	116	2024-08-12 00:00:00	75000	25000
500	50	50	2024-08-12 04:30:39.202846	26	54	2024-08-12 00:00:00	118000	62000
424	50	50	2024-08-01 11:41:47.912153	22	90	2024-08-01 00:00:00	85000	37440
501	200	200	2024-08-12 04:30:39.202846	4	66	2024-08-12 00:00:00	82000	37500
505	50	50	2024-08-12 04:30:39.202846	31	53	2024-08-12 00:00:00	450000	180000
511	50	50	2024-08-12 04:30:39.202846	31	86	2024-08-12 00:00:00	450000	180000
461	500	300	2024-08-02 05:46:04.624128	12	86	2024-08-02 00:00:00	72000	37500
579	20	0	2024-08-12 11:58:22.266451	18	60	2024-08-12 00:00:00	47500	18950
523	200	0	2024-08-12 04:30:39.202846	4	40	2024-08-12 00:00:00	82000	37500
502	100	80	2024-08-12 04:30:39.202846	30	82	2024-08-12 00:00:00	75000	25000
355	100	0	2024-08-01 05:04:01.168448	30	40	2024-08-01 00:00:00	75000	25000
492	50	50	2024-08-12 04:30:39.202846	31	51	2024-08-12 00:00:00	450000	180000
493	200	200	2024-08-12 04:30:39.202846	4	51	2024-08-12 00:00:00	82000	37500
836	100	0	2024-09-26 12:30:20.415993	28	49	2024-08-27 00:00:00	85000	37750
398	200	0	2024-08-01 11:41:47.912153	13	54	2024-08-01 00:00:00	85000	42500
538	200	200	2024-08-12 04:30:39.202846	4	50	2024-08-12 00:00:00	82000	37500
536	200	0	2024-08-12 04:30:39.202846	4	49	2024-08-12 00:00:00	82000	37500
409	50	0	2024-08-01 11:41:47.912153	24	49	2024-08-01 00:00:00	72000	33280
548	50	0	2024-08-12 04:30:39.202846	31	100	2024-08-12 00:00:00	450000	180000
549	300	0	2024-08-12 04:30:39.202846	30	100	2024-08-12 00:00:00	75000	25000
551	200	0	2024-08-12 04:30:39.202846	4	100	2024-08-12 00:00:00	82000	37500
416	50	0	2024-08-01 11:41:47.912153	19	50	2024-08-01 00:00:00	65000	26500
342	50	0	2024-08-01 05:04:01.168448	31	46	2024-08-01 00:00:00	450000	180000
465	100	80	2024-08-02 05:46:04.624128	12	62	2024-08-02 00:00:00	72000	37500
468	100	80	2024-08-02 05:46:04.624128	24	62	2024-08-02 00:00:00	72000	33280
639	100	0	2024-08-30 04:32:52.425527	13	85	2024-09-30 00:00:00	450000	165000
397	160	170	2024-08-01 11:41:47.912153	12	54	2024-08-01 00:00:00	72000	37500
445	55	0	2024-08-01 11:41:47.912153	33	60	2024-08-01 00:00:00	300000	220000
410	50	0	2024-08-01 11:41:47.912153	31	50	2024-08-01 00:00:00	450000	180000
504	50	0	2024-08-12 04:30:39.202846	26	82	2024-08-12 00:00:00	118000	62000
414	100	0	2024-08-01 11:41:47.912153	13	50	2024-08-01 00:00:00	85000	42500
417	100	0	2024-08-01 11:41:47.912153	24	50	2024-08-01 00:00:00	72000	33280
544	200	0	2024-08-12 04:30:39.202846	4	46	2024-08-12 00:00:00	82000	37500
376	100	0	2024-08-01 05:04:01.168448	33	43	2024-08-01 00:00:00	300000	220000
550	500	-100	2024-08-12 04:30:39.202846	25	100	2024-08-12 00:00:00	155000	52600
524	100	0	2024-08-12 04:30:39.202846	12	40	2024-08-12 00:00:00	72000	37500
494	200	200	2024-08-12 04:30:39.202846	27	51	2024-08-12 00:00:00	190000	94500
498	50	50	2024-08-12 04:30:39.202846	31	54	2024-08-12 00:00:00	450000	180000
581	10	0	2024-08-12 11:58:22.266451	10	60	2024-08-12 00:00:00	130000	62000
625	200	0	2024-08-29 10:25:24.399416	25	66	2024-09-29 00:00:00	450000	165000
210	200	100	2024-07-29 13:29:43.656437	27	82	2024-07-30 00:00:00	190000	94500
303	50	0	2024-07-31 09:53:53.562829	13	53	2024-07-31 00:00:00	85000	42500
386	100	0	2024-08-01 10:05:00.529811	13	53	2024-08-01 00:00:00	85000	42500
215	150	150	2024-07-29 13:29:43.656437	25	66	2024-07-30 00:00:00	155000	52600
327	100	0	2024-08-01 05:04:01.168448	25	66	2024-08-01 00:00:00	155000	52600
284	1000	1000	2024-07-30 09:31:31.045248	25	49	2024-07-31 00:00:00	155000	52600
332	50	0	2024-08-01 05:04:01.168448	19	66	2024-08-01 00:00:00	65000	26500
328	100	0	2024-08-01 05:04:01.168448	12	66	2024-08-01 00:00:00	72000	37500
326	100	0	2024-08-01 05:04:01.168448	30	66	2024-08-01 00:00:00	75000	25000
373	200	100	2024-08-01 05:04:01.168448	12	43	2024-08-01 00:00:00	72000	37500
323	200	50	2024-08-01 05:04:01.168448	18	82	2024-08-01 00:00:00	47500	18950
535	100	50	2024-08-12 04:30:39.202846	26	43	2024-08-12 00:00:00	118000	62000
634	100	0	2024-08-30 04:32:52.425527	5	51	2024-09-30 00:00:00	450000	165000
432	350	0	2024-08-01 11:41:47.912153	25	60	2024-08-01 00:00:00	155000	52600
330	50	0	2024-08-01 05:04:01.168448	18	66	2024-08-01 00:00:00	47500	18950
627	200	0	2024-08-29 10:25:24.399416	12	66	2024-09-29 00:00:00	450000	165000
207	100	0	2024-07-29 13:29:43.656437	12	82	2024-07-30 00:00:00	72000	37500
617	100	0	2024-08-29 10:25:24.399416	12	82	2024-09-29 00:00:00	450000	165000
851	100	0	2024-10-08 22:22:53.185305	19	60	2024-10-09 00:00:00	65000	26500
867	500	0	2024-10-08 22:22:53.185305	12	86	2024-10-09 00:00:00	72000	37500
863	50	0	2024-10-08 22:22:53.185305	31	62	2024-10-09 00:00:00	325000	165000
860	100	0	2024-10-08 22:22:53.185305	24	62	2024-10-09 00:00:00	72000	33280
888	88	0	2024-10-08 22:22:53.185305	22	51	2024-10-09 00:00:00	85000	37440
890	200	0	2024-10-08 22:22:53.185305	5	51	2024-10-09 00:00:00	152600	70000
856	200	0	2024-10-08 22:22:53.185305	18	62	2024-10-09 00:00:00	47500	18950
857	200	0	2024-10-08 22:22:53.185305	13	62	2024-10-09 00:00:00	85000	42500
906	300	0	2024-10-08 22:22:53.185305	25	110	2024-10-09 00:00:00	155000	52600
916	200	0	2024-10-08 22:22:53.185305	30	90	2024-10-09 00:00:00	75000	25000
901	300	0	2024-10-08 22:22:53.185305	25	114	2024-10-09 00:00:00	155000	52600
908	100	0	2024-10-08 22:22:53.185305	12	110	2024-10-09 00:00:00	72000	37500
914	300	0	2024-10-08 22:22:53.185305	27	43	2024-10-09 00:00:00	190000	94500
258	200	0	2024-07-30 09:31:31.045248	12	46	2024-07-31 00:00:00	72000	37500
279	50	50	2024-07-30 09:31:31.045248	27	39	2024-07-31 00:00:00	190000	94500
275	20	20	2024-07-30 09:31:31.045248	10	39	2024-07-31 00:00:00	130000	62000
265	200	200	2024-07-30 09:31:31.045248	13	40	2024-07-31 00:00:00	85000	42500
247	150	0	2024-07-30 09:31:31.045248	12	54	2024-07-30 00:00:00	72000	37500
316	50	50	2024-07-31 09:53:53.562829	24	49	2024-07-31 00:00:00	72000	33280
209	50	0	2024-07-29 13:29:43.656437	26	82	2024-07-30 00:00:00	118000	62000
200	100	100	2024-07-29 13:29:43.656437	18	60	2024-07-30 00:00:00	47500	18950
287	300	300	2024-07-30 09:31:31.045248	25	50	2024-07-31 00:00:00	155000	52600
248	150	0	2024-07-30 09:31:31.045248	13	54	2024-07-30 00:00:00	85000	42500
203	50	50	2024-07-29 13:29:43.656437	24	60	2024-07-30 00:00:00	72000	33280
289	150	150	2024-07-30 09:31:31.045248	12	50	2024-07-31 00:00:00	72000	37500
264	100	0	2024-07-30 09:31:31.045248	12	40	2024-07-31 00:00:00	72000	37500
499	200	200	2024-08-12 04:30:39.202846	4	54	2024-08-12 00:00:00	82000	37500
223	10	10	2024-07-29 13:29:43.656437	15	60	2024-06-30 00:00:00	95000	48900
225	10	0	2024-07-29 13:29:43.656437	15	60	2024-07-30 00:00:00	95000	48900
224	15	0	2024-07-29 13:29:43.656437	14	60	2024-07-30 00:00:00	175000	89500
462	200	0	2024-08-02 05:46:04.624128	24	86	2024-08-02 00:00:00	72000	33280
451	500	0	2024-08-02 05:46:04.624128	25	85	2024-08-02 00:00:00	155000	52600
294	50	50	2024-07-30 09:31:31.045248	24	50	2024-07-31 00:00:00	72000	33280
227	100	100	2024-07-29 13:29:43.656437	12	90	2024-07-30 00:00:00	72000	37500
228	200	200	2024-07-29 13:29:43.656437	13	90	2024-07-30 00:00:00	85000	42500
230	100	100	2024-07-30 06:40:42.916593	22	90	2024-07-30 00:00:00	85000	37440
292	200	200	2024-07-30 09:31:31.045248	19	50	2024-07-31 00:00:00	65000	26500
485	60	10	2024-08-06 10:08:26.69756	27	62	2024-08-06 00:00:00	190000	94500
657	200	0	2024-08-30 11:09:09.416373	25	100	2024-09-30 00:00:00	450000	165000
359	50	0	2024-08-01 05:04:01.168448	27	40	2024-08-01 00:00:00	190000	94500
793	30	0	2024-09-09 09:56:53.434255	33	60	2024-09-10 00:00:00	300000	150000
796	0	0	2024-09-09 09:56:53.434255	28	114	2024-09-10 00:00:00	85000	37750
663	200	0	2024-08-30 11:09:09.416373	28	100	2024-09-30 00:00:00	450000	165000
404	300	90	2024-08-01 11:41:47.912153	24	54	2024-08-01 00:00:00	72000	33280
360	20	0	2024-08-01 05:04:01.168448	33	40	2024-08-01 00:00:00	300000	220000
361	50	0	2024-08-01 05:04:01.168448	24	40	2024-08-01 00:00:00	72000	33280
318	50	25	2024-08-01 05:04:01.168448	31	82	2024-08-01 00:00:00	450000	180000
354	50	0	2024-08-01 05:04:01.168448	31	40	2024-08-01 00:00:00	450000	180000
319	150	90	2024-08-01 05:04:01.168448	25	82	2024-08-01 00:00:00	155000	52600
321	200	30	2024-08-01 05:04:01.168448	13	82	2024-08-01 00:00:00	85000	42500
252	200	200	2024-07-30 09:31:31.045248	24	54	2024-07-30 00:00:00	72000	33280
358	50	0	2024-08-01 05:04:01.168448	26	40	2024-08-01 00:00:00	118000	62000
377	200	0	2024-08-01 05:04:01.168448	25	39	2024-08-01 00:00:00	155000	52600
202	100	100	2024-07-29 13:29:43.656437	22	60	2024-07-30 00:00:00	85000	37440
545	250	250	2024-08-12 04:30:39.202846	4	90	2024-08-12 00:00:00	82000	37500
226	400	400	2024-07-29 13:29:43.656437	25	90	2024-07-30 00:00:00	155000	52600
201	100	100	2024-07-29 13:29:43.656437	19	60	2024-07-30 00:00:00	65000	26500
449	87	0	2024-08-02 05:46:04.624128	31	85	2024-08-02 00:00:00	450000	180000
452	100	0	2024-08-02 05:46:04.624128	12	85	2024-08-02 00:00:00	72000	37500
537	100	0	2024-08-12 04:30:39.202846	26	49	2024-08-12 00:00:00	118000	62000
345	300	100	2024-08-01 05:04:01.168448	13	51	2024-08-01 00:00:00	85000	42500
552	20	0	2024-08-12 04:30:39.202846	10	100	2024-08-12 00:00:00	130000	62000
555	50	0	2024-08-12 04:30:39.202846	33	100	2024-08-12 00:00:00	300000	220000
794	7	0	2024-09-09 09:56:53.434255	24	82	2024-08-10 00:00:00	72000	33280
378	480	0	2024-08-01 05:04:01.168448	13	39	2024-08-01 00:00:00	85000	42500
324	50	0	2024-08-01 05:04:01.168448	19	82	2024-08-01 00:00:00	65000	26500
436	90	0	2024-08-01 11:41:47.912153	19	60	2024-08-01 00:00:00	65000	26500
435	80	0	2024-08-01 11:41:47.912153	22	60	2024-08-01 00:00:00	85000	37440
471	20	10	2024-08-05 07:36:09.406116	14	60	2024-08-05 00:00:00	175000	89500
470	20	0	2024-08-05 07:36:09.406116	15	60	2024-08-05 00:00:00	95000	48900
320	100	0	2024-08-01 05:04:01.168448	12	82	2024-08-01 00:00:00	72000	37500
411	50	0	2024-08-01 11:41:47.912153	30	50	2024-08-01 00:00:00	75000	25000
413	100	0	2024-08-01 11:41:47.912153	12	50	2024-08-01 00:00:00	72000	37500
370	100	0	2024-08-01 05:04:01.168448	31	43	2024-08-01 00:00:00	450000	180000
371	500	0	2024-08-01 05:04:01.168448	30	43	2024-08-01 00:00:00	75000	25000
446	320	13	2024-08-01 11:41:47.912153	12	60	2024-08-01 00:00:00	72000	37500
580	40	0	2024-08-12 11:58:22.266451	24	60	2024-08-12 00:00:00	72000	33280
447	50	50	2024-08-02 05:46:04.624128	31	85	2024-07-02 00:00:00	450000	180000
199	150	12	2024-07-29 13:29:43.656437	13	60	2024-07-30 00:00:00	85000	42500
285	200	200	2024-07-30 09:31:31.045248	12	49	2024-07-31 00:00:00	72000	37500
453	100	0	2024-08-02 05:46:04.624128	13	85	2024-08-02 00:00:00	85000	42500
472	50	50	2024-08-05 07:36:09.406116	13	85	2024-07-05 00:00:00	85000	42500
267	50	50	2024-07-30 09:31:31.045248	27	40	2024-07-31 00:00:00	190000	94500
206	200	200	2024-07-29 13:29:43.656437	25	82	2024-07-30 00:00:00	155000	52600
208	100	100	2024-07-29 13:29:43.656437	13	82	2024-07-30 00:00:00	85000	42500
286	600	600	2024-07-30 09:31:31.045248	13	49	2024-07-31 00:00:00	85000	42500
322	100	44	2024-08-01 05:04:01.168448	27	82	2024-08-01 00:00:00	190000	94500
213	50	50	2024-07-29 13:29:43.656437	19	82	2024-07-30 00:00:00	65000	26500
270	500	500	2024-07-30 09:31:31.045248	25	43	2024-07-31 00:00:00	155000	52600
272	200	200	2024-07-30 09:31:31.045248	13	43	2024-07-31 00:00:00	85000	42500
273	50	50	2024-07-30 09:31:31.045248	27	43	2024-07-31 00:00:00	190000	94500
274	500	500	2024-07-30 09:31:31.045248	25	39	2024-07-31 00:00:00	155000	52600
277	100	100	2024-07-30 09:31:31.045248	13	39	2024-07-31 00:00:00	85000	42500
811	200	200	2024-09-11 12:45:01.790506	25	116	2024-08-12 00:00:00	155000	52600
401	100	70	2024-08-01 11:41:47.912153	19	54	2024-08-01 00:00:00	65000	26500
800	10	10	2024-09-11 12:45:01.790506	24	80	2024-08-12 00:00:00	72000	33280
392	100	100	2024-08-01 11:41:47.912153	30	54	2024-08-01 00:00:00	75000	25000
466	130	0	2024-08-02 05:46:04.624128	13	62	2024-08-02 00:00:00	85000	42500
440	130	-30	2024-08-01 11:41:47.912153	13	60	2024-08-01 00:00:00	85000	42500
356	200	0	2024-08-01 05:04:01.168448	25	40	2024-08-01 00:00:00	155000	52600
250	100	100	2024-07-30 09:31:31.045248	19	54	2024-07-30 00:00:00	65000	26500
263	200	200	2024-07-30 09:31:31.045248	25	40	2024-07-31 00:00:00	155000	52600
266	50	50	2024-07-30 09:31:31.045248	26	40	2024-07-31 00:00:00	118000	62000
269	100	100	2024-07-30 09:31:31.045248	24	40	2024-07-31 00:00:00	72000	33280
803	25	21	2024-09-11 12:45:01.790506	19	80	2024-08-12 00:00:00	65000	26500
824	10	0	2024-09-16 12:51:47.584962	24	62	2024-09-19 00:00:00	72000	33280
831	20	0	2024-09-20 05:14:24.308522	30	46	2024-09-24 00:00:00	75000	25000
838	20	0	2024-09-26 12:30:20.415993	37	85	2024-09-27 00:00:00	450000	165000
420	500	200	2024-08-01 11:41:47.912153	25	90	2024-08-01 00:00:00	155000	52600
846	300	0	2024-10-08 22:22:53.185305	25	60	2024-10-09 00:00:00	155000	52600
866	500	0	2024-10-08 22:22:53.185305	25	86	2024-10-09 00:00:00	155000	52600
870	50	0	2024-10-08 22:22:53.185305	22	86	2024-10-09 00:00:00	85000	37440
858	50	0	2024-10-08 22:22:53.185305	27	62	2024-10-09 00:00:00	190000	94500
885	88	0	2024-10-08 22:22:53.185305	18	51	2024-10-09 00:00:00	47500	18950
889	300	0	2024-10-08 22:22:53.185305	24	51	2024-10-09 00:00:00	72000	33280
891	400	0	2024-10-08 22:22:53.185305	28	104	2024-10-09 00:00:00	85000	37750
897	40	0	2024-10-08 22:22:53.185305	27	54	2024-10-09 00:00:00	190000	94500
678	0	0	2024-09-03 05:01:24.418477	18	85	2024-09-03 00:00:00	47500	18950
676	0	0	2024-09-03 05:01:24.418477	21	85	2024-09-03 00:00:00	55000	22340
679	0	0	2024-09-03 05:01:24.418477	22	85	2024-09-03 00:00:00	85000	37440
672	0	0	2024-09-03 05:01:24.418477	21	82	2024-09-03 00:00:00	55000	22340
673	0	0	2024-09-03 05:01:24.418477	22	82	2024-09-03 00:00:00	85000	37440
344	100	0	2024-08-01 05:04:01.168448	30	46	2024-08-01 00:00:00	75000	25000
583	500	0	2024-08-13 10:07:30.062188	28	104	2024-08-13 00:00:00	85000	37750
402	400	0	2024-08-01 11:41:47.912153	30	49	2024-08-01 00:00:00	75000	25000
407	50	0	2024-08-01 11:41:47.912153	33	49	2024-08-01 00:00:00	300000	220000
341	500	90	2024-08-01 05:04:01.168448	25	51	2024-08-01 00:00:00	155000	52600
408	200	0	2024-08-01 11:41:47.912153	22	49	2024-08-01 00:00:00	85000	37440
587	5	0	2024-08-13 12:09:01.302234	10	53	2024-08-13 00:00:00	130000	62000
586	30	0	2024-08-13 12:09:01.302234	23	53	2024-08-13 00:00:00	49500	21570
585	10	0	2024-08-13 12:09:01.302234	7	53	2024-08-13 00:00:00	75000	33500
588	20	0	2024-08-13 12:09:01.302234	28	50	2024-08-14 00:00:00	85000	37750
584	200	0	2024-08-13 10:07:30.062188	26	51	2024-08-13 00:00:00	118000	62000
372	500	0	2024-08-01 05:04:01.168448	25	43	2024-08-01 00:00:00	155000	52600
375	100	0	2024-08-01 05:04:01.168448	27	43	2024-08-01 00:00:00	190000	94500
592	20	0	2024-08-15 11:23:50.492139	28	100	2024-08-21 00:00:00	85000	37750
593	10	0	2024-08-21 07:39:51.715336	27	60	2024-08-22 00:00:00	190000	94500
400	110	0	2024-08-01 11:41:47.912153	31	49	2024-08-01 00:00:00	450000	180000
595	30	0	2024-08-23 10:32:41.493645	11	66	2024-08-23 00:00:00	173000	75000
590	50	0	2024-08-14 11:51:29.125952	25	54	2024-08-15 00:00:00	155000	52600
596	50	0	2024-08-23 11:35:41.148911	28	110	2024-08-23 00:00:00	85000	37750
597	50	0	2024-08-23 11:35:41.148911	25	110	2024-08-23 00:00:00	155000	52600
598	30	0	2024-08-23 11:35:41.148911	13	110	2024-08-23 00:00:00	85000	42500
599	20	0	2024-08-23 11:35:41.148911	27	110	2024-08-23 00:00:00	190000	94500
600	20	10	2024-08-26 05:57:51.327947	4	114	2024-08-27 00:00:00	82000	37500
601	50	10	2024-08-26 05:57:51.327947	12	114	2024-08-27 00:00:00	72000	37500
655	200	0	2024-08-30 06:53:43.877021	20	86	2024-08-30 00:00:00	60000	31200
405	200	0	2024-08-01 11:41:47.912153	12	49	2024-08-01 00:00:00	72000	37500
406	300	150	2024-08-01 11:41:47.912153	13	49	2024-08-01 00:00:00	85000	42500
374	200	-59	2024-08-01 05:04:01.168448	13	43	2024-08-01 00:00:00	85000	42500
349	300	90	2024-08-01 05:04:01.168448	12	46	2024-08-01 00:00:00	72000	37500
674	0	0	2024-09-03 05:01:24.418477	18	66	2024-09-03 00:00:00	47500	18950
412	200	0	2024-08-01 11:41:47.912153	25	50	2024-08-01 00:00:00	155000	52600
675	0	0	2024-09-03 05:01:24.418477	22	66	2024-09-03 00:00:00	85000	37440
403	720	0	2024-08-01 11:41:47.912153	25	49	2024-08-01 00:00:00	155000	52600
839	28	0	2024-09-26 12:30:20.415993	8	50	2024-08-27 00:00:00	155000	52600
795	90	0	2024-09-09 09:56:53.434255	27	60	2024-09-10 00:00:00	190000	94500
602	50	10	2024-08-26 05:57:51.327947	13	114	2024-08-27 00:00:00	85000	42500
688	0	0	2024-09-03 05:01:24.418477	22	62	2024-09-03 00:00:00	85000	37440
687	100	0	2024-09-03 05:01:24.418477	18	62	2024-09-03 00:00:00	47500	18950
686	50	0	2024-09-03 05:01:24.418477	18	60	2024-09-03 00:00:00	47500	18950
589	70	6	2024-08-14 11:51:29.125952	5	40	2024-08-14 00:00:00	152600	70000
847	200	0	2024-10-08 22:22:53.185305	12	60	2024-10-09 00:00:00	72000	37500
854	10	0	2024-10-08 22:22:53.185305	31	60	2024-10-09 00:00:00	325000	165000
594	100	39	2024-08-22 05:40:04.669963	33	39	2024-08-22 00:00:00	300000	220000
804	300	0	2024-09-11 12:45:01.790506	25	86	2024-09-12 00:00:00	155000	52600
807	200	0	2024-09-11 12:45:01.790506	18	86	2024-09-12 00:00:00	47500	18950
813	100	100	2024-09-11 12:45:01.790506	13	116	2024-08-12 00:00:00	85000	42500
819	300	0	2024-09-13 06:20:00.107924	12	49	2024-09-13 00:00:00	72000	37500
825	10	0	2024-09-16 12:51:47.584962	27	62	2024-09-19 00:00:00	190000	94500
832	60	0	2024-09-26 12:30:20.415993	18	100	2024-08-27 00:00:00	47500	18950
872	100	0	2024-10-08 22:22:53.185305	5	53	2024-10-09 00:00:00	152600	70000
875	50	0	2024-10-08 22:22:53.185305	13	53	2024-10-09 00:00:00	85000	42500
871	500	0	2024-10-08 22:22:53.185305	25	53	2024-10-09 00:00:00	155000	52600
859	150	0	2024-10-08 22:22:53.185305	33	62	2024-10-09 00:00:00	300000	150000
876	400	0	2024-10-08 22:22:53.185305	25	85	2024-10-09 00:00:00	155000	52600
899	50	0	2024-10-08 22:22:53.185305	19	54	2024-10-09 00:00:00	65000	26500
895	200	0	2024-10-08 22:22:53.185305	12	54	2024-10-09 00:00:00	72000	37500
894	230	0	2024-10-08 22:22:53.185305	5	54	2024-10-09 00:00:00	152600	70000
892	50	0	2024-10-08 22:22:53.185305	31	54	2024-10-09 00:00:00	325000	165000
922	50	0	2024-10-08 22:22:53.185305	20	90	2024-10-09 00:00:00	60000	31200
920	120	0	2024-10-08 22:22:53.185305	13	90	2024-10-09 00:00:00	85000	42500
924	50	0	2024-10-08 22:22:53.185305	31	39	2024-10-09 00:00:00	325000	165000
927	80	0	2024-10-08 22:22:53.185305	5	39	2024-10-09 00:00:00	152600	70000
932	50	0	2024-10-08 22:22:53.185305	28	39	2024-10-09 00:00:00	85000	37750
933	50	0	2024-10-08 22:22:53.185305	20	39	2024-10-09 00:00:00	60000	31200
934	25	0	2024-10-08 22:22:53.185305	31	40	2024-10-09 00:00:00	325000	165000
939	50	0	2024-10-08 22:22:53.185305	11	40	2024-10-09 00:00:00	173000	75000
936	300	0	2024-10-08 22:22:53.185305	25	40	2024-10-09 00:00:00	155000	52600
938	130	0	2024-10-08 22:22:53.185305	5	40	2024-10-09 00:00:00	152600	70000
941	200	0	2024-10-08 22:22:53.185305	13	40	2024-10-09 00:00:00	85000	42500
943	20	0	2024-10-08 22:22:53.185305	33	40	2024-10-09 00:00:00	300000	150000
966	100	0	2024-10-08 22:22:53.185305	5	50	2024-10-09 00:00:00	152600	70000
902	200	0	2024-10-08 22:22:53.185305	5	114	2024-10-09 00:00:00	152600	70000
909	200	0	2024-10-08 22:22:53.185305	13	110	2024-10-09 00:00:00	85000	42500
912	100	0	2024-10-08 22:22:53.185305	4	43	2024-10-09 00:00:00	70000	30000
964	300	0	2024-10-08 22:22:53.185305	25	50	2024-10-09 00:00:00	155000	52600
970	100	0	2024-10-08 22:22:53.185305	24	50	2024-10-09 00:00:00	72000	33280
977	200	0	2024-10-08 22:22:53.185305	28	49	2024-10-09 00:00:00	85000	37750
975	200	0	2024-10-08 22:22:53.185305	12	49	2024-10-09 00:00:00	72000	37500
976	200	0	2024-10-08 22:22:53.185305	13	49	2024-10-09 00:00:00	85000	42500
979	30	0	2024-10-08 22:22:53.185305	24	49	2024-10-09 00:00:00	72000	33280
944	100	0	2024-10-08 22:22:53.185305	30	100	2024-10-09 00:00:00	75000	25000
950	50	0	2024-10-08 22:22:53.185305	19	100	2024-10-09 00:00:00	65000	26500
947	100	0	2024-10-08 22:22:53.185305	12	100	2024-10-09 00:00:00	72000	37500
951	50	0	2024-10-08 22:22:53.185305	21	100	2024-10-09 00:00:00	55000	22340
954	50	0	2024-10-08 22:22:53.185305	30	46	2024-10-09 00:00:00	75000	25000
953	200	0	2024-10-08 22:22:53.185305	24	100	2024-10-09 00:00:00	72000	33280
960	50	0	2024-10-08 22:22:53.185305	18	46	2024-10-09 00:00:00	47500	18950
956	50	0	2024-10-08 22:22:53.185305	4	46	2024-10-09 00:00:00	70000	30000
958	200	0	2024-10-08 22:22:53.185305	12	46	2024-10-09 00:00:00	72000	37500
963	300	0	2024-10-08 22:22:53.185305	24	46	2024-10-09 00:00:00	72000	33280
962	20	0	2024-10-08 22:22:53.185305	21	46	2024-10-09 00:00:00	55000	22340
917	200	0	2024-10-08 22:22:53.185305	5	90	2024-10-09 00:00:00	152600	70000
918	100	0	2024-10-08 22:22:53.185305	11	90	2024-10-09 00:00:00	173000	75000
981	10	0	2024-10-15 07:30:10.570801	26	62	2024-10-15 00:00:00	118000	62000
689	0	0	2024-09-03 05:01:24.418477	18	53	2024-09-03 00:00:00	47500	18950
691	0	0	2024-09-03 05:01:24.418477	21	53	2024-09-03 00:00:00	55000	22340
805	100	0	2024-09-11 12:45:01.790506	12	86	2024-09-12 00:00:00	72000	37500
808	50	0	2024-09-11 12:45:01.790506	33	86	2024-09-12 00:00:00	300000	150000
931	60	0	2024-10-08 22:22:53.185305	33	39	2024-10-09 00:00:00	300000	150000
814	200	0	2024-09-11 12:45:01.790506	27	116	2024-08-12 00:00:00	190000	94500
935	100	0	2024-10-08 22:22:53.185305	30	40	2024-10-09 00:00:00	75000	25000
937	50	0	2024-10-08 22:22:53.185305	4	40	2024-10-09 00:00:00	70000	30000
826	96	0	2024-09-16 12:51:47.584962	38	54	2024-09-19 00:00:00	120000	66000
833	40	0	2024-09-26 12:30:20.415993	11	100	2024-08-27 00:00:00	173000	75000
840	5	0	2024-09-26 12:30:20.415993	19	46	2024-08-27 00:00:00	65000	26500
848	100	0	2024-10-08 22:22:53.185305	13	60	2024-10-09 00:00:00	85000	42500
849	60	0	2024-10-08 22:22:53.185305	24	60	2024-10-09 00:00:00	72000	33280
850	30	0	2024-10-08 22:22:53.185305	33	60	2024-10-09 00:00:00	300000	150000
852	50	0	2024-10-08 22:22:53.185305	22	60	2024-10-09 00:00:00	85000	37440
940	200	0	2024-10-08 22:22:53.185305	12	40	2024-10-09 00:00:00	72000	37500
942	20	0	2024-10-08 22:22:53.185305	27	40	2024-10-09 00:00:00	190000	94500
903	350	0	2024-10-08 22:22:53.185305	12	114	2024-10-09 00:00:00	72000	37500
893	100	0	2024-10-08 22:22:53.185305	25	54	2024-10-09 00:00:00	155000	52600
882	1000	0	2024-10-08 22:22:53.185305	4	51	2024-10-09 00:00:00	70000	30000
880	1500	0	2024-10-08 22:22:53.185305	30	51	2024-10-09 00:00:00	75000	25000
907	100	0	2024-10-08 22:22:53.185305	4	110	2024-10-09 00:00:00	70000	30000
884	550	0	2024-10-08 22:22:53.185305	13	51	2024-10-09 00:00:00	85000	42500
861	100	0	2024-10-08 22:22:53.185305	20	62	2024-10-09 00:00:00	60000	31200
910	10	0	2024-10-08 22:22:53.185305	33	110	2024-10-09 00:00:00	300000	150000
913	1000	0	2024-10-08 22:22:53.185305	13	43	2024-10-09 00:00:00	85000	42500
878	200	0	2024-10-08 22:22:53.185305	12	85	2024-10-09 00:00:00	72000	37500
900	300	0	2024-10-08 22:22:53.185305	24	54	2024-10-09 00:00:00	72000	33280
873	100	0	2024-10-08 22:22:53.185305	20	53	2024-10-09 00:00:00	60000	31200
967	500	0	2024-10-08 22:22:53.185305	12	50	2024-10-09 00:00:00	72000	37500
896	200	0	2024-10-08 22:22:53.185305	13	54	2024-10-09 00:00:00	85000	42500
968	60	0	2024-10-08 22:22:53.185305	28	50	2024-10-09 00:00:00	85000	37750
855	300	0	2024-10-08 22:22:53.185305	5	60	2024-10-09 00:00:00	152600	70000
971	100	0	2024-10-08 22:22:53.185305	31	49	2024-10-09 00:00:00	325000	165000
919	120	0	2024-10-08 22:22:53.185305	12	90	2024-10-09 00:00:00	72000	37500
923	100	0	2024-10-08 22:22:53.185305	21	90	2024-10-09 00:00:00	55000	22340
925	50	0	2024-10-08 22:22:53.185305	30	39	2024-10-09 00:00:00	75000	25000
926	180	0	2024-10-08 22:22:53.185305	25	39	2024-10-09 00:00:00	155000	52600
928	80	0	2024-10-08 22:22:53.185305	11	39	2024-10-09 00:00:00	173000	75000
929	300	0	2024-10-08 22:22:53.185305	13	39	2024-10-09 00:00:00	85000	42500
973	600	0	2024-10-08 22:22:53.185305	25	49	2024-10-09 00:00:00	155000	52600
974	300	0	2024-10-08 22:22:53.185305	4	49	2024-10-09 00:00:00	70000	30000
978	200	0	2024-10-08 22:22:53.185305	22	49	2024-10-09 00:00:00	85000	37440
945	400	0	2024-10-08 22:22:53.185305	25	100	2024-10-09 00:00:00	155000	52600
948	200	0	2024-10-08 22:22:53.185305	13	100	2024-10-09 00:00:00	85000	42500
959	200	0	2024-10-08 22:22:53.185305	13	46	2024-10-09 00:00:00	85000	42500
955	50	0	2024-10-08 22:22:53.185305	25	46	2024-10-09 00:00:00	155000	52600
746	50	0	2024-09-03 11:45:40.756053	22	110	2024-09-04 00:00:00	85000	37440
733	100	0	2024-09-03 11:45:40.756053	33	115	2024-09-04 00:00:00	300000	150000
720	50	0	2024-09-03 11:45:40.756053	31	40	2024-09-04 00:00:00	320000	165000
722	300	0	2024-09-03 11:45:40.756053	25	40	2024-09-04 00:00:00	155000	52600
724	200	0	2024-09-03 11:45:40.756053	12	40	2024-09-04 00:00:00	72000	37500
721	100	0	2024-09-03 11:45:40.756053	30	40	2024-09-04 00:00:00	75000	25000
723	50	0	2024-09-03 11:45:40.756053	4	40	2024-09-04 00:00:00	68992	30000
725	100	0	2024-09-03 11:45:40.756053	13	40	2024-09-04 00:00:00	85000	42500
726	20	0	2024-09-03 11:45:40.756053	27	40	2024-09-04 00:00:00	190000	94500
750	40	0	2024-09-03 11:45:40.756053	27	114	2024-09-04 00:00:00	190000	94500
690	0	0	2024-09-03 05:01:24.418477	22	53	2024-09-03 00:00:00	85000	37440
728	30	0	2024-09-03 11:45:40.756053	19	40	2024-09-04 00:00:00	65000	26500
711	100	0	2024-09-03 11:45:40.756053	30	39	2024-09-04 00:00:00	75000	25000
692	100	0	2024-09-03 05:01:24.418477	18	54	2024-09-03 00:00:00	47500	18950
710	30	0	2024-09-03 11:45:40.756053	31	39	2024-09-04 00:00:00	320000	165000
712	120	0	2024-09-03 11:45:40.756053	25	39	2024-09-04 00:00:00	155000	52600
713	50	0	2024-09-03 11:45:40.756053	12	39	2024-09-04 00:00:00	72000	37500
714	100	0	2024-09-03 11:45:40.756053	13	39	2024-09-04 00:00:00	85000	42500
715	40	0	2024-09-03 11:45:40.756053	27	39	2024-09-04 00:00:00	190000	94500
716	50	0	2024-09-03 11:45:40.756053	18	39	2024-09-04 00:00:00	47500	18950
666	0	0	2024-08-30 11:09:09.416373	25	51	2024-09-30 00:00:00	450000	165000
718	50	0	2024-09-03 11:45:40.756053	21	39	2024-09-04 00:00:00	55000	22340
719	50	0	2024-09-03 11:45:40.756053	22	39	2024-09-04 00:00:00	85000	37440
765	371	0	2024-09-03 11:45:40.756053	25	50	2024-09-04 00:00:00	155000	52600
743	500	0	2024-09-03 11:45:40.756053	13	110	2024-09-04 00:00:00	85000	42500
757	210	0	2024-09-03 11:45:40.756053	13	46	2024-09-04 00:00:00	85000	42500
751	0	0	2024-09-03 11:45:40.756053	18	114	2024-09-04 00:00:00	47500	18950
752	50	0	2024-09-03 11:45:40.756053	22	114	2024-09-04 00:00:00	85000	37440
785	100	0	2024-09-03 11:45:40.756053	24	114	2024-09-04 00:00:00	72000	33280
777	300	0	2024-09-03 11:45:40.756053	4	49	2024-09-04 00:00:00	68992	30000
736	200	0	2024-09-03 11:45:40.756053	12	43	2024-09-04 00:00:00	72000	37500
737	500	0	2024-09-03 11:45:40.756053	13	43	2024-09-04 00:00:00	85000	42500
738	100	0	2024-09-03 11:45:40.756053	27	43	2024-09-04 00:00:00	190000	94500
776	400	0	2024-09-03 11:45:40.756053	25	49	2024-09-04 00:00:00	155000	52600
740	50	0	2024-09-03 11:45:40.756053	22	43	2024-09-04 00:00:00	85000	37440
753	0	0	2024-09-03 11:45:40.756053	22	100	2024-09-04 00:00:00	85000	37440
741	300	30	2024-09-03 11:45:40.756053	25	110	2024-09-04 00:00:00	155000	52600
748	365	50	2024-09-03 11:45:40.756053	12	114	2024-09-04 00:00:00	72000	37500
775	200	0	2024-09-03 11:45:40.756053	31	49	2024-09-04 00:00:00	320000	165000
780	0	0	2024-09-03 11:45:40.756053	18	49	2024-09-04 00:00:00	47500	18950
778	0	0	2024-09-03 11:45:40.756053	14	49	2024-09-04 00:00:00	175000	89500
781	100	0	2024-09-03 11:45:40.756053	28	49	2024-09-04 00:00:00	85000	37750
756	220	0	2024-09-03 11:45:40.756053	12	46	2024-09-04 00:00:00	72000	37500
782	0	0	2024-09-03 11:45:40.756053	21	49	2024-09-04 00:00:00	55000	22340
783	200	0	2024-09-03 11:45:40.756053	22	49	2024-09-04 00:00:00	85000	37440
784	100	0	2024-09-03 11:45:40.756053	24	49	2024-09-04 00:00:00	72000	33280
763	20	0	2024-09-03 11:45:40.756053	31	50	2024-09-04 00:00:00	320000	165000
779	300	0	2024-09-03 11:45:40.756053	13	49	2024-09-04 00:00:00	85000	42500
764	50	0	2024-09-03 11:45:40.756053	30	50	2024-09-04 00:00:00	75000	25000
768	50	0	2024-09-03 11:45:40.756053	13	50	2024-09-04 00:00:00	85000	42500
747	300	100	2024-09-03 11:45:40.756053	25	114	2024-09-04 00:00:00	155000	52600
769	0	0	2024-09-03 11:45:40.756053	18	50	2024-09-04 00:00:00	47500	18950
770	50	0	2024-09-03 11:45:40.756053	33	50	2024-09-04 00:00:00	300000	150000
773	0	0	2024-09-03 11:45:40.756053	22	50	2024-09-04 00:00:00	85000	37440
771	100	0	2024-09-03 11:45:40.756053	19	50	2024-09-04 00:00:00	65000	26500
772	0	0	2024-09-03 11:45:40.756053	21	50	2024-09-04 00:00:00	55000	22340
774	100	0	2024-09-03 11:45:40.756053	24	50	2024-09-04 00:00:00	72000	33280
749	315	60	2024-09-03 11:45:40.756053	13	114	2024-09-04 00:00:00	85000	42500
766	50	0	2024-09-03 11:45:40.756053	4	50	2024-09-04 00:00:00	68992	30000
622	50	0	2024-08-29 10:25:24.399416	19	82	2024-09-29 00:00:00	450000	165000
754	100	0	2024-09-03 11:45:40.756053	25	46	2024-09-04 00:00:00	155000	52600
755	50	0	2024-09-03 11:45:40.756053	4	46	2024-09-04 00:00:00	68992	30000
744	50	0	2024-09-03 11:45:40.756053	18	110	2024-09-04 00:00:00	47500	18950
762	200	0	2024-09-03 11:45:40.756053	24	46	2024-09-04 00:00:00	72000	33280
761	0	0	2024-09-03 11:45:40.756053	22	46	2024-09-04 00:00:00	85000	37440
759	60	0	2024-09-03 11:45:40.756053	19	46	2024-09-04 00:00:00	65000	26500
760	50	0	2024-09-03 11:45:40.756053	21	46	2024-09-04 00:00:00	55000	22340
767	400	0	2024-09-03 11:45:40.756053	12	50	2024-09-04 00:00:00	72000	37500
742	500	40	2024-09-03 11:45:40.756053	12	110	2024-09-04 00:00:00	72000	37500
702	50	0	2024-09-03 11:45:40.756053	4	90	2024-09-04 00:00:00	68992	30000
700	300	0	2024-09-03 11:45:40.756053	30	90	2024-09-04 00:00:00	75000	25000
698	100	0	2024-09-03 05:01:24.418477	21	51	2024-09-03 00:00:00	55000	22340
706	100	0	2024-09-03 11:45:40.756053	18	90	2024-09-04 00:00:00	47500	18950
707	50	0	2024-09-03 11:45:40.756053	33	90	2024-09-04 00:00:00	300000	150000
708	100	0	2024-09-03 11:45:40.756053	21	90	2024-09-04 00:00:00	55000	22340
694	100	0	2024-09-03 05:01:24.418477	21	54	2024-09-03 00:00:00	55000	22340
704	100	0	2024-09-03 11:45:40.756053	13	90	2024-09-04 00:00:00	85000	42500
745	100	0	2024-09-03 11:45:40.756053	28	110	2024-09-04 00:00:00	85000	37750
717	50	0	2024-09-03 11:45:40.756053	33	39	2024-09-04 00:00:00	300000	150000
732	0	0	2024-09-03 11:45:40.756053	18	115	2024-09-04 00:00:00	47500	18950
730	50	0	2024-09-03 11:45:40.756053	31	115	2024-09-04 00:00:00	320000	165000
734	0	0	2024-09-03 11:45:40.756053	21	115	2024-09-04 00:00:00	55000	22340
701	120	0	2024-09-03 11:45:40.756053	25	90	2024-09-04 00:00:00	155000	52600
703	300	0	2024-09-03 11:45:40.756053	12	90	2024-09-04 00:00:00	72000	37500
735	0	0	2024-09-03 11:45:40.756053	22	115	2024-09-04 00:00:00	85000	37440
695	0	0	2024-09-03 05:01:24.418477	4	51	2024-09-03 00:00:00	68992	30000
693	0	0	2024-09-03 05:01:24.418477	22	54	2024-09-03 00:00:00	85000	37440
705	30	0	2024-09-03 11:45:40.756053	14	90	2024-09-04 00:00:00	175000	89500
697	100	0	2024-09-03 05:01:24.418477	22	51	2024-09-03 00:00:00	85000	37440
727	0	0	2024-09-03 11:45:40.756053	18	40	2024-09-04 00:00:00	47500	18950
739	100	0	2024-09-03 11:45:40.756053	18	43	2024-09-04 00:00:00	47500	18950
696	88	0	2024-09-03 05:01:24.418477	18	51	2024-09-03 00:00:00	47500	18950
758	100	0	2024-09-03 11:45:40.756053	18	46	2024-09-04 00:00:00	47500	18950
616	100	0	2024-08-29 10:25:24.399416	25	82	2024-09-29 00:00:00	450000	165000
618	200	0	2024-08-29 10:25:24.399416	13	82	2024-09-29 00:00:00	450000	165000
620	100	0	2024-08-29 10:25:24.399416	27	82	2024-09-29 00:00:00	450000	165000
806	100	0	2024-09-11 12:45:01.790506	13	86	2024-09-12 00:00:00	85000	42500
619	0	0	2024-08-29 10:25:24.399416	26	82	2024-09-29 00:00:00	450000	165000
638	100	0	2024-08-30 04:32:52.425527	12	85	2024-09-30 00:00:00	450000	165000
658	200	0	2024-08-30 11:09:09.416373	4	100	2024-09-30 00:00:00	450000	165000
603	300	0	2024-08-26 05:57:51.327947	25	85	2024-09-28 00:00:00	450000	165000
641	400	0	2024-08-30 06:04:24.187282	25	53	2024-09-30 00:00:00	450000	165000
652	100	0	2024-08-30 06:53:43.877021	12	62	2024-09-30 00:00:00	450000	165000
789	50	0	2024-09-09 09:56:53.434255	25	43	2024-09-09 00:00:00	155000	52600
946	200	0	2024-10-08 22:22:53.185305	5	100	2024-10-09 00:00:00	152600	70000
790	20	0	2024-09-09 09:56:53.434255	27	54	2024-09-09 00:00:00	190000	94500
615	50	0	2024-08-29 10:25:24.399416	31	82	2024-09-29 00:00:00	450000	165000
644	366	0	2024-08-30 06:04:24.187282	12	60	2024-09-30 00:00:00	450000	165000
647	70	0	2024-08-30 06:04:24.187282	24	60	2024-09-30 00:00:00	450000	165000
632	285	5	2024-08-29 12:10:28.923345	25	60	2024-09-29 00:00:00	450000	165000
642	100	0	2024-08-30 06:04:24.187282	12	53	2024-09-30 00:00:00	450000	165000
643	100	0	2024-08-30 06:04:24.187282	13	53	2024-09-30 00:00:00	450000	165000
731	300	0	2024-09-03 11:45:40.756053	30	115	2024-09-04 00:00:00	75000	25000
651	200	0	2024-08-30 06:53:43.877021	25	62	2024-09-30 00:00:00	450000	165000
640	200	0	2024-08-30 04:32:52.425527	27	85	2024-09-30 00:00:00	450000	165000
815	30	0	2024-09-12 13:06:50.343136	30	82	2024-09-13 00:00:00	75000	25000
662	50	0	2024-08-30 11:09:09.416373	33	100	2024-09-30 00:00:00	450000	165000
664	100	0	2024-08-30 11:09:09.416373	19	100	2024-09-30 00:00:00	450000	165000
668	200	0	2024-08-30 11:09:09.416373	24	100	2024-09-30 00:00:00	450000	165000
629	0	0	2024-08-29 10:25:24.399416	33	66	2024-09-29 00:00:00	450000	165000
621	200	0	2024-08-29 10:25:24.399416	18	82	2024-09-29 00:00:00	450000	165000
659	100	0	2024-08-30 11:09:09.416373	12	100	2024-09-30 00:00:00	450000	165000
660	200	0	2024-08-30 11:09:09.416373	13	100	2024-09-30 00:00:00	450000	165000
604	100	0	2024-08-26 05:57:51.327947	25	54	2024-09-28 00:00:00	450000	165000
661	0	0	2024-08-30 11:09:09.416373	18	100	2024-09-30 00:00:00	450000	165000
834	20	0	2024-09-26 12:30:20.415993	5	100	2024-08-27 00:00:00	152600	70000
633	500	0	2024-08-30 04:32:52.425527	30	51	2024-09-30 00:00:00	450000	165000
837	10	0	2024-09-26 12:30:20.415993	10	49	2024-08-27 00:00:00	130000	62000
665	0	0	2024-08-30 11:09:09.416373	21	100	2024-09-30 00:00:00	450000	165000
667	50	0	2024-08-30 11:09:09.416373	29	100	2024-09-30 00:00:00	450000	165000
623	50	0	2024-08-29 10:25:24.399416	33	82	2024-09-29 00:00:00	450000	165000
646	0	0	2024-08-30 06:04:24.187282	22	60	2024-09-30 00:00:00	450000	165000
844	5	0	2024-09-26 12:30:20.415993	14	90	2024-08-27 00:00:00	175000	89500
654	50	0	2024-08-30 06:53:43.877021	33	62	2024-09-30 00:00:00	450000	165000
635	200	0	2024-08-30 04:32:52.425527	12	51	2024-09-30 00:00:00	450000	165000
605	100	0	2024-08-26 05:57:51.327947	12	54	2024-09-28 00:00:00	450000	165000
853	50	0	2024-10-08 22:22:53.185305	30	60	2024-10-09 00:00:00	75000	25000
787	0	0	2024-09-05 09:25:02.880335	5	114	2024-09-05 00:00:00	152600	70000
636	200	0	2024-08-30 04:32:52.425527	13	51	2024-09-30 00:00:00	450000	165000
949	50	0	2024-10-08 22:22:53.185305	18	100	2024-10-09 00:00:00	47500	18950
952	100	0	2024-10-08 22:22:53.185305	29	100	2024-10-09 00:00:00	85000	39750
637	300	0	2024-08-30 04:32:52.425527	24	51	2024-09-30 00:00:00	450000	165000
656	50	0	2024-08-30 11:09:09.416373	30	100	2024-09-30 00:00:00	450000	165000
645	100	0	2024-08-30 06:04:24.187282	19	60	2024-09-30 00:00:00	450000	165000
653	50	0	2024-08-30 06:53:43.877021	13	62	2024-09-30 00:00:00	450000	165000
841	10	0	2024-09-26 12:30:20.415993	10	40	2024-08-27 00:00:00	130000	62000
957	50	0	2024-10-08 22:22:53.185305	5	46	2024-10-09 00:00:00	152600	70000
843	5	0	2024-09-26 12:30:20.415993	10	90	2024-08-27 00:00:00	130000	62000
961	50	0	2024-10-08 22:22:53.185305	20	46	2024-10-09 00:00:00	60000	31200
879	150	0	2024-10-08 22:22:53.185305	13	85	2024-10-09 00:00:00	85000	42500
788	5	0	2024-09-05 09:25:02.880335	31	46	2024-09-06 00:00:00	118000	62000
821	134	0	2024-09-16 06:06:47.814033	5	53	2024-09-16 00:00:00	152600	70000
898	80	0	2024-10-08 22:22:53.185305	18	54	2024-10-09 00:00:00	47500	18950
827	10	0	2024-09-16 12:51:47.584962	19	54	2024-09-19 00:00:00	65000	26500
921	100	0	2024-10-08 22:22:53.185305	33	90	2024-10-09 00:00:00	300000	150000
930	50	0	2024-10-08 22:22:53.185305	27	39	2024-10-09 00:00:00	190000	94500
904	400	0	2024-10-08 22:22:53.185305	13	114	2024-10-09 00:00:00	85000	42500
911	200	0	2024-10-08 22:22:53.185305	28	110	2024-10-09 00:00:00	85000	37750
965	50	0	2024-10-08 22:22:53.185305	4	50	2024-10-09 00:00:00	70000	30000
980	100	0	2024-10-08 22:22:53.185305	13	50	2024-10-09 00:00:00	85000	42500
969	200	0	2024-10-08 22:22:53.185305	19	50	2024-10-09 00:00:00	65000	26500
972	100	0	2024-10-08 22:22:53.185305	30	49	2024-10-09 00:00:00	75000	25000
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, full_name, username, hashed_password, status, deleted, region_id, region_manager_id, ffm_id, product_manager_id, deputy_director_id, director_id, email, code, expire_date) FROM stdin;
1	директор	директор	$2b$12$UJ0wW6GXIZ89FkCgcStxTePcKDtnjtdzI0BIrK1PKCPyaz0piCF5.	director	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
80	Abdulaziz	abdulaziz	$2b$12$TLb2wod.hGwCufYcfy81.edfqKnrR26pzVT5Rh2f3ZFG21opgXYeW	medical_representative	f	1	7	4	3	73	1	\N	\N	\N
47	Karshiev Bobomurod	Karshiev	$2b$12$QCig/LxXaFoG6C4Db1fp..RH./35/u.fuMBYKibhv5MxlFR/EQuWe	regional_manager	f	2	\N	31	29	73	1	\N	\N	\N
92	Director	director	$2b$12$CS/6invpSSnUVMqMfUaviuXTXVx3WrH3Wt9GKVkhtY9TayTe5KIOG	director	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
104	Ким Марина	Kim	$2b$12$O/ZpBnkLd263g5qo/xSNj.2FoXADNe3npUXLicTImqhxBCUKJthO.	medical_representative	f	7	55	35	30	73	1	\N	\N	\N
73	deputy_director	deputy_director	$2b$12$LJjOl76ImiQMVaFmEg1cbO3A2S5nzylS1rVZBtjJDHHNK84V5e.qu	deputy_director	f	1	\N	\N	\N	\N	1	\N	\N	\N
3	продукт менеджер	продукт_менеджер	$2b$12$LdDm8LzSLUj.N5S7AMCcMO4M4v6rDVam5hW/paGM3PhO5asN23Wym	product_manager	f	1	\N	\N	\N	73	1	\N	\N	\N
4	ff_manager	ff_manager	$2b$12$4G7LGx6j/OywkN4NeN3/g.FCWwSGcPohjF8CzpMnHNvzG9R4takcy	ff_manager	f	1	\N	\N	3	73	1	\N	\N	\N
5	wholesale_manager	wholesale_manager	$2b$12$iA8WSWVanOVTXOuNl.9VQO2Xp/RO4c73oYu9AviVXIcpPxlOcI5DS	wholesale_manager	f	1	\N	\N	\N	73	1	\N	\N	\N
6	head_of_orders	head_of_orders	$2b$12$vmAPMY437RnYeNOeRsSlo.E3uX5DCHFMEn6nVWqgu26xBTDSHsN9q	head_of_orders	f	1	\N	\N	\N	73	1	\N	\N	\N
7	regional_manager	regional_manager	$2b$12$3vy64AbCe.fMhc9sh0vxNueQDPGdBT1uwDThqp2dnfa33dRHywefO	regional_manager	f	1	\N	4	3	73	1	\N	\N	\N
46	Xolmuratova Feruza	Xolmuratova	$2b$12$oGbFRkvTk5Y2EVHTNJ8uguslwMuy/8CpyrsfaN9PFzYes6AxYsBJ.	medical_representative	f	1	42	31	29	73	1	\N	\N	\N
31	Asanov Boburjon	Boburjon	$2b$12$bGJrvsgxfv6FG7ptFk6I9eI2NjW.6c7nIMU9lYTW2ACFsqpqX6eoC	ff_manager	f	1	\N	\N	29	73	1	\N	\N	\N
32	Asanov Boburjon	Bobur	$2b$12$iPJPthcvGnEuJ6Rw0K9JC.bzagKaFQBlqoKVUIfu1akE1BGihMy/a	ff_manager	f	1	\N	\N	29	73	1	\N	\N	\N
36	Usmanova Dilnoza	Usmanova	$2b$12$uhVAixPWn3PDg1Y4iJlx.uj7SpuuaZ9aGHl/kSpXpGULGkKaIVsji	regional_manager	f	1	\N	35	30	73	1	\N	\N	\N
54	Shamsieva Feruza	Shamsieva	$2b$12$lKfLxldcXKHgzZR.qDMZ2eMiPlIsoJj5FA20FrrPbwULewDn0ydAK	medical_representative	f	1	36	35	30	73	1	\N	\N	\N
35	Masalimova	Neyla	$2b$12$pj8kZlctEt3jlkoPvD/K7.16yYdwn5TQoCVlCmu6cCb2ig71.JNUW	ff_manager	f	1	\N	\N	30	73	1	\N	\N	\N
64	Gulnoza Artikova	Gulnoza	$2b$12$WCBeXoGLnC7ltV7slhgvweNF1R2YGytKqw244RTyIzpyPE614fRHW	ff_manager	f	1	\N	\N	63	73	1	\N	\N	\N
30	Masalimova Neyla	Masalimova	$2b$12$2n0oL9fgHMSBpZidFS4WbetWQm1KYgsSLwhi2XAcHF.0.LUrq1wyC	product_manager	f	1	\N	\N	\N	73	1	\N	\N	\N
63	Artikova Gulnoza	Artikova	$2b$12$57536bouPeLsoLNGAZiNceS7MbujUT9bMphsvIthTO12xU06axCGG	product_manager	f	1	\N	\N	\N	73	1	\N	\N	\N
75	Toshmat Eshmatov	toshmat_ff	$2b$12$eLqYIlI.AJPIqN0bCS2/AuGeMpBP39N7EE2PVwZnQobub2bdX0682	ff_manager	f	1	\N	\N	30	73	1	\N	\N	\N
40	Kurbanov Abbos	Abbos	$2b$12$2gADPlMvMdefjtHWPrXhY.x.GvDHKM8n8QVH0AmbP0QV3Or1eCpoa	medical_representative	f	3	37	31	29	73	1	\N	\N	\N
37	Kuriyazova Zebiniso	Kuriyazova	$2b$12$p4dLx2SMNJeNqtmQzg.3suKUbpHtmHrYSOrtn5Ok4MnfJ5DDgXVSu	regional_manager	f	3	\N	31	29	73	1	\N	\N	\N
39	Kurbanov Hursand	Kurbanov	$2b$12$5X6rWfdssFAMgGhGmRjUJOTULCmebPOvrN.Xd83Ut/8HvyO65iyW6	medical_representative	f	3	37	31	29	73	1	\N	\N	\N
42	Eshdavlatova Xonzoda	Eshdavlatova	$2b$12$wDpZWe3RmjwGh4jEIh0.GujiglMIJ4Gzsjj5aasuR7Px/o8Qbu9uq	regional_manager	f	4	\N	31	29	73	1	\N	\N	\N
43	Narzieva Hilola	Narzieva	$2b$12$cUTdMaqSIYTqsxLZ.18HwuEbPlPnfHNICW1iK3Mk0BJotd6R/vPK6	medical_representative	f	4	42	31	29	73	1	\N	\N	\N
29	Asanov Boburjon	Asanov	$2b$12$nKVvP1z7r4vEVEZWIxN2Je5B33LSigSi0cBCXTOayxV5koImuWgLW	product_manager	f	1	\N	\N	\N	73	1	\N	\N	\N
49	Niyazova Salima	Niyazova	$2b$12$56NLSg7PMbxMxpiDQbVR5eS6i1zGD.Ps0YihkmSd0C7n8etHVK2ya	medical_representative	f	2	47	31	29	73	1	\N	\N	\N
50	Olimov Abdurauf	Olimov	$2b$12$VYPE/LqP46x1Wz/z5vPW9.noDpBUM6BHYo1DlUpsA0FrBuyk/AP2C	medical_representative	f	2	47	31	29	73	1	\N	\N	\N
65	Kadirov Miraziz	Kadirov 	$2b$12$yvzYtsVScMwzkAO.rVAae.du3.Ej63NAg4qiIRAKa4H8hXFfdDIsK	regional_manager	f	1	\N	64	63	73	1	\N	\N	\N
51	Melieva Gulnoza	Melieva	$2b$12$LocxrVX4l0vRl77KHdTBn./a4O2bmqagILFA5sBDA.FhepLftw5GG	medical_representative	f	12	36	35	30	73	1	\N	\N	\N
53	Tursunov Mansurjon	Tursunov	$2b$12$FUmiFjWPEEKiUPlnROTf9ucYjY95P28LSqhhR7wkBvcG9W/vOjVnK	medical_representative	f	12	36	35	30	73	1	\N	\N	\N
59	Xalilova Yulduz	Xalilova	$2b$12$sM3iAez.zBjQxvdXDoNGluNzAPBpb2A7FtErr/7y84S1VppF6kD6y	regional_manager	f	6	\N	35	30	73	1	\N	\N	\N
60	Xalimova Anvara	Xalimova	$2b$12$5igspBsQERKW7SspsTMT1eLcl/31t57vqNdVm2StSLAxMr739HPkG	medical_representative	f	6	59	35	30	73	1	\N	\N	\N
62	Zamira Xalimova	Zamira	$2b$12$3BrhxbPdPTg5.wOq0LpdtOexQxeM1BV9rz58REe.F25C8aK1YfTIm	medical_representative	f	6	59	35	30	73	1	\N	\N	\N
55	Xudoybergenova Gulayim	Xudoybergenova	$2b$12$t1TlEUROAc/JBqeIpQZTXuWRMRx51q5lfExpeY9t7AO0953nupT9a	regional_manager	f	7	\N	35	30	73	1	\N	\N	\N
66	Nigmanova Shahnoza	Nigmanova	$2b$12$LPqD4k8uMdR6sPwtS3/msus2e3miTqHnpBGjnKeCIhPJfFGHeUgzO	medical_representative	f	1	65	64	63	73	1	\N	\N	\N
86	Xalilova Yulduz	Yulduz	$2b$12$192TV0fu/vQv/JgXM7.CmuySlJ1YVmqcABzTOTFHfBCAfr4yPRFL.	medical_representative	f	6	59	35	30	73	1	\N	\N	\N
82	Miraziz Kadirov	Miraziz	$2b$12$e28oTVItvpnCQjwOPAlocOWS/f0jlRzXutKudPYv1I89ckS7O6GP6	medical_representative	f	1	65	64	63	73	1	\N	\N	\N
78	Islom Qulmatov	islom_rm	$2b$12$xwu4rDK99ubWCyV0RhVL9.1gHkVeKq.xL32C.RdmzkRQBrjyeFt4u	regional_manager	f	4	\N	75	30	73	1	\N	\N	\N
100	Xo'jaqulov Ahmad	Xo'jaqulov	$2b$12$lQiNdBhbdVriv7jT85.bB.VvuXuYK5G79CpG5PlQIUQIPlHYFFRHG	medical_representative	f	2	47	31	29	73	1	string	\N	\N
76	Farrux Abdusamadov	farruxbek_rm	$2b$12$k0UJN4L15lyAk63FXQJFa.RbZTb1a43K6RCPHAwVpwqkierf6YTUe	regional_manager	f	7	\N	32	30	73	1	\N	\N	\N
90	Kuriyazova 	Zebiniso	$2b$12$DM0yAyyCRbdB/ynANv3sa.r2wMkPgX6C3svl1B3u4IPJ6jC6FD1iu	medical_representative	f	3	37	31	29	73	1	\N	\N	\N
85	Xudoybergenova Gulayim	Gulayim	$2b$12$rTLG0Q0PdQjQNrYvM3BxRu25.dA3gUIzqzwYhWeAJLz/QOz3oGtUu	medical_representative	f	7	55	35	30	73	1	\N	\N	\N
106	Test	test_pm	$2b$12$0x9bCa/hlQjVxNb2X9bhbOxNR/FQfdTh3gGXbD8wuVuk//NrpASXO	product_manager	f	1	\N	\N	\N	73	1	\N	\N	\N
107	Test FF	test_ff	$2b$12$n59qxQqGT2ogFlmoL8x1x.B0NrCEk49uVlFA0B9rNSLFBbgVs79ja	ff_manager	f	1	\N	\N	106	73	1	\N	\N	\N
108	Test RM	test_rm	$2b$12$0lyHuMZN7gTF1OCFjFTzm.151q7600ymRwcSbihQT.fciF3VsM9Ke	regional_manager	f	13	\N	107	106	73	1	\N	\N	\N
110	Назарова Зиёда	Nazarova	$2b$12$Y6wPfmMq2OMBpUnHTbtxku.x2S.Xeaf7/IMmWaqOPP31gycVDl5l2	medical_representative	f	4	42	31	29	73	1	\N	\N	\N
111	string	test_user	$2b$12$Vf92in40dGB/1GghQhbi7e/IG7aLfarEB.lbndC8ulpyHGtNBciD2	medical_representative	f	1	7	4	3	73	1	ravshanbekeshquvvatov@gmail.com	\N	2024-08-26 06:26:21.958202
114	Бозорова Лобар	Lobar	$2b$12$JDpPF.kg/y40zKnSSpjgMeSrRcl7CtyorTeohF6Zar0KvniYveIQq	medical_representative	f	4	42	31	29	73	1	\N	\N	\N
102	MadinaToxirova	Madina	$2b$12$E.LazbpAWsPg0wYMe/hfU.LhEudc75AWWJvRIwuO4kgrwWLqhrqJa	medical_representative	f	17	7	31	29	73	1	\N	\N	\N
115	Хонзода Эшдавлатова	Xonzoda	$2b$12$safuw1Uqci6ZZ70oMl7OkejxFI6spO7EbUO1biIltxYEzAq3Ve5VK	medical_representative	f	4	42	31	29	73	1	\N	\N	\N
116	Sadikova Tazaxan	Sadikova	$2b$12$z4KMyKZVcYbKjZ2sFEd/S.IYTMqn1Y9bo/6URowMxtDhdmwk05BWG	medical_representative	f	7	55	35	30	73	1	\N	\N	\N
117	financier	financier	$2b$12$0E9SKj2eEsuuW6ZXBfJ.TOhqT781hei0JinKraa4voc5eLBfFZGpO	financier	f	1	\N	\N	\N	73	1	user@example.com	\N	\N
118	Human Resources	hr	$2b$12$yn.rkcxGd5Kln18HnIa4.uFgRxxMVsC8Rct8lOBozhz0rUHwKinzi	hr	f	1	\N	\N	\N	73	1	user@example.com	\N	\N
\.


--
-- Data for Name: wholesale; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.wholesale (id, name, contact, region_id) FROM stdin;
5	Test	indiana	8
6	Зума склад	Марат Арипович	15
1	Азиз - М	+998906078026	6
7	Зам Зам	+998907400022	8
2	Зебинисо	+998935025013	3
3	Мерос Фарм	+998990303223	15
9	Самфарм	+998958379333	1
8	Мадина Фарм Ташкент		1
4	Фарм Люкс Инвест	+998945343165	15
10	Мадина Фарм Синтез	90-3409200	6
11	Мирзохид Искандер		6
12	Саховат Универсал Фарм	94-1060030	18
13	Орие Мехр		15
14	Беш Юлдуз Мед Фарм	91-3626242	12
15	Мирзохид Фарм Сервис	91-3626242	12
16	Биг Фемили		8
\.


--
-- Data for Name: wholesale_output; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.wholesale_output (id, amount, date, pharmacy, product_id, wholesale_id) FROM stdin;
\.


--
-- Data for Name: wholesale_reservation; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.wholesale_reservation (id, date, date_implementation, expire_date, discount, discountable, total_quantity, total_amount, total_payable, total_payable_with_nds, invoice_number, profit, debt, wholesale_id, manufactured_company_id, checked, med_rep_id, reailized_debt, prosrochenniy_debt, bonus) FROM stdin;
120	2024-09-20 00:00:00	2024-09-20 06:44:55.94132	2024-11-19 05:14:24.339684	8	\N	340	34200000	31464000	35239680	1775	0	35239680	9	1	t	100	0	f	t
31	2024-08-13 00:00:00	2024-08-01 00:00:00	2024-09-12 10:07:30.092732	8	\N	1193	126341000	116233720	130181766	1	115920	130065846	9	3	t	80	18157201	f	t
54	2024-08-15 00:00:00	2024-08-19 07:52:42.367411	2024-09-14 11:23:50.522362	8	\N	88	6336000	5829120	6528614	2548	0	6528614	9	3	t	100	1706347	f	t
53	2024-08-15 00:00:00	2024-08-16 06:24:54.077927	2024-09-14 11:23:50.522362	8	\N	787	115485000	106246200	118995744	1552	0	118995744	9	1	t	100	19140762	f	t
131	2024-10-08 22:22:53.231515	2024-10-14 08:52:50.835158	2024-12-07 22:22:53.231576	8	\N	132	11220000	10322400	11561088	1322	0	11561088	9	1	t	100	0	f	t
32	2024-08-13 00:00:00	2024-08-14 03:58:29.975341	2024-09-12 12:09:01.335323	8	\N	35	3660000	3367200	3771264	2331	0	3771264	10	3	t	86	0	f	t
25	2024-08-13 00:00:00	2024-08-01 00:00:00	2024-09-12 02:35:16.539831	8	\N	50	2475000	2277000	2550240	7	0	2550240	2	3	t	39	0	f	t
29	2024-08-13 00:00:00	2024-08-01 00:00:00	2024-09-12 10:07:30.092732	8	\N	376	24831500	22844980	25586378	3	0	25586378	3	3	t	82	0	f	t
18	2024-08-13 00:00:00	2024-08-01 00:00:00	2024-09-12 02:35:16.539831	8	\N	127	13209000	12152280	13610554	10	0	13610554	1	1	t	86	74189	f	t
116	2024-09-15 00:00:00	2024-09-16 00:00:00	2024-11-14 20:04:37.195416	8	\N	100	7000000	6440000	7212800	1730	0	7212800	8	1	t	100	0	f	t
70	2024-08-31 00:00:00	2024-07-01 00:00:00	2024-10-03 05:01:24.446489	8	\N	360	28260000	25999200	29119104	1228	29300000	0	9	1	t	100	0	f	t
71	2024-08-31 00:00:00	2024-07-02 00:00:00	2024-10-03 05:01:24.446489	8	\N	660	51810000	47665200	53385024	1229	53500000	0	9	1	t	100	0	f	t
86	2024-08-31 00:00:00	2024-09-03 11:27:31.653613	2024-10-03 09:48:38.714978	8	\N	35	3660000	3367200	3771264	291	3771264	0	10	3	t	86	0	f	t
85	2024-08-31 00:00:00	2024-09-03 11:24:12.898586	2024-10-03 09:48:38.714978	33.73	\N	110	5389000	3571290	3999846	612	4000000	0	2	3	t	90	0	f	t
84	2024-08-31 00:00:00	2024-09-03 11:18:48.236739	2024-10-03 09:48:38.714978	20.39	\N	88	5720000	4553692	5100135	614	5100000	135	13	3	t	80	0	f	t
80	2024-08-31 00:00:00	2024-08-28 00:00:00	2024-10-03 09:48:38.714978	12.18	\N	60	5520800	4848367	5430170	492	5430000	170	4	1	t	80	0	f	t
82	2024-08-31 00:00:00	2024-09-03 11:04:42.218136	2024-10-03 09:48:38.714978	8.008	\N	455	29118000	26786231	30000578	1997	30000000	578	9	3	t	100	0	f	t
81	2024-08-31 00:00:00	2024-09-03 10:54:19.330898	2024-10-03 09:48:38.714978	30.23	\N	60	9050000	6314185	7071887	108	7072000	0	11	1	t	86	0	f	t
79	2024-08-31 00:00:00	2024-09-03 10:40:39.771013	2024-10-03 09:48:38.714978	10.86	\N	785	100165000	89287081	100001533	939	100000000	1533	8	1	t	100	0	f	t
78	2024-08-31 00:00:00	2024-09-03 10:12:59.984096	2024-10-03 09:48:38.714978	27.4	\N	78	5973000	4336398	4856766	85	4860000	0	14	1	t	51	0	f	t
77	2024-08-31 00:00:00	2024-09-03 10:08:05.215363	2024-10-03 09:48:38.714978	8	\N	30	4650000	4278000	4791360	1206	4791360	0	10	1	t	86	0	f	t
26	2024-08-13 00:00:00	2024-08-01 00:00:00	2024-09-12 10:07:30.092732	8	\N	949	94628000	87057760	97504691	6	0	97504691	8	1	t	82	48902800	f	t
97	2024-09-09 00:00:00	2024-09-09 11:05:27.304174	2024-11-08 09:56:53.4669	27.031	\N	95	12236200	8928633	10000068	1210	10000000	68	1	1	t	86	0	f	t
93	2024-09-05 00:00:00	2024-09-05 13:06:41.789665	2024-11-04 09:25:02.909227	8.04	\N	20	1942000	1785863	2000167	1189	2000000	167	2	1	t	90	0	f	t
89	2024-08-31 00:00:00	2024-06-07 00:00:00	2024-11-02 11:45:40.788044	13.846	\N	270	41350000	35624679	39899642	2000	39900000	0	2	1	t	90	0	f	t
87	2024-08-31 00:00:00	2024-06-06 00:00:00	2024-11-02 11:45:40.788044	8.08	\N	94	14570000	13392744	14999872	1065	15000000	0	7	1	t	51	0	f	t
110	2024-08-31 00:00:00	2024-09-20 05:44:32.719921	2024-11-08 09:56:53.4669	8	\N	15	2006000	1845520	2066982	1215	0	2066982	10	3	t	80	0	f	t
111	2024-08-31 00:00:00	2024-09-20 05:44:25.26136	2024-11-08 09:56:53.4669	8	\N	27	1999500	1839540	2060285	1216	0	2060285	3	3	t	80	1565693	f	t
94	2024-09-05 00:00:00	2024-09-06 07:30:36.451454	2024-11-04 09:25:02.909227	13.968	\N	45	3424800	2946428	3299994	211	3300000	0	15	1	t	51	0	f	t
91	2024-09-05 00:00:00	2024-09-05 13:02:44.850417	2024-11-04 09:25:02.909227	27.025	\N	95	12236200	8929369	10000891	1188	10000000	891	1	1	t	86	0	f	t
23	2024-08-13 00:00:00	2024-08-01 00:00:00	2024-09-12 02:35:16.539831	8	\N	180	12302500	11318300	12676496	9	0	12676496	1	3	t	86	0	f	t
22	2024-08-13 00:00:00	2024-08-01 00:00:00	2024-09-12 02:35:16.539831	8	\N	484	31460500	28943660	32416899	11	0	32416899	7	3	t	51	0	f	t
59	2024-08-15 00:00:00	2024-08-20 10:29:34.02299	2024-09-14 11:23:50.522362	8	\N	248	35918600	33045112	37010525	15	0	37010525	4	1	t	80	0	f	t
38	2024-08-13 00:00:00	2024-08-08 00:00:00	2024-09-12 12:09:01.335323	8	\N	5	1500000	1380000	1545600	2374	1545600	0	11	3	t	86	0	f	t
37	2024-08-13 00:00:00	2024-08-08 00:00:00	2024-09-12 12:09:01.335323	8	\N	70	9190000	8454800	9469376	1481	9469380	-4	11	1	t	86	0	f	t
36	2024-08-13 00:00:00	2024-08-08 00:00:00	2024-09-12 12:09:01.335323	8	\N	40	5550000	5106000	5718720	1482	5718720	0	11	1	t	86	0	f	t
60	2024-08-15 00:00:00	2024-08-20 10:29:23.333018	2024-09-14 11:23:50.522362	8	\N	566	38101000	35052920	39259270	16	699	39258571	4	3	t	80	66277	f	t
95	2024-09-05 00:00:00	2024-09-06 12:31:31.592642	2024-11-04 09:25:02.909227	27.031	\N	95	12236200	8928632	10000069	1194	10000000	69	1	1	t	86	0	f	t
109	2024-08-31 00:00:00	2024-09-20 05:44:37.301706	2024-11-08 09:56:53.4669	8	\N	308	32252880	29672650	33233368	1214	111	33233257	10	1	t	80	0	f	t
28	2024-08-13 00:00:00	2024-08-01 00:00:00	2024-09-12 10:07:30.092732	8	\N	56	7380000	6789600	7604352	4	0	7604352	3	1	t	82	1741376	f	t
27	2024-08-13 00:00:00	2024-08-01 00:00:00	2024-09-12 10:07:30.092732	8	\N	740	99806000	91821520	102840102	5	0	102840102	8	3	t	82	4771787	f	t
103	2024-08-31 00:00:00	\N	2024-11-08 09:56:53.4669	8	\N	71	11188000	10292960	11528115	1208	0	11528115	7	1	f	80	0	f	t
98	2024-08-31 00:00:00	\N	2024-11-08 09:56:53.4669	8	\N	8	576000	529920	593510	1205	0	593510	1	1	f	80	0	f	t
104	2024-08-31 00:00:00	\N	2024-11-08 09:56:53.4669	8	\N	50	2475000	2277000	2550240	1209	0	2550240	2	3	f	80	0	f	t
106	2024-08-31 00:00:00	\N	2024-11-08 09:56:53.4669	8	\N	389	60250000	55430000	62081600	1211	0	62081600	2	1	f	80	0	f	t
107	2024-08-31 00:00:00	\N	2024-11-08 09:56:53.4669	8	\N	574	52048000	47884160	53630259	1212	0	53630259	8	1	f	80	0	f	t
83	2024-08-31 00:00:00	2024-08-28 00:00:00	2024-10-03 09:48:38.714978	34.015	\N	407	22627000	14930425	16722077	735	16722000	77	4	3	t	80	0	f	t
108	2024-08-31 00:00:00	2024-09-10 06:08:11.118959	2024-11-08 09:56:53.4669	8	\N	200	19581000	18014520	20176262	1213	0	20176262	8	3	t	80	16677024	f	t
20	2024-08-13 00:00:00	2024-08-01 00:00:00	2024-09-12 02:35:16.539831	8	\N	1249	126547000	116423240	130394029	12	0	130394029	7	1	t	51	4471936	f	t
33	2024-08-13 00:00:00	2024-08-14 00:00:00	2024-09-12 12:09:01.335323	8	\N	30	4650000	4278000	4791360	1461	0	4791360	10	1	t	86	318136	f	t
30	2024-08-13 00:00:00	2024-08-01 00:00:00	2024-09-12 10:07:30.092732	8	\N	1106	133463000	122785960	137520275	2	20000	137500275	9	1	t	80	95035243	f	t
61	2024-08-23 00:00:00	2024-08-01 00:00:00	2024-09-22 04:46:18.283653	8	\N	606	86134400	79243648	88752886	17	191	88752695	13	1	t	80	35469858	f	t
24	2024-08-13 00:00:00	2024-08-01 00:00:00	2024-09-12 02:35:16.539831	8	\N	534	80350000	73922000	82792640	8	0	82792640	2	1	t	39	62081595	f	t
132	2024-10-08 22:22:53.231515	2024-10-11 17:07:35.98955	2024-12-07 22:22:53.231576	8	\N	151	12835000	11808200	13225184	3218	0	13225184	9	3	t	100	0	f	t
112	2024-08-31 00:00:00	\N	2024-11-08 09:56:53.4669	8	\N	7	910000	837200	937664	1217	0	937664	3	1	f	80	0	f	t
117	2024-09-16 00:00:00	2024-09-11 00:00:00	2024-11-15 12:51:47.618549	8	\N	100	7200000	6624000	7418880	1698	0	7418880	8	1	t	100	0	f	t
128	2024-10-08 22:22:53.231515	2024-10-09 15:09:20.019517	2024-12-07 22:22:53.231576	8	\N	330	23760000	21859200	24482304	1886	0	24482304	9	1	t	100	0	f	t
113	2024-08-31 00:00:00	\N	2024-11-08 09:56:53.4669	8	\N	905	103047400	94803608	106180041	1218	0	106180041	9	1	f	80	0	f	t
118	2024-09-16 00:00:00	2024-09-18 07:22:46.836052	2024-11-15 12:51:47.618549	0	\N	30	1425000	1425000	1596000	13874	0	1596000	16	3	t	54	0	f	t
102	2024-08-31 00:00:00	\N	2024-11-08 09:56:53.4669	8	\N	28	1557500	1432900	1604848	1207	0	1604848	1	3	f	80	0	f	t
114	2024-08-31 00:00:00	\N	2024-11-08 09:56:53.4669	8	\N	281	20802000	19137840	21434381	1219	0	21434381	9	3	f	80	0	f	t
119	2024-09-16 00:00:00	2024-09-19 04:54:24.22098	2024-11-15 12:51:47.618549	8	\N	50	4250000	3910000	4379200	2976	0	4379200	9	3	t	100	0	f	t
130	2024-10-08 22:22:53.231515	2024-10-09 15:09:03.062999	2024-12-07 22:22:53.231576	8	\N	110	7920000	7286400	8160768	3139	0	8160768	9	3	t	100	0	f	t
136	2024-10-11 14:48:56.44198	2024-10-14 12:54:01.819871	2024-12-10 14:48:56.442021	8	\N	176	14960000	13763200	15414784	3254	0	15414784	9	3	t	100	0	f	t
\.


--
-- Data for Name: wholesale_reservation_payed_amounts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.wholesale_reservation_payed_amounts (id, amount, description, date, product_id, doctor_id, pharmacy_id, med_rep_id, reservation_id, total_sum, remainder_sum, quantity, payed, nds_sum, fot_sum, promo_sum, skidka_sum, pure_proceeds) FROM stdin;
36	100		2024-09-02 00:00:00	\N	\N	\N	\N	61	100	91	\N	t	\N	\N	\N	\N	\N
38	91		2024-09-02 00:00:00	\N	\N	\N	\N	61	91	0	\N	t	\N	\N	\N	\N	\N
39	20000		2024-09-02 00:00:00	\N	\N	\N	\N	30	20000	0	\N	t	\N	\N	\N	\N	\N
41	29300000		2024-08-31 00:00:00	\N	\N	\N	\N	70	29300000	0	\N	t	\N	\N	\N	\N	\N
40	53500000		2024-08-31 00:00:00	\N	\N	\N	\N	71	53500000	0	\N	t	\N	\N	\N	\N	\N
53	3771264		2024-08-31 00:00:00	\N	\N	\N	\N	86	3771264	0	\N	t	\N	\N	\N	\N	\N
52	4000000		2024-08-31 00:00:00	\N	\N	\N	\N	85	4000000	0	\N	t	\N	\N	\N	\N	\N
51	5100000		2024-08-31 00:00:00	\N	\N	\N	\N	84	5100000	0	\N	t	\N	\N	\N	\N	\N
50	16722000		2024-08-31 00:00:00	\N	\N	\N	\N	83	16722000	0	\N	t	\N	\N	\N	\N	\N
49	30000000		2024-08-31 00:00:00	\N	\N	\N	\N	82	30000000	0	\N	t	\N	\N	\N	\N	\N
48	7072000		2024-08-31 00:00:00	\N	\N	\N	\N	81	7072000	0	\N	t	\N	\N	\N	\N	\N
47	5430000		2024-08-31 00:00:00	\N	\N	\N	\N	80	5430000	0	\N	t	\N	\N	\N	\N	\N
46	100000000		2024-08-31 00:00:00	\N	\N	\N	\N	79	100000000	0	\N	t	\N	\N	\N	\N	\N
45	4860000		2024-08-31 00:00:00	\N	\N	\N	\N	78	4860000	0	\N	t	\N	\N	\N	\N	\N
44	4791360		2024-08-31 00:00:00	\N	\N	\N	\N	77	4791360	0	\N	t	\N	\N	\N	\N	\N
55	39900000		2024-08-31 00:00:00	\N	\N	\N	\N	89	39900000	0	\N	t	\N	\N	\N	\N	\N
54	15000000		2024-08-31 00:00:00	\N	\N	\N	\N	87	15000000	0	\N	t	\N	\N	\N	\N	\N
57	10000000		2024-09-05 00:00:00	\N	\N	\N	\N	91	10000000	0	\N	t	\N	\N	\N	\N	\N
58	2000000		2024-09-05 00:00:00	\N	\N	\N	\N	93	2000000	0	\N	t	\N	\N	\N	\N	\N
59	3300000		2024-09-05 00:00:00	\N	\N	\N	\N	94	3300000	0	\N	t	\N	\N	\N	\N	\N
60	10000000		2024-09-05 00:00:00	\N	\N	\N	\N	95	10000000	0	\N	t	\N	\N	\N	\N	\N
61	10000000		2024-09-09 00:00:00	\N	\N	\N	\N	97	10000000	0	\N	t	\N	\N	\N	\N	\N
97	111	test	2024-09-26 00:00:00	\N	\N	\N	\N	109	111	0	\N	t	\N	\N	\N	\N	\N
20	48944	Hello	2024-08-13 00:00:00	18	357	91	60	31	200000	84080	1	t	5244	14000	12000	3800	47500
21	66976	Hello	2024-08-13 00:00:00	19	313	91	60	31	200000	84080	1	t	7176	19000	16000	5200	65000
22	1545600	.	2024-08-21 00:00:00	33	592	151	60	38	1545600	0	5	t	165600	375000	300000	120000	1500000
23	7985600	.	2024-08-21 00:00:00	25	589	151	60	37	9469380	0	50	t	855600	2250000	2500000	620000	7750000
24	1483780	.	2024-08-21 00:00:00	12	591	151	60	37	9469380	0	20	t	158976	320000	320000	115196	1440000
25	1957760	.	2024-08-21 00:00:00	27	591	151	60	36	5718720	0	10	t	209760	460000	400000	152000	1900000
26	1803200	.	2024-08-21 00:00:00	14	591	151	60	36	5718720	0	10	t	193200	420000	350000	140000	1750000
27	1957760	.	2024-08-21 00:00:00	15	591	151	60	36	5718720	0	20	t	209760	430000	400000	152000	1900000
28	0	JKJKJKJK	2024-08-22 00:00:00	19	370	78	80	60	0	0	1	t	0	19000	16000	65000	65000
37	74189		2024-09-02 00:00:00	12	339	35	82	18	0	0	1	f	7949	16000	16000	5760	72000
62	875840		2024-09-10 00:00:00	28	652	180	82	27	0	0	10	f	93840	220000	210000	68000	850000
63	222567		2024-09-10 00:00:00	24	652	180	82	27	0	0	3	f	23846	54000	51000	17279	216000
64	1597120		2024-09-10 00:00:00	25	426	183	82	30	0	0	10	f	171120	450000	500000	124000	1550000
66	222567		2024-09-10 00:00:00	24	652	185	82	31	0	0	3	f	23846	54000	51000	17279	216000
67	437920		2024-09-10 00:00:00	22	466	187	49	31	0	0	5	f	46920	115000	100000	34000	425000
68	437920		2024-09-10 00:00:00	22	468	187	49	27	0	0	5	f	46920	115000	100000	34000	425000
69	15971200		2024-09-10 00:00:00	25	466	189	49	26	0	0	100	f	1711200	4500000	5000000	1240000	15500000
71	370945		2024-09-11 00:00:00	12	466	191	49	30	0	0	5	f	39744	80000	80000	28799	360000
72	437920		2024-09-11 00:00:00	13	597	191	49	30	0	0	5	f	46920	100000	100000	34000	425000
73	3565180		2024-09-13 00:00:00	11	426	93	82	61	0	0	20	f	381984	900000	900000	276804	3460000
74	267904		2024-09-13 00:00:00	10	481	200	100	28	0	0	2	f	28704	60000	60000	20800	260000
75	267904		2024-09-13 00:00:00	10	481	200	100	28	0	0	2	f	28704	60000	60000	20800	260000
76	267904		2024-09-13 00:00:00	10	481	200	100	28	0	0	2	f	28704	60000	60000	20800	260000
77	700672		2024-09-13 00:00:00	28	652	180	82	27	0	0	8	f	75072	176000	168000	54400	680000
65	1174656		2024-09-10 00:00:00	27	340	184	82	30	0	0	6	t	125856	276000	240000	91200	1140000
78	875840		2024-09-13 00:00:00	28	652	180	82	27	0	0	10	f	93840	220000	210000	68000	850000
79	296756		2024-09-13 00:00:00	24	652	185	82	31	0	0	4	f	31795	72000	68000	23039	288000
80	3766112		2024-09-20 00:00:00	13	599	153	82	61	0	0	43	f	403512	860000	860000	292400	3655000
94	3565180	.	2024-09-26 00:00:00	11	652	230	82	61	0	0	20	f	381984	900000	900000	276804	3460000
95	7704711	.	2024-09-26 00:00:00	5	303	19	53	61	0	0	49	f	825505	1960000	1715000	598194	7477400
96	13208076	.	2024-09-26 00:00:00	5	303	101	53	61	0	0	84	f	1415151	3360000	2940000	1025475	12818400
103	2627520	.	2024-09-26 00:00:00	29	476	198	100	31	0	0	30	f	281520	630000	600000	204000	2550000
104	2887696	.	2024-09-26 00:00:00	18	477	198	100	31	0	0	59	f	309396	826000	708000	224200	2802500
105	2225670	.	2024-09-26 00:00:00	24	478	198	100	31	0	0	30	f	238465	540000	510000	172795	2160000
106	2987541	.	2024-09-26 00:00:00	5	481	198	100	30	0	0	19	f	320094	760000	665000	231953	2899400
107	4278216	.	2024-09-26 00:00:00	11	481	198	100	30	0	0	24	f	458380	1080000	1080000	332164	4152000
108	3503360	.	2024-09-26 00:00:00	13	476	198	100	30	0	0	40	f	375360	800000	800000	272000	3400000
109	741890	.	2024-09-26 00:00:00	12	477	199	100	30	0	0	10	f	79488	160000	160000	57598	720000
110	1751680	.	2024-09-26 00:00:00	13	477	199	100	30	0	0	20	f	187680	400000	400000	136000	1700000
111	1483780	.	2024-09-26 00:00:00	24	479	228	100	27	0	0	20	f	158976	360000	340000	115196	1440000
112	2225670	.	2024-09-26 00:00:00	12	480	228	100	26	0	0	30	f	238465	480000	480000	172795	2160000
113	4379200	.	2024-09-26 00:00:00	13	480	228	100	26	0	0	50	f	469200	1000000	1000000	340000	4250000
114	1597120	.	2024-09-26 00:00:00	25	583	228	100	26	0	0	10	f	171120	450000	500000	124000	1550000
115	51005	.	2024-09-26 00:00:00	23	478	200	100	111	0	0	1	f	5465	13500	12000	3960	49500
116	267904	.	2024-09-26 00:00:00	10	481	200	100	28	0	0	2	f	28704	60000	60000	20800	260000
117	175168	.	2024-09-26 00:00:00	22	471	186	49	27	0	0	2	f	18768	46000	40000	13600	170000
118	3091200	.	2024-09-26 00:00:00	33	469	189	49	108	0	0	10	f	331200	750000	600000	240000	3000000
119	8758400	.	2024-09-26 00:00:00	28	644	189	49	108	0	0	100	f	938400	2200000	2100000	680000	8500000
120	963424	.	2024-09-26 00:00:00	22	468	189	49	108	0	0	11	f	103224	253000	220000	74800	935000
140	669760	.	2024-09-26 00:00:00	10	466	189	49	26	0	0	5	f	71760	150000	150000	52000	650000
141	3709450	.	2024-09-26 00:00:00	12	469	189	49	26	0	0	50	f	397441	800000	800000	287991	3600000
142	4379200	.	2024-09-26 00:00:00	13	469	189	49	26	0	0	50	f	469200	1000000	1000000	340000	4250000
143	12776960	.	2024-09-26 00:00:00	25	467	189	49	26	0	0	80	f	1368960	3600000	4000000	992000	12400000
144	9459072	.	2024-09-26 00:00:00	22	468	190	49	31	0	0	108	f	1013472	2484000	2160000	734400	9180000
145	34497792	.	2024-09-26 00:00:00	25	466	190	49	30	0	0	216	f	3696192	9720000	10800000	2678400	33480000
146	1854725	.	2024-09-26 00:00:00	12	466	190	49	30	0	0	25	f	198721	400000	400000	143996	1800000
147	2189600	.	2024-09-26 00:00:00	13	469	190	49	30	0	0	25	f	234600	500000	500000	170000	2125000
148	1313760	.	2024-09-26 00:00:00	22	471	190	49	111	0	0	15	f	140760	345000	300000	102000	1275000
149	3194240	.	2024-09-26 00:00:00	25	467	189	49	26	0	0	20	f	342240	900000	1000000	248000	3100000
150	18769817	/	2024-09-26 00:00:00	12	482	194	50	53	0	0	253	f	2011052	4048000	4048000	1457235	18216000
151	1236480	/	2024-09-26 00:00:00	33	80	195	50	108	0	0	4	f	132480	300000	240000	96000	1200000
152	2627520	/	2024-09-26 00:00:00	28	514	195	50	108	0	0	30	f	281520	660000	630000	204000	2550000
154	157239	.	2024-09-26 00:00:00	5	303	19	53	61	0	0	1	f	16847	40000	35000	12208	152600
155	1706347	/	2024-09-26 00:00:00	24	602	96	46	54	0	0	23	f	182823	414000	391000	132476	1656000
156	370945	/	2024-09-26 00:00:00	12	299	96	46	53	0	0	5	f	39744	80000	80000	28799	360000
157	200928	/	2024-09-26 00:00:00	19	522	208	46	111	0	0	3	f	21528	57000	48000	15600	195000
158	669760	/	2024-09-26 00:00:00	10	425	62	39	28	0	0	5	f	71760	150000	150000	52000	650000
159	27151040	.	2024-09-26 00:00:00	25	384	210	40	24	0	0	170	f	2909040	7650000	8500000	2108000	26350000
160	937664	.	2024-09-26 00:00:00	10	384	210	40	24	0	0	7	f	100464	210000	210000	72800	910000
161	5347770	.	2024-09-26 00:00:00	11	412	210	40	24	0	0	30	f	572975	1350000	1350000	415205	5190000
162	3503360	.	2024-09-26 00:00:00	13	302	21	54	61	0	0	40	f	375360	800000	800000	272000	3400000
163	370945	.	2024-09-26 00:00:00	12	604	211	90	24	0	0	5	f	39744	80000	80000	28799	360000
164	721280	.	2024-09-26 00:00:00	14	603	211	90	24	0	0	4	f	77280	168000	140000	56000	700000
165	27151040	.	2024-09-26 00:00:00	25	603	211	90	24	0	0	170	f	2909040	7650000	8500000	2108000	26350000
166	401856	.	2024-09-26 00:00:00	10	322	211	90	24	0	0	3	f	43056	90000	90000	31200	390000
\.


--
-- Data for Name: wholesale_reservation_products; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.wholesale_reservation_products (id, quantity, product_id, price, reservation_id, not_payed_quantity) FROM stdin;
22	60	10	133952	18	60
24	45	13	87584	18	45
26	48	10	133952	20	48
27	440	12	74189	20	440
28	486	13	87584	20	486
29	123	14	180320	20	123
30	124	11	178259	20	124
31	33	18	48944	22	33
32	365	19	66976	22	365
33	2	20	61824	22	2
34	84	24	74189	22	84
35	25	18	48944	23	25
36	52	28	87584	23	52
37	103	19	66976	23	103
41	20	13	87584	24	20
43	30	27	195776	24	30
45	50	23	51005	25	50
50	120	15	97888	26	120
51	26	18	48944	27	26
52	200	33	309120	27	200
54	85	19	66976	27	85
57	4	8	159712	28	4
59	89	19	66976	29	89
60	204	20	61824	29	204
61	76	22	87584	29	76
62	7	23	51005	29	7
73	160	33	309120	31	160
74	176	28	87584	31	176
79	5	33	309120	32	5
80	30	24	74189	32	30
75	284	19	66976	31	283
106	10	7	77280	59	10
107	99	8	159712	59	99
108	93	10	133952	59	93
109	11	5	157239	59	11
110	35	11	178259	59	35
112	64	23	51005	60	64
113	329	24	74189	60	329
90	5	33	309120	38	0
88	50	25	159712	37	0
89	20	12	74189	37	0
94	60	25	159712	53	60
96	165	13	87584	53	165
97	136	31	463680	53	136
98	96	30	77280	53	96
85	10	27	195776	36	0
86	10	14	180320	36	0
87	20	15	97888	36	0
111	173	19	66976	60	172
114	74	8	159712	61	74
115	100	10	133952	61	100
23	22	12	74189	18	21
81	30	25	159712	33	27
150	180	12	74189	70	180
151	180	13	87584	70	180
152	330	12	74189	71	330
153	330	13	87584	71	330
222	15	18	48944	102	15
208	25	4	66475	94	25
209	20	13	81901	94	20
223	13	19	66976	102	13
188	30	24	74189	86	30
185	88	19	57956	84	88
171	2	8	152457	80	2
224	1	7	77280	103	1
225	28	8	159712	103	28
175	50	8	121121	81	50
176	10	10	101585	81	10
226	31	11	178259	103	31
99	88	24	74189	54	65
56	263	24	74189	27	240
118	169	11	178259	61	129
95	330	12	74189	53	72
58	52	10	133952	28	39
44	30	11	178259	24	0
55	76	22	87584	27	69
69	97	27	195776	30	91
116	114	13	87584	61	31
40	30	12	74189	24	25
47	60	10	133952	26	55
48	249	12	74189	26	169
49	330	13	87584	26	230
76	254	22	87584	31	141
42	44	14	180320	24	40
77	141	29	87584	31	111
72	60	18	48944	31	0
78	118	24	74189	31	81
70	20	5	157239	30	1
71	70	11	178259	30	46
38	340	25	159712	24	0
39	40	10	133952	24	30
64	17	8	159712	30	17
65	84	10	133952	30	84
68	232	15	97888	30	232
66	158	12	74189	30	118
67	192	13	87584	30	102
63	236	25	159712	30	10
25	28	8	159712	20	0
117	149	5	157239	61	15
164	30	25	159712	77	30
181	176	18	35103	83	176
182	88	23	36581	83	88
183	88	24	53210	83	88
184	55	19	48038	83	55
165	28	7	60984	78	28
166	29	12	58545	78	29
167	21	13	69115	78	21
267	60	18	48944	114	60
268	20	28	87584	114	20
269	2	19	66976	114	2
270	108	22	87584	114	108
271	30	29	87584	114	30
272	61	24	74189	114	61
292	132	13	87584	131	132
53	90	28	87584	27	62
274	100	4	72128	116	100
172	8	5	150097	80	8
173	30	13	83603	80	30
174	20	12	70820	80	20
275	100	12	74189	117	100
276	30	18	53200	118	30
277	50	22	87584	119	50
186	28	18	35256	85	28
187	82	23	36740	85	82
189	5	33	309120	86	5
278	100	12	74189	120	100
279	120	4	72128	120	120
280	120	25	159712	120	120
190	94	8	159574	87	94
293	151	22	87584	132	151
210	25	8	126676	95	25
211	17	5	124714	95	17
212	17	11	141384	95	17
213	18	12	58841	95	18
214	18	13	69466	95	18
216	25	8	126674	97	25
217	17	5	124713	97	17
218	17	11	141385	97	17
168	500	25	154747	79	500
169	120	12	71884	79	120
170	165	13	84859	79	165
219	18	12	58842	97	18
220	18	13	69466	97	18
221	8	12	74189	98	8
227	5	12	74189	103	5
228	6	14	180320	103	6
229	50	23	51005	104	50
230	340	25	159712	106	340
231	10	10	133952	106	10
232	30	11	178259	106	30
233	5	12	74189	106	5
234	4	14	180320	106	4
235	110	25	159712	107	110
236	100	13	87584	107	100
237	359	12	74189	107	359
238	5	10	133952	107	5
177	176	18	48938	82	176
178	89	24	74182	82	89
179	90	19	66968	82	90
180	100	28	87579	82	100
193	250	25	149563	89	250
194	20	10	125441	89	20
242	33	24	74189	108	33
243	57	25	159712	109	57
244	15	4	71089	109	15
245	17	11	178259	109	17
199	25	8	126684	91	25
200	17	5	124724	91	17
201	17	11	141395	91	17
202	18	12	58846	91	18
203	18	13	69474	91	18
246	55	26	121587	109	55
247	76	12	74189	109	76
248	88	13	87584	109	88
249	5	18	48944	110	5
250	5	33	309120	110	5
251	2	20	61824	110	2
252	3	23	51005	110	3
254	8	20	61824	111	8
204	5	8	159642	93	5
205	3	7	77246	93	3
206	6	12	74157	93	6
207	6	13	87546	93	6
257	7	10	133952	112	7
258	10	31	334880	113	10
259	332	25	159712	113	332
260	1	10	133952	113	1
261	24	11	178259	113	24
262	19	5	157239	113	19
263	293	12	74189	113	293
264	198	13	87584	113	198
265	6	27	195776	113	6
266	22	15	97888	113	22
256	1	23	51005	111	0
295	176	28	87584	136	176
241	13	22	87584	108	2
255	15	22	87584	111	0
46	190	25	159712	26	0
239	14	33	309120	108	0
240	140	28	87584	108	10
253	3	19	66976	111	0
289	330	12	74189	128	330
291	110	24	74189	130	110
\.


--
-- Name: bonus_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.bonus_id_seq', 1538, true);


--
-- Name: bonus_payed_amounts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.bonus_payed_amounts_id_seq', 69, true);


--
-- Name: checking_balance_in_stock_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.checking_balance_in_stock_id_seq', 303, true);


--
-- Name: checking_stock_products_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.checking_stock_products_id_seq', 398, true);


--
-- Name: current_balance_in_stock_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.current_balance_in_stock_id_seq', 302, true);


--
-- Name: current_factory_warehouse_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.current_factory_warehouse_id_seq', 50, true);


--
-- Name: current_wholesale_warehouse_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.current_wholesale_warehouse_id_seq', 131, true);


--
-- Name: debt_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.debt_id_seq', 1, false);


--
-- Name: distance_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.distance_id_seq', 1, true);


--
-- Name: doctor_category_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.doctor_category_id_seq', 3, true);


--
-- Name: doctor_fact_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.doctor_fact_id_seq', 405, true);


--
-- Name: doctor_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.doctor_id_seq', 730, true);


--
-- Name: doctor_monthly_plan_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.doctor_monthly_plan_id_seq', 1633, true);


--
-- Name: doctor_plan_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.doctor_plan_id_seq', 378, true);


--
-- Name: doctor_postupleniya_fact_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.doctor_postupleniya_fact_id_seq', 314, true);


--
-- Name: doctor_visit_info_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.doctor_visit_info_id_seq', 12, true);


--
-- Name: editable_plan_months_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.editable_plan_months_id_seq', 12, true);


--
-- Name: expense_category_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.expense_category_id_seq', 1, false);


--
-- Name: expense_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.expense_id_seq', 1, false);


--
-- Name: hospital_bonus_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.hospital_bonus_id_seq', 4, true);


--
-- Name: hospital_fact_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.hospital_fact_id_seq', 18, true);


--
-- Name: hospital_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.hospital_id_seq', 22, true);


--
-- Name: hospital_monthly_plan_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.hospital_monthly_plan_id_seq', 38, true);


--
-- Name: hospital_postupleniya_fact_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.hospital_postupleniya_fact_id_seq', 1, false);


--
-- Name: hospital_reservation_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.hospital_reservation_id_seq', 34, true);


--
-- Name: hospital_reservation_payed_amounts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.hospital_reservation_payed_amounts_id_seq', 17, true);


--
-- Name: hospital_reservation_products_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.hospital_reservation_products_id_seq', 46, true);


--
-- Name: incoming_balance_in_stock_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.incoming_balance_in_stock_id_seq', 56, true);


--
-- Name: incoming_stock_products_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.incoming_stock_products_id_seq', 62, true);


--
-- Name: invoice_number_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.invoice_number_seq', 1327, true);


--
-- Name: manufactured_company_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.manufactured_company_id_seq', 6, true);


--
-- Name: medical_organization_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.medical_organization_id_seq', 240, true);


--
-- Name: notification_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.notification_id_seq', 12, true);


--
-- Name: pharmacy_fact_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pharmacy_fact_id_seq', 505, true);


--
-- Name: pharmacy_hot_sale_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pharmacy_hot_sale_id_seq', 77, true);


--
-- Name: pharmacy_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pharmacy_id_seq', 244, true);


--
-- Name: pharmacy_plan_attached_product_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pharmacy_plan_attached_product_id_seq', 1, false);


--
-- Name: pharmacy_plan_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pharmacy_plan_id_seq', 358, true);


--
-- Name: product_category_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.product_category_id_seq', 13, true);


--
-- Name: product_expenses_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.product_expenses_id_seq', 17, true);


--
-- Name: products_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.products_id_seq', 40, true);


--
-- Name: region_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.region_id_seq', 19, true);


--
-- Name: remainder_sum_from_reservation_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.remainder_sum_from_reservation_id_seq', 1, false);


--
-- Name: report_factory_warehouse_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.report_factory_warehouse_id_seq', 102, true);


--
-- Name: reservation_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.reservation_id_seq', 523, true);


--
-- Name: reservation_payed_amounts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.reservation_payed_amounts_id_seq', 372, true);


--
-- Name: reservation_products_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.reservation_products_id_seq', 659, true);


--
-- Name: speciality_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.speciality_id_seq', 23, true);


--
-- Name: user_login_monitoring_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_login_monitoring_id_seq', 308, true);


--
-- Name: user_product_plan_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_product_plan_id_seq', 981, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 118, true);


--
-- Name: wholesale_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.wholesale_id_seq', 16, true);


--
-- Name: wholesale_output_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.wholesale_output_id_seq', 1, true);


--
-- Name: wholesale_reservation_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.wholesale_reservation_id_seq', 136, true);


--
-- Name: wholesale_reservation_payed_amounts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.wholesale_reservation_payed_amounts_id_seq', 166, true);


--
-- Name: wholesale_reservation_products_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.wholesale_reservation_products_id_seq', 295, true);


--
-- Name: alembic_version alembic_version_pkc; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.alembic_version
    ADD CONSTRAINT alembic_version_pkc PRIMARY KEY (version_num);


--
-- Name: bonus_payed_amounts bonus_payed_amounts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bonus_payed_amounts
    ADD CONSTRAINT bonus_payed_amounts_pkey PRIMARY KEY (id);


--
-- Name: bonus bonus_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bonus
    ADD CONSTRAINT bonus_pkey PRIMARY KEY (id);


--
-- Name: checking_balance_in_stock checking_balance_in_stock_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.checking_balance_in_stock
    ADD CONSTRAINT checking_balance_in_stock_pkey PRIMARY KEY (id);


--
-- Name: checking_stock_products checking_stock_products_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.checking_stock_products
    ADD CONSTRAINT checking_stock_products_pkey PRIMARY KEY (id);


--
-- Name: current_balance_in_stock current_balance_in_stock_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.current_balance_in_stock
    ADD CONSTRAINT current_balance_in_stock_pkey PRIMARY KEY (id);


--
-- Name: current_factory_warehouse current_factory_warehouse_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.current_factory_warehouse
    ADD CONSTRAINT current_factory_warehouse_pkey PRIMARY KEY (id);


--
-- Name: current_wholesale_warehouse current_wholesale_warehouse_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.current_wholesale_warehouse
    ADD CONSTRAINT current_wholesale_warehouse_pkey PRIMARY KEY (id);


--
-- Name: debt debt_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.debt
    ADD CONSTRAINT debt_pkey PRIMARY KEY (id);


--
-- Name: distance distance_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.distance
    ADD CONSTRAINT distance_pkey PRIMARY KEY (id);


--
-- Name: doctor_category doctor_category_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.doctor_category
    ADD CONSTRAINT doctor_category_name_key UNIQUE (name);


--
-- Name: doctor_category doctor_category_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.doctor_category
    ADD CONSTRAINT doctor_category_pkey PRIMARY KEY (id);


--
-- Name: doctor_fact doctor_fact_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.doctor_fact
    ADD CONSTRAINT doctor_fact_pkey PRIMARY KEY (id);


--
-- Name: doctor_monthly_plan doctor_monthly_plan_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.doctor_monthly_plan
    ADD CONSTRAINT doctor_monthly_plan_pkey PRIMARY KEY (id);


--
-- Name: doctor doctor_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.doctor
    ADD CONSTRAINT doctor_pkey PRIMARY KEY (id);


--
-- Name: doctor_plan doctor_plan_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.doctor_plan
    ADD CONSTRAINT doctor_plan_pkey PRIMARY KEY (id);


--
-- Name: doctor_postupleniya_fact doctor_postupleniya_fact_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.doctor_postupleniya_fact
    ADD CONSTRAINT doctor_postupleniya_fact_pkey PRIMARY KEY (id);


--
-- Name: doctor_visit_info doctor_visit_info_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.doctor_visit_info
    ADD CONSTRAINT doctor_visit_info_pkey PRIMARY KEY (id);


--
-- Name: editable_plan_months editable_plan_months_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.editable_plan_months
    ADD CONSTRAINT editable_plan_months_pkey PRIMARY KEY (id);


--
-- Name: expense_category expense_category_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.expense_category
    ADD CONSTRAINT expense_category_name_key UNIQUE (name);


--
-- Name: expense_category expense_category_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.expense_category
    ADD CONSTRAINT expense_category_pkey PRIMARY KEY (id);


--
-- Name: expense expense_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.expense
    ADD CONSTRAINT expense_pkey PRIMARY KEY (id);


--
-- Name: hospital_bonus hospital_bonus_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hospital_bonus
    ADD CONSTRAINT hospital_bonus_pkey PRIMARY KEY (id);


--
-- Name: hospital_fact hospital_fact_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hospital_fact
    ADD CONSTRAINT hospital_fact_pkey PRIMARY KEY (id);


--
-- Name: hospital_monthly_plan hospital_monthly_plan_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hospital_monthly_plan
    ADD CONSTRAINT hospital_monthly_plan_pkey PRIMARY KEY (id);


--
-- Name: hospital hospital_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hospital
    ADD CONSTRAINT hospital_pkey PRIMARY KEY (id);


--
-- Name: hospital_postupleniya_fact hospital_postupleniya_fact_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hospital_postupleniya_fact
    ADD CONSTRAINT hospital_postupleniya_fact_pkey PRIMARY KEY (id);


--
-- Name: hospital_reservation hospital_reservation_invoice_number_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hospital_reservation
    ADD CONSTRAINT hospital_reservation_invoice_number_key UNIQUE (invoice_number);


--
-- Name: hospital_reservation_payed_amounts hospital_reservation_payed_amounts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hospital_reservation_payed_amounts
    ADD CONSTRAINT hospital_reservation_payed_amounts_pkey PRIMARY KEY (id);


--
-- Name: hospital_reservation hospital_reservation_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hospital_reservation
    ADD CONSTRAINT hospital_reservation_pkey PRIMARY KEY (id);


--
-- Name: hospital_reservation_products hospital_reservation_products_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hospital_reservation_products
    ADD CONSTRAINT hospital_reservation_products_pkey PRIMARY KEY (id);


--
-- Name: incoming_balance_in_stock incoming_balance_in_stock_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.incoming_balance_in_stock
    ADD CONSTRAINT incoming_balance_in_stock_pkey PRIMARY KEY (id);


--
-- Name: incoming_stock_products incoming_stock_products_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.incoming_stock_products
    ADD CONSTRAINT incoming_stock_products_pkey PRIMARY KEY (id);


--
-- Name: manufactured_company manufactured_company_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.manufactured_company
    ADD CONSTRAINT manufactured_company_name_key UNIQUE (name);


--
-- Name: manufactured_company manufactured_company_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.manufactured_company
    ADD CONSTRAINT manufactured_company_pkey PRIMARY KEY (id);


--
-- Name: medical_organization medical_organization_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.medical_organization
    ADD CONSTRAINT medical_organization_name_key UNIQUE (name);


--
-- Name: medical_organization medical_organization_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.medical_organization
    ADD CONSTRAINT medical_organization_pkey PRIMARY KEY (id);


--
-- Name: notification notification_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notification
    ADD CONSTRAINT notification_pkey PRIMARY KEY (id);


--
-- Name: pharmacy_doctor pharmacy_doctor_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pharmacy_doctor
    ADD CONSTRAINT pharmacy_doctor_pkey PRIMARY KEY (doctor_id, pharmacy_id);


--
-- Name: pharmacy_fact pharmacy_fact_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pharmacy_fact
    ADD CONSTRAINT pharmacy_fact_pkey PRIMARY KEY (id);


--
-- Name: pharmacy_hot_sale pharmacy_hot_sale_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pharmacy_hot_sale
    ADD CONSTRAINT pharmacy_hot_sale_pkey PRIMARY KEY (id);


--
-- Name: pharmacy pharmacy_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pharmacy
    ADD CONSTRAINT pharmacy_pkey PRIMARY KEY (id);


--
-- Name: pharmacy_plan_attached_product pharmacy_plan_attached_product_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pharmacy_plan_attached_product
    ADD CONSTRAINT pharmacy_plan_attached_product_pkey PRIMARY KEY (id);


--
-- Name: pharmacy_plan pharmacy_plan_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pharmacy_plan
    ADD CONSTRAINT pharmacy_plan_pkey PRIMARY KEY (id);


--
-- Name: product_category product_category_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_category
    ADD CONSTRAINT product_category_name_key UNIQUE (name);


--
-- Name: product_category product_category_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_category
    ADD CONSTRAINT product_category_pkey PRIMARY KEY (id);


--
-- Name: product_expenses product_expenses_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_expenses
    ADD CONSTRAINT product_expenses_pkey PRIMARY KEY (id);


--
-- Name: products products_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_name_key UNIQUE (name);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- Name: region region_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.region
    ADD CONSTRAINT region_name_key UNIQUE (name);


--
-- Name: region region_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.region
    ADD CONSTRAINT region_pkey PRIMARY KEY (id);


--
-- Name: remainder_sum_from_reservation remainder_sum_from_reservation_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.remainder_sum_from_reservation
    ADD CONSTRAINT remainder_sum_from_reservation_pkey PRIMARY KEY (id);


--
-- Name: report_factory_warehouse report_factory_warehouse_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.report_factory_warehouse
    ADD CONSTRAINT report_factory_warehouse_pkey PRIMARY KEY (id);


--
-- Name: reservation reservation_invoice_number_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reservation
    ADD CONSTRAINT reservation_invoice_number_key UNIQUE (invoice_number);


--
-- Name: reservation_payed_amounts reservation_payed_amounts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reservation_payed_amounts
    ADD CONSTRAINT reservation_payed_amounts_pkey PRIMARY KEY (id);


--
-- Name: reservation reservation_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reservation
    ADD CONSTRAINT reservation_pkey PRIMARY KEY (id);


--
-- Name: reservation_products reservation_products_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reservation_products
    ADD CONSTRAINT reservation_products_pkey PRIMARY KEY (id);


--
-- Name: speciality speciality_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.speciality
    ADD CONSTRAINT speciality_name_key UNIQUE (name);


--
-- Name: speciality speciality_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.speciality
    ADD CONSTRAINT speciality_pkey PRIMARY KEY (id);


--
-- Name: user_login_monitoring user_login_monitoring_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_login_monitoring
    ADD CONSTRAINT user_login_monitoring_pkey PRIMARY KEY (id);


--
-- Name: user_product_plan user_product_plan_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_product_plan
    ADD CONSTRAINT user_product_plan_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: users users_username_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- Name: wholesale_output wholesale_output_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wholesale_output
    ADD CONSTRAINT wholesale_output_pkey PRIMARY KEY (id);


--
-- Name: wholesale wholesale_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wholesale
    ADD CONSTRAINT wholesale_pkey PRIMARY KEY (id);


--
-- Name: wholesale_reservation wholesale_reservation_invoice_number_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wholesale_reservation
    ADD CONSTRAINT wholesale_reservation_invoice_number_key UNIQUE (invoice_number);


--
-- Name: wholesale_reservation_payed_amounts wholesale_reservation_payed_amounts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wholesale_reservation_payed_amounts
    ADD CONSTRAINT wholesale_reservation_payed_amounts_pkey PRIMARY KEY (id);


--
-- Name: wholesale_reservation wholesale_reservation_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wholesale_reservation
    ADD CONSTRAINT wholesale_reservation_pkey PRIMARY KEY (id);


--
-- Name: wholesale_reservation_products wholesale_reservation_products_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wholesale_reservation_products
    ADD CONSTRAINT wholesale_reservation_products_pkey PRIMARY KEY (id);


--
-- Name: bonus bonus_doctor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bonus
    ADD CONSTRAINT bonus_doctor_id_fkey FOREIGN KEY (doctor_id) REFERENCES public.doctor(id) ON DELETE CASCADE;


--
-- Name: bonus_payed_amounts bonus_payed_amounts_bonus_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bonus_payed_amounts
    ADD CONSTRAINT bonus_payed_amounts_bonus_id_fkey FOREIGN KEY (bonus_id) REFERENCES public.bonus(id) ON DELETE CASCADE;


--
-- Name: bonus bonus_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bonus
    ADD CONSTRAINT bonus_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- Name: checking_balance_in_stock checking_balance_in_stock_pharmacy_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.checking_balance_in_stock
    ADD CONSTRAINT checking_balance_in_stock_pharmacy_id_fkey FOREIGN KEY (pharmacy_id) REFERENCES public.pharmacy(id) ON DELETE CASCADE;


--
-- Name: checking_stock_products checking_stock_products_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.checking_stock_products
    ADD CONSTRAINT checking_stock_products_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- Name: checking_stock_products checking_stock_products_stock_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.checking_stock_products
    ADD CONSTRAINT checking_stock_products_stock_id_fkey FOREIGN KEY (stock_id) REFERENCES public.checking_balance_in_stock(id) ON DELETE CASCADE;


--
-- Name: current_balance_in_stock current_balance_in_stock_pharmacy_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.current_balance_in_stock
    ADD CONSTRAINT current_balance_in_stock_pharmacy_id_fkey FOREIGN KEY (pharmacy_id) REFERENCES public.pharmacy(id) ON DELETE CASCADE;


--
-- Name: current_balance_in_stock current_balance_in_stock_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.current_balance_in_stock
    ADD CONSTRAINT current_balance_in_stock_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- Name: current_factory_warehouse current_factory_warehouse_factory_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.current_factory_warehouse
    ADD CONSTRAINT current_factory_warehouse_factory_id_fkey FOREIGN KEY (factory_id) REFERENCES public.manufactured_company(id);


--
-- Name: current_factory_warehouse current_factory_warehouse_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.current_factory_warehouse
    ADD CONSTRAINT current_factory_warehouse_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- Name: current_wholesale_warehouse current_wholesale_warehouse_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.current_wholesale_warehouse
    ADD CONSTRAINT current_wholesale_warehouse_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- Name: current_wholesale_warehouse current_wholesale_warehouse_wholesale_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.current_wholesale_warehouse
    ADD CONSTRAINT current_wholesale_warehouse_wholesale_id_fkey FOREIGN KEY (wholesale_id) REFERENCES public.wholesale(id) ON DELETE CASCADE;


--
-- Name: debt debt_pharmacy_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.debt
    ADD CONSTRAINT debt_pharmacy_id_fkey FOREIGN KEY (pharmacy_id) REFERENCES public.pharmacy(id) ON DELETE CASCADE;


--
-- Name: doctor doctor_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.doctor
    ADD CONSTRAINT doctor_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.doctor_category(id);


--
-- Name: doctor doctor_deputy_director_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.doctor
    ADD CONSTRAINT doctor_deputy_director_id_fkey FOREIGN KEY (deputy_director_id) REFERENCES public.users(id);


--
-- Name: doctor doctor_director_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.doctor
    ADD CONSTRAINT doctor_director_id_fkey FOREIGN KEY (director_id) REFERENCES public.users(id);


--
-- Name: doctor_fact doctor_fact_doctor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.doctor_fact
    ADD CONSTRAINT doctor_fact_doctor_id_fkey FOREIGN KEY (doctor_id) REFERENCES public.doctor(id) ON DELETE CASCADE;


--
-- Name: doctor_fact doctor_fact_pharmacy_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.doctor_fact
    ADD CONSTRAINT doctor_fact_pharmacy_id_fkey FOREIGN KEY (pharmacy_id) REFERENCES public.pharmacy(id);


--
-- Name: doctor_fact doctor_fact_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.doctor_fact
    ADD CONSTRAINT doctor_fact_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- Name: doctor doctor_ffm_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.doctor
    ADD CONSTRAINT doctor_ffm_id_fkey FOREIGN KEY (ffm_id) REFERENCES public.users(id);


--
-- Name: doctor doctor_med_rep_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.doctor
    ADD CONSTRAINT doctor_med_rep_id_fkey FOREIGN KEY (med_rep_id) REFERENCES public.users(id);


--
-- Name: doctor doctor_medical_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.doctor
    ADD CONSTRAINT doctor_medical_organization_id_fkey FOREIGN KEY (medical_organization_id) REFERENCES public.medical_organization(id);


--
-- Name: doctor_monthly_plan doctor_monthly_plan_doctor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.doctor_monthly_plan
    ADD CONSTRAINT doctor_monthly_plan_doctor_id_fkey FOREIGN KEY (doctor_id) REFERENCES public.doctor(id) ON DELETE CASCADE;


--
-- Name: doctor_monthly_plan doctor_monthly_plan_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.doctor_monthly_plan
    ADD CONSTRAINT doctor_monthly_plan_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- Name: doctor_plan doctor_plan_doctor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.doctor_plan
    ADD CONSTRAINT doctor_plan_doctor_id_fkey FOREIGN KEY (doctor_id) REFERENCES public.doctor(id) ON DELETE CASCADE;


--
-- Name: doctor_plan doctor_plan_med_rep_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.doctor_plan
    ADD CONSTRAINT doctor_plan_med_rep_id_fkey FOREIGN KEY (med_rep_id) REFERENCES public.users(id);


--
-- Name: doctor_postupleniya_fact doctor_postupleniya_fact_doctor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.doctor_postupleniya_fact
    ADD CONSTRAINT doctor_postupleniya_fact_doctor_id_fkey FOREIGN KEY (doctor_id) REFERENCES public.doctor(id) ON DELETE CASCADE;


--
-- Name: doctor_postupleniya_fact doctor_postupleniya_fact_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.doctor_postupleniya_fact
    ADD CONSTRAINT doctor_postupleniya_fact_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- Name: doctor doctor_product_manager_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.doctor
    ADD CONSTRAINT doctor_product_manager_id_fkey FOREIGN KEY (product_manager_id) REFERENCES public.users(id);


--
-- Name: doctor doctor_region_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.doctor
    ADD CONSTRAINT doctor_region_id_fkey FOREIGN KEY (region_id) REFERENCES public.region(id);


--
-- Name: doctor doctor_region_manager_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.doctor
    ADD CONSTRAINT doctor_region_manager_id_fkey FOREIGN KEY (region_manager_id) REFERENCES public.users(id);


--
-- Name: doctor doctor_speciality_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.doctor
    ADD CONSTRAINT doctor_speciality_id_fkey FOREIGN KEY (speciality_id) REFERENCES public.speciality(id);


--
-- Name: doctor_visit_info doctor_visit_info_doctor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.doctor_visit_info
    ADD CONSTRAINT doctor_visit_info_doctor_id_fkey FOREIGN KEY (doctor_id) REFERENCES public.doctor(id) ON DELETE CASCADE;


--
-- Name: doctor_visit_info doctor_visit_info_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.doctor_visit_info
    ADD CONSTRAINT doctor_visit_info_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- Name: expense expense_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.expense
    ADD CONSTRAINT expense_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.expense_category(id);


--
-- Name: hospital_bonus hospital_bonus_hospital_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hospital_bonus
    ADD CONSTRAINT hospital_bonus_hospital_id_fkey FOREIGN KEY (hospital_id) REFERENCES public.hospital(id) ON DELETE CASCADE;


--
-- Name: hospital_bonus hospital_bonus_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hospital_bonus
    ADD CONSTRAINT hospital_bonus_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- Name: hospital_fact hospital_fact_hospital_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hospital_fact
    ADD CONSTRAINT hospital_fact_hospital_id_fkey FOREIGN KEY (hospital_id) REFERENCES public.hospital(id) ON DELETE CASCADE;


--
-- Name: hospital_fact hospital_fact_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hospital_fact
    ADD CONSTRAINT hospital_fact_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- Name: hospital hospital_med_rep_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hospital
    ADD CONSTRAINT hospital_med_rep_id_fkey FOREIGN KEY (med_rep_id) REFERENCES public.users(id);


--
-- Name: hospital_monthly_plan hospital_monthly_plan_hospital_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hospital_monthly_plan
    ADD CONSTRAINT hospital_monthly_plan_hospital_id_fkey FOREIGN KEY (hospital_id) REFERENCES public.hospital(id) ON DELETE CASCADE;


--
-- Name: hospital_monthly_plan hospital_monthly_plan_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hospital_monthly_plan
    ADD CONSTRAINT hospital_monthly_plan_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- Name: hospital_postupleniya_fact hospital_postupleniya_fact_hospital_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hospital_postupleniya_fact
    ADD CONSTRAINT hospital_postupleniya_fact_hospital_id_fkey FOREIGN KEY (hospital_id) REFERENCES public.hospital(id) ON DELETE CASCADE;


--
-- Name: hospital_postupleniya_fact hospital_postupleniya_fact_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hospital_postupleniya_fact
    ADD CONSTRAINT hospital_postupleniya_fact_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- Name: hospital hospital_region_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hospital
    ADD CONSTRAINT hospital_region_id_fkey FOREIGN KEY (region_id) REFERENCES public.region(id);


--
-- Name: hospital_reservation hospital_reservation_hospital_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hospital_reservation
    ADD CONSTRAINT hospital_reservation_hospital_id_fkey FOREIGN KEY (hospital_id) REFERENCES public.hospital(id) ON DELETE CASCADE;


--
-- Name: hospital_reservation hospital_reservation_manufactured_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hospital_reservation
    ADD CONSTRAINT hospital_reservation_manufactured_company_id_fkey FOREIGN KEY (manufactured_company_id) REFERENCES public.manufactured_company(id);


--
-- Name: hospital_reservation hospital_reservation_med_rep_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hospital_reservation
    ADD CONSTRAINT hospital_reservation_med_rep_id_fkey FOREIGN KEY (med_rep_id) REFERENCES public.users(id);


--
-- Name: hospital_reservation_payed_amounts hospital_reservation_payed_amounts_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hospital_reservation_payed_amounts
    ADD CONSTRAINT hospital_reservation_payed_amounts_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE;


--
-- Name: hospital_reservation_payed_amounts hospital_reservation_payed_amounts_reservation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hospital_reservation_payed_amounts
    ADD CONSTRAINT hospital_reservation_payed_amounts_reservation_id_fkey FOREIGN KEY (reservation_id) REFERENCES public.hospital_reservation(id) ON DELETE CASCADE;


--
-- Name: hospital_reservation_products hospital_reservation_products_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hospital_reservation_products
    ADD CONSTRAINT hospital_reservation_products_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- Name: hospital_reservation_products hospital_reservation_products_reservation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hospital_reservation_products
    ADD CONSTRAINT hospital_reservation_products_reservation_id_fkey FOREIGN KEY (reservation_id) REFERENCES public.hospital_reservation(id) ON DELETE CASCADE;


--
-- Name: incoming_balance_in_stock incoming_balance_in_stock_factory_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.incoming_balance_in_stock
    ADD CONSTRAINT incoming_balance_in_stock_factory_id_fkey FOREIGN KEY (factory_id) REFERENCES public.manufactured_company(id);


--
-- Name: incoming_balance_in_stock incoming_balance_in_stock_pharmacy_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.incoming_balance_in_stock
    ADD CONSTRAINT incoming_balance_in_stock_pharmacy_id_fkey FOREIGN KEY (pharmacy_id) REFERENCES public.pharmacy(id) ON DELETE CASCADE;


--
-- Name: incoming_balance_in_stock incoming_balance_in_stock_wholesale_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.incoming_balance_in_stock
    ADD CONSTRAINT incoming_balance_in_stock_wholesale_id_fkey FOREIGN KEY (wholesale_id) REFERENCES public.wholesale(id);


--
-- Name: incoming_stock_products incoming_stock_products_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.incoming_stock_products
    ADD CONSTRAINT incoming_stock_products_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- Name: incoming_stock_products incoming_stock_products_stock_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.incoming_stock_products
    ADD CONSTRAINT incoming_stock_products_stock_id_fkey FOREIGN KEY (stock_id) REFERENCES public.incoming_balance_in_stock(id) ON DELETE CASCADE;


--
-- Name: medical_organization medical_organization_region_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.medical_organization
    ADD CONSTRAINT medical_organization_region_id_fkey FOREIGN KEY (region_id) REFERENCES public.region(id);


--
-- Name: notification notification_doctor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notification
    ADD CONSTRAINT notification_doctor_id_fkey FOREIGN KEY (doctor_id) REFERENCES public.doctor(id) ON DELETE CASCADE;


--
-- Name: notification notification_med_rep_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notification
    ADD CONSTRAINT notification_med_rep_id_fkey FOREIGN KEY (med_rep_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: notification notification_pharmacy_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notification
    ADD CONSTRAINT notification_pharmacy_id_fkey FOREIGN KEY (pharmacy_id) REFERENCES public.pharmacy(id) ON DELETE CASCADE;


--
-- Name: notification notification_region_manager_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notification
    ADD CONSTRAINT notification_region_manager_id_fkey FOREIGN KEY (region_manager_id) REFERENCES public.users(id);


--
-- Name: notification notification_wholesale_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notification
    ADD CONSTRAINT notification_wholesale_id_fkey FOREIGN KEY (wholesale_id) REFERENCES public.wholesale(id) ON DELETE CASCADE;


--
-- Name: pharmacy pharmacy_deputy_director_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pharmacy
    ADD CONSTRAINT pharmacy_deputy_director_id_fkey FOREIGN KEY (deputy_director_id) REFERENCES public.users(id);


--
-- Name: pharmacy pharmacy_director_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pharmacy
    ADD CONSTRAINT pharmacy_director_id_fkey FOREIGN KEY (director_id) REFERENCES public.users(id);


--
-- Name: pharmacy_doctor pharmacy_doctor_doctor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pharmacy_doctor
    ADD CONSTRAINT pharmacy_doctor_doctor_id_fkey FOREIGN KEY (doctor_id) REFERENCES public.doctor(id) ON DELETE CASCADE;


--
-- Name: pharmacy_doctor pharmacy_doctor_pharmacy_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pharmacy_doctor
    ADD CONSTRAINT pharmacy_doctor_pharmacy_id_fkey FOREIGN KEY (pharmacy_id) REFERENCES public.pharmacy(id) ON DELETE CASCADE;


--
-- Name: pharmacy_fact pharmacy_fact_doctor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pharmacy_fact
    ADD CONSTRAINT pharmacy_fact_doctor_id_fkey FOREIGN KEY (doctor_id) REFERENCES public.doctor(id) ON DELETE CASCADE;


--
-- Name: pharmacy_fact pharmacy_fact_pharmacy_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pharmacy_fact
    ADD CONSTRAINT pharmacy_fact_pharmacy_id_fkey FOREIGN KEY (pharmacy_id) REFERENCES public.pharmacy(id) ON DELETE CASCADE;


--
-- Name: pharmacy_fact pharmacy_fact_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pharmacy_fact
    ADD CONSTRAINT pharmacy_fact_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- Name: pharmacy pharmacy_ffm_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pharmacy
    ADD CONSTRAINT pharmacy_ffm_id_fkey FOREIGN KEY (ffm_id) REFERENCES public.users(id);


--
-- Name: pharmacy_hot_sale pharmacy_hot_sale_pharmacy_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pharmacy_hot_sale
    ADD CONSTRAINT pharmacy_hot_sale_pharmacy_id_fkey FOREIGN KEY (pharmacy_id) REFERENCES public.pharmacy(id) ON DELETE CASCADE;


--
-- Name: pharmacy_hot_sale pharmacy_hot_sale_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pharmacy_hot_sale
    ADD CONSTRAINT pharmacy_hot_sale_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- Name: pharmacy pharmacy_med_rep_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pharmacy
    ADD CONSTRAINT pharmacy_med_rep_id_fkey FOREIGN KEY (med_rep_id) REFERENCES public.users(id);


--
-- Name: pharmacy_plan_attached_product pharmacy_plan_attached_product_plan_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pharmacy_plan_attached_product
    ADD CONSTRAINT pharmacy_plan_attached_product_plan_id_fkey FOREIGN KEY (plan_id) REFERENCES public.pharmacy_plan(id) ON DELETE CASCADE;


--
-- Name: pharmacy_plan pharmacy_plan_med_rep_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pharmacy_plan
    ADD CONSTRAINT pharmacy_plan_med_rep_id_fkey FOREIGN KEY (med_rep_id) REFERENCES public.users(id);


--
-- Name: pharmacy_plan pharmacy_plan_pharmacy_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pharmacy_plan
    ADD CONSTRAINT pharmacy_plan_pharmacy_id_fkey FOREIGN KEY (pharmacy_id) REFERENCES public.pharmacy(id) ON DELETE CASCADE;


--
-- Name: pharmacy pharmacy_product_manager_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pharmacy
    ADD CONSTRAINT pharmacy_product_manager_id_fkey FOREIGN KEY (product_manager_id) REFERENCES public.users(id);


--
-- Name: pharmacy pharmacy_region_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pharmacy
    ADD CONSTRAINT pharmacy_region_id_fkey FOREIGN KEY (region_id) REFERENCES public.region(id);


--
-- Name: pharmacy pharmacy_region_manager_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pharmacy
    ADD CONSTRAINT pharmacy_region_manager_id_fkey FOREIGN KEY (region_manager_id) REFERENCES public.users(id);


--
-- Name: product_expenses product_expenses_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_expenses
    ADD CONSTRAINT product_expenses_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- Name: products products_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.product_category(id);


--
-- Name: products products_man_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_man_company_id_fkey FOREIGN KEY (man_company_id) REFERENCES public.manufactured_company(id);


--
-- Name: remainder_sum_from_reservation remainder_sum_from_reservation_pharmacy_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.remainder_sum_from_reservation
    ADD CONSTRAINT remainder_sum_from_reservation_pharmacy_id_fkey FOREIGN KEY (pharmacy_id) REFERENCES public.pharmacy(id) ON DELETE CASCADE;


--
-- Name: remainder_sum_from_reservation remainder_sum_from_reservation_wholesale_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.remainder_sum_from_reservation
    ADD CONSTRAINT remainder_sum_from_reservation_wholesale_id_fkey FOREIGN KEY (wholesale_id) REFERENCES public.wholesale(id);


--
-- Name: report_factory_warehouse report_factory_warehouse_factory_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.report_factory_warehouse
    ADD CONSTRAINT report_factory_warehouse_factory_id_fkey FOREIGN KEY (factory_id) REFERENCES public.manufactured_company(id);


--
-- Name: report_factory_warehouse report_factory_warehouse_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.report_factory_warehouse
    ADD CONSTRAINT report_factory_warehouse_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- Name: reservation reservation_manufactured_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reservation
    ADD CONSTRAINT reservation_manufactured_company_id_fkey FOREIGN KEY (manufactured_company_id) REFERENCES public.manufactured_company(id);


--
-- Name: reservation reservation_med_rep_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reservation
    ADD CONSTRAINT reservation_med_rep_id_fkey FOREIGN KEY (med_rep_id) REFERENCES public.users(id);


--
-- Name: reservation_payed_amounts reservation_payed_amounts_doctor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reservation_payed_amounts
    ADD CONSTRAINT reservation_payed_amounts_doctor_id_fkey FOREIGN KEY (doctor_id) REFERENCES public.doctor(id) ON DELETE CASCADE;


--
-- Name: reservation_payed_amounts reservation_payed_amounts_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reservation_payed_amounts
    ADD CONSTRAINT reservation_payed_amounts_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE;


--
-- Name: reservation_payed_amounts reservation_payed_amounts_reservation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reservation_payed_amounts
    ADD CONSTRAINT reservation_payed_amounts_reservation_id_fkey FOREIGN KEY (reservation_id) REFERENCES public.reservation(id) ON DELETE CASCADE;


--
-- Name: reservation reservation_pharmacy_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reservation
    ADD CONSTRAINT reservation_pharmacy_id_fkey FOREIGN KEY (pharmacy_id) REFERENCES public.pharmacy(id) ON DELETE CASCADE;


--
-- Name: reservation_products reservation_products_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reservation_products
    ADD CONSTRAINT reservation_products_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- Name: reservation_products reservation_products_reservation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reservation_products
    ADD CONSTRAINT reservation_products_reservation_id_fkey FOREIGN KEY (reservation_id) REFERENCES public.reservation(id) ON DELETE CASCADE;


--
-- Name: user_login_monitoring user_login_monitoring_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_login_monitoring
    ADD CONSTRAINT user_login_monitoring_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: user_product_plan user_product_plan_med_rep_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_product_plan
    ADD CONSTRAINT user_product_plan_med_rep_id_fkey FOREIGN KEY (med_rep_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: user_product_plan user_product_plan_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_product_plan
    ADD CONSTRAINT user_product_plan_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- Name: users users_deputy_director_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_deputy_director_id_fkey FOREIGN KEY (deputy_director_id) REFERENCES public.users(id);


--
-- Name: users users_director_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_director_id_fkey FOREIGN KEY (director_id) REFERENCES public.users(id);


--
-- Name: users users_ffm_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_ffm_id_fkey FOREIGN KEY (ffm_id) REFERENCES public.users(id);


--
-- Name: users users_product_manager_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_product_manager_id_fkey FOREIGN KEY (product_manager_id) REFERENCES public.users(id);


--
-- Name: users users_region_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_region_id_fkey FOREIGN KEY (region_id) REFERENCES public.region(id);


--
-- Name: users users_region_manager_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_region_manager_id_fkey FOREIGN KEY (region_manager_id) REFERENCES public.users(id);


--
-- Name: wholesale_output wholesale_output_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wholesale_output
    ADD CONSTRAINT wholesale_output_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- Name: wholesale_output wholesale_output_wholesale_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wholesale_output
    ADD CONSTRAINT wholesale_output_wholesale_id_fkey FOREIGN KEY (wholesale_id) REFERENCES public.wholesale(id);


--
-- Name: wholesale wholesale_region_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wholesale
    ADD CONSTRAINT wholesale_region_id_fkey FOREIGN KEY (region_id) REFERENCES public.region(id);


--
-- Name: wholesale_reservation wholesale_reservation_manufactured_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wholesale_reservation
    ADD CONSTRAINT wholesale_reservation_manufactured_company_id_fkey FOREIGN KEY (manufactured_company_id) REFERENCES public.manufactured_company(id);


--
-- Name: wholesale_reservation wholesale_reservation_med_rep_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wholesale_reservation
    ADD CONSTRAINT wholesale_reservation_med_rep_id_fkey FOREIGN KEY (med_rep_id) REFERENCES public.users(id);


--
-- Name: wholesale_reservation_payed_amounts wholesale_reservation_payed_amounts_doctor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wholesale_reservation_payed_amounts
    ADD CONSTRAINT wholesale_reservation_payed_amounts_doctor_id_fkey FOREIGN KEY (doctor_id) REFERENCES public.doctor(id) ON DELETE CASCADE;


--
-- Name: wholesale_reservation_payed_amounts wholesale_reservation_payed_amounts_med_rep_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wholesale_reservation_payed_amounts
    ADD CONSTRAINT wholesale_reservation_payed_amounts_med_rep_id_fkey FOREIGN KEY (med_rep_id) REFERENCES public.users(id);


--
-- Name: wholesale_reservation_payed_amounts wholesale_reservation_payed_amounts_pharmacy_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wholesale_reservation_payed_amounts
    ADD CONSTRAINT wholesale_reservation_payed_amounts_pharmacy_id_fkey FOREIGN KEY (pharmacy_id) REFERENCES public.pharmacy(id) ON DELETE CASCADE;


--
-- Name: wholesale_reservation_payed_amounts wholesale_reservation_payed_amounts_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wholesale_reservation_payed_amounts
    ADD CONSTRAINT wholesale_reservation_payed_amounts_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE;


--
-- Name: wholesale_reservation_payed_amounts wholesale_reservation_payed_amounts_reservation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wholesale_reservation_payed_amounts
    ADD CONSTRAINT wholesale_reservation_payed_amounts_reservation_id_fkey FOREIGN KEY (reservation_id) REFERENCES public.wholesale_reservation(id) ON DELETE CASCADE;


--
-- Name: wholesale_reservation_products wholesale_reservation_products_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wholesale_reservation_products
    ADD CONSTRAINT wholesale_reservation_products_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- Name: wholesale_reservation_products wholesale_reservation_products_reservation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wholesale_reservation_products
    ADD CONSTRAINT wholesale_reservation_products_reservation_id_fkey FOREIGN KEY (reservation_id) REFERENCES public.wholesale_reservation(id) ON DELETE CASCADE;


--
-- Name: wholesale_reservation wholesale_reservation_wholesale_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wholesale_reservation
    ADD CONSTRAINT wholesale_reservation_wholesale_id_fkey FOREIGN KEY (wholesale_id) REFERENCES public.wholesale(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

