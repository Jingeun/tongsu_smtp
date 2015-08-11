#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, char *argv[]) {
   char command[100] = "useradd -m ";
   if ( argc <2 ) {
      printf("error");
      exit(1);
   }

   if(strcmp(argv[1], "--adduser") == 0)
      strcat(command, argv[2]);
   else if(strcmp(argv[1], "--deluser") == 0) {
      strcpy(command, "deluser --remove-home ");
      strcat(command, argv[2]);
   }
   system(command);
   return 0;
}

