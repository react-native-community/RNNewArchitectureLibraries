#ifndef Person_hpp
#define Person_hpp

#include <string>
namespace facebook::react {
class Person {
public:
  Person(int age): _age(age) {};
  //  ~Person();
  int doubleAge() ;
private:
  int _age;
};
};

#endif /* Person_hpp */
