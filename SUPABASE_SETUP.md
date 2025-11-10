# 🔧 Supabase Setup Guide

## Step 1: Create a Supabase Project

1. Go to [https://supabase.com](https://supabase.com)
2. Sign up or log in to your account
3. Click "New Project"
4. Choose your organization
5. Give your project a name (e.g., "Intelligent Career Counselling")
6. Set a database password (save this - you'll need it later)
7. Choose a region close to your users
8. Click "Create new project"

## Step 2: Get Your Project Credentials

1. Once your project is created, go to **Settings** → **API**
2. You'll see:
   - **Project URL** (something like `https://abcdefgh.supabase.co`)
   - **Project API Keys**:
     - `anon` `public` key (this is safe to use in your app)
     - `service_role` `secret` key (keep this private!)

## Step 3: Update Your Flutter App Configuration

1. Open `lib/supabase_config.dart` in your Flutter project
2. Replace the placeholder values:

```dart
const String supabaseUrl = 'https://YOUR-PROJECT-REF.supabase.co';
const String supabaseAnonKey = 'your-anon-key-here';
```

**Example:**
```dart
const String supabaseUrl = 'https://abcdefghijklmnop.supabase.co';
const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFiY2RlZmdoaWprbG1ub3AiLCJyb2xlIjoiYW5vbiIsImlhdCI6MTY0ODc0NjQwMCwiZXhwIjoxOTY0MzIyNDAwfQ.SomeRandomSignature';
```

## Step 4: Set Up Database Tables

1. In your Supabase dashboard, go to **SQL Editor**
2. Create a new query and paste the contents from `supabase/authentication.sql`
3. Run the query to create all necessary tables and policies

## Step 5: Test the Connection

1. Run your Flutter app: `flutter run`
2. Try to sign up with a test account
3. If successful, you should see the user in **Authentication** → **Users** in your Supabase dashboard

## 🚨 Common Issues and Solutions

### Issue: "Invalid API key" (401 error)
**Solution:** 
- Double-check that you copied the correct `anon` key (not the `service_role` key)
- Make sure there are no extra spaces or characters
- The anon key should start with `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9`

### Issue: "Project URL not found"
**Solution:**
- Verify the project URL format: `https://YOUR-PROJECT-REF.supabase.co`
- Make sure your project is fully deployed (green status in dashboard)

### Issue: Database connection errors
**Solution:**
- Run the SQL setup script from `supabase/authentication.sql`
- Check that Row Level Security policies are properly set up

### Issue: Authentication not working
**Solution:**
- Verify email confirmations are disabled for development (Settings → Authentication → Email)
- Check that your auth policies allow user registration

## 🔒 Security Best Practices

1. **Never commit secrets**: Add `.env` to your `.gitignore`
2. **Use environment variables** for production
3. **Enable Row Level Security** on all tables
4. **Set up proper auth policies**

## 📝 Environment Variables (Optional)

For better security, you can use environment variables:

1. Create a `.env` file in your project root:
```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
```

2. Update `supabase_config.dart`:
```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

const String supabaseUrl = String.fromEnvironment('SUPABASE_URL', 
  defaultValue: 'https://your-project.supabase.co');
const String supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY', 
  defaultValue: 'your-anon-key-here');
```

## ✅ Verification Checklist

- [ ] Supabase project created and deployed
- [ ] Project URL copied correctly (starts with `https://` and ends with `.supabase.co`)
- [ ] Anon key copied correctly (starts with `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9`)
- [ ] Database tables created using the SQL script
- [ ] App builds and runs without configuration errors
- [ ] User registration works (check Supabase dashboard → Authentication → Users)

## 🆘 Still Having Issues?

1. Check the Flutter console for detailed error messages
2. Verify your Supabase project status in the dashboard
3. Try creating a simple test user directly in the Supabase dashboard
4. Check the Supabase logs in your dashboard for any errors

---

Once you complete these steps, your career counselling app should connect successfully to Supabase!