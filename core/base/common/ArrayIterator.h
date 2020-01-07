/// \ingroup base
/// \class ttk::ArrayIterator
/// \author Charles Gueunet charles.gueunet@kitware.com
/// \date 2020-01-08
///
///\brief TTK class to iterate over any array with a generic interface

#pragma once

#include "DataTypes.h"
#include <iterator>

template <typename ElementType>
class GenericIterator
  : public std::iterator<std::random_access_iterator_tag, ElementType> {
  ElementType *p;

public:
  GenericIterator() : p(nullptr) {
    // Why is this required ??
  }
  GenericIterator(ElementType *x) : p(x) {
  }
  GenericIterator(const GenericIterator<ElementType> &it) : p(it.p) {
  }
  GenericIterator &operator++() {
    ++p;
    return *this;
  }
  GenericIterator operator++(int) {
    GenericIterator tmp(*this);
    operator++();
    return tmp;
  }
  GenericIterator operator+(int offset) {
    return p + offset;
  }
  bool operator==(const GenericIterator<ElementType> &rhs) const {
    return p == rhs.p;
  }
  bool operator!=(const GenericIterator<ElementType> &rhs) const {
    return p != rhs.p;
  }
  ElementType &operator*() {
    return *p;
  }
};

template <typename ElementType>
class ArrayHandler : public GenericIterator<ElementType> {

  using iteratorT = GenericIterator<ElementType>;
  iteratorT beginIt, endIt;

public:
  ArrayHandler(iteratorT b, iteratorT e) : beginIt(b), endIt(e) {
  }
  ArrayHandler(ElementType *b, ElementType *e) : beginIt(b), endIt(e) {
  }
  // TODO cbegin / cend

  iteratorT begin()
  {
    return this->beginIt;
  }

  iteratorT end()
  {
    return this->endIt;
  }

  // Access underlying data

  ElementType &operator[](int idx) {
    return *(this->beginIt + idx);
  }
};
