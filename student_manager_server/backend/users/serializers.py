from rest_framework import serializers
from django.contrib.auth.models import User
from .models import QuizQuestion, QuizResult, Resource


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
        fields = ['user', 'subject', 'level', 'results']