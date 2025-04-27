# users/models.py
import json
from django.db import models
from django.contrib.auth.models import User
from django.db.models import JSONField


class QuizQuestion(models.Model):
    SUBJECT_CHOICES = [
        ("DSA", "Data Structures & Algorithms"),
        ("OOP", "Object-Oriented Programming"),
        ("SE", "Software Engineering"),
    ]

    DIFFICULTY_CHOICES = [
        ("Beginner", "Beginner"),
        ("Intermediate", "Intermediate"),
        ("Advanced", "Advanced"),
    ]

    subject = models.CharField(max_length=28, choices=SUBJECT_CHOICES)
    question = models.TextField()
    choice_1 = models.CharField(max_length=255)
    choice_2 = models.CharField(max_length=255)
    choice_3 = models.CharField(max_length=255)
    choice_4 = models.CharField(max_length=255)
    correct_answer = models.CharField(max_length=255)
    difficulty_level = models.CharField(max_length=12, choices=DIFFICULTY_CHOICES)

    def __str__(self):
        return f"{self.subject} - {self.difficulty_level} - {self.question}"


class Resource(models.Model):
    SUBJECT_CHOICES = [
        ("DSA", "Data Structures & Algorithms"),
        ("OOP", "Object-Oriented Programming"),
        ("SE", "Software Engineering"),
        # Add more subjects as needed
    ]

    STUDY_LEVEL_CHOICES = [
        ("Beginner", "Beginner"),
        ("Intermediate", "Intermediate"),
        ("Advanced", "Advanced"),
    ]

    subject = models.CharField(max_length=3, choices=SUBJECT_CHOICES)
    resource = models.URLField(max_length=2000)  # To store URLs
    study_level = models.CharField(max_length=12, choices=STUDY_LEVEL_CHOICES)

    def __str__(self):
        return f"{self.subject} - {self.study_level} - {self.resource}"


class QuizResult(models.Model):
    SUBJECT_CHOICES = [
        ("DSA", "Data Structures & Algorithms"),
        ("OOP", "Object-Oriented Programming"),
        ("SE", "Software Engineering"),
    ]

    LEVEL_CHOICES = [
        ("Beginner", "Beginner"),
        ("Intermediate", "Intermediate"),
        ("Advanced", "Advanced"),
    ]

    user = models.ForeignKey(User, on_delete=models.CASCADE)
    subject = models.CharField(max_length=28, choices=SUBJECT_CHOICES)
    level = models.CharField(max_length=12, choices=LEVEL_CHOICES)
    results = models.TextField()

    def __str__(self):
        return f"{self.user.username} - {self.subject} - {self.level} - {self.results}"


class TaskEvent(models.Model):
    TASK_TYPE_CHOICES = [
        ("Study", "Study"),
        ("Review", "Review"),
        ("Project", "Project"),
        ("Exam", "Exam"),
    ]

    STATUS_CHOICES = [
        ("Pending", "Pending"),
        ("Not Complete", "Not Complete"),
        ("Complete", "Complete"),
        ("Deleted", "Deleted"),
    ]

    user = models.ForeignKey(
        User, on_delete=models.CASCADE
    )  # Link to the user who created the task
    task_name = models.CharField(max_length=255)
    subject = models.CharField(max_length=100)
    task_type = models.CharField(max_length=50, choices=TASK_TYPE_CHOICES)
    start_date = models.DateTimeField()
    event_date = models.DateTimeField()
    estimated_study_hours = models.FloatField()  # Store estimated hours as a float
    notes = models.TextField()
    priority = models.FloatField()
    status = models.CharField(
        max_length=20, choices=STATUS_CHOICES, default="Pending"
    )  # Add the status field
    skip_days = models.JSONField(
        default=list, blank=True, null=True
    )  # Store list of days to skip (e.g., ["Monday", "Wednesday"])

    def __str__(self):
        skip_days_str = (
            json.dumps(self.skip_days) if self.skip_days is not None else "[]"
        )
        return f"Task/Event for {self.subject} by {self.user.username} (Skip Days: {skip_days_str})"

    def clean(self):
        """Validate skip_days to ensure only valid day names are included."""
        if self.skip_days is not None:
            valid_days = [
                "Monday",
                "Tuesday",
                "Wednesday",
                "Thursday",
                "Friday",
                "Saturday",
                "Sunday",
            ]
            if not isinstance(self.skip_days, list):
                raise models.ValidationError({"skip_days": "Must be a list of days."})
            for day in self.skip_days:
                if day not in valid_days:
                    raise models.ValidationError(
                        {
                            "skip_days": f"Invalid day: {day}. Must be one of {valid_days}."
                        }
                    )
            if len(self.skip_days) >= 7:
                raise models.ValidationError(
                    {"skip_days": "Cannot skip all days of the week."}
                )


class UserPreference(models.Model):
    user = models.OneToOneField(
        User, on_delete=models.CASCADE, related_name="preferences"
    )
    strengths = JSONField(default=list)  # Changed from selected_strengths
    weaknesses = JSONField(default=list)  # Changed from selected_weaknesses
    hours_per_day = models.FloatField(default=2.0)
    days_per_week = models.IntegerField(default=5)
    preferred_study_time = models.CharField(
        max_length=20,
        choices=[
            ("Morning", "Morning"),
            ("Day", "Day"),
            ("Night", "Night"),
        ],
        default="Morning",
    )

    def get_strengths(self):
        return self.strengths or []

    def get_weaknesses(self):
        return self.weaknesses or []

    def __str__(self):
        return f"Preferences for {self.user.username}"


class StudyPlan(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)  # Link to the user
    subject = models.CharField(max_length=100)  # Subject of the study plan
    study_type = models.CharField(
        max_length=50
    )  # Type of study plan (e.g., exam preparation)
    plan = (
        models.JSONField()
    )  # Store the plan as a JSON object (detailed study sessions)
    event_id = models.ForeignKey(TaskEvent, on_delete=models.CASCADE)

    def __str__(self):
        return (
            f"Study Plan for {self.user.username} - {self.subject} ({self.study_type})"
        )
