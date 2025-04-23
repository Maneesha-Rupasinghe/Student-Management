from rest_framework import status
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework_simplejwt.tokens import RefreshToken
from django.contrib.auth.models import User
from users.models import QuizQuestion, QuizResult
from rest_framework_simplejwt.views import TokenObtainPairView


from .serializers import QuizQuestionSerializer, ResourceSerializer, UserSerializer
from rest_framework.permissions import IsAuthenticated


from rest_framework.permissions import (
    AllowAny,
)  # This allows unauthenticated users to access this view


class RegisterView(APIView):
    permission_classes = [
        AllowAny
    ]  # This line ensures the endpoint is open to everyone (no authentication required)

    def post(self, request, *args, **kwargs):
        user_serializer = UserSerializer(data=request.data)
        if user_serializer.is_valid():
            user = user_serializer.save()  # Save the new user
            token = RefreshToken.for_user(
                user
            )  # Create JWT tokens (access and refresh)
            return Response(
                {
                    "user": user_serializer.data,  # Return the user data
                    "access_token": str(token.access_token),  # Return the access token
                    "refresh_token": str(token),  # Return the refresh token
                },
                status=status.HTTP_201_CREATED,
            )
        return Response(user_serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class UpdateProfileView(APIView):
    permission_classes = [IsAuthenticated]  # Ensure the user is authenticated

    def put(self, request, *args, **kwargs):
        user = request.user  # Get the currently authenticated user
        user_serializer = UserSerializer(
            user, data=request.data, partial=True
        )  # Partial update (not all fields required)

        if user_serializer.is_valid():
            user_serializer.save()  # Save the updated user data
            return Response(
                user_serializer.data, status=status.HTTP_200_OK
            )  # Return updated user data
        return Response(user_serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class DeleteProfileView(APIView):
    permission_classes = [IsAuthenticated]  # Ensure the user is authenticated

    def delete(self, request, *args, **kwargs):
        user = request.user  # Get the currently authenticated user
        user.delete()  # Delete the user profile
        return Response(status=status.HTTP_204_NO_CONTENT)  # Return success status


class CustomTokenObtainPairView(TokenObtainPairView):
    # Optionally, override this view if you need custom token generation
    pass


class CustomTokenRefreshView(APIView):
    def post(self, request, *args, **kwargs):
        refresh_token = request.data.get("refresh")
        if not refresh_token:
            return Response(
                {"detail": "Refresh token is required."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        try:
            # Decode the refresh token to get the user information
            refresh = RefreshToken(refresh_token)
            access_token = refresh.access_token  # Generate new access token

            return Response({"access": str(access_token)}, status=status.HTTP_200_OK)

        except Exception as e:
            return Response({"detail": str(e)}, status=status.HTTP_400_BAD_REQUEST)


class AddQuizQuestionsView(APIView):
    permission_classes = [IsAuthenticated]  # Ensure the user is authenticated

    def post(self, request, *args, **kwargs):
        questions_data = request.data  # List of questions sent in the request body
        if isinstance(questions_data, list):
            # Serialize the list of questions
            serializer = QuizQuestionSerializer(data=questions_data, many=True)
            if serializer.is_valid():
                serializer.save()  # Save all questions in the database
                return Response(
                    {"message": "Questions added successfully"},
                    status=status.HTTP_201_CREATED,
                )
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        else:
            return Response(
                {"error": "Expected a list of questions"},
                status=status.HTTP_400_BAD_REQUEST,
            )


class AddResourceView(APIView):
    def post(self, request, *args, **kwargs):
        resources_data = (
            request.data
        )  # Expecting a list of resources in the request body
        if isinstance(resources_data, list):  # Check if the data is a list
            serializer = ResourceSerializer(
                data=resources_data, many=True
            )  # Serialize the list of resources
            if serializer.is_valid():
                serializer.save()  # Save all the resources in the database
                return Response(
                    {"message": "Resources added successfully!"},
                    status=status.HTTP_201_CREATED,
                )
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        else:
            return Response(
                {"error": "Expected a list of resources"},
                status=status.HTTP_400_BAD_REQUEST,
            )


class GetQuizQuestions(APIView):
    def get(self, request, *args, **kwargs):
        subject = request.query_params.get("subject")
        level = request.query_params.get("level")

        if not subject or not level:
            return Response(
                {"error": "Subject and level are required."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        if level == "Mixed":
            # Get 5 questions from each level
            beginner_questions = QuizQuestion.objects.filter(
                subject=subject, difficulty_level="Beginner"
            )[:5]
            intermediate_questions = QuizQuestion.objects.filter(
                subject=subject, difficulty_level="Intermediate"
            )[:5]
            advanced_questions = QuizQuestion.objects.filter(
                subject=subject, difficulty_level="Advanced"
            )[:5]

            questions = (
                list(beginner_questions)
                + list(intermediate_questions)
                + list(advanced_questions)
            )

        else:
            # Get 10 questions from the specified level
            questions = QuizQuestion.objects.filter(
                subject=subject, difficulty_level=level
            )[:10]

        # Prepare the data to be returned
        serialized_questions = []
        for question in questions:
            serialized_questions.append(
                {
                    "question": question.question,
                    "choices": [
                        question.choice_1,
                        question.choice_2,
                        question.choice_3,
                        question.choice_4,
                    ],
                    "correct_answer": question.correct_answer,
                    "difficulty_level": question.difficulty_level,
                }
            )

        return Response({"questions": serialized_questions}, status=status.HTTP_200_OK)


class SaveQuizResultView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, *args, **kwargs):
        data = request.data
        subject = data.get("subject")
        level = data.get("level")
        results = data.get("results")

        if not subject or not level or not results:
            return Response(
                {"error": "Subject, level, and results are required."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        # Use update_or_create to handle both creating and updating results
        quiz_result, created = QuizResult.objects.update_or_create(
            user=request.user,
            subject=subject,
            level=level,
            defaults={"results": results},
        )

        if created:
            return Response(
                {"message": "Quiz result created successfully!"},
                status=status.HTTP_201_CREATED,
            )
        else:
            return Response(
                {"message": "Quiz result updated successfully!"},
                status=status.HTTP_200_OK,
            )
