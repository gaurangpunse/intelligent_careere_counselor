# 📧 Email Verification Setup Instructions

## Supabase Email Configuration

To enable email verification in your Supabase project, follow these steps:

### 1. Enable Email Confirmation

1. Go to your Supabase Dashboard
2. Navigate to **Authentication** → **Settings**
3. Find the **Email** section
4. **Enable** "Confirm email" option
5. Save the changes

### 2. Configure Email Templates (Optional)

1. In the same **Authentication** → **Settings** page
2. Scroll down to **Email Templates**
3. You can customize the email templates for:
   - **Confirmation email** (sent after signup)
   - **Magic Link** (if you want to use magic link authentication)
   - **Password reset** (for password recovery)

### 3. Email Provider Setup (For Production)

For development, Supabase uses their default email service. For production, you should configure your own email provider:

1. Go to **Authentication** → **Settings** → **SMTP Settings**
2. Choose your email provider (SendGrid, Mailgun, etc.)
3. Configure the SMTP settings

### 4. Redirect URLs (Important!)

1. In **Authentication** → **Settings**
2. Find **Site URL** and **Redirect URLs**
3. Add your app's URL patterns:
   - For development: `http://localhost:3000/**`
   - For production: `https://yourdomain.com/**`
   - For mobile apps: `your-app-scheme://login-callback`

### 5. Testing Email Verification

#### Development Testing:
1. Sign up with a real email address
2. Check your email inbox (and spam folder)
3. Click the verification link
4. The app should now recognize you as verified

#### Email Configuration Checklist:
- [ ] Email confirmation is enabled in Supabase settings
- [ ] Site URL is configured correctly
- [ ] Redirect URLs include your app domains
- [ ] Email templates are customized (optional)
- [ ] SMTP provider is configured for production (optional)

## App Behavior After Email Verification

Once properly configured, your app will:

1. **On Signup**: User receives verification email and is redirected to verification page
2. **On Login (unverified)**: User is redirected to verification page
3. **On Login (verified)**: User proceeds directly to dashboard
4. **Resend Email**: Users can request new verification emails with cooldown timer
5. **Verification Check**: Users can manually check if they've been verified

## Troubleshooting

### Email Not Received:
- Check spam/junk folder
- Verify email address is correct
- Check Supabase logs for delivery errors
- Ensure SMTP settings are correct (production)

### Verification Link Not Working:
- Check redirect URLs in Supabase settings
- Verify site URL is correct
- Check browser console for errors

### App Not Recognizing Verification:
- User may need to refresh the app
- Check if session is being refreshed properly
- Verify email confirmation field is being checked

---

**Note**: For development, you can temporarily disable email confirmation in Supabase settings to test other app features, but remember to re-enable it for production!