from rest_framework import serializers
from django.contrib.auth.models import User
from .models import (
    DeviceToken,
    Notification,
    QuizQuestion,
    QuizResult,
    Resource,
    TaskEvent,
    UserPreference,
)


class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ["username", "email", "password"]
        extra_kwargs = {"password": {"write_only": True}}

    def create(self, validated_data):
        user = User.objects.create_user(**validated_data)
        return user


class QuizQuestionSerializer(serializers.ModelSerializer):
    class Meta:
        model = QuizQuestion
        fields = [
            "subject",
            "question",
            "choice_1",
            "choice_2",
            "choice_3",
            "choice_4",
            "correct_answer",
            "difficulty_level",
        ]


class ResourceSerializer(serializers.ModelSerializer):
    class Meta:
        model = Resource
        fields = ["subject", "resource", "study_level"]


class QuizResultSerializer(serializers.ModelSerializer):
    class Meta:
        model = QuizResult
        fields = ["user", "subject", "level", "results"]


class TaskEventSerializer(serializers.ModelSerializer):
    class Meta:
        model = TaskEvent
        fields = [
            "id",
            "task_name",
            "subject",
            "task_type",
            "start_date",
            "event_date",
            "estimated_study_hours",
            "notes",
            "priority",
            "status",
            "user",
            "skip_days",  # Corrected from 'skipping_days' to 'skip_days'
        ]

    def validate_skip_days(self, value):
        """Validate that skip_days is a list of valid day names and not all days."""
        if value is None:
            return []
        valid_days = [
            "Monday",
            "Tuesday",
            "Wednesday",
            "Thursday",
            "Friday",
            "Saturday",
            "Sunday",
        ]
        if not isinstance(value, list):
            raise serializers.ValidationError("skip_days must be a list of days.")
        for day in value:
            if day not in valid_days:
                raise serializers.ValidationError(
                    f"Invalid day: {day}. Must be one of {valid_days}."
                )
        if len(value) >= 7:
            raise serializers.ValidationError("Cannot skip all days of the week.")
        return value

    def validate(self, data):
        """Custom validation for start_date, event_date, and other fields."""
        # Validate dates
        if "start_date" in data and "event_date" in data:
            start_date = data["start_date"]
            event_date = data["event_date"]
            if start_date >= event_date:
                raise serializers.ValidationError(
                    "Event date must be after the start date."
                )
        return data


class UserPreferenceSerializer(serializers.ModelSerializer):
    strengths = serializers.ListField(
        child=serializers.CharField(max_length=255), allow_empty=True, required=False
    )
    weaknesses = serializers.ListField(
        child=serializers.CharField(max_length=255), allow_empty=True, required=False
    )

    class Meta:
        model = UserPreference
        fields = [
            "strengths",
            "weaknesses",
            "hours_per_day",
            "days_per_week",
            "preferred_study_time",
        ]

    def validate_strengths(self, value):
        valid_strengths = [
            "Can work more than 3 hours continuously",
            "Good at organizing tasks and time",
            "Quick learner",
            "Can stay focused for extended periods",
            "Good at retaining information through reading",
        ]
        for strength in value:
            if strength not in valid_strengths:
                raise serializers.ValidationError(f"Invalid strength: {strength}")
        return value

    def validate_weaknesses(self, value):
        valid_weaknesses = [
            "Easily distracted",
            "Tend to procrastinate often",
            "Find it hard to start studying without motivation",
            "Struggle with organizing tasks",
            "Have difficulty managing stress",
        ]
        for weakness in value:
            if weakness not in valid_weaknesses:
                raise serializers.ValidationError(f"Invalid weakness: {weakness}")
        return value

    def validate_hours_per_day(self, value):
        if value < 0 or value > 24:
            raise serializers.ValidationError("Hours per day must be between 0 and 24.")
        return value

    def validate_days_per_week(self, value):
        if value < 1 or value > 7:
            raise serializers.ValidationError("Days per week must be between 1 and 7.")
        return value


class DeviceTokenSerializer(serializers.ModelSerializer):
    class Meta:
        model = DeviceToken
        fields = ["token"]


class NotificationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Notification
        fields = ["id", "title", "body", "timestamp", "is_read"]


class UsersResourceSerializer(serializers.ModelSerializer):
    class Meta:
        model = Resource
        fields = ['subject', 'resource', 'study_level']

        