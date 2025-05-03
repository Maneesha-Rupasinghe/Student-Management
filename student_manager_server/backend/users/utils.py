# import firebase_admin
# from firebase_admin import credentials, messaging
# from django.conf import settings
# import os
# from .models import DeviceToken

# # Initialize Firebase Admin SDK
# if not firebase_admin._apps:
#     cred_path = os.path.join(
#         settings.BASE_DIR, "cred", "studentmanagement-a6df5-e751db8a7933.json"
#     )
#     print(f"Firebase credentials path: {cred_path}")  # Debug
#     cred = credentials.Certificate(cred_path)
#     firebase_admin.initialize_app(cred)


# def send_push_notification(user_id, title, body):
#     try:
#         device = DeviceToken.objects.get(user_id=user_id)
#         registration_token = device.token

#         # Create a message
#         message = messaging.Message(
#             notification=messaging.Notification(
#                 title=title,
#                 body=body,
#             ),
#             token=registration_token,
#         )

#         # Send the message
#         response = messaging.send(message)
#         return {"success": True, "message_id": response}
#     except DeviceToken.DoesNotExist:
#         return {"error": "Device token not found"}
#     except Exception as e:
#         return {"error": str(e)}
