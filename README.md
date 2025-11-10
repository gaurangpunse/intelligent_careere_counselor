# intelligent_career_counselling

# 🎯 Intelligent Career Counselling App

A comprehensive Flutter app that provides AI-powered career guidance and counselling services. Users can take detailed assessments and receive personalized career recommendations, skill development plans, and actionable next steps.

## ✨ Features

### 🔐 Authentication & User Management
- **Secure Authentication**: Supabase-powered sign up, login, and password management
- **User Profiles**: Comprehensive profile management with personal details
- **Session Management**: Persistent login with automatic session handling

### 🎯 Career Assessment & Guidance
- **Detailed Questionnaire**: Comprehensive career assessment covering education, skills, interests, and preferences
- **AI-Powered Analysis**: Advanced AI analysis using OpenAI GPT models with fallback offline heuristics
- **Personalized Recommendations**: Tailored career paths, skill development plans, and certification suggestions
- **4-Week Learning Plans**: Structured learning roadmaps with actionable steps

### 📊 Dashboard & History
- **Interactive Dashboard**: Clean, modern interface with quick actions and statistics
- **Assessment History**: Complete history of all career assessments and guidance
- **Progress Tracking**: Statistics and insights on assessment frequency and career development
- **Quick Actions**: Easy access to new assessments and previous guidance

### 💾 Data Persistence & Management
- **Supabase Integration**: Full backend with PostgreSQL database
- **Real-time Sync**: Automatic data synchronization across devices
- **Data Export**: Share and export career guidance results
- **Secure Storage**: Row-level security and proper data protection

### 🤖 AI Integration
- **Multiple AI Providers**: Support for OpenAI API and custom proxy endpoints
- **Intelligent Fallback**: Offline heuristic-based guidance when AI services are unavailable
- **Error Handling**: Robust error handling with user-friendly fallback responses
- **Rate Limiting**: Built-in retry logic and rate limit handling

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>=3.0.0)
- Dart SDK (>=3.0.0)
- Supabase account
- OpenAI API key (optional, for AI features)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd intelligent_career_counselling
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up Supabase**
   - Create a new Supabase project
   - Run the SQL scripts from `supabase/authentication.sql` in your Supabase SQL editor
   - Update `lib/supabase_config.dart` with your project URL and anon key

4. **Configure environment variables**
   ```bash
   cp .env.example .env
   # Edit .env file with your actual values
   ```

5. **Run the app**
   ```bash
   flutter run
   ```

## 🏗️ Project Structure

```
lib/
├── main.dart                          # App entry point
├── supabase_config.dart              # Supabase configuration
├── models/                           # Data models
│   ├── assessment_data.dart          # Assessment form data model
│   ├── career_guidance.dart          # Career guidance response model
│   └── chat_message.dart             # Chat message model
├── services/                         # Business logic services
│   ├── ai_service.dart               # AI integration service
│   ├── auth_service.dart             # Authentication service
│   └── data_service.dart             # Data persistence service
├── views/                            # UI screens
│   ├── dashboard_page.dart           # Main dashboard with navigation
│   ├── dashboard_home_view.dart      # Dashboard home with stats and history
│   ├── career_form_view.dart         # Career assessment form
│   ├── career_guidance_results_page.dart # Results display page
│   ├── login_page.dart               # User login
│   ├── signup_page.dart              # User registration
│   ├── profile_view.dart             # User profile display
│   ├── edit_profile_page.dart        # Profile editing
│   ├── change_password_page.dart     # Password management
│   └── assessments_view.dart         # Assessment overview
└── widgets/                          # Reusable UI components
```

## 🔧 Configuration

### Supabase Setup

1. **Database Tables**: The app requires specific database tables. Run the SQL from `supabase/authentication.sql`:
   - `profiles` - User profile information
   - `career_guidance` - Career assessment results and AI responses

2. **Row Level Security**: The SQL script sets up proper RLS policies to ensure users can only access their own data.

3. **Authentication**: Supabase handles user registration, login, and session management.

### AI Service Configuration

The app supports multiple AI providers:

- **OpenAI Direct**: Set `OPENAI_API_KEY` environment variable
- **Proxy Endpoint**: Set `AI_PROXY_ENDPOINT` for custom AI proxy
- **Offline Mode**: Automatic fallback with heuristic-based guidance

### Environment Variables

Create a `.env` file based on `.env.example`:

```env
SUPABASE_URL=your_supabase_project_url
SUPABASE_ANON_KEY=your_supabase_anon_key
OPENAI_API_KEY=your_openai_api_key
AI_PROXY_ENDPOINT=your_proxy_endpoint
```

## 🎨 User Experience

### Assessment Flow
1. **Login/Signup**: Secure authentication with Supabase
2. **Dashboard**: Overview of previous assessments and quick actions
3. **Career Form**: Comprehensive questionnaire covering:
   - Educational background
   - Technical and soft skills
   - Interests and preferences
   - Career goals and constraints
4. **AI Processing**: Real-time AI analysis with loading indicators
5. **Results Display**: Formatted career guidance with:
   - Role recommendations
   - Skill development plans
   - Learning resources
   - 4-week action plan
6. **Save & Share**: Option to save results and share via clipboard

### Navigation
- **Sidebar Navigation**: Clean, intuitive navigation between sections
- **Dashboard Home**: Statistics, recent assessments, and quick actions
- **Career Guide**: Assessment form and guidance
- **Profile Management**: User settings and account management

## 🛠️ Technical Features

### Error Handling
- **Network Errors**: Graceful handling of connectivity issues
- **API Failures**: Automatic fallback to offline mode
- **User Feedback**: Clear error messages and recovery options
- **Retry Logic**: Automatic retry with exponential backoff

### Data Management
- **Real-time Sync**: Automatic synchronization with Supabase
- **Offline Support**: Limited offline functionality with local storage
- **Data Validation**: Comprehensive form validation and data integrity
- **Security**: Row-level security and proper data encryption

### Performance
- **Lazy Loading**: Efficient loading of assessment history
- **Caching**: Smart caching of user data and preferences
- **Responsive Design**: Optimized for various screen sizes
- **Smooth Animations**: Polished UI transitions and loading states

## 🚀 Deployment

### Building for Production

```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

### Environment Configuration

Ensure all environment variables are properly set for production:
- Use production Supabase instance
- Configure proper API keys
- Enable proper security settings

## 📱 Platform Support

- ✅ **Android**: Full support (API 21+)
- ✅ **iOS**: Full support (iOS 12+)
- ✅ **Web**: Full support with responsive design
- ✅ **Windows**: Desktop support
- ✅ **macOS**: Desktop support
- ✅ **Linux**: Desktop support

## 🔒 Security Features

- **Row Level Security**: Database-level access control
- **JWT Authentication**: Secure token-based authentication
- **Data Encryption**: All data encrypted in transit and at rest
- **Input Validation**: Comprehensive validation and sanitization
- **API Security**: Proper API key management and rate limiting

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

If you encounter any issues or have questions:

1. Check the troubleshooting section below
2. Search existing issues
3. Create a new issue with detailed information

### Troubleshooting

**Authentication Issues**:
- Verify Supabase configuration
- Check network connectivity
- Ensure proper API keys

**AI Service Issues**:
- Verify OpenAI API key
- Check API quotas and limits
- Test with offline mode

**Database Issues**:
- Run SQL scripts in correct order
- Verify RLS policies
- Check user permissions

---

Built with ❤️ using Flutter and Supabase

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
#   i n t e l l i g e n t _ c a r e e r e _ c o u n s e l o r  
 