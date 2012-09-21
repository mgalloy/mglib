int culaInitialize();
void culaShutdown();

int culaGetLastStatus();
char *culaGetStatusString(int e);
char *culaGetStatusAsString(int e);
void culaFreeBuffers();

int culaGetVersion();
int culaGetCudaMinimumVersion();
int culaGetCudaRuntimeVersion();
int culaGetCudaDriverVersion();
int culaGetCublasMinimumVersion();
int culaGetCublasRuntimeVersion();

int culaGetDeviceCount(int *dev);
int culaSelectDevice(int dev);
int culaGetExecutingDevice(int *dev);
int culaGetDeviceInfo(int dev, char *buf, int bufsize);

