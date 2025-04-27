from datetime import datetime, timedelta
import math
from django.http import JsonResponse
from django.shortcuts import get_object_or_404
from rest_framework import status
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework_simplejwt.tokens import RefreshToken
from django.contrib.auth.models import User
from users.models import QuizQuestion, QuizResult, StudyPlan, TaskEvent, UserPreference
from rest_framework_simplejwt.views import TokenObtainPairView


from .serializers import (
    QuizQuestionSerializer,
    ResourceSerializer,
    TaskEventSerializer,
    UserPreferenceSerializer,
    UserSerializer,
)
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


class SaveTaskEventView(APIView):
    permission_classes = [IsAuthenticated]  # Ensure the user is authenticated

    def post(self, request, *args, **kwargs):
        data = request.data

        # Automatically assign the logged-in user from the request
        data["user"] = request.user.id  # Get the user id from the authenticated user

        # Validate and save the task data
        serializer = TaskEventSerializer(data=data)

        if serializer.is_valid():
            # Save the task/event to the database
            task_event = serializer.save()  # This will save and return the instance

            # Retrieve the id of the newly saved task/event
            task_event_id = task_event.id  # Get the ID of the saved task/event

            return Response(
                {
                    "message": "Task/Event created successfully!",
                    "task_event_id": task_event_id,
                },
                status=status.HTTP_201_CREATED,
            )

        # Return errors if the task data is not valid
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class UserPreferenceView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, *args, **kwargs):
        user = request.user
        serializer = UserPreferenceSerializer(data=request.data)

        if serializer.is_valid():
            try:
                user_preference, created = UserPreference.objects.update_or_create(
                    user=user, defaults=serializer.validated_data
                )
                return Response(
                    {
                        "message": (
                            "User preferences created successfully!"
                            if created
                            else "User preferences updated successfully!"
                        )
                    },
                    status=status.HTTP_201_CREATED if created else status.HTTP_200_OK,
                )
            except Exception as e:
                return Response(
                    {"error": f"Failed to save preferences: {str(e)}"},
                    status=status.HTTP_500_INTERNAL_SERVER_ERROR,
                )
        return Response(
            serializer.errors,
            status=status.HTTP_400_BAD_REQUEST,
        )

    def get(self, request, *args, **kwargs):
        user = request.user
        try:
            user_preference = UserPreference.objects.get(user=user)
            serializer = UserPreferenceSerializer(user_preference)
            return Response(serializer.data, status=status.HTTP_200_OK)
        except UserPreference.DoesNotExist:
            return Response(
                {"error": "User preferences not found."},
                status=status.HTTP_404_NOT_FOUND,
            )


class TaskEventListView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, *args, **kwargs):
        user = request.user  # Get the logged-in user
        tasks = (
            TaskEvent.objects.filter(user=user)
            .exclude(status="Deleted")
            .order_by("event_date")
        )

        serializer = TaskEventSerializer(tasks, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)


class UpdateTaskStatusView(APIView):
    permission_classes = [IsAuthenticated]

    def patch(self, request, task_id, *args, **kwargs):
        task = TaskEvent.objects.filter(id=task_id, user=request.user).first()

        if not task:
            return Response(
                {"error": "Task not found or you don't have permission to modify it."},
                status=status.HTTP_404_NOT_FOUND,
            )

        # Get the new status from the request
        new_status = request.data.get("status")

        if new_status not in ["Pending", "Not Complete", "Complete", "Deleted"]:
            return Response(
                {"error": "Invalid status value."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        task.status = new_status
        task.save()

        return Response(
            {"message": "Task status updated successfully!"}, status=status.HTTP_200_OK
        )


class UserProfileView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, *args, **kwargs):
        # Get the authenticated user
        user = request.user
        user_data = {
            "username": user.username,
            "email": user.email,
        }
        return Response(user_data)


class UserQuizPercentageView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, *args, **kwargs):
        user = request.user

        # Retrieve quiz results for the user
        results = QuizResult.objects.filter(user=user)

        # Initialize scores to 0
        advanced_score = 0
        intermediate_score = 0
        beginner_score = 0

        # Check if each level's score exists, if not, set it to 0
        advanced_result = results.filter(level="Advanced").first()
        intermediate_result = results.filter(level="Intermediate").first()
        beginner_result = results.filter(level="Beginner").first()

        # If the result exists, convert the percentage string to a float (remove '%')
        if advanced_result:
            advanced_score = float(advanced_result.results.replace("%", "").strip())
        if intermediate_result:
            intermediate_score = float(
                intermediate_result.results.replace("%", "").strip()
            )
        if beginner_result:
            beginner_score = float(beginner_result.results.replace("%", "").strip())

        # Calculate the overall quiz percentage based on the weighted formula
        overall_percentage = (
            (advanced_score * 0.5)
            + (intermediate_score * 0.35)
            + (beginner_score * 0.15)
        )

        return Response({"overall_percentage": overall_percentage})


class DeleteQuizQuestionView(APIView):

    def delete(self, request, quiz_id, *args, **kwargs):
        try:
            # Retrieve the quiz question using the provided id
            quiz_question = QuizQuestion.objects.get(id=quiz_id)

            # Delete the quiz question
            quiz_question.delete()

            return Response(
                {"message": "Quiz question deleted successfully"},
                status=status.HTTP_204_NO_CONTENT,
            )
        except QuizQuestion.DoesNotExist:
            return Response(
                {"error": "Quiz question not found"},
                status=status.HTTP_404_NOT_FOUND,
            )


class GetStudyPlanView(APIView):
    permission_classes = [IsAuthenticated]  # Ensure the user is authenticated

    def get(self, request, event_id, *args, **kwargs):
        # Debugging - Check if event_id is passed correctly
        print(f"Received event_id: {event_id}")  # Debugging print

        # Debugging - Check if user is authenticated
        print(f"Authenticated user: {request.user}")  # Debugging print

        # Step 1: Retrieve the StudyPlan based on event_id
        try:
            study_plan = StudyPlan.objects.get(
                event_id_id=event_id
            )  # Find the StudyPlan by event_id
            print(f"Found study plan: {study_plan}")  # Debugging print
        except StudyPlan.DoesNotExist:
            return Response(
                {"error": "Study plan not found for the given event_id"},
                status=status.HTTP_404_NOT_FOUND,
            )

        # Step 2: Return the plan as a JSON response
        return JsonResponse(study_plan.plan, safe=False)


def generate_study_plan(user, task_data, event_id):
    """
    Generate or update a study plan for a given task event.
    Returns a tuple: (study_plan_data, error_response).
    If successful, study_plan_data contains the plan; error_response is None.
    If failed, study_plan_data is None; error_response is a Response object.
    """
    # Step 1: Retrieve User Preferences
    try:
        user_preference = UserPreference.objects.get(user=user)
    except UserPreference.DoesNotExist:
        return None, Response(
            {"error": "User preferences not found."},
            status=status.HTTP_404_NOT_FOUND,
        )

    # Step 2: Retrieve Quiz Results
    try:
        quiz_results = QuizResult.objects.filter(user=user)
    except QuizResult.DoesNotExist:
        return None, Response(
            {"error": "User quiz results not found."},
            status=status.HTTP_404_NOT_FOUND,
        )

    # Step 3: Retrieve Task/Event Data
    subject = task_data.get("subject")
    try:
        study_start_date = datetime.fromisoformat(
            task_data.get("study_start_date").replace("Z", "+00:00")
        )
        exam_date = datetime.fromisoformat(
            task_data.get("exam_date").replace("Z", "+00:00")
        )
    except (ValueError, TypeError) as e:
        return None, Response(
            {"error": f"Invalid date format: {str(e)}"},
            status=status.HTTP_400_BAD_REQUEST,
        )
    estimated_study_hours = task_data.get("estimated_study_hours")

    # Validate dates
    if study_start_date >= exam_date:
        return None, Response(
            {"error": "Study start date must be before exam date."},
            status=status.HTTP_400_BAD_REQUEST,
        )

    # Retrieve TaskEvent to get skip_days
    try:
        task_event = TaskEvent.objects.get(id=event_id, user=user)
        skip_days = task_event.skip_days or []
    except TaskEvent.DoesNotExist:
        skip_days = []

    # Step 4: Adjust Study Hours Based on Quiz Results
    study_hours_per_day = min(user_preference.hours_per_day, 4.0)

    advanced_result = quiz_results.filter(level="Advanced").first()
    intermediate_result = quiz_results.filter(level="Intermediate").first()
    beginner_result = quiz_results.filter(level="Beginner").first()

    def convert_to_float(percentage_str):
        return float(percentage_str.replace("%", "").strip()) if percentage_str else 0.0

    if advanced_result and convert_to_float(advanced_result.results) > 60:
        study_hours_per_day *= 0.7
    elif intermediate_result and convert_to_float(intermediate_result.results) > 60:
        study_hours_per_day *= 0.8
    elif beginner_result and convert_to_float(beginner_result.results) > 60:
        study_hours_per_day *= 0.9
    else:
        study_hours_per_day = min(study_hours_per_day + 0.5, 4.0)

    # Step 5: Calculate Study Plan Basics
    total_days = (exam_date - study_start_date).days  # Exclude exam_date
    if total_days < 1:
        return None, Response(
            {"error": "No days available for study plan before exam date."},
            status=status.HTTP_400_BAD_REQUEST,
        )

    skip_days_count = sum(
        1
        for i in range(total_days)
        if (study_start_date + timedelta(days=i)).strftime("%A") in skip_days
    )
    available_days = (total_days - skip_days_count) * (
        user_preference.days_per_week / 7
    )
    if available_days < 1:
        return None, Response(
            {"error": "No available days for study plan after skipping days."},
            status=status.HTTP_400_BAD_REQUEST,
        )

    hours_per_session = estimated_study_hours / available_days

    # Step 6: Adjust for Strengths and Weaknesses
    strength_factor = 1
    weakness_factor = 1

    strengths = user_preference.get_strengths()
    weaknesses = user_preference.get_weaknesses()

    strength_ratings = {
        "Can work more than 3 hours continuously": 5,
        "Good at organizing tasks and time": 4,
        "Quick learner": 4,
        "Can stay focused for extended periods": 5,
        "Good at retaining information through reading": 3,
    }

    weakness_ratings = {
        "Easily distracted": 5,
        "Tend to procrastinate often": 5,
        "Find it hard to start studying without motivation": 4,
        "Struggle with organizing tasks": 4,
        "Have difficulty managing stress": 3,
    }

    adjusted_hours = hours_per_session
    for strength in strengths:
        if strength in strength_ratings:
            adjusted_hours *= 1 + (strength_ratings[strength] * 0.05)

    for weakness in weaknesses:
        if weakness in weakness_ratings:
            adjusted_hours *= 1 - (weakness_ratings[weakness] * 0.05)

    adjusted_hours = min(adjusted_hours, 1.5)

    # Step 7: Generate Study Plan with Sessions
    max_session_length = 1.5
    max_sessions_per_day = 2
    study_plan = []

    current_date = study_start_date
    days_added = 0
    exam_date_minus_one = exam_date - timedelta(days=1)
    while days_added < int(available_days) and current_date <= exam_date_minus_one:
        weekday_name = current_date.strftime("%A")
        if weekday_name in skip_days:
            current_date += timedelta(days=1)
            continue

        if user_preference.preferred_study_time == "Morning":
            study_start_time = current_date.replace(hour=6, minute=0)
        elif user_preference.preferred_study_time == "Day":
            study_start_time = current_date.replace(hour=12, minute=0)
        elif user_preference.preferred_study_time == "Night":
            study_start_time = current_date.replace(hour=21, minute=0)
        else:
            study_start_time = current_date.replace(hour=8, minute=0)

        sessions_per_day = min(
            max(1, math.ceil(study_hours_per_day / max_session_length)),
            max_sessions_per_day,
        )
        session_hours = min(study_hours_per_day / sessions_per_day, max_session_length)
        daily_schedule = []

        current_time = study_start_time
        for session in range(sessions_per_day):
            session_end_time = current_time + timedelta(hours=session_hours)
            daily_schedule.append(
                {
                    "start_time": current_time.strftime("%H:%M"),
                    "end_time": session_end_time.strftime("%H:%M"),
                    "hours_to_study": round(session_hours, 2),
                }
            )
            current_time = session_end_time + timedelta(minutes=30)

        study_plan.append(
            {
                "study_date": current_date.strftime("%Y-%m-%d"),
                "sessions": daily_schedule,
                "subject": subject,
                "study_time": user_preference.preferred_study_time,
                "total_hours": round(session_hours * sessions_per_day, 2),
            }
        )
        days_added += 1
        current_date += timedelta(days=1)

    # Step 8: Save the Study Plan
    study_plan_data = {
        "user": user,
        "subject": subject,
        "study_type": "exam preparation",
        "plan": study_plan,
        "event_id_id": event_id,
    }
    return study_plan_data, None


class StudyPlanView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, *args, **kwargs):
        user = request.user
        task_data = request.data
        event_id = task_data.get("id")

        study_plan_data, error_response = generate_study_plan(user, task_data, event_id)
        if error_response:
            return error_response

        # Save the study plan
        study_plan_instance = StudyPlan.objects.create(**study_plan_data)

        # Return response
        return Response(
            {
                "study_plan": study_plan_data["plan"],
                "study_plan_id": study_plan_instance.id,
                "total_study_hours": sum(
                    day["total_hours"] for day in study_plan_data["plan"]
                ),
            },
            status=status.HTTP_200_OK,
        )


class UpdateStudyPlansView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, *args, **kwargs):
        user = request.user
        subject = request.data.get("subject")

        if not subject:
            return Response(
                {"error": "Subject is required."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        # Step 1: Find all TaskEvent records for the user with the given subject and status 'Pending'
        try:
            task_events = TaskEvent.objects.filter(
                user=user, subject=subject, status="Pending"
            )
        except TaskEvent.DoesNotExist:
            return Response(
                {"message": f"No pending tasks found for subject '{subject}'."},
                status=status.HTTP_200_OK,
            )

        if not task_events.exists():
            return Response(
                {"message": f"No pending tasks found for subject '{subject}'."},
                status=status.HTTP_200_OK,
            )

        # Step 2: Regenerate study plans for each task
        updated_plans = []
        errors = []

        for task_event in task_events:
            # Construct task_data from TaskEvent
            task_data = {
                "subject": task_event.subject,
                "study_start_date": task_event.start_date.isoformat(),
                "exam_date": task_event.event_date.isoformat(),
                "estimated_study_hours": task_event.estimated_study_hours,
                "id": task_event.id,
            }

            # Generate study plan
            study_plan_data, error_response = generate_study_plan(
                user, task_data, task_event.id
            )
            if error_response:
                errors.append(
                    {
                        "task_event_id": task_event.id,
                        "task_name": task_event.task_name,
                        "error": error_response.data["error"],
                    }
                )
                continue

            # Update or create StudyPlan
            try:
                study_plan_instance, created = StudyPlan.objects.update_or_create(
                    event_id_id=task_event.id,
                    defaults={
                        "user": user,
                        "subject": study_plan_data["subject"],
                        "study_type": study_plan_data["study_type"],
                        "plan": study_plan_data["plan"],
                    },
                )
                updated_plans.append(
                    {
                        "task_event_id": task_event.id,
                        "task_name": task_event.task_name,
                        "study_plan_id": study_plan_instance.id,
                        "total_study_hours": sum(
                            day["total_hours"] for day in study_plan_data["plan"]
                        ),
                    }
                )
            except Exception as e:
                errors.append(
                    {
                        "task_event_id": task_event.id,
                        "task_name": task_event.task_name,
                        "error": f"Failed to save study plan: {str(e)}",
                    }
                )

        # Step 3: Return response
        response_data = {
            "updated_plans": updated_plans,
            "errors": errors,
        }
        if errors and not updated_plans:
            return Response(
                response_data,
                status=status.HTTP_500_INTERNAL_SERVER_ERROR,
            )
        elif errors:
            return Response(
                response_data,
                status=status.HTTP_207_MULTI_STATUS,
            )
        return Response(
            response_data,
            status=status.HTTP_200_OK,
        )
