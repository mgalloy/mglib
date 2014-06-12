void zmq_version(int *major, int *minor, int *patch);
int zmq_errno();
char *zmq_strerror(int errnum);

void *zmq_ctx_new();
int zmq_ctx_term(void *context);
int zmq_ctx_shutdown(void *ctx_);
int zmq_ctx_set(void *context, int option, int optval);
int zmq_ctx_get(void *context, int option);
