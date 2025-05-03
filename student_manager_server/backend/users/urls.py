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
    NotificationListView,
    NotificationReadView,
    NotificationSaveView,
    RegisterView,
    SaveDeviceTokenView,
    SaveQuizResultView,
    SaveTaskEventView,
    StudyPlanView,
    TaskEventListView,
    TaskStatusUpdateView,
    TestNotificationView,
    UpdateProfileView,
    UpdateStudyPlanView,
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
        "tasks/<int:task_id>/update-status/",
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
    path(
        "study-plan/update/<int:event_id>/",
        UpdateStudyPlanView.as_view(),
        name="update-study-plan",
    ),
    path("save-device-token/", SaveDeviceTokenView.as_view(), name="save-device-token"),
    path(
        "test-notification/", TestNotificationView.as_view(), name="test-notification"
    ),
    path(
        "tasks/<int:task_id>/status/",
        TaskStatusUpdateView.as_view(),
        name="task-status-update",
    ),
    path("notifications/", NotificationListView.as_view(), name="notification-list"),
    path(
        "notifications/save/", NotificationSaveView.as_view(), name="notification-save"
    ),
      path("notifications/<int:notification_id>/read/", NotificationReadView.as_view(), name="notification-read"),
]
