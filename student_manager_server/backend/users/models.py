# users/models.py
from django.db import models
from django.contrib.auth.models import User


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
