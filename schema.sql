-- =============================================
-- PARCHI MVP - SECURE DATABASE SCHEMA
-- PostgreSQL (Supabase) Implementation
-- =============================================

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- =============================================
-- ENUMS (Type Safety)
-- =============================================

CREATE TYPE user_role AS ENUM ('student', 'merchant_corporate', 'merchant_branch', 'admin');
CREATE TYPE verification_status AS ENUM ('pending', 'approved', 'rejected', 'expired');
CREATE TYPE offer_status AS ENUM ('active', 'inactive');

-- =============================================
-- CORE TABLES
-- =============================================

-- Users: Central authentication table (syncs with Supabase Auth)
CREATE TABLE users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20),
    role user_role NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Students
CREATE TABLE students (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    parchi_id VARCHAR(10) UNIQUE NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    university VARCHAR(255) NOT NULL,
    graduation_year INTEGER,
    is_founders_club BOOLEAN DEFAULT false,
    total_savings DECIMAL(12,2) DEFAULT 0.00,
    total_redemptions INTEGER DEFAULT 0,
    verification_status verification_status DEFAULT 'pending',
    verified_at TIMESTAMPTZ,
    verification_expires_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Student KYC Documents
CREATE TABLE student_kyc (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
    student_id_image_path TEXT NOT NULL,
    selfie_image_path TEXT NOT NULL,
    submitted_at TIMESTAMPTZ DEFAULT NOW(),
    reviewed_by UUID REFERENCES users(id),
    reviewed_at TIMESTAMPTZ,
    review_notes TEXT,
    is_annual_renewal BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Merchants (Corporate Level)
CREATE TABLE merchants (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    business_name VARCHAR(255) NOT NULL,
    business_registration_number VARCHAR(100),
    contact_email VARCHAR(255) NOT NULL,
    contact_phone VARCHAR(20) NOT NULL,
    logo_path TEXT,
    category VARCHAR(100),
    verification_status verification_status DEFAULT 'pending',
    verified_at TIMESTAMPTZ,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Merchant Branches
CREATE TABLE merchant_branches (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    merchant_id UUID NOT NULL REFERENCES merchants(id) ON DELETE CASCADE,
    user_id UUID UNIQUE REFERENCES users(id) ON DELETE SET NULL,
    branch_name VARCHAR(255) NOT NULL,
    address TEXT NOT NULL,
    city VARCHAR(100) NOT NULL,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    contact_phone VARCHAR(20),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================
-- OFFERS & REWARDS
-- =============================================

CREATE TABLE offers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    merchant_id UUID NOT NULL REFERENCES merchants(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    image_url TEXT,
    discount_type VARCHAR(20) NOT NULL CHECK (discount_type IN ('percentage', 'fixed')),
    discount_value DECIMAL(10,2) NOT NULL,
    min_order_value DECIMAL(10,2) DEFAULT 0,
    max_discount_amount DECIMAL(10,2),
    terms_conditions TEXT,
    valid_from TIMESTAMPTZ NOT NULL,
    valid_until TIMESTAMPTZ NOT NULL,
    daily_limit INTEGER,
    total_limit INTEGER,
    current_redemptions INTEGER DEFAULT 0,
    status offer_status DEFAULT 'active',
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT valid_date_range CHECK (valid_until > valid_from),
    CONSTRAINT positive_discount CHECK (discount_value > 0)
);

-- Branch-specific offer availability
CREATE TABLE offer_branches (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    offer_id UUID NOT NULL REFERENCES offers(id) ON DELETE CASCADE,
    branch_id UUID NOT NULL REFERENCES merchant_branches(id) ON DELETE CASCADE,
    is_active BOOLEAN DEFAULT true,
    UNIQUE(offer_id, branch_id)
);

-- Merchant Bonus Settings
CREATE TABLE merchant_bonus_settings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    merchant_id UUID UNIQUE NOT NULL REFERENCES merchants(id) ON DELETE CASCADE,
    image_url TEXT,
    redemptions_required INTEGER NOT NULL DEFAULT 5,
    discount_type VARCHAR(20) NOT NULL DEFAULT 'percentage' CHECK (discount_type IN ('percentage', 'fixed')),
    discount_value DECIMAL(10,2) NOT NULL,
    max_discount_amount DECIMAL(10,2),
    validity_days INTEGER DEFAULT 30,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================
-- REDEMPTIONS
-- =============================================

CREATE TABLE redemptions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    student_id UUID NOT NULL REFERENCES students(id),
    offer_id UUID NOT NULL REFERENCES offers(id),
    branch_id UUID NOT NULL REFERENCES merchant_branches(id),
    is_bonus_applied BOOLEAN DEFAULT false,
    bonus_discount_applied DECIMAL(12,2),
    verified_by UUID REFERENCES users(id),
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Student-Merchant redemption counter
CREATE TABLE student_merchant_stats (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
    merchant_id UUID NOT NULL REFERENCES merchants(id) ON DELETE CASCADE,
    redemption_count INTEGER DEFAULT 0,
    total_savings DECIMAL(12,2) DEFAULT 0.00,
    last_redemption_at TIMESTAMPTZ,
    UNIQUE(student_id, merchant_id)
);

-- Branch-level statistics
CREATE TABLE student_branch_stats (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
    branch_id UUID NOT NULL REFERENCES merchant_branches(id) ON DELETE CASCADE,
    redemption_count INTEGER DEFAULT 0,
    total_savings DECIMAL(12,2) DEFAULT 0.00,
    last_redemption_at TIMESTAMPTZ,
    UNIQUE(student_id, branch_id)
);

-- =============================================
-- AUDIT & SECURITY
-- =============================================

CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id),
    action VARCHAR(100) NOT NULL,
    table_name VARCHAR(100),
    record_id UUID,
    old_values JSONB,
    new_values JSONB,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE system_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    level VARCHAR(20) NOT NULL,
    message TEXT NOT NULL,
    metadata JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE rate_limits (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    identifier VARCHAR(255) NOT NULL,
    action VARCHAR(100) NOT NULL,
    attempts INTEGER DEFAULT 1,
    window_start TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(identifier, action)
);

-- =============================================
-- INDEXES (Performance & Security)
-- =============================================

CREATE INDEX idx_students_parchi_id ON students(parchi_id);
CREATE INDEX idx_students_verification ON students(verification_status);
CREATE INDEX idx_students_user ON students(user_id);

CREATE INDEX idx_merchants_status ON merchants(verification_status);
CREATE INDEX idx_branches_merchant ON merchant_branches(merchant_id);
CREATE INDEX idx_branches_location ON merchant_branches(city);

CREATE INDEX idx_offers_merchant ON offers(merchant_id);
CREATE INDEX idx_offers_status ON offers(status);
CREATE INDEX idx_offers_validity ON offers(valid_from, valid_until);

CREATE INDEX idx_redemptions_student ON redemptions(student_id);
CREATE INDEX idx_redemptions_offer ON redemptions(offer_id);
CREATE INDEX idx_redemptions_branch ON redemptions(branch_id);
CREATE INDEX idx_redemptions_created ON redemptions(created_at);

CREATE INDEX idx_audit_user ON audit_logs(user_id);
CREATE INDEX idx_audit_action ON audit_logs(action);
CREATE INDEX idx_audit_created ON audit_logs(created_at);

CREATE INDEX idx_student_merchant_stats ON student_merchant_stats(student_id, merchant_id);