import '../models/adaptive_question.dart';

class CareerRecommendationEngine {
  static final CareerRecommendationEngine _instance =
      CareerRecommendationEngine._internal();
  factory CareerRecommendationEngine() => _instance;
  CareerRecommendationEngine._internal();

  static CareerRecommendationEngine get instance => _instance;

  Map<String, dynamic> generateCustomizedRecommendations(
    AssessmentSession session,
  ) {
    final answers = session.getAllAnswers();

    return {
      'career_paths': _generateCareerPaths(answers),
      'companies': _getTargetCompanies(answers),
      'courses': _getRecommendedCourses(answers),
      'certifications': _getRelevantCertifications(answers),
      'salary_insights': _getSalaryInsights(answers),
      'next_steps': _getActionableNextSteps(answers),
      'networking': _getNetworkingOpportunities(answers),
      'job_portals': _getJobPortals(answers),
      'skills_gap': _getSkillsGapAnalysis(answers),
      'timeline': _get90DayPlan(answers),
    };
  }

  List<Map<String, dynamic>> _generateCareerPaths(
    Map<String, dynamic> answers,
  ) {
    final interests = answers['career_interests'] as List? ?? [];
    final techSpecialization = answers['tech_specialization'];
    final businessRole = answers['business_role_type'];
    final creativeField = answers['creative_domain'];
    final healthcarePath = answers['healthcare_path'];
    final experienceLevel = answers['education_level'];
    final salaryExpectation = answers['salary_expectations'];

    List<Map<String, dynamic>> paths = [];

    // Tech Career Paths
    if (interests.contains('Software Development') ||
        techSpecialization != null) {
      paths.addAll(
        _getTechCareerPaths(
          techSpecialization,
          experienceLevel,
          salaryExpectation,
        ),
      );
    }

    // Business Career Paths
    if (interests.contains('Finance') ||
        interests.contains('Marketing') ||
        businessRole != null) {
      paths.addAll(
        _getBusinessCareerPaths(
          businessRole,
          experienceLevel,
          salaryExpectation,
        ),
      );
    }

    // Creative Career Paths
    if (interests.contains('Design') || creativeField != null) {
      paths.addAll(
        _getCreativeCareerPaths(
          creativeField,
          experienceLevel,
          salaryExpectation,
        ),
      );
    }

    // Healthcare Career Paths
    if (interests.contains('Healthcare') || healthcarePath != null) {
      paths.addAll(
        _getHealthcareCareerPaths(
          healthcarePath,
          experienceLevel,
          salaryExpectation,
        ),
      );
    }

    // Data Science paths
    if (interests.contains('Data Science')) {
      paths.addAll(
        _getDataScienceCareerPaths(experienceLevel, salaryExpectation),
      );
    }

    return paths.take(4).toList();
  }

  List<Map<String, dynamic>> _getTechCareerPaths(
    String? specialization,
    String? experience,
    String? salary,
  ) {
    final baseSalaryMultiplier = _getSalaryMultiplier(experience);

    switch (specialization) {
      case 'Frontend':
        return [
          {
            'title': 'Frontend Developer',
            'description': 'Build user interfaces using React, Vue, or Angular',
            'salary_range':
                '${(4 * baseSalaryMultiplier).toInt()}-${(8 * baseSalaryMultiplier).toInt()} LPA',
            'growth_path':
                'Frontend Dev → Senior Frontend → Lead Developer → Engineering Manager',
            'demand': 'High - 15,000+ openings',
            'remote_friendly': true,
          },
          {
            'title': 'UI/UX Developer',
            'description':
                'Bridge design and development with interactive prototypes',
            'salary_range':
                '${(5 * baseSalaryMultiplier).toInt()}-${(10 * baseSalaryMultiplier).toInt()} LPA',
            'growth_path':
                'UI/UX Dev → Senior UI/UX → Design System Lead → Product Designer',
            'demand': 'Very High - 8,000+ openings',
            'remote_friendly': true,
          },
        ];

      case 'Backend':
        return [
          {
            'title': 'Backend Developer',
            'description':
                'Build APIs and server-side applications using Node.js, Python, Java',
            'salary_range':
                '${(5 * baseSalaryMultiplier).toInt()}-${(12 * baseSalaryMultiplier).toInt()} LPA',
            'growth_path':
                'Backend Dev → Senior Backend → Tech Lead → Engineering Manager',
            'demand': 'Very High - 20,000+ openings',
            'remote_friendly': true,
          },
          {
            'title': 'DevOps Engineer',
            'description': 'Manage deployments, CI/CD, cloud infrastructure',
            'salary_range':
                '${(6 * baseSalaryMultiplier).toInt()}-${(15 * baseSalaryMultiplier).toInt()} LPA',
            'growth_path':
                'DevOps → Senior DevOps → DevOps Lead → Cloud Architect',
            'demand': 'High - 12,000+ openings',
            'remote_friendly': true,
          },
        ];

      case 'Fullstack':
        return [
          {
            'title': 'Full Stack Developer',
            'description':
                'Build complete web applications from frontend to backend',
            'salary_range':
                '${(6 * baseSalaryMultiplier).toInt()}-${(14 * baseSalaryMultiplier).toInt()} LPA',
            'growth_path':
                'Fullstack Dev → Senior Fullstack → Tech Lead → Engineering Manager',
            'demand': 'Very High - 25,000+ openings',
            'remote_friendly': true,
          },
        ];

      case 'Mobile':
        return [
          {
            'title': 'Mobile App Developer',
            'description':
                'Build iOS/Android apps using React Native, Flutter, or native',
            'salary_range':
                '${(5 * baseSalaryMultiplier).toInt()}-${(12 * baseSalaryMultiplier).toInt()} LPA',
            'growth_path':
                'Mobile Dev → Senior Mobile Dev → Mobile Lead → Product Manager',
            'demand': 'High - 10,000+ openings',
            'remote_friendly': true,
          },
        ];

      default:
        return [
          {
            'title': 'Software Developer',
            'description':
                'General software development across various technologies',
            'salary_range':
                '${(4 * baseSalaryMultiplier).toInt()}-${(10 * baseSalaryMultiplier).toInt()} LPA',
            'growth_path':
                'Developer → Senior Developer → Tech Lead → Engineering Manager',
            'demand': 'Very High - 30,000+ openings',
            'remote_friendly': true,
          },
        ];
    }
  }

  List<Map<String, dynamic>> _getBusinessCareerPaths(
    String? role,
    String? experience,
    String? salary,
  ) {
    final baseSalaryMultiplier = _getSalaryMultiplier(experience);

    switch (role) {
      case 'Marketing':
        return [
          {
            'title': 'Digital Marketing Specialist',
            'description':
                'Manage social media, SEO, PPC campaigns, content marketing',
            'salary_range':
                '${(3 * baseSalaryMultiplier).toInt()}-${(8 * baseSalaryMultiplier).toInt()} LPA',
            'growth_path':
                'Digital Marketing → Senior Marketing → Marketing Manager → CMO',
            'demand': 'High - 12,000+ openings',
            'remote_friendly': true,
          },
        ];

      case 'Finance':
        return [
          {
            'title': 'Financial Analyst',
            'description':
                'Analyze financial data, create reports, support investment decisions',
            'salary_range':
                '${(4 * baseSalaryMultiplier).toInt()}-${(10 * baseSalaryMultiplier).toInt()} LPA',
            'growth_path': 'Analyst → Senior Analyst → Finance Manager → CFO',
            'demand': 'Medium - 8,000+ openings',
            'remote_friendly': false,
          },
        ];

      default:
        return [
          {
            'title': 'Business Analyst',
            'description':
                'Bridge business and technology to improve processes',
            'salary_range':
                '${(4 * baseSalaryMultiplier).toInt()}-${(9 * baseSalaryMultiplier).toInt()} LPA',
            'growth_path': 'BA → Senior BA → Product Manager → VP Product',
            'demand': 'High - 15,000+ openings',
            'remote_friendly': true,
          },
        ];
    }
  }

  List<Map<String, dynamic>> _getCreativeCareerPaths(
    String? field,
    String? experience,
    String? salary,
  ) {
    final baseSalaryMultiplier = _getSalaryMultiplier(experience);

    return [
      {
        'title': 'UI/UX Designer',
        'description':
            'Design user interfaces and experiences for apps and websites',
        'salary_range':
            '${(4 * baseSalaryMultiplier).toInt()}-${(12 * baseSalaryMultiplier).toInt()} LPA',
        'growth_path':
            'UI/UX Designer → Senior Designer → Design Lead → Head of Design',
        'demand': 'Very High - 10,000+ openings',
        'remote_friendly': true,
      },
    ];
  }

  List<Map<String, dynamic>> _getHealthcareCareerPaths(
    String? path,
    String? experience,
    String? salary,
  ) {
    final baseSalaryMultiplier = _getSalaryMultiplier(experience);

    return [
      {
        'title': 'Healthcare Data Analyst',
        'description': 'Analyze healthcare data to improve patient outcomes',
        'salary_range':
            '${(5 * baseSalaryMultiplier).toInt()}-${(12 * baseSalaryMultiplier).toInt()} LPA',
        'growth_path':
            'Data Analyst → Senior Analyst → Data Science Manager → Chief Data Officer',
        'demand': 'Medium - 3,000+ openings',
        'remote_friendly': true,
      },
    ];
  }

  List<Map<String, dynamic>> _getDataScienceCareerPaths(
    String? experience,
    String? salary,
  ) {
    final baseSalaryMultiplier = _getSalaryMultiplier(experience);

    return [
      {
        'title': 'Data Scientist',
        'description':
            'Build ML models, analyze data patterns, generate insights',
        'salary_range':
            '${(6 * baseSalaryMultiplier).toInt()}-${(18 * baseSalaryMultiplier).toInt()} LPA',
        'growth_path':
            'Data Scientist → Senior Data Scientist → ML Engineer → Chief Data Officer',
        'demand': 'Very High - 8,000+ openings',
        'remote_friendly': true,
      },
    ];
  }

  double _getSalaryMultiplier(String? experience) {
    switch (experience) {
      case 'Class 10':
      case 'Class 12':
        return 0.8;
      case 'Diploma':
      case 'Undergraduate':
        return 1.0;
      case 'Postgraduate':
        return 1.3;
      case 'Working Professional':
        return 1.5;
      default:
        return 1.0;
    }
  }

  List<Map<String, dynamic>> _getTargetCompanies(Map<String, dynamic> answers) {
    final interests = answers['career_interests'] as List? ?? [];
    final companySize = answers['ideal_company_size'];

    List<Map<String, dynamic>> companies = [];

    if (interests.contains('Software Development') ||
        interests.contains('Data Science')) {
      companies.addAll([
        {
          'name': 'TCS',
          'type': 'Large Corporation',
          'locations': ['Mumbai', 'Pune', 'Bangalore', 'Chennai', 'Hyderabad'],
          'hiring_level': 'Entry to Senior',
          'application_link': 'https://careers.tcs.com',
          'insider_tip': 'Apply through campus drives for higher success rate',
        },
        {
          'name': 'Infosys',
          'type': 'Large Corporation',
          'locations': ['Bangalore', 'Pune', 'Chennai', 'Hyderabad'],
          'hiring_level': 'Entry to Senior',
          'application_link': 'https://careers.infosys.com',
          'insider_tip': 'Strong training programs for freshers',
        },
        {
          'name': 'Flipkart',
          'type': 'Large Corporation',
          'locations': ['Bangalore', 'Hyderabad', 'Delhi NCR'],
          'hiring_level': 'Mid to Senior',
          'application_link': 'https://careers.flipkart.com',
          'insider_tip': 'Focus on system design and problem-solving skills',
        },
        {
          'name': 'Zomato',
          'type': 'Medium',
          'locations': ['Delhi NCR', 'Bangalore'],
          'hiring_level': 'All levels',
          'application_link': 'https://careers.zomato.com',
          'insider_tip': 'Emphasize product thinking and customer focus',
        },
        {
          'name': 'Razorpay',
          'type': 'Medium',
          'locations': ['Bangalore', 'Delhi NCR'],
          'hiring_level': 'All levels',
          'application_link': 'https://razorpay.com/careers',
          'insider_tip':
              'Strong technical interviews, prepare data structures well',
        },
      ]);
    }

    // Filter by company size preference
    if (companySize != null && companySize != 'No preference') {
      companies = companies
          .where(
            (company) => company['type'].toString().toLowerCase().contains(
              companySize.toLowerCase(),
            ),
          )
          .toList();
    }

    return companies.take(6).toList();
  }

  List<Map<String, dynamic>> _getRecommendedCourses(
    Map<String, dynamic> answers,
  ) {
    final interests = answers['career_interests'] as List? ?? [];
    final learningStyle = answers['learning_preference'] as List? ?? [];

    List<Map<String, dynamic>> courses = [];

    if (interests.contains('Software Development')) {
      if (learningStyle.contains('Videos')) {
        courses.addAll([
          {
            'title': 'Complete Web Development Bootcamp',
            'provider': 'Udemy',
            'duration': '3-4 months',
            'cost': '₹1,499 (often ₹499 on sale)',
            'rating': '4.7/5',
            'link':
                'https://udemy.com/course/the-complete-web-development-bootcamp/',
            'outcome': 'Build 5+ projects, job-ready portfolio',
          },
          {
            'title': 'React - The Complete Guide',
            'provider': 'Udemy',
            'duration': '2-3 months',
            'cost': '₹1,499',
            'rating': '4.6/5',
            'link':
                'https://udemy.com/course/react-the-complete-guide-incl-redux/',
            'outcome': 'Master React, Redux, hooks, context',
          },
        ]);
      }

      if (learningStyle.contains('Structured learning')) {
        courses.addAll([
          {
            'title': 'Full Stack Web Development',
            'provider': 'Coding Ninjas',
            'duration': '6-8 months',
            'cost': '₹75,000-₹1,50,000',
            'rating': '4.5/5',
            'link':
                'https://codingninjas.com/courses/full-stack-web-development',
            'outcome': 'Guaranteed placement assistance, 1:1 mentoring',
          },
        ]);
      }
    }

    if (interests.contains('Data Science')) {
      courses.addAll([
        {
          'title': 'Data Science Specialization',
          'provider': 'Coursera (Johns Hopkins)',
          'duration': '4-6 months',
          'cost': '₹3,000/month (financial aid available)',
          'rating': '4.5/5',
          'link': 'https://coursera.org/specializations/jhu-data-science',
          'outcome': 'University certificate, capstone project',
        },
        {
          'title': 'Applied Data Science Program',
          'provider': 'IIT Madras (Coursera)',
          'duration': '8 months',
          'cost': '₹49,000',
          'rating': '4.8/5',
          'link': 'https://onlinedegree.iitm.ac.in/course_pages/BSCS.html',
          'outcome': 'IIT certificate, industry projects',
        },
      ]);
    }

    return courses.take(4).toList();
  }

  List<Map<String, dynamic>> _getRelevantCertifications(
    Map<String, dynamic> answers,
  ) {
    final interests = answers['career_interests'] as List? ?? [];

    List<Map<String, dynamic>> certifications = [];

    if (interests.contains('Software Development')) {
      certifications.addAll([
        {
          'name': 'AWS Certified Developer',
          'provider': 'Amazon Web Services',
          'cost': '₹12,000',
          'validity': '3 years',
          'difficulty': 'Intermediate',
          'prep_time': '2-3 months',
          'value': 'High - increases salary by 15-25%',
          'next_exam': 'Available year-round at Pearson centers',
        },
        {
          'name': 'Google Cloud Professional Developer',
          'provider': 'Google Cloud',
          'cost': '₹15,000',
          'validity': '2 years',
          'difficulty': 'Intermediate-Advanced',
          'prep_time': '3-4 months',
          'value': 'High - preferred by many startups',
          'next_exam': 'Available year-round',
        },
        {
          'name': 'Microsoft Azure Developer Associate',
          'provider': 'Microsoft',
          'cost': '₹12,000',
          'validity': '2 years',
          'difficulty': 'Intermediate',
          'prep_time': '2-3 months',
          'value': 'High - especially for enterprise roles',
          'next_exam': 'Available year-round',
        },
      ]);
    }

    if (interests.contains('Data Science')) {
      certifications.addAll([
        {
          'name': 'TensorFlow Developer Certificate',
          'provider': 'Google',
          'cost': '₹7,500',
          'validity': '3 years',
          'difficulty': 'Intermediate',
          'prep_time': '2-3 months',
          'value': 'Very High - industry standard for ML roles',
          'next_exam': 'Available year-round online',
        },
      ]);
    }

    return certifications.take(3).toList();
  }

  Map<String, dynamic> _getSalaryInsights(Map<String, dynamic> answers) {
    final interests = answers['career_interests'] as List? ?? [];

    Map<String, dynamic> insights = {
      'current_market': {},
      'growth_projection': {},
      'location_comparison': {},
      'negotiation_tips': [],
    };

    if (interests.contains('Software Development')) {
      insights['current_market'] = {
        'entry_level': '3-6 LPA',
        'mid_level': '8-15 LPA',
        'senior_level': '18-35 LPA',
        'factors': [
          'Company size',
          'Tech stack',
          'Location',
          'Interview performance',
        ],
      };

      insights['growth_projection'] = {
        'year_1': '+20-30% with job switch',
        'year_3': '+40-60% with senior role',
        'year_5': '+100-150% with lead position',
      };

      insights['location_comparison'] = {
        'Bangalore': 'Highest paying (15-20% premium)',
        'Mumbai': 'High cost of living, adjust salary accordingly',
        'Pune': 'Good balance of salary and cost',
        'Hyderabad': 'Growing hub, competitive salaries',
        'Remote': 'Access to global opportunities',
      };

      insights['negotiation_tips'] = [
        'Research Glassdoor/AmbitionBox for company-specific data',
        'Highlight unique skills (cloud, ML, system design)',
        'Mention competing offers (if true)',
        'Ask for signing bonus if base salary is fixed',
        'Consider ESOPs for startups (can be valuable)',
      ];
    }

    return insights;
  }

  List<Map<String, dynamic>> _getActionableNextSteps(
    Map<String, dynamic> answers,
  ) {
    final interests = answers['career_interests'] as List? ?? [];

    List<Map<String, dynamic>> steps = [];

    // Week 1-2 steps
    steps.add({
      'timeframe': 'Week 1-2',
      'title': 'Profile Setup & Market Research',
      'tasks': [
        'Update LinkedIn profile with target role keywords',
        'Create GitHub portfolio with 2-3 projects',
        'Research 10 target companies on Glassdoor',
        'Join relevant Discord/Slack communities',
        'Set up job alerts on Naukri, LinkedIn, AngelList',
      ],
      'outcome': 'Professional online presence established',
    });

    // Week 3-4 steps
    if (interests.contains('Software Development')) {
      steps.add({
        'timeframe': 'Week 3-4',
        'title': 'Skill Building Sprint',
        'tasks': [
          'Complete one online coding challenge daily (LeetCode/HackerRank)',
          'Build a CRUD application in your preferred stack',
          'Contribute to 1 open source project',
          'Practice system design basics (if applying for senior roles)',
          'Mock interview with friends/platforms like Pramp',
        ],
        'outcome': 'Interview-ready technical skills',
      });
    }

    // Month 2 steps
    steps.add({
      'timeframe': 'Month 2',
      'title': 'Active Job Hunting',
      'tasks': [
        'Apply to 5-7 companies per week',
        'Reach out to 3 professionals for informational interviews',
        'Attend 2 tech meetups/webinars for networking',
        'Prepare STAR format answers for behavioral questions',
        'Create a follow-up schedule for applications',
      ],
      'outcome': 'Multiple interview opportunities',
    });

    // Month 3 steps
    steps.add({
      'timeframe': 'Month 3',
      'title': 'Interview & Negotiation',
      'tasks': [
        'Schedule and complete interviews',
        'Send thank-you emails within 24 hours',
        'Research salary ranges for final round companies',
        'Prepare negotiation strategy with multiple offers',
        'Plan your notice period and transition',
      ],
      'outcome': 'Job offer with competitive package',
    });

    return steps;
  }

  List<Map<String, dynamic>> _getNetworkingOpportunities(
    Map<String, dynamic> answers,
  ) {
    final interests = answers['career_interests'] as List? ?? [];
    final location = answers['location_preference'] as List? ?? [];

    List<Map<String, dynamic>> opportunities = [];

    if (interests.contains('Software Development')) {
      opportunities.addAll([
        {
          'type': 'Meetup',
          'name': 'Bangalore JS',
          'frequency': 'Monthly',
          'location': 'Bangalore',
          'link': 'https://meetup.com/bangalorejs',
          'value': 'Learn latest JS trends, network with developers',
        },
        {
          'type': 'Conference',
          'name': 'ReactFoo',
          'frequency': 'Annual',
          'location': 'Bangalore/Online',
          'link': 'https://reactfoo.in',
          'value': 'Premium React conference, job opportunities',
        },
        {
          'type': 'Online Community',
          'name': 'IndiaJS Slack',
          'frequency': 'Daily',
          'location': 'Online',
          'link': 'https://indiajs.slack.com',
          'value': 'Daily discussions, job postings, mentorship',
        },
        {
          'type': 'Hackathon',
          'name': 'Smart India Hackathon',
          'frequency': 'Annual',
          'location': 'Multiple cities',
          'link': 'https://sih.gov.in',
          'value': 'Build projects, win prizes, get noticed by companies',
        },
      ]);
    }

    // Filter by user's location preference
    if (location.isNotEmpty) {
      opportunities = opportunities
          .where(
            (opp) =>
                opp['location'] == 'Online' ||
                location.any((loc) => opp['location'].toString().contains(loc)),
          )
          .toList();
    }

    return opportunities.take(5).toList();
  }

  List<Map<String, dynamic>> _getJobPortals(Map<String, dynamic> answers) {
    return [
      {
        'name': 'LinkedIn',
        'best_for': 'All roles, especially mid-senior level',
        'tip': 'Use "Open to Work" frame, post technical content',
        'success_rate': 'High for experienced professionals',
        'link': 'https://linkedin.com/jobs',
      },
      {
        'name': 'Naukri.com',
        'best_for': 'Entry to mid-level, Indian companies',
        'tip': 'Update profile weekly for better visibility',
        'success_rate': 'Very High for Indian market',
        'link': 'https://naukri.com',
      },
      {
        'name': 'AngelList (Wellfound)',
        'best_for': 'Startups, equity-based roles',
        'tip': 'Highlight startup experience and adaptability',
        'success_rate': 'Medium but high growth potential',
        'link': 'https://wellfound.com',
      },
      {
        'name': 'HackerEarth',
        'best_for': 'Technical roles, coding challenges',
        'tip': 'Participate in contests to get noticed',
        'success_rate': 'High for technical skills demonstration',
        'link': 'https://hackerearth.com/challenges',
      },
      {
        'name': 'Instahyre',
        'best_for': 'Tech roles, quick hiring process',
        'tip': 'Complete technical assessments for better matches',
        'success_rate': 'High for tech roles',
        'link': 'https://instahyre.com',
      },
    ];
  }

  Map<String, dynamic> _getSkillsGapAnalysis(Map<String, dynamic> answers) {
    final interests = answers['career_interests'] as List? ?? [];
    final currentSkills = answers['programming_languages'] as List? ?? [];
    final skillRatings = answers['skill_assessment'] as Map? ?? {};

    Map<String, dynamic> analysis = {
      'missing_skills': [],
      'improvement_areas': [],
      'learning_resources': [],
      'timeline': {},
    };

    if (interests.contains('Software Development')) {
      List<String> requiredSkills = [
        'JavaScript',
        'React',
        'Node.js',
        'Git',
        'REST APIs',
      ];
      List<String> missing = requiredSkills
          .where((skill) => !currentSkills.contains(skill))
          .toList();

      analysis['missing_skills'] = missing
          .map(
            (skill) => {
              'skill': skill,
              'priority': 'High',
              'estimated_learning_time': '2-4 weeks',
              'best_resource': _getBestResourceForSkill(skill),
            },
          )
          .toList();

      // Check skill ratings for improvement areas
      skillRatings.forEach((skill, rating) {
        if (rating < 3) {
          analysis['improvement_areas'].add({
            'skill': skill,
            'current_level': rating,
            'target_level': 4,
            'improvement_plan': _getImprovementPlan(skill),
          });
        }
      });
    }

    return analysis;
  }

  String _getBestResourceForSkill(String skill) {
    final resources = {
      'JavaScript': 'JavaScript30 by Wes Bos (Free)',
      'React': 'React Official Tutorial + Build 3 projects',
      'Node.js': 'Node.js crash course by Traversy Media',
      'Git': 'Pro Git book (Free) + GitHub practice',
      'REST APIs': 'Build APIs with Express.js tutorial series',
    };
    return resources[skill] ?? 'Search for "$skill tutorial" on YouTube';
  }

  String _getImprovementPlan(String skill) {
    final plans = {
      'communication': 'Join Toastmasters, practice technical presentations',
      'problem_solving': 'Solve 2 LeetCode problems daily, explain solutions',
      'technical': 'Build side projects, contribute to open source',
      'leadership': 'Lead a team project, mentor junior developers',
      'teamwork': 'Participate in group projects, practice code reviews',
    };
    return plans[skill] ?? 'Practice through real projects and feedback';
  }

  Map<String, dynamic> _get90DayPlan(Map<String, dynamic> answers) {
    return {
      'days_1_30': {
        'focus': 'Foundation & Setup',
        'goals': [
          'Complete profile setup across all platforms',
          'Finish 1 comprehensive course/tutorial',
          'Build 1 portfolio project',
          'Apply to 20+ companies',
        ],
        'success_metrics': 'At least 3 interview calls scheduled',
      },
      'days_31_60': {
        'focus': 'Active Interviewing',
        'goals': [
          'Complete 8-10 technical interviews',
          'Build 1 more advanced project',
          'Get 1 certification',
          'Attend 2 networking events',
        ],
        'success_metrics': 'Reach final rounds at 2+ companies',
      },
      'days_61_90': {
        'focus': 'Offer & Transition',
        'goals': [
          'Negotiate and secure job offer',
          'Complete notice period professionally',
          'Set up learning plan for new role',
          'Build connections at new company',
        ],
        'success_metrics': 'Start new role with 20%+ salary increase',
      },
    };
  }
}
