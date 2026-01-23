from firebase_admin import messaging

def send_push_notification(
    fcm_token: str,
    title: str,
    body: str,
    data: dict | None = None,
):
    message = messaging.Message(
        token=fcm_token,
        notification=messaging.Notification(
            title=title,
            body=body,
        ),
        data=data or {},
    )

    messaging.send(message)
