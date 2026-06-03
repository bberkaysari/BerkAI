--
-- PostgreSQL database dump
--

-- Dumped from database version 17.4
-- Dumped by pg_dump version 17.4

-- Started on 2026-01-06 21:06:19 +03

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 222 (class 1259 OID 24629)
-- Name: Addresses; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Addresses" (
    "Id" uuid NOT NULL,
    "FirstName" character varying(100) NOT NULL,
    "LastName" character varying(100) NOT NULL,
    "PhoneNumber" character varying(20) NOT NULL,
    "AddressLine1" character varying(255) NOT NULL,
    "AddressLine2" character varying(255),
    "City" character varying(100) NOT NULL,
    "State" character varying(100) NOT NULL,
    "Country" character varying(100) NOT NULL,
    "ZipCode" character varying(20) NOT NULL,
    "IsDefault" boolean NOT NULL,
    "UserId" uuid NOT NULL,
    "CreatedAt" timestamp with time zone NOT NULL,
    "UpdatedAt" timestamp with time zone,
    "IsDeleted" boolean NOT NULL
);


ALTER TABLE public."Addresses" OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 24784)
-- Name: Admins; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Admins" (
    "Id" uuid NOT NULL,
    "Username" text NOT NULL,
    "PasswordHash" text NOT NULL,
    "Email" text NOT NULL,
    "LastLoginAt" timestamp with time zone,
    "CreatedAt" timestamp with time zone NOT NULL,
    "UpdatedAt" timestamp with time zone,
    "IsDeleted" boolean NOT NULL
);


ALTER TABLE public."Admins" OWNER TO postgres;

--
-- TOC entry 218 (class 1259 OID 24586)
-- Name: Brands; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Brands" (
    "Id" uuid NOT NULL,
    "Name" character varying(100) NOT NULL,
    "Slug" character varying(150) NOT NULL,
    "Description" character varying(500),
    "LogoUrl" character varying(500),
    "WebsiteUrl" character varying(255),
    "CreatedAt" timestamp with time zone NOT NULL,
    "UpdatedAt" timestamp with time zone,
    "IsDeleted" boolean NOT NULL
);


ALTER TABLE public."Brands" OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 24712)
-- Name: CartItems; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."CartItems" (
    "Id" uuid NOT NULL,
    "Quantity" integer NOT NULL,
    "CartId" uuid NOT NULL,
    "ProductId" uuid NOT NULL,
    "ProductVariantId" uuid,
    "CreatedAt" timestamp with time zone NOT NULL,
    "UpdatedAt" timestamp with time zone,
    "IsDeleted" boolean NOT NULL
);


ALTER TABLE public."CartItems" OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 24641)
-- Name: Carts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Carts" (
    "Id" uuid NOT NULL,
    "UserId" uuid NOT NULL,
    "CreatedAt" timestamp with time zone NOT NULL,
    "UpdatedAt" timestamp with time zone,
    "IsDeleted" boolean NOT NULL
);


ALTER TABLE public."Carts" OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 24593)
-- Name: Categories; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Categories" (
    "Id" uuid NOT NULL,
    "Name" character varying(100) NOT NULL,
    "Slug" character varying(150) NOT NULL,
    "Description" character varying(500),
    "ImageUrl" character varying(500),
    "Gender" integer NOT NULL,
    "ParentCategoryId" uuid,
    "CreatedAt" timestamp with time zone NOT NULL,
    "UpdatedAt" timestamp with time zone,
    "IsDeleted" boolean NOT NULL
);


ALTER TABLE public."Categories" OWNER TO postgres;

--
-- TOC entry 231 (class 1259 OID 24803)
-- Name: Favorites; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Favorites" (
    "Id" uuid NOT NULL,
    "UserId" uuid NOT NULL,
    "ProductId" uuid NOT NULL,
    "CreatedAt" timestamp with time zone NOT NULL,
    "UpdatedAt" timestamp with time zone,
    "IsDeleted" boolean NOT NULL
);


ALTER TABLE public."Favorites" OWNER TO postgres;

--
-- TOC entry 228 (class 1259 OID 24732)
-- Name: OrderItems; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."OrderItems" (
    "Id" uuid NOT NULL,
    "Quantity" integer NOT NULL,
    "UnitPrice" numeric(18,2) NOT NULL,
    "TotalPrice" numeric(18,2) NOT NULL,
    "ProductName" character varying(255) NOT NULL,
    "ProductSKU" character varying(100) NOT NULL,
    "Size" character varying(20),
    "Color" character varying(50),
    "OrderId" uuid NOT NULL,
    "ProductId" uuid NOT NULL,
    "ProductVariantId" uuid,
    "CreatedAt" timestamp with time zone NOT NULL,
    "UpdatedAt" timestamp with time zone,
    "IsDeleted" boolean NOT NULL
);


ALTER TABLE public."OrderItems" OWNER TO postgres;

--
-- TOC entry 226 (class 1259 OID 24690)
-- Name: Orders; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Orders" (
    "Id" uuid NOT NULL,
    "OrderNumber" character varying(50) NOT NULL,
    "SubTotal" numeric(18,2) NOT NULL,
    "ShippingCost" numeric(18,2) NOT NULL,
    "Tax" numeric(18,2) NOT NULL,
    "Total" numeric(18,2) NOT NULL,
    "Status" integer NOT NULL,
    "PaymentStatus" integer NOT NULL,
    "PaymentMethod" integer NOT NULL,
    "PaymentTransactionId" character varying(255),
    "TrackingNumber" character varying(100),
    "Notes" character varying(1000),
    "ShippedAt" timestamp with time zone,
    "DeliveredAt" timestamp with time zone,
    "UserId" uuid NOT NULL,
    "ShippingAddressId" uuid NOT NULL,
    "BillingAddressId" uuid,
    "CreatedAt" timestamp with time zone NOT NULL,
    "UpdatedAt" timestamp with time zone,
    "IsDeleted" boolean NOT NULL
);


ALTER TABLE public."Orders" OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 24651)
-- Name: ProductImages; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."ProductImages" (
    "Id" uuid NOT NULL,
    "ImageUrl" character varying(500) NOT NULL,
    "ThumbnailUrl" character varying(500),
    "AltText" character varying(255),
    "DisplayOrder" integer NOT NULL,
    "IsMainImage" boolean NOT NULL,
    "ProductId" uuid NOT NULL,
    "CreatedAt" timestamp with time zone NOT NULL,
    "UpdatedAt" timestamp with time zone,
    "IsDeleted" boolean NOT NULL
);


ALTER TABLE public."ProductImages" OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 24663)
-- Name: ProductVariants; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."ProductVariants" (
    "Id" uuid NOT NULL,
    "Size" character varying(20) NOT NULL,
    "Color" character varying(50) NOT NULL,
    "ColorHex" character varying(7),
    "StockQuantity" integer NOT NULL,
    "SKU" character varying(100) NOT NULL,
    "PriceAdjustment" numeric(18,2),
    "ProductId" uuid NOT NULL,
    "CreatedAt" timestamp with time zone NOT NULL,
    "UpdatedAt" timestamp with time zone,
    "IsDeleted" boolean NOT NULL
);


ALTER TABLE public."ProductVariants" OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 24612)
-- Name: Products; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Products" (
    "Id" uuid NOT NULL,
    "Name" character varying(255) NOT NULL,
    "Slug" character varying(300) NOT NULL,
    "Description" character varying(2000) NOT NULL,
    "ShortDescription" character varying(500),
    "Price" numeric(18,2) NOT NULL,
    "DiscountPrice" numeric(18,2),
    "SKU" character varying(100) NOT NULL,
    "StockQuantity" integer NOT NULL,
    "Gender" integer NOT NULL,
    "IsFeatured" boolean NOT NULL,
    "IsActive" boolean NOT NULL,
    "ViewCount" integer NOT NULL,
    "CategoryId" uuid NOT NULL,
    "BrandId" uuid NOT NULL,
    "CreatedAt" timestamp with time zone NOT NULL,
    "UpdatedAt" timestamp with time zone,
    "IsDeleted" boolean NOT NULL
);


ALTER TABLE public."Products" OWNER TO postgres;

--
-- TOC entry 230 (class 1259 OID 24791)
-- Name: SpecialCollectionProducts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."SpecialCollectionProducts" (
    "Id" uuid NOT NULL,
    "Name" text NOT NULL,
    "Price" numeric NOT NULL,
    "Description" text,
    "ImagePaths" text NOT NULL,
    "DisplayOrder" integer NOT NULL,
    "IsActive" boolean NOT NULL,
    "CreatedAt" timestamp with time zone NOT NULL,
    "UpdatedAt" timestamp with time zone,
    "IsDeleted" boolean NOT NULL,
    "StockL" integer DEFAULT 0 NOT NULL,
    "StockM" integer DEFAULT 0 NOT NULL,
    "StockS" integer DEFAULT 0 NOT NULL,
    "StockXL" integer DEFAULT 0 NOT NULL,
    "ProductId" uuid
);


ALTER TABLE public."SpecialCollectionProducts" OWNER TO postgres;

--
-- TOC entry 220 (class 1259 OID 24605)
-- Name: Users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Users" (
    "Id" uuid NOT NULL,
    "FirstName" character varying(100) NOT NULL,
    "LastName" character varying(100) NOT NULL,
    "Email" character varying(255) NOT NULL,
    "PasswordHash" character varying(500) NOT NULL,
    "PhoneNumber" character varying(20),
    "ProfileImageUrl" character varying(500),
    "IsEmailConfirmed" boolean NOT NULL,
    "LastLoginAt" timestamp with time zone,
    "CreatedAt" timestamp with time zone NOT NULL,
    "UpdatedAt" timestamp with time zone,
    "IsDeleted" boolean NOT NULL,
    "EmailConfirmationCode" text,
    "EmailConfirmationCodeExpiry" timestamp with time zone,
    "Gender" text,
    "AuthProvider" integer DEFAULT 0 NOT NULL
);


ALTER TABLE public."Users" OWNER TO postgres;

--
-- TOC entry 217 (class 1259 OID 24581)
-- Name: __EFMigrationsHistory; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."__EFMigrationsHistory" (
    "MigrationId" character varying(150) NOT NULL,
    "ProductVersion" character varying(32) NOT NULL
);


ALTER TABLE public."__EFMigrationsHistory" OWNER TO postgres;

--
-- TOC entry 3842 (class 0 OID 24629)
-- Dependencies: 222
-- Data for Name: Addresses; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Addresses" ("Id", "FirstName", "LastName", "PhoneNumber", "AddressLine1", "AddressLine2", "City", "State", "Country", "ZipCode", "IsDefault", "UserId", "CreatedAt", "UpdatedAt", "IsDeleted") FROM stdin;
\.


--
-- TOC entry 3849 (class 0 OID 24784)
-- Dependencies: 229
-- Data for Name: Admins; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Admins" ("Id", "Username", "PasswordHash", "Email", "LastLoginAt", "CreatedAt", "UpdatedAt", "IsDeleted") FROM stdin;
\.


--
-- TOC entry 3838 (class 0 OID 24586)
-- Dependencies: 218
-- Data for Name: Brands; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Brands" ("Id", "Name", "Slug", "Description", "LogoUrl", "WebsiteUrl", "CreatedAt", "UpdatedAt", "IsDeleted") FROM stdin;
fb1fb2c6-5303-4e2d-a754-df33a0f80a55	Zara	zara	Modern ve şık tasarımlar	https://upload.wikimedia.org/wikipedia/commons/f/fd/Zara_Logo.svg	\N	2026-01-05 15:06:11.349673+03	2026-01-05 15:06:11.349673+03	f
135db8fc-165d-44de-8b15-984f4f520ced	Mango	mango	Kaliteli ve trend ürünler	https://upload.wikimedia.org/wikipedia/commons/8/83/Mango_Logo.svg	\N	2026-01-05 15:06:11.435111+03	2026-01-05 15:06:11.435111+03	f
5cf92308-168c-4d0e-bbb4-f37dc25cc993	H&M	hm	Uygun fiyatlı moda	https://upload.wikimedia.org/wikipedia/commons/5/53/H%26M-Logo.svg	\N	2026-01-05 15:06:11.435477+03	2026-01-05 15:06:11.435477+03	f
8f64a539-f94b-4d2b-b2d5-42e0be55e24f	Pull&Bear	pullbear	Genç ve rahat stiller	\N	\N	2026-01-05 15:06:11.435679+03	2026-01-05 15:06:11.435679+03	f
aad9bf8c-b0aa-4de7-88bd-61f81867e2aa	Bershka	bershka	Cesur ve özgün tasarımlar	\N	\N	2026-01-05 15:06:11.435847+03	2026-01-05 15:06:11.435847+03	f
8e3ee78f-9960-4c73-a20a-5ad8271e7112	Koton	koton	Türk markası, her stile uygun	\N	\N	2026-01-05 15:06:11.436007+03	2026-01-05 15:06:11.436007+03	f
3dbeca4e-177e-44ec-ac97-92401d7aa349	LC Waikiki	lcwaikiki	Herkes için moda	\N	\N	2026-01-05 15:06:11.445882+03	2026-01-05 15:06:11.445882+03	f
8e590ef0-22d1-4d4f-9e1e-5a651cb74cc1	Nike	nike	Spor giyim ve ayakkabı	https://upload.wikimedia.org/wikipedia/commons/a/a6/Logo_NIKE.svg	\N	2026-01-05 15:06:11.446493+03	2026-01-05 15:06:11.446493+03	f
430a8aa6-5107-49b2-9841-a8a4f7d8109c	Adidas	adidas	Spor ve günlük giyim	https://upload.wikimedia.org/wikipedia/commons/2/20/Adidas_Logo.svg	\N	2026-01-05 15:06:11.446825+03	2026-01-05 15:06:11.446825+03	f
a7e291db-52ce-4bc8-ae9c-39c6ebead732	Defacto	defacto	Modern Türk markası	\N	\N	2026-01-05 15:06:11.447105+03	2026-01-05 15:06:11.447105+03	f
\.


--
-- TOC entry 3847 (class 0 OID 24712)
-- Dependencies: 227
-- Data for Name: CartItems; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."CartItems" ("Id", "Quantity", "CartId", "ProductId", "ProductVariantId", "CreatedAt", "UpdatedAt", "IsDeleted") FROM stdin;
\.


--
-- TOC entry 3843 (class 0 OID 24641)
-- Dependencies: 223
-- Data for Name: Carts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Carts" ("Id", "UserId", "CreatedAt", "UpdatedAt", "IsDeleted") FROM stdin;
\.


--
-- TOC entry 3839 (class 0 OID 24593)
-- Dependencies: 219
-- Data for Name: Categories; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Categories" ("Id", "Name", "Slug", "Description", "ImageUrl", "Gender", "ParentCategoryId", "CreatedAt", "UpdatedAt", "IsDeleted") FROM stdin;
071b8986-a76e-4081-80a1-007c0f52028d	Elbise	elbise	Kadın elbiseleri	https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=500	2	\N	2026-01-05 14:44:35.17025+03	2026-01-05 14:44:35.17025+03	f
efde8faf-5a12-458e-8c7c-3947fe80ddd8	Bluz	bluz	Kadın bluzları	https://images.unsplash.com/photo-1564859228273-274232fdb516?w=500	2	\N	2026-01-05 14:44:35.175546+03	2026-01-05 14:44:35.175546+03	f
61351b59-0557-4d43-b42a-63ad8051f356	Pantolon	pantolon-kadin	Kadın pantolonları	https://images.unsplash.com/photo-1506629082955-511b1aa562c8?w=500	2	\N	2026-01-05 14:44:35.17599+03	2026-01-05 14:44:35.17599+03	f
6f688345-731d-4979-8341-a7cf431d9499	Etek	etek	Kadın etekleri	https://images.unsplash.com/photo-1583496661160-fb5886a0aaaa?w=500	2	\N	2026-01-05 14:44:35.176394+03	2026-01-05 14:44:35.176394+03	f
06028ab9-f9da-4f1f-bd6d-f26213484d00	Ceket	ceket-kadin	Kadın ceketleri	https://images.unsplash.com/photo-1591047139829-d91aecb6caea?w=500	2	\N	2026-01-05 14:44:35.176749+03	2026-01-05 14:44:35.176749+03	f
80be2a3d-32f1-4d94-9db4-39d3db520cc1	Ayakkabı	ayakkabi-kadin	Kadın ayakkabıları	https://images.unsplash.com/photo-1543163521-1bf539c55dd2?w=500	2	\N	2026-01-05 14:44:35.177101+03	2026-01-05 14:44:35.177101+03	f
8fe001c0-19a2-4b19-a435-c3dbf95941a6	T-Shirt	t-shirt	Erkek t-shirtleri	https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=500	1	\N	2026-01-05 14:44:35.17744+03	2026-01-05 14:44:35.17744+03	f
28f92ac2-299f-41cf-bb86-3af38192820c	Gömlek	gomlek	Erkek gömlekleri	https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?w=500	1	\N	2026-01-05 14:44:35.177718+03	2026-01-05 14:44:35.177718+03	f
96ef328d-8dd8-4a40-be01-cb79f1eed35f	Pantolon	pantolon-erkek	Erkek pantolonları	https://images.unsplash.com/photo-1473966968600-fa801b869a1a?w=500	1	\N	2026-01-05 14:44:35.178002+03	2026-01-05 14:44:35.178002+03	f
319f176d-0ca7-4049-8a26-c4c683ca6ca4	Ceket	ceket-erkek	Erkek ceketleri	https://images.unsplash.com/photo-1551028719-00167b16eac5?w=500	1	\N	2026-01-05 14:44:35.178276+03	2026-01-05 14:44:35.178276+03	f
2c905335-1544-4194-acd7-1a4c81b38158	Ayakkabı	ayakkabi-erkek	Erkek ayakkabıları	https://images.unsplash.com/photo-1549298916-b41d501d3772?w=500	1	\N	2026-01-05 14:44:35.178538+03	2026-01-05 14:44:35.178538+03	f
4673ea4f-8cf8-40e2-bb26-e1c09146d44d	Kazak	kazak	Erkek kazakları	https://images.unsplash.com/photo-1576566588028-4147f3842f27?w=500	1	\N	2026-01-05 14:44:35.178828+03	2026-01-05 14:44:35.178828+03	f
fe7de772-ae12-4181-93da-f44dffa533d2	Çanta	canta	Çantalar	https://images.unsplash.com/photo-1590874103328-eac38a683ce7?w=500	3	\N	2026-01-05 14:44:35.179128+03	2026-01-05 14:44:35.179128+03	f
0456fbf9-feb3-4acd-8c5a-81ec230b1f57	Saat	saat	Saatler	https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=500	3	\N	2026-01-05 14:44:35.179429+03	2026-01-05 14:44:35.179429+03	f
dd694b5a-d715-494f-8f4b-f66fe9cde9da	Gözlük	gozluk	Güneş gözlükleri	https://images.unsplash.com/photo-1511499767150-a48a237f0083?w=500	3	\N	2026-01-05 14:44:35.179674+03	2026-01-05 14:44:35.179674+03	f
0be3c8d2-45c3-4ba5-bdfa-53905d534156	Şapka	sapka	Şapkalar	https://images.unsplash.com/photo-1521369909029-2afed882baee?w=500	3	\N	2026-01-05 14:44:35.179842+03	2026-01-05 14:44:35.179842+03	f
00025ac0-8a36-4cc4-b02e-c417b5063626	Kemer	kemer	Kemerler	https://images.unsplash.com/photo-1624222247344-550fb60583dc?w=500	3	\N	2026-01-05 14:44:35.18016+03	2026-01-05 14:44:35.18016+03	f
\.


--
-- TOC entry 3851 (class 0 OID 24803)
-- Dependencies: 231
-- Data for Name: Favorites; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Favorites" ("Id", "UserId", "ProductId", "CreatedAt", "UpdatedAt", "IsDeleted") FROM stdin;
\.


--
-- TOC entry 3848 (class 0 OID 24732)
-- Dependencies: 228
-- Data for Name: OrderItems; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."OrderItems" ("Id", "Quantity", "UnitPrice", "TotalPrice", "ProductName", "ProductSKU", "Size", "Color", "OrderId", "ProductId", "ProductVariantId", "CreatedAt", "UpdatedAt", "IsDeleted") FROM stdin;
\.


--
-- TOC entry 3846 (class 0 OID 24690)
-- Dependencies: 226
-- Data for Name: Orders; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Orders" ("Id", "OrderNumber", "SubTotal", "ShippingCost", "Tax", "Total", "Status", "PaymentStatus", "PaymentMethod", "PaymentTransactionId", "TrackingNumber", "Notes", "ShippedAt", "DeliveredAt", "UserId", "ShippingAddressId", "BillingAddressId", "CreatedAt", "UpdatedAt", "IsDeleted") FROM stdin;
\.


--
-- TOC entry 3844 (class 0 OID 24651)
-- Dependencies: 224
-- Data for Name: ProductImages; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."ProductImages" ("Id", "ImageUrl", "ThumbnailUrl", "AltText", "DisplayOrder", "IsMainImage", "ProductId", "CreatedAt", "UpdatedAt", "IsDeleted") FROM stdin;
\.


--
-- TOC entry 3845 (class 0 OID 24663)
-- Dependencies: 225
-- Data for Name: ProductVariants; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."ProductVariants" ("Id", "Size", "Color", "ColorHex", "StockQuantity", "SKU", "PriceAdjustment", "ProductId", "CreatedAt", "UpdatedAt", "IsDeleted") FROM stdin;
\.


--
-- TOC entry 3841 (class 0 OID 24612)
-- Dependencies: 221
-- Data for Name: Products; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Products" ("Id", "Name", "Slug", "Description", "ShortDescription", "Price", "DiscountPrice", "SKU", "StockQuantity", "Gender", "IsFeatured", "IsActive", "ViewCount", "CategoryId", "BrandId", "CreatedAt", "UpdatedAt", "IsDeleted") FROM stdin;
2c2da245-bba9-46da-a2a6-ab1869018bd7	Siyah Midi Elbise	siyah-midi-elbise	Şık ve zarif siyah midi elbise. Günlük kullanım ve özel günler için ideal.	\N	899.99	\N	ELB-001-BLK	45	2	t	t	0	071b8986-a76e-4081-80a1-007c0f52028d	fb1fb2c6-5303-4e2d-a754-df33a0f80a55	2026-01-05 15:09:01.821106+03	2026-01-05 15:09:01.821106+03	f
f84b6711-d36f-413d-9da4-0af23fe238e3	Çiçek Desenli Maxi Elbise	cicek-desenli-maxi-elbise	Yaz için mükemmel çiçek desenli uzun elbise.	\N	749.99	\N	ELB-002-FLR	30	2	t	t	0	071b8986-a76e-4081-80a1-007c0f52028d	135db8fc-165d-44de-8b15-984f4f520ced	2026-01-05 15:09:01.832773+03	2026-01-05 15:09:01.832773+03	f
6ea0ff67-72b3-4495-ab0a-ff74165ee40d	Kırmızı Kokteyl Elbise	kirmizi-kokteyl-elbise	Özel günler için kırmızı kokteyl elbise.	\N	1299.99	\N	ELB-003-RED	20	2	t	t	0	071b8986-a76e-4081-80a1-007c0f52028d	fb1fb2c6-5303-4e2d-a754-df33a0f80a55	2026-01-05 15:09:01.835153+03	2026-01-05 15:09:01.835153+03	f
225333da-e2f1-4f14-9349-f5c86fb6f543	Beyaz Saten Bluz	beyaz-saten-bluz	Şık saten dokulu beyaz bluz. İş ve günlük kullanım için.	\N	449.99	\N	BLZ-001-WHT	60	2	f	t	0	efde8faf-5a12-458e-8c7c-3947fe80ddd8	5cf92308-168c-4d0e-bbb4-f37dc25cc993	2026-01-05 15:09:01.835929+03	2026-01-05 15:09:01.835929+03	f
9e99bf70-3ffc-4bc6-99bb-4a7d9fe5c931	Çizgili Gömlek Bluz	cizgili-gomlek-bluz	Modern çizgili desenli gömlek bluz.	\N	399.99	\N	BLZ-002-STR	50	2	f	t	0	efde8faf-5a12-458e-8c7c-3947fe80ddd8	8e3ee78f-9960-4c73-a20a-5ad8271e7112	2026-01-05 15:09:01.836631+03	2026-01-05 15:09:01.836631+03	f
16ac535f-a3a2-4218-9961-dda240674ffa	Yüksek Bel Jean Pantolon	yuksek-bel-jean-pantolon-kadin	Rahat kesim yüksek bel kot pantolon.	\N	599.99	\N	PNT-001-DEN	70	2	t	t	0	61351b59-0557-4d43-b42a-63ad8051f356	fb1fb2c6-5303-4e2d-a754-df33a0f80a55	2026-01-05 15:09:01.837237+03	2026-01-05 15:09:01.837237+03	f
839f5e57-5ba2-47fc-a3f0-1221cc6ca7ef	Wide Leg Kumaş Pantolon	wide-leg-kumas-pantolon	Geniş paça şık kumaş pantolon.	\N	699.99	\N	PNT-002-WID	40	2	f	t	0	61351b59-0557-4d43-b42a-63ad8051f356	135db8fc-165d-44de-8b15-984f4f520ced	2026-01-05 15:09:01.838052+03	2026-01-05 15:09:01.838052+03	f
03bcf2ec-fb31-4408-a6e6-6621538b0084	Pileli Midi Etek	pileli-midi-etek	Şık pileli midi boy etek. Her kombinle uyumlu.	\N	499.99	\N	ETK-001-PLT	40	2	f	t	0	6f688345-731d-4979-8341-a7cf431d9499	135db8fc-165d-44de-8b15-984f4f520ced	2026-01-05 15:09:01.838694+03	2026-01-05 15:09:01.838694+03	f
e2fbb78d-bd68-48a3-ada3-3a3a0790b5c2	Deri Mini Etek	deri-mini-etek	Siyah deri mini etek.	\N	599.99	\N	ETK-002-LTH	35	2	t	t	0	6f688345-731d-4979-8341-a7cf431d9499	fb1fb2c6-5303-4e2d-a754-df33a0f80a55	2026-01-05 15:09:01.839249+03	2026-01-05 15:09:01.839249+03	f
e9e824db-0a94-4e1b-8242-49541092bd08	Blazer Ceket Kadın	blazer-ceket-kadin	Klasik kesim blazer ceket.	\N	999.99	\N	CKT-001-BLZ	30	2	t	t	0	06028ab9-f9da-4f1f-bd6d-f26213484d00	135db8fc-165d-44de-8b15-984f4f520ced	2026-01-05 15:09:01.839778+03	2026-01-05 15:09:01.839778+03	f
313eb873-6bff-4c2f-a101-c1e6c10c9b4f	Topuklu Ayakkabı Siyah	topuklu-ayakkabi-siyah	Klasik siyah topuklu ayakkabı.	\N	799.99	\N	AYK-001-HEL	50	2	f	t	0	80be2a3d-32f1-4d94-9db4-39d3db520cc1	fb1fb2c6-5303-4e2d-a754-df33a0f80a55	2026-01-05 15:09:01.840264+03	2026-01-05 15:09:01.840264+03	f
939cb9db-bd82-4ee1-ae2c-b994c98b9a33	Basic Beyaz T-Shirt	basic-beyaz-tshirt-erkek	Klasik beyaz basic t-shirt. Her gardırobun olmazsa olmazı.	\N	199.99	\N	TSH-001-WHT	100	1	t	t	0	8fe001c0-19a2-4b19-a435-c3dbf95941a6	5cf92308-168c-4d0e-bbb4-f37dc25cc993	2026-01-05 15:09:01.840856+03	2026-01-05 15:09:01.840856+03	f
1f8fae30-653c-411c-9367-652399e76f43	Siyah Baskılı T-Shirt	siyah-baskili-tshirt-erkek	Modern grafik baskılı siyah t-shirt.	\N	249.99	\N	TSH-002-BLK	80	1	f	t	0	8fe001c0-19a2-4b19-a435-c3dbf95941a6	a7e291db-52ce-4bc8-ae9c-39c6ebead732	2026-01-05 15:09:01.841407+03	2026-01-05 15:09:01.841407+03	f
dd9a98a8-0f72-426a-aac4-d98cc15a258a	Polo Yaka T-Shirt	polo-yaka-tshirt	Klasik polo yaka t-shirt.	\N	349.99	\N	TSH-003-POL	60	1	t	t	0	8fe001c0-19a2-4b19-a435-c3dbf95941a6	8e3ee78f-9960-4c73-a20a-5ad8271e7112	2026-01-05 15:09:01.842111+03	2026-01-05 15:09:01.842111+03	f
1653b8a9-3aff-4cb5-a724-341906a4283a	Slim Fit Beyaz Gömlek	slim-fit-beyaz-gomlek-erkek	Klasik slim fit beyaz gömlek. İş ve özel günler için.	\N	499.99	\N	GML-001-WHT	55	1	t	t	0	28f92ac2-299f-41cf-bb86-3af38192820c	fb1fb2c6-5303-4e2d-a754-df33a0f80a55	2026-01-05 15:09:01.842695+03	2026-01-05 15:09:01.842695+03	f
a2ad7f2a-ac58-48b4-b643-510340dc225e	Kareli Gömlek	kareli-gomlek	Günlük kullanım için kareli gömlek.	\N	399.99	\N	GML-002-CHK	45	1	f	t	0	28f92ac2-299f-41cf-bb86-3af38192820c	5cf92308-168c-4d0e-bbb4-f37dc25cc993	2026-01-05 15:09:01.84322+03	2026-01-05 15:09:01.84322+03	f
fe8680b9-b26e-4ad3-9b7f-b22b0b3ec47c	Slim Fit Chino Pantolon	slim-fit-chino-pantolon-erkek	Modern kesim chino pantolon. Günlük kullanım için ideal.	\N	549.99	\N	PNT-003-CHN	65	1	f	t	0	96ef328d-8dd8-4a40-be01-cb79f1eed35f	8e3ee78f-9960-4c73-a20a-5ad8271e7112	2026-01-05 15:09:01.843559+03	2026-01-05 15:09:01.843559+03	f
df6e632f-7682-4d21-9e7d-34a8346dffd6	Slim Fit Jean Pantolon	slim-fit-jean-pantolon-erkek	Koyu mavi slim fit jean.	\N	599.99	\N	PNT-004-JEN	70	1	t	t	0	96ef328d-8dd8-4a40-be01-cb79f1eed35f	fb1fb2c6-5303-4e2d-a754-df33a0f80a55	2026-01-05 15:09:01.843927+03	2026-01-05 15:09:01.843927+03	f
33387038-ffae-4d3f-aff2-f4866555fc72	Deri Bomber Ceket	deri-bomber-ceket-erkek	Siyah deri bomber ceket. Modern ve şık.	\N	1299.99	\N	CKT-002-BMB	25	1	t	t	0	319f176d-0ca7-4049-8a26-c4c683ca6ca4	fb1fb2c6-5303-4e2d-a754-df33a0f80a55	2026-01-05 15:09:01.844249+03	2026-01-05 15:09:01.844249+03	f
89fea25d-bbe8-4317-8dbb-d60696c078cb	Kot Ceket	kot-ceket-erkek	Klasik mavi kot ceket.	\N	699.99	\N	CKT-003-DEN	40	1	f	t	0	319f176d-0ca7-4049-8a26-c4c683ca6ca4	5cf92308-168c-4d0e-bbb4-f37dc25cc993	2026-01-05 15:09:01.844569+03	2026-01-05 15:09:01.844569+03	f
439d2cd8-5575-402e-976f-e6015f350ae7	Boğazlı Triko Kazak	bogazli-triko-kazak	Sıcak tutan boğazlı triko kazak.	\N	449.99	\N	KZK-001-TUR	50	1	f	t	0	4673ea4f-8cf8-40e2-bb26-e1c09146d44d	5cf92308-168c-4d0e-bbb4-f37dc25cc993	2026-01-05 15:09:01.844869+03	2026-01-05 15:09:01.844869+03	f
03e9865d-d6ec-4780-b0f0-c8996a593edf	V Yaka Kazak	v-yaka-kazak	Şık v yaka kazak.	\N	399.99	\N	KZK-002-VNK	45	1	t	t	0	4673ea4f-8cf8-40e2-bb26-e1c09146d44d	8e3ee78f-9960-4c73-a20a-5ad8271e7112	2026-01-05 15:09:01.845168+03	2026-01-05 15:09:01.845168+03	f
6a460d36-1216-4107-93e3-5104398a8c4d	Klasik Siyah Ayakkabı	klasik-siyah-ayakkabi-erkek	İş ve özel günler için klasik siyah ayakkabı.	\N	899.99	\N	AYK-002-CLS	40	1	f	t	0	2c905335-1544-4194-acd7-1a4c81b38158	fb1fb2c6-5303-4e2d-a754-df33a0f80a55	2026-01-05 15:09:01.845493+03	2026-01-05 15:09:01.845493+03	f
101097c8-2ef2-4262-8351-576364c2b51d	Deri Omuz Çantası	deri-omuz-cantasi	Şık deri omuz çantası. Kadın ve erkek kullanımına uygun.	\N	899.99	\N	CNT-001-SHL	35	3	t	t	0	fe7de772-ae12-4181-93da-f44dffa533d2	135db8fc-165d-44de-8b15-984f4f520ced	2026-01-05 15:09:01.845826+03	2026-01-05 15:09:01.845826+03	f
b458aa22-b7ef-4d1f-a7dd-1f7907534fd0	Sırt Çantası	sirt-cantasi	Günlük kullanım için pratik sırt çantası.	\N	599.99	\N	CNT-002-BCK	50	3	f	t	0	fe7de772-ae12-4181-93da-f44dffa533d2	5cf92308-168c-4d0e-bbb4-f37dc25cc993	2026-01-05 15:09:01.846213+03	2026-01-05 15:09:01.846213+03	f
40d2e3d3-bb5d-4099-8c68-8d179067c834	Minimal Kol Saati	minimal-kol-saati	Zarif ve minimal tasarım kol saati.	\N	699.99	\N	SAT-001-MIN	40	3	f	t	0	0456fbf9-feb3-4acd-8c5a-81ec230b1f57	fb1fb2c6-5303-4e2d-a754-df33a0f80a55	2026-01-05 15:09:01.846466+03	2026-01-05 15:09:01.846466+03	f
6c06a1cd-0672-4abe-bed2-1a0b35aa95c8	Dijital Spor Saati	dijital-spor-saati	Spor aktiviteleri için dijital saat.	\N	449.99	\N	SAT-002-DIG	60	3	t	t	0	0456fbf9-feb3-4acd-8c5a-81ec230b1f57	a7e291db-52ce-4bc8-ae9c-39c6ebead732	2026-01-05 15:09:01.846711+03	2026-01-05 15:09:01.846711+03	f
6aa31ee7-4ced-4a4c-9b4e-41a107276519	Güneş Gözlüğü Aviator	gunes-gozlugu-aviator	Klasik aviator model güneş gözlüğü.	\N	299.99	\N	GZL-001-AVI	60	3	t	t	0	dd694b5a-d715-494f-8f4b-f66fe9cde9da	5cf92308-168c-4d0e-bbb4-f37dc25cc993	2026-01-05 15:09:01.84703+03	2026-01-05 15:09:01.84703+03	f
305a2739-6abe-48b7-8c1c-c83b0389c9b4	Wayfarer Güneş Gözlüğü	wayfarer-gunes-gozlugu	Klasik wayfarer güneş gözlüğü.	\N	349.99	\N	GZL-002-WAY	50	3	f	t	0	dd694b5a-d715-494f-8f4b-f66fe9cde9da	fb1fb2c6-5303-4e2d-a754-df33a0f80a55	2026-01-05 15:09:01.847304+03	2026-01-05 15:09:01.847304+03	f
\.


--
-- TOC entry 3850 (class 0 OID 24791)
-- Dependencies: 230
-- Data for Name: SpecialCollectionProducts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."SpecialCollectionProducts" ("Id", "Name", "Price", "Description", "ImagePaths", "DisplayOrder", "IsActive", "CreatedAt", "UpdatedAt", "IsDeleted", "StockL", "StockM", "StockS", "StockXL", "ProductId") FROM stdin;
\.


--
-- TOC entry 3840 (class 0 OID 24605)
-- Dependencies: 220
-- Data for Name: Users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Users" ("Id", "FirstName", "LastName", "Email", "PasswordHash", "PhoneNumber", "ProfileImageUrl", "IsEmailConfirmed", "LastLoginAt", "CreatedAt", "UpdatedAt", "IsDeleted", "EmailConfirmationCode", "EmailConfirmationCodeExpiry", "Gender", "AuthProvider") FROM stdin;
\.


--
-- TOC entry 3837 (class 0 OID 24581)
-- Dependencies: 217
-- Data for Name: __EFMigrationsHistory; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."__EFMigrationsHistory" ("MigrationId", "ProductVersion") FROM stdin;
20251028144948_InitialCreate	9.0.10
20251028172724_AddEmailVerificationToUser	9.0.10
20251111210603_AddGenderToUser	9.0.10
20251111213304_ConvertGenderToString	9.0.10
20251113145228_AddAdminTable	9.0.10
20251113161602_AddSpecialCollectionProductTable	9.0.10
20251113162631_AddSizeStockFields	9.0.10
20251120180043_AddAuthProviderToUser	9.0.10
20251120183423_AddFavoritesTable	9.0.10
20251121175241_AddProductIdToSpecialCollection	9.0.10
\.


--
-- TOC entry 3637 (class 2606 OID 24635)
-- Name: Addresses PK_Addresses; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Addresses"
    ADD CONSTRAINT "PK_Addresses" PRIMARY KEY ("Id");


--
-- TOC entry 3665 (class 2606 OID 24790)
-- Name: Admins PK_Admins; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Admins"
    ADD CONSTRAINT "PK_Admins" PRIMARY KEY ("Id");


--
-- TOC entry 3621 (class 2606 OID 24592)
-- Name: Brands PK_Brands; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Brands"
    ADD CONSTRAINT "PK_Brands" PRIMARY KEY ("Id");


--
-- TOC entry 3658 (class 2606 OID 24716)
-- Name: CartItems PK_CartItems; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CartItems"
    ADD CONSTRAINT "PK_CartItems" PRIMARY KEY ("Id");


--
-- TOC entry 3640 (class 2606 OID 24645)
-- Name: Carts PK_Carts; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Carts"
    ADD CONSTRAINT "PK_Carts" PRIMARY KEY ("Id");


--
-- TOC entry 3625 (class 2606 OID 24599)
-- Name: Categories PK_Categories; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Categories"
    ADD CONSTRAINT "PK_Categories" PRIMARY KEY ("Id");


--
-- TOC entry 3672 (class 2606 OID 24807)
-- Name: Favorites PK_Favorites; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Favorites"
    ADD CONSTRAINT "PK_Favorites" PRIMARY KEY ("Id");


--
-- TOC entry 3663 (class 2606 OID 24736)
-- Name: OrderItems PK_OrderItems; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."OrderItems"
    ADD CONSTRAINT "PK_OrderItems" PRIMARY KEY ("Id");


--
-- TOC entry 3653 (class 2606 OID 24696)
-- Name: Orders PK_Orders; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Orders"
    ADD CONSTRAINT "PK_Orders" PRIMARY KEY ("Id");


--
-- TOC entry 3643 (class 2606 OID 24657)
-- Name: ProductImages PK_ProductImages; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ProductImages"
    ADD CONSTRAINT "PK_ProductImages" PRIMARY KEY ("Id");


--
-- TOC entry 3647 (class 2606 OID 24667)
-- Name: ProductVariants PK_ProductVariants; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ProductVariants"
    ADD CONSTRAINT "PK_ProductVariants" PRIMARY KEY ("Id");


--
-- TOC entry 3634 (class 2606 OID 24618)
-- Name: Products PK_Products; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Products"
    ADD CONSTRAINT "PK_Products" PRIMARY KEY ("Id");


--
-- TOC entry 3668 (class 2606 OID 24797)
-- Name: SpecialCollectionProducts PK_SpecialCollectionProducts; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SpecialCollectionProducts"
    ADD CONSTRAINT "PK_SpecialCollectionProducts" PRIMARY KEY ("Id");


--
-- TOC entry 3628 (class 2606 OID 24611)
-- Name: Users PK_Users; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Users"
    ADD CONSTRAINT "PK_Users" PRIMARY KEY ("Id");


--
-- TOC entry 3618 (class 2606 OID 24585)
-- Name: __EFMigrationsHistory PK___EFMigrationsHistory; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."__EFMigrationsHistory"
    ADD CONSTRAINT "PK___EFMigrationsHistory" PRIMARY KEY ("MigrationId");


--
-- TOC entry 3635 (class 1259 OID 24752)
-- Name: IX_Addresses_UserId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_Addresses_UserId" ON public."Addresses" USING btree ("UserId");


--
-- TOC entry 3619 (class 1259 OID 24753)
-- Name: IX_Brands_Slug; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IX_Brands_Slug" ON public."Brands" USING btree ("Slug");


--
-- TOC entry 3654 (class 1259 OID 24754)
-- Name: IX_CartItems_CartId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_CartItems_CartId" ON public."CartItems" USING btree ("CartId");


--
-- TOC entry 3655 (class 1259 OID 24755)
-- Name: IX_CartItems_ProductId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_CartItems_ProductId" ON public."CartItems" USING btree ("ProductId");


--
-- TOC entry 3656 (class 1259 OID 24756)
-- Name: IX_CartItems_ProductVariantId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_CartItems_ProductVariantId" ON public."CartItems" USING btree ("ProductVariantId");


--
-- TOC entry 3638 (class 1259 OID 24757)
-- Name: IX_Carts_UserId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IX_Carts_UserId" ON public."Carts" USING btree ("UserId");


--
-- TOC entry 3622 (class 1259 OID 24758)
-- Name: IX_Categories_ParentCategoryId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_Categories_ParentCategoryId" ON public."Categories" USING btree ("ParentCategoryId");


--
-- TOC entry 3623 (class 1259 OID 24759)
-- Name: IX_Categories_Slug; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IX_Categories_Slug" ON public."Categories" USING btree ("Slug");


--
-- TOC entry 3669 (class 1259 OID 24818)
-- Name: IX_Favorites_ProductId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_Favorites_ProductId" ON public."Favorites" USING btree ("ProductId");


--
-- TOC entry 3670 (class 1259 OID 24819)
-- Name: IX_Favorites_UserId_ProductId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IX_Favorites_UserId_ProductId" ON public."Favorites" USING btree ("UserId", "ProductId");


--
-- TOC entry 3659 (class 1259 OID 24760)
-- Name: IX_OrderItems_OrderId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_OrderItems_OrderId" ON public."OrderItems" USING btree ("OrderId");


--
-- TOC entry 3660 (class 1259 OID 24761)
-- Name: IX_OrderItems_ProductId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_OrderItems_ProductId" ON public."OrderItems" USING btree ("ProductId");


--
-- TOC entry 3661 (class 1259 OID 24762)
-- Name: IX_OrderItems_ProductVariantId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_OrderItems_ProductVariantId" ON public."OrderItems" USING btree ("ProductVariantId");


--
-- TOC entry 3648 (class 1259 OID 24763)
-- Name: IX_Orders_BillingAddressId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_Orders_BillingAddressId" ON public."Orders" USING btree ("BillingAddressId");


--
-- TOC entry 3649 (class 1259 OID 24764)
-- Name: IX_Orders_OrderNumber; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IX_Orders_OrderNumber" ON public."Orders" USING btree ("OrderNumber");


--
-- TOC entry 3650 (class 1259 OID 24765)
-- Name: IX_Orders_ShippingAddressId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_Orders_ShippingAddressId" ON public."Orders" USING btree ("ShippingAddressId");


--
-- TOC entry 3651 (class 1259 OID 24766)
-- Name: IX_Orders_UserId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_Orders_UserId" ON public."Orders" USING btree ("UserId");


--
-- TOC entry 3641 (class 1259 OID 24767)
-- Name: IX_ProductImages_ProductId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_ProductImages_ProductId" ON public."ProductImages" USING btree ("ProductId");


--
-- TOC entry 3644 (class 1259 OID 24772)
-- Name: IX_ProductVariants_ProductId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_ProductVariants_ProductId" ON public."ProductVariants" USING btree ("ProductId");


--
-- TOC entry 3645 (class 1259 OID 24773)
-- Name: IX_ProductVariants_SKU; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IX_ProductVariants_SKU" ON public."ProductVariants" USING btree ("SKU");


--
-- TOC entry 3629 (class 1259 OID 24768)
-- Name: IX_Products_BrandId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_Products_BrandId" ON public."Products" USING btree ("BrandId");


--
-- TOC entry 3630 (class 1259 OID 24769)
-- Name: IX_Products_CategoryId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_Products_CategoryId" ON public."Products" USING btree ("CategoryId");


--
-- TOC entry 3631 (class 1259 OID 24770)
-- Name: IX_Products_SKU; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IX_Products_SKU" ON public."Products" USING btree ("SKU");


--
-- TOC entry 3632 (class 1259 OID 24771)
-- Name: IX_Products_Slug; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IX_Products_Slug" ON public."Products" USING btree ("Slug");


--
-- TOC entry 3666 (class 1259 OID 24820)
-- Name: IX_SpecialCollectionProducts_ProductId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_SpecialCollectionProducts_ProductId" ON public."SpecialCollectionProducts" USING btree ("ProductId");


--
-- TOC entry 3626 (class 1259 OID 24776)
-- Name: IX_Users_Email; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IX_Users_Email" ON public."Users" USING btree ("Email");


--
-- TOC entry 3676 (class 2606 OID 24636)
-- Name: Addresses FK_Addresses_Users_UserId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Addresses"
    ADD CONSTRAINT "FK_Addresses_Users_UserId" FOREIGN KEY ("UserId") REFERENCES public."Users"("Id") ON DELETE CASCADE;


--
-- TOC entry 3683 (class 2606 OID 24717)
-- Name: CartItems FK_CartItems_Carts_CartId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CartItems"
    ADD CONSTRAINT "FK_CartItems_Carts_CartId" FOREIGN KEY ("CartId") REFERENCES public."Carts"("Id") ON DELETE CASCADE;


--
-- TOC entry 3684 (class 2606 OID 24722)
-- Name: CartItems FK_CartItems_ProductVariants_ProductVariantId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CartItems"
    ADD CONSTRAINT "FK_CartItems_ProductVariants_ProductVariantId" FOREIGN KEY ("ProductVariantId") REFERENCES public."ProductVariants"("Id") ON DELETE RESTRICT;


--
-- TOC entry 3685 (class 2606 OID 24727)
-- Name: CartItems FK_CartItems_Products_ProductId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CartItems"
    ADD CONSTRAINT "FK_CartItems_Products_ProductId" FOREIGN KEY ("ProductId") REFERENCES public."Products"("Id") ON DELETE RESTRICT;


--
-- TOC entry 3677 (class 2606 OID 24646)
-- Name: Carts FK_Carts_Users_UserId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Carts"
    ADD CONSTRAINT "FK_Carts_Users_UserId" FOREIGN KEY ("UserId") REFERENCES public."Users"("Id") ON DELETE CASCADE;


--
-- TOC entry 3673 (class 2606 OID 24600)
-- Name: Categories FK_Categories_Categories_ParentCategoryId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Categories"
    ADD CONSTRAINT "FK_Categories_Categories_ParentCategoryId" FOREIGN KEY ("ParentCategoryId") REFERENCES public."Categories"("Id") ON DELETE RESTRICT;


--
-- TOC entry 3690 (class 2606 OID 24808)
-- Name: Favorites FK_Favorites_Products_ProductId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Favorites"
    ADD CONSTRAINT "FK_Favorites_Products_ProductId" FOREIGN KEY ("ProductId") REFERENCES public."Products"("Id") ON DELETE CASCADE;


--
-- TOC entry 3691 (class 2606 OID 24813)
-- Name: Favorites FK_Favorites_Users_UserId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Favorites"
    ADD CONSTRAINT "FK_Favorites_Users_UserId" FOREIGN KEY ("UserId") REFERENCES public."Users"("Id") ON DELETE CASCADE;


--
-- TOC entry 3686 (class 2606 OID 24737)
-- Name: OrderItems FK_OrderItems_Orders_OrderId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."OrderItems"
    ADD CONSTRAINT "FK_OrderItems_Orders_OrderId" FOREIGN KEY ("OrderId") REFERENCES public."Orders"("Id") ON DELETE CASCADE;


--
-- TOC entry 3687 (class 2606 OID 24742)
-- Name: OrderItems FK_OrderItems_ProductVariants_ProductVariantId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."OrderItems"
    ADD CONSTRAINT "FK_OrderItems_ProductVariants_ProductVariantId" FOREIGN KEY ("ProductVariantId") REFERENCES public."ProductVariants"("Id") ON DELETE RESTRICT;


--
-- TOC entry 3688 (class 2606 OID 24747)
-- Name: OrderItems FK_OrderItems_Products_ProductId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."OrderItems"
    ADD CONSTRAINT "FK_OrderItems_Products_ProductId" FOREIGN KEY ("ProductId") REFERENCES public."Products"("Id") ON DELETE RESTRICT;


--
-- TOC entry 3680 (class 2606 OID 24697)
-- Name: Orders FK_Orders_Addresses_BillingAddressId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Orders"
    ADD CONSTRAINT "FK_Orders_Addresses_BillingAddressId" FOREIGN KEY ("BillingAddressId") REFERENCES public."Addresses"("Id") ON DELETE RESTRICT;


--
-- TOC entry 3681 (class 2606 OID 24702)
-- Name: Orders FK_Orders_Addresses_ShippingAddressId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Orders"
    ADD CONSTRAINT "FK_Orders_Addresses_ShippingAddressId" FOREIGN KEY ("ShippingAddressId") REFERENCES public."Addresses"("Id") ON DELETE RESTRICT;


--
-- TOC entry 3682 (class 2606 OID 24707)
-- Name: Orders FK_Orders_Users_UserId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Orders"
    ADD CONSTRAINT "FK_Orders_Users_UserId" FOREIGN KEY ("UserId") REFERENCES public."Users"("Id") ON DELETE RESTRICT;


--
-- TOC entry 3678 (class 2606 OID 24658)
-- Name: ProductImages FK_ProductImages_Products_ProductId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ProductImages"
    ADD CONSTRAINT "FK_ProductImages_Products_ProductId" FOREIGN KEY ("ProductId") REFERENCES public."Products"("Id") ON DELETE CASCADE;


--
-- TOC entry 3679 (class 2606 OID 24668)
-- Name: ProductVariants FK_ProductVariants_Products_ProductId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ProductVariants"
    ADD CONSTRAINT "FK_ProductVariants_Products_ProductId" FOREIGN KEY ("ProductId") REFERENCES public."Products"("Id") ON DELETE CASCADE;


--
-- TOC entry 3674 (class 2606 OID 24619)
-- Name: Products FK_Products_Brands_BrandId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Products"
    ADD CONSTRAINT "FK_Products_Brands_BrandId" FOREIGN KEY ("BrandId") REFERENCES public."Brands"("Id") ON DELETE RESTRICT;


--
-- TOC entry 3675 (class 2606 OID 24624)
-- Name: Products FK_Products_Categories_CategoryId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Products"
    ADD CONSTRAINT "FK_Products_Categories_CategoryId" FOREIGN KEY ("CategoryId") REFERENCES public."Categories"("Id") ON DELETE RESTRICT;


--
-- TOC entry 3689 (class 2606 OID 24821)
-- Name: SpecialCollectionProducts FK_SpecialCollectionProducts_Products_ProductId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SpecialCollectionProducts"
    ADD CONSTRAINT "FK_SpecialCollectionProducts_Products_ProductId" FOREIGN KEY ("ProductId") REFERENCES public."Products"("Id");


-- Completed on 2026-01-06 21:06:20 +03

--
-- PostgreSQL database dump complete
--
