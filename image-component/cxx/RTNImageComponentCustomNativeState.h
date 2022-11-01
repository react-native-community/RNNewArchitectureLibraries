#pragma once

#ifdef ANDROID
#include <folly/dynamic.h>
#include <react/renderer/mapbuffer/MapBuffer.h>
#include <react/renderer/mapbuffer/MapBufferBuilder.h>
#endif

#include <react/renderer/imagemanager/ImageRequest.h>
#include <react/renderer/imagemanager/primitives.h>

namespace facebook {
namespace react {

/*
 * State for <Slider> component.
 */
class RTNImageComponentCustomNativeState final {
 public:
  RTNImageComponentCustomNativeState(
      ImageSource const &imageSource,
      ImageRequest imageRequest)
      : imageSource_(imageSource),
        imageRequest_(
            std::make_shared<ImageRequest>(std::move(imageRequest))){};

  RTNImageComponentCustomNativeState() = default;

  ImageSource getImageSource() const;
  ImageRequest const &getImageRequest() const;

#ifdef ANDROID
  RTNImageComponentCustomNativeState(RTNImageComponentCustomNativeState const &previousState, folly::dynamic data){};

  /*
   * Empty implementation for Android because it doesn't use this class.
   */
  folly::dynamic getDynamic() const {
    return {};
  };
  MapBuffer getMapBuffer() const {
    return MapBufferBuilder::EMPTY();
  };
#endif

 private:
  ImageSource imageSource_;
  std::shared_ptr<ImageRequest> imageRequest_;
};

} // namespace react
} // namespace facebook
