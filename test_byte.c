#include <stdio.h>
#ifdef __APPLE__
#include <CoreServices/CoreServices.h>
#endif
int main() {
    Byte b = 0;
    printf("%d\n", b);
    return 0;
}
