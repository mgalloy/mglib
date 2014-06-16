void zmq_version(int *major, int *minor, int *patch);
int zmq_errno();
char *zmq_strerror(int errnum);

void *zmq_ctx_new();
int zmq_ctx_term(void *context);
int zmq_ctx_shutdown(void *ctx_);
int zmq_ctx_set(void *context, int option, int optval);
int zmq_ctx_get(void *context, int option);

void *zmq_init (int io_threads);
int zmq_term (void *context);
int zmq_ctx_destroy (void *context);

int zmq_msg_init(zmq_msg_t *msg);
int zmq_msg_init_size(zmq_msg_t *msg, unsigned int size);
int zmq_msg_init_data(zmq_msg_t *msg, void *data, unsigned int size, zmq_free_fn *ffn, void *hint);
int zmq_msg_send(zmq_msg_t *msg, void *s, int flags);
int zmq_msg_recv(zmq_msg_t *msg, void *s, int flags);
int zmq_msg_close(zmq_msg_t *msg);
int zmq_msg_move(zmq_msg_t *dest, zmq_msg_t *src);
int zmq_msg_copy(zmq_msg_t *dest, zmq_msg_t *src);
void *zmq_msg_data(zmq_msg_t *msg);
unsigned int zmq_msg_size(zmq_msg_t *msg);
int zmq_msg_more(zmq_msg_t *msg);
int zmq_msg_get(zmq_msg_t *msg, int option);
int zmq_msg_set(zmq_msg_t *msg, int option, int optval);

void *zmq_socket(void *s, int type);
int zmq_close(void *s);
int zmq_setsockopt(void *s, int option, void *optval, unsigned int optvallen);
int zmq_getsockopt(void *s, int option, void *optval, unsigned int *optvallen);
int zmq_bind(void *s, char *addr);
int zmq_connect(void *s, char *addr);
int zmq_unbind(void *s, char *addr);
int zmq_disconnect(void *s, char *addr);
int zmq_send(void *s, void *buf, unsigned int len, int flags);
int zmq_send_const(void *s, void *buf, unsigned int len, int flags);
int zmq_recv(void *s, void *buf, unsigned int len, int flags);
int zmq_socket_monitor(void *s, char *addr, int events);

int zmq_sendmsg(void *s, zmq_msg_t *msg, int flags);
int zmq_recvmsg(void *s, zmq_msg_t *msg, int flags);

int zmq_sendiov(void *s, struct iovec *iov, unsigned int count, int flags);
int zmq_recviov(void *s, struct iovec *iov, unsigned int *count, int flags);

int zmq_poll(zmq_pollitem_t *items, int nitems, long timeout);

int zmq_proxy (void *frontend, void *backend, void *capture);
char *zmq_z85_encode (char *dest, uint8_t *data, unsigned int size);
uint8_t *zmq_z85_decode (uint8_t *dest, char *string);
