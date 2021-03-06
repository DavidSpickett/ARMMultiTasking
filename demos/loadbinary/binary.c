#include "common/assert.h"
#include "user/thread.h"

const char* globalmsg = "Using a global!";
// To prove we init .bss correctly
int zero_init_global = 0;

void other_worker() {
  log_event(globalmsg);
}

// The entry point
void worker() {
  assert(zero_init_global == 0);
  /* Note that this *will* get reloaded when loadbinary
     loads the file again. So each time we'll add a new thread. */
  static bool add_new_thread = true;
  const char* msg = "Hello";
  log_event(msg);
  if (add_new_thread) {
    log_event("Adding a new thread!");
    add_named_thread(other_worker, "other");
    add_new_thread = false;
  }
  log_event("Goodbye");
}
