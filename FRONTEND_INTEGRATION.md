# Frontend Integration Guide - Authentication

This guide explains how to integrate the Parchi backend authentication system with your frontend application.

## Base URL

```
http://localhost:3000/auth
```

For production, replace with your production API URL.

---

## Authentication Flow

### 1. Signup Flow

**Endpoint:** `POST /auth/signup`

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "password123",
  "role": "student",
  "phone": "+1234567890"  // optional
}
```

**Valid Roles:**
- `student` - For student app users
- `merchant_corporate` - For corporate merchant accounts
- `merchant_branch` - For branch merchant accounts
- `admin` - For admin dashboard users

**Response:**
```json
{
  "data": {
    "user": {
      "id": "uuid",
      "email": "user@example.com",
      "role": "student",
      "is_active": false  // false for students/merchants (pending approval)
    },
    "session": {
      "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
      "refresh_token": "v1.xxx...",
      "expires_at": 1234567890,
      "expires_in": 3600,
      "token_type": "bearer",
      "user": {
        "id": "uuid",
        "email": "user@example.com"
      }
    }
  },
  "status": 201,
  "message": "User registered successfully"
}
```

**Note:** Students and merchants will have `is_active: false` until admin approval. Admins are auto-approved.

---

### 2. Login Flow

**Endpoint:** `POST /auth/login`

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response:**
```json
{
  "data": {
    "user": {
      "id": "uuid",
      "email": "user@example.com",
      "role": "student",
      "is_active": true
    },
    "session": {
      "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
      "refresh_token": "v1.xxx...",
      "expires_at": 1234567890,
      "expires_in": 3600,
      "token_type": "bearer"
    }
  },
  "status": 200,
  "message": "Login successful"
}
```

**Error Response (if account pending):**
```json
{
  "statusCode": 401,
  "message": "Account is pending approval",
  "error": "Unauthorized"
}
```

---

### 3. Get Current User Profile

**Endpoint:** `GET /auth/me`

**Headers:**
```
Authorization: Bearer <access_token>
```

**Response:**
```json
{
  "data": {
    "id": "uuid",
    "email": "user@example.com",
    "role": "student",
    "is_active": true
  },
  "status": 200,
  "message": "Profile retrieved successfully"
}
```

---

### 4. Logout

**Endpoint:** `POST /auth/logout`

**Headers:**
```
Authorization: Bearer <access_token>
```

**Response:**
```json
{
  "data": null,
  "status": 200,
  "message": "Logout successful"
}
```

---

## Frontend Implementation Examples

### React/Next.js Example

#### 1. Create Auth Service (`lib/auth.service.ts`)

```typescript
const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3000';

interface SignupData {
  email: string;
  password: string;
  role: 'student' | 'merchant_corporate' | 'merchant_branch' | 'admin';
  phone?: string;
}

interface LoginData {
  email: string;
  password: string;
}

interface AuthResponse {
  data: {
    user: {
      id: string;
      email: string;
      role: string;
      is_active: boolean;
    };
    session: {
      access_token: string;
      refresh_token: string;
      expires_at: number;
    };
  };
  status: number;
  message: string;
}

class AuthService {
  private getToken(): string | null {
    if (typeof window === 'undefined') return null;
    return localStorage.getItem('access_token');
  }

  private setToken(token: string): void {
    if (typeof window === 'undefined') return;
    localStorage.setItem('access_token', token);
  }

  private getRefreshToken(): string | null {
    if (typeof window === 'undefined') return null;
    return localStorage.getItem('refresh_token');
  }

  private setRefreshToken(token: string): void {
    if (typeof window === 'undefined') return;
    localStorage.setItem('refresh_token', token);
  }

  private setTokenExpiry(expiresAt: number): void {
    if (typeof window === 'undefined') return;
    localStorage.setItem('token_expires_at', expiresAt.toString());
  }

  private removeToken(): void {
    if (typeof window === 'undefined') return;
    localStorage.removeItem('access_token');
    localStorage.removeItem('refresh_token');
    localStorage.removeItem('token_expires_at');
  }

  async signup(data: SignupData): Promise<AuthResponse> {
    const response = await fetch(`${API_BASE_URL}/auth/signup`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(data),
    });

    const result = await response.json();

    if (!response.ok) {
      throw new Error(result.message || 'Signup failed');
    }

    // Store tokens if signup successful
    if (result.data?.session?.access_token) {
      this.setToken(result.data.session.access_token);
      if (result.data.session.refresh_token) {
        this.setRefreshToken(result.data.session.refresh_token);
      }
      if (result.data.session.expires_at) {
        this.setTokenExpiry(result.data.session.expires_at);
      }
    }

    return result;
  }

  async login(data: LoginData): Promise<AuthResponse> {
    const response = await fetch(`${API_BASE_URL}/auth/login`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(data),
    });

    const result = await response.json();

    if (!response.ok) {
      throw new Error(result.message || 'Login failed');
    }

    // Store tokens
    if (result.data?.session?.access_token) {
      this.setToken(result.data.session.access_token);
      if (result.data.session.refresh_token) {
        this.setRefreshToken(result.data.session.refresh_token);
      }
      if (result.data.session.expires_at) {
        this.setTokenExpiry(result.data.session.expires_at);
      }
    }

    return result;
  }

  async getProfile() {
    const token = this.getToken();
    if (!token) {
      throw new Error('No token found');
    }

    const response = await fetch(`${API_BASE_URL}/auth/me`, {
      method: 'GET',
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json',
      },
    });

    const result = await response.json();

    if (!response.ok) {
      throw new Error(result.message || 'Failed to get profile');
    }

    return result;
  }

  async logout(): Promise<void> {
    const token = this.getToken();
    if (!token) {
      return;
    }

    try {
      await fetch(`${API_BASE_URL}/auth/logout`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
        },
      });
    } catch (error) {
      console.error('Logout error:', error);
    } finally {
      this.removeToken();
    }
  }

  isAuthenticated(): boolean {
    const token = this.getToken();
    if (!token) return false;

    // Check if token is expired
    const expiresAt = localStorage.getItem('token_expires_at');
    if (expiresAt) {
      const expiryTime = parseInt(expiresAt, 10) * 1000; // Convert to milliseconds
      if (Date.now() >= expiryTime) {
        this.removeToken();
        return false;
      }
    }

    return true;
  }
}

export const authService = new AuthService();
```

#### 2. Create Auth Context (`contexts/AuthContext.tsx`)

```typescript
'use client';

import React, { createContext, useContext, useState, useEffect } from 'react';
import { authService } from '@/lib/auth.service';

interface User {
  id: string;
  email: string;
  role: string;
  is_active: boolean;
}

interface AuthContextType {
  user: User | null;
  loading: boolean;
  login: (email: string, password: string) => Promise<void>;
  signup: (email: string, password: string, role: string, phone?: string) => Promise<void>;
  logout: () => Promise<void>;
  refreshUser: () => Promise<void>;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // Check if user is logged in on mount
    if (authService.isAuthenticated()) {
      refreshUser();
    } else {
      setLoading(false);
    }
  }, []);

  const refreshUser = async () => {
    try {
      const response = await authService.getProfile();
      setUser(response.data);
    } catch (error) {
      console.error('Failed to get user:', error);
      authService.logout();
      setUser(null);
    } finally {
      setLoading(false);
    }
  };

  const login = async (email: string, password: string) => {
    const response = await authService.login({ email, password });
    setUser(response.data.user);
  };

  const signup = async (email: string, password: string, role: string, phone?: string) => {
    const response = await authService.signup({ email, password, role, phone });
    setUser(response.data.user);
  };

  const logout = async () => {
    await authService.logout();
    setUser(null);
  };

  return (
    <AuthContext.Provider value={{ user, loading, login, signup, logout, refreshUser }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
}
```

#### 3. Login Component Example

```typescript
'use client';

import { useState } from 'react';
import { useAuth } from '@/contexts/AuthContext';
import { useRouter } from 'next/navigation';

export default function LoginPage() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  const { login } = useAuth();
  const router = useRouter();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setLoading(true);

    try {
      await login(email, password);
      router.push('/dashboard');
    } catch (err: any) {
      setError(err.message || 'Login failed');
    } finally {
      setLoading(false);
    }
  };

  return (
    <form onSubmit={handleSubmit}>
      <input
        type="email"
        value={email}
        onChange={(e) => setEmail(e.target.value)}
        placeholder="Email"
        required
      />
      <input
        type="password"
        value={password}
        onChange={(e) => setPassword(e.target.value)}
        placeholder="Password"
        required
      />
      {error && <div className="error">{error}</div>}
      <button type="submit" disabled={loading}>
        {loading ? 'Logging in...' : 'Login'}
      </button>
    </form>
  );
}
```

#### 4. Protected Route Example (Next.js Middleware)

```typescript
// middleware.ts
import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';

export function middleware(request: NextRequest) {
  const token = request.cookies.get('access_token')?.value;

  // Check if route requires authentication
  if (request.nextUrl.pathname.startsWith('/dashboard')) {
    if (!token) {
      return NextResponse.redirect(new URL('/login', request.url));
    }
  }

  return NextResponse.next();
}

export const config = {
  matcher: ['/dashboard/:path*', '/admin/:path*'],
};
```

#### 5. API Route Helper (Next.js)

```typescript
// lib/api-client.ts
const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3000';

export async function apiRequest(
  endpoint: string,
  options: RequestInit = {}
): Promise<any> {
  const token = typeof window !== 'undefined' 
    ? localStorage.getItem('access_token') 
    : null;

  const response = await fetch(`${API_BASE_URL}${endpoint}`, {
    ...options,
    headers: {
      'Content-Type': 'application/json',
      ...(token && { Authorization: `Bearer ${token}` }),
      ...options.headers,
    },
  });

  const data = await response.json();

  if (!response.ok) {
    throw new Error(data.message || 'Request failed');
  }

  return data;
}

// Usage:
// const profile = await apiRequest('/auth/me');
// const offers = await apiRequest('/offers');
```

---

## Testing with cURL

### 1. Signup
```bash
curl -X POST http://localhost:3000/auth/signup \
  -H "Content-Type: application/json" \
  -d '{
    "email": "student@example.com",
    "password": "password123",
    "role": "student",
    "phone": "+1234567890"
  }'
```

### 2. Login
```bash
curl -X POST http://localhost:3000/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "student@example.com",
    "password": "password123"
  }'
```

### 3. Get Profile (replace TOKEN with actual token)
```bash
curl -X GET http://localhost:3000/auth/me \
  -H "Authorization: Bearer TOKEN"
```

### 4. Logout
```bash
curl -X POST http://localhost:3000/auth/logout \
  -H "Authorization: Bearer TOKEN"
```

---

## Testing with Postman/Insomnia

1. **Create Environment Variables:**
   - `base_url`: `http://localhost:3000`
   - `access_token`: (will be set after login)

2. **Signup Request:**
   - Method: `POST`
   - URL: `{{base_url}}/auth/signup`
   - Body (JSON):
     ```json
     {
       "email": "test@example.com",
       "password": "password123",
       "role": "student"
     }
     ```
   - Test Script (to save token):
     ```javascript
     if (pm.response.code === 201) {
       const jsonData = pm.response.json();
       pm.environment.set("access_token", jsonData.data.session.access_token);
     }
     ```

3. **Login Request:**
   - Method: `POST`
   - URL: `{{base_url}}/auth/login`
   - Body (JSON): Same as signup
   - Test Script: Same as signup

4. **Get Profile:**
   - Method: `GET`
   - URL: `{{base_url}}/auth/me`
   - Headers: `Authorization: Bearer {{access_token}}`

---

## Error Handling

### Common Error Responses

**401 Unauthorized:**
```json
{
  "statusCode": 401,
  "message": "Invalid email or password",
  "error": "Unauthorized"
}
```

**403 Forbidden:**
```json
{
  "statusCode": 403,
  "message": "Access forbidden",
  "error": "Forbidden"
}
```

**400 Bad Request:**
```json
{
  "statusCode": 400,
  "message": "User with this email already exists",
  "error": "Bad Request"
}
```

---

## Role-Based Access Control

### Protecting Routes by Role

```typescript
// components/ProtectedRoute.tsx
'use client';

import { useAuth } from '@/contexts/AuthContext';
import { useRouter } from 'next/navigation';
import { useEffect } from 'react';

interface ProtectedRouteProps {
  children: React.ReactNode;
  allowedRoles: string[];
}

export default function ProtectedRoute({ children, allowedRoles }: ProtectedRouteProps) {
  const { user, loading } = useAuth();
  const router = useRouter();

  useEffect(() => {
    if (!loading) {
      if (!user) {
        router.push('/login');
      } else if (!allowedRoles.includes(user.role)) {
        router.push('/unauthorized');
      }
    }
  }, [user, loading, allowedRoles, router]);

  if (loading) {
    return <div>Loading...</div>;
  }

  if (!user || !allowedRoles.includes(user.role)) {
    return null;
  }

  return <>{children}</>;
}

// Usage:
// <ProtectedRoute allowedRoles={['admin']}>
//   <AdminDashboard />
// </ProtectedRoute>
```

---

## Environment Variables for Frontend

Create `.env.local` in your Next.js app:

```env
NEXT_PUBLIC_API_URL=http://localhost:3000
```

---

## Complete Example: Signup Page

```typescript
'use client';

import { useState } from 'react';
import { useAuth } from '@/contexts/AuthContext';
import { useRouter } from 'next/navigation';

export default function SignupPage() {
  const [formData, setFormData] = useState({
    email: '',
    password: '',
    role: 'student' as const,
    phone: '',
  });
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  const { signup } = useAuth();
  const router = useRouter();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setLoading(true);

    try {
      await signup(
        formData.email,
        formData.password,
        formData.role,
        formData.phone || undefined
      );
      
      // Show success message
      alert('Signup successful! Please wait for admin approval.');
      router.push('/login');
    } catch (err: any) {
      setError(err.message || 'Signup failed');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div>
      <h1>Sign Up</h1>
      <form onSubmit={handleSubmit}>
        <input
          type="email"
          placeholder="Email"
          value={formData.email}
          onChange={(e) => setFormData({ ...formData, email: e.target.value })}
          required
        />
        <input
          type="password"
          placeholder="Password (min 6 characters)"
          value={formData.password}
          onChange={(e) => setFormData({ ...formData, password: e.target.value })}
          minLength={6}
          required
        />
        <select
          value={formData.role}
          onChange={(e) => setFormData({ ...formData, role: e.target.value as any })}
        >
          <option value="student">Student</option>
          <option value="merchant_corporate">Merchant (Corporate)</option>
          <option value="merchant_branch">Merchant (Branch)</option>
          <option value="admin">Admin</option>
        </select>
        <input
          type="tel"
          placeholder="Phone (optional)"
          value={formData.phone}
          onChange={(e) => setFormData({ ...formData, phone: e.target.value })}
        />
        {error && <div style={{ color: 'red' }}>{error}</div>}
        <button type="submit" disabled={loading}>
          {loading ? 'Signing up...' : 'Sign Up'}
        </button>
      </form>
    </div>
  );
}
```

---

## Token Management

### Storing Tokens

The authentication endpoints return a `session` object containing:
- `access_token`: JWT token for API authentication (store this)
- `refresh_token`: Token for refreshing the access token (store this securely)
- `expires_at`: Unix timestamp when the token expires
- `expires_in`: Number of seconds until expiration (typically 3600 = 1 hour)

### Token Storage Best Practices

1. **Development:** Store tokens in `localStorage` or `sessionStorage` for simplicity
2. **Production:** Consider using `httpOnly` cookies for better security (requires backend support)
3. **Refresh Token:** Store refresh token securely (consider encrypted storage)

### Handling Token Expiration

The access token typically expires after 1 hour. You should:

1. **Check expiration before API calls:**
```typescript
function isTokenExpired(expiresAt: number): boolean {
  return Date.now() >= expiresAt * 1000;
}
```

2. **Implement automatic token refresh:**
```typescript
async function refreshAccessToken(refreshToken: string): Promise<string> {
  // Note: This requires using Supabase client directly
  // The backend doesn't expose a refresh endpoint
  // You can use @supabase/supabase-js on the frontend
  const { data, error } = await supabase.auth.refreshSession({
    refresh_token: refreshToken
  });
  
  if (error) throw error;
  return data.session.access_token;
}
```

3. **Alternative:** Re-authenticate the user when token expires by redirecting to login

### Using Supabase Client for Token Refresh

If you need automatic token refresh, you can use the Supabase client directly:

```typescript
import { createClient } from '@supabase/supabase-js';

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
);

// Supabase client handles token refresh automatically
// Use supabase.auth.getSession() to get current session
```

**Note:** The backend uses Supabase for authentication. If you need automatic token refresh, consider using the Supabase client on the frontend, or implement a refresh endpoint in the backend.

---

## Tips

1. **Token Storage:** Use `httpOnly` cookies in production for better security
2. **Token Refresh:** Implement token refresh logic before expiration, or use Supabase client
3. **Error Handling:** Always handle network errors and API errors gracefully
4. **Loading States:** Show loading indicators during API calls
5. **Form Validation:** Validate forms on both client and server side
6. **Redirect Logic:** Redirect based on user role after login
7. **Token Expiration:** Monitor token expiration and refresh or re-authenticate as needed

---

## Next Steps

1. Set up your frontend environment variables
2. Implement the auth service in your frontend
3. Create login/signup pages
4. Add protected routes
5. Implement role-based access control
6. Test all authentication flows

