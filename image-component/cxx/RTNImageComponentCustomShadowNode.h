#pragma once
#include "RTNImageComponentCustomNativeState.h"

#include <jsi/jsi.h>
#include <react/renderer/components/RTNImageViewSpec/EventEmitters.h>
#include <react/renderer/components/RTNImageViewSpec/Props.h>
#include <react/renderer/components/view/ConcreteViewShadowNode.h>

#include <react/renderer/imagemanager/ImageManager.h>
#include <react/renderer/imagemanager/primitives.h>

namespace facebook {
namespace react {

JSI_EXPORT extern const char RTNImageComponentComponentName[];

/*
 * `ShadowNode` for <Slider> component.
 */
class RTNImageComponentCustomShadowNode final
    : public ConcreteViewShadowNode<
          RTNImageComponentComponentName,
          RTNImageComponentProps,
          RTNImageComponentEventEmitter,
          RTNImageComponentCustomNativeState> {
 public:
  using ConcreteViewShadowNode::ConcreteViewShadowNode;

  // Associates a shared `ImageManager` with the node.
  void setImageManager(const SharedImageManager &imageManager);

  static RTNImageComponentCustomNativeState initialStateData(
      ShadowNodeFragment const &fragment,
      ShadowNodeFamilyFragment const &familyFragment,
      ComponentDescriptor const &componentDescriptor) {
    auto imageSource = ImageSource{ImageSource::Type::Invalid};
    return {imageSource, {imageSource, nullptr}};
  }

#pragma mark - LayoutableShadowNode

  void layout(LayoutContext layoutContext) override;

 private:
  void updateStateIfNeeded();

  ImageSource getImageSource() const;

  SharedImageManager imageManager_;
};

} // namespace react
} // namespace facebook
