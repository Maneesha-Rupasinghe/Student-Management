from django.urls import path
from .views import (
    AddQuizQuestionsView,
    AddResourceView,
    CompletedTasksView,
    CustomTokenObtainPairView,
    CustomTokenRefreshView,
    DeleteProfileView,
    DeleteQuizQuestionView,
    GetQuizQuestions,
    GetStudyPlanView,
    RegisterView,
    SaveQuizResultView,
    SaveTaskEventView,
    StudyPlanView,
    TaskEventListView,
    UpdateProfileView,
    UpdateStudyPlansView,
    UpdateTaskStatusView,
    UserPreferenceView,
    UserProfileView,
    UserQuizPercentageView,
)

urlpatterns = [
    path("register/", RegisterView.as_view(), name="register"),
    path("profile/update/", UpdateProfileView.as_view(), name="update-profile"),
    path("profile/delete/", DeleteProfileView.as_view(), name="delete-profile"),
    path("token/", CustomTokenObtainPairView.as_view(), name="token_obtain_pair"),
    path("token/refresh/", CustomTokenRefreshView.as_view(), name="token_refresh"),
    path("questions/add/", AddQuizQuestionsView.as_view(), name="add-quiz-questions"),
    path("resources/add/", AddResourceView.as_view(), name="add-resource"),
    path("questions/", GetQuizQuestions.as_view(), name="get-quiz-questions"),
    path("quiz/results/save/", SaveQuizResultView.as_view(), name="save-quiz-result"),
    path("task-event/save/", SaveTaskEventView.as_view(), name="save-task-event"),
    path("user/preferences/", UserPreferenceView.as_view(), name="user-preferences"),
    path("study-plan/", StudyPlanView.as_view(), name="study-plan"),
    path("tasks/", TaskEventListView.as_view(), name="get-tasks"),
    path(
        "tasks/<int:task_id>/status/",
        UpdateTaskStatusView.as_view(),
        name="update-task-status",
    ),
    path("user/profile/", UserProfileView.as_view(), name="user-profile"),
    path(
        "user/quiz-percentage/",
        UserQuizPercentageView.as_view(),
        name="user-quiz-percentage",
    ),
    path(
        "questions/delete/<int:quiz_id>/",
        DeleteQuizQuestionView.as_view(),
        name="delete-quiz-question",
    ),
    path(
        "study-plan-data/<int:event_id>/",
        GetStudyPlanView.as_view(),
        name="get-study-plan",
    ),
    path(
        "update-study-plans/", UpdateStudyPlansView.as_view(), name="update_study_plans"
    ),
    path("tasks/completed/", CompletedTasksView.as_view(), name="completed-tasks"),
]


# {
#     "refresh": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc1Mzg1NzQyNSwiaWF0IjoxNzQ1MjE3NDI1LCJqdGkiOiJlYTExMjc0NDVlYzA0Yzk3YmYxZTY3MDA5NzVhYjNjMCIsInVzZXJfaWQiOjF9.jPgUPnNAni7b3Yw1Sa6iEkwnXRX5zxpUWrRMAtk-0qY",
#     "access": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzQ4ODE3NDI1LCJpYXQiOjE3NDUyMTc0MjUsImp0aSI6ImFmZDNkNjRmODhiOTQ4YTNhZjQ4ZWQ2MTc5NzZjNTk1IiwidXNlcl9pZCI6MX0.NQYDXcyEKzBO3c7YL9bpMIiOEbYMQ5rF00aQdDK8kAk"
# }
