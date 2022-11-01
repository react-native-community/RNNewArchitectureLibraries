#include "RTNImageComponentCustomShadowNode.h"

#include <react/renderer/core/LayoutContext.h>

namespace facebook {
namespace react {

extern const char RTNImageComponentComponentName[] =
    "RTNImageComponent";

void RTNImageComponentCustomShadowNode::setImageManager(
    const SharedImageManager &imageManager) {
  ensureUnsealed();
  imageManager_ = imageManager;
}

void RTNImageComponentCustomShadowNode::updateStateIfNeeded() {
  const auto &newImageSource = getImageSource();

  auto const &currentState = getStateData();

  auto imageSource = currentState.getImageSource();

  bool anyChanged = newImageSource != imageSource;

  if (!anyChanged) {
    return;
  }

  // Now we are about to mutate the Shadow Node.
  ensureUnsealed();

  // It is not possible to copy or move image requests from SliderLocalData,
  // so instead we recreate any image requests (that may already be in-flight?)
  // TODO: check if multiple requests are cached or if it's a net loss
  auto state = RTNImageComponentCustomNativeState{
      newImageSource,
      imageManager_->requestImage(newImageSource, getSurfaceId())};
  setStateData(std::move(state));
}

ImageSource RTNImageComponentCustomShadowNode::getImageSource()
    const {
  return getConcreteProps().image;
}

void RTNImageComponentCustomShadowNode::layout(
    LayoutContext layoutContext) {
  updateStateIfNeeded();
  ConcreteViewShadowNode::layout(layoutContext);
}

} // namespace react
} // namespace facebook
