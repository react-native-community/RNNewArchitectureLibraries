cmake_minimum_required(VERSION 3.13)
set(CMAKE_VERBOSE_MAKEFILE on)

file(
  GLOB react_codegen_SRCS CONFIGURE_DEPENDS
  *.cpp
  react/renderer/components/RTNImageViewSpec/*.cpp
  ../android/build/generated/source/codegen/jni/react/renderer/components/RTNImageViewSpec/EventEmitters.cpp
  ../android/build/generated/source/codegen/jni/react/renderer/components/RTNImageViewSpec/Props.cpp
  ../android/build/generated/source/codegen/jni/RTNImageViewSpec-generated.cpp
)

add_library(
  react_codegen_RTNImageViewSpec
  SHARED
  ${react_codegen_SRCS}
)

target_include_directories(
  react_codegen_RTNImageViewSpec
  PUBLIC
  .
  react/renderer/components/RTNImageViewSpec
  ../android/build/generated/source/codegen/jni
  ../android/build/generated/source/codegen/jni/react/renderer/components/RTNImageViewSpec
)

target_link_libraries(
  react_codegen_RTNImageViewSpec
  fbjni
  folly_runtime
  glog
  jsi
  react_codegen_rncore
  react_debug
  react_nativemodule_core
  react_render_core
  react_render_debug
  react_render_graphics
  react_render_imagemanager
  react_render_mapbuffer
  rrc_image
  rrc_view
  turbomodulejsijni
  yoga
)

target_compile_options(
  react_codegen_RTNImageViewSpec
  PRIVATE
  -DLOG_TAG=\"ReactNative\"
  -fexceptions
  -frtti
  -std=c++17
  -Wall
)
