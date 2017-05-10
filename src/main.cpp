#include <memory>
#include <iostream>
#include <type_traits>

using namespace std;

struct Base {
  int foo()
  {
    cout << "Hello world" << endl;
  }
};


struct Handle : std::shared_ptr<Base>
{
  
  using X = decltype(&Base::foo)(Base);
  using Quux = typename std::result_of<X>::type;
  
  static_assert(std::is_same<Quux, int>::value, "");

  template <typename R, typename ...Args>
  R call_foo( Args &&... args)
  {
    return (*this)->foo(std::forward<Args>(args)...);
  }

  template <typename T, typename R, typename ...Args>
  static auto getproxy(R (T::*mf)(Args...))
  {
    return &Handle::call_foo<R, Args...>;
  }


};



int main(int argc, char **argvc)
{
  Base *b = new Base();
  Handle h;
  h.reset(b);

  auto func = Handle::getproxy(&Base::foo);
  (h.*func)();

}




