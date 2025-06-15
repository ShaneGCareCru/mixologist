import openai

class OpenAIAPIException(Exception):
    def __init__(self, status_code, error_type, error_message, openai_code=None):
        self.status_code = status_code
        self.error_type = error_type
        self.error_message = error_message
        self.openai_code = openai_code
        super().__init__(f"{error_type}: {error_message}")

def map_openai_error(e):
    # Support both OpenAI SDK v0.x and v1.x error classes
    if hasattr(openai, 'error'):
        # Old SDK
        if isinstance(e, openai.error.InvalidRequestError):
            return 400, "invalid_request_error", str(e), getattr(e, 'code', None)
        elif isinstance(e, openai.error.AuthenticationError):
            return 401, "authentication_error", str(e), getattr(e, 'code', None)
        elif isinstance(e, openai.error.PermissionError):
            return 403, "permission_error", str(e), getattr(e, 'code', None)
        elif isinstance(e, openai.error.RateLimitError):
            return 429, "rate_limit_error", str(e), getattr(e, 'code', None)
        elif isinstance(e, openai.error.APIConnectionError):
            return 502, "api_connection_error", str(e), getattr(e, 'code', None)
        elif isinstance(e, openai.error.ServiceUnavailableError):
            return 503, "service_unavailable_error", str(e), getattr(e, 'code', None)
        elif isinstance(e, openai.error.Timeout):
            return 504, "timeout_error", str(e), getattr(e, 'code', None)
        elif isinstance(e, openai.error.APIError):
            return 500, "api_error", str(e), getattr(e, 'code', None)
        elif isinstance(e, openai.error.OpenAIError):
            return 500, "openai_error", str(e), getattr(e, 'code', None)
        else:
            return 500, "unknown_openai_error", str(e), getattr(e, 'code', None)
    else:
        # New SDK (>=1.0.0)
        if isinstance(e, openai.BadRequestError):
            return 400, "invalid_request_error", str(e), getattr(e, 'code', None)
        elif isinstance(e, openai.AuthenticationError):
            return 401, "authentication_error", str(e), getattr(e, 'code', None)
        elif isinstance(e, openai.PermissionDeniedError):
            return 403, "permission_error", str(e), getattr(e, 'code', None)
        elif isinstance(e, openai.RateLimitError):
            return 429, "rate_limit_error", str(e), getattr(e, 'code', None)
        elif isinstance(e, openai.APITimeoutError):
            return 504, "timeout_error", str(e), getattr(e, 'code', None)
        elif isinstance(e, openai.APIConnectionError):
            return 502, "api_connection_error", str(e), getattr(e, 'code', None)
        elif isinstance(e, openai.APIStatusError):
            return 500, "api_error", str(e), getattr(e, 'code', None)
        elif isinstance(e, openai.OpenAIError):
            return 500, "openai_error", str(e), getattr(e, 'code', None)
        else:
            return 500, "unknown_openai_error", str(e), getattr(e, 'code', None) 