#include "user/thread.h"
#include "thread.h"
#include "mutex.h"
#include "util.h"
#include <string.h>

Mutex buffer_mutex;
char buffer[4];

void thread_work(const char* word) {
  while (!lock_mutex(&buffer_mutex)) {
    // Can't unlock a mutex you didn't lock
    bool unlocked = unlock_mutex(&buffer_mutex);
    assert(!unlocked);
    yield_next();
  }

  /* Looks a little silly, but shows we can
     yield during the copy with no issues. */
  char* dest = buffer;
  while (*word) {
    *dest++ = *word++;
    log_event("copying...");
    yield_next();
  }

  log_event(buffer);
  unlock_mutex(&buffer_mutex);
}

void setup(void) {
  KernelConfig cfg = { .log_scheduler=false,
                       .destroy_on_stack_err=false};
  k_set_kernel_config(&cfg);

  init_mutex(&buffer_mutex);

  const char* word1 = "dog";
  ThreadArgs args1 = make_args(word1, 0, 0, 0);
  k_add_named_thread_with_args(thread_work, NULL, &args1);

  const char* word2 = "cat";
  ThreadArgs args2 = make_args(word2, 0, 0, 0);
  k_add_named_thread_with_args(thread_work, NULL, &args2);
}
