#include "RTNImageComponentCustomNativeState.h"

namespace facebook::react {

ImageSource RTNImageComponentCustomNativeState::getImageSource() const {
  return imageSource_;
}

ImageRequest const &RTNImageComponentCustomNativeState::getImageRequest() const {
  return *imageRequest_;
}

} // namespace facebook::react
