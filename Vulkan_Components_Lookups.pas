(******************************************************************************
 *                                 vgVulkan                                  *
 ******************************************************************************
 *                        Version 2021-05-01-01-01-0000                       *
 ******************************************************************************
 *                                zlib license                                *
 *============================================================================*
 *                                                                            *
 * Copyright (C) 2021 Datavis (www.datavis.com.au) johnh@datavis.com.au       *
 *                                                                            *
 * This software is provided 'as-is', without any express or implied          *
 * warranty. In no event will the authors be held liable for any damages      *
 * arising from the use of this software.                                     *
 *                                                                            *
 * Permission is granted to anyone to use this software for any purpose,      *
 * including commercial applications, and to alter it and redistribute it     *
 * freely, subject to the following restrictions:                             *
 *                                                                            *
 * 1. The origin of this software must not be misrepresented; you must not    *
 *    claim that you wrote the original software. If you use this software    *
 *    in a product, an acknowledgement in the product documentation would be  *
 *    appreciated but is not required.                                        *
 * 2. Altered source versions must be plainly marked as such, and must not be *
 *    misrepresented as being the original software.                          *
 * 3. This notice may not be removed or altered from any source distribution. *
 *                                                                            *
 ******************************************************************************
 *                  General guidelines for code contributors                  *
 *============================================================================*
 *                                                                            *
 * 1. Make sure you are legally allowed to make a contribution under the zlib *
 *    license.                                                                *
 * 2. The zlib license header goes at the top of each source file, with       *
 *    appropriate copyright notice.                                           *
 * 3. This PasVulkan wrapper may be used only with the PasVulkan-own Vulkan   *
 *    Pascal header.                                                          *
 * 4. After a pull request, check the status of your pull request on          *
      http://github.com/BeRo1985/pasvulkan                                    *
 * 5. Write code which's compatible with Delphi >= 2009 and FreePascal >=     *
 *    3.1.1                                                                   *
 * 6. Don't use Delphi-only, FreePascal-only or Lazarus-only libraries/units, *
 *    but if needed, make it out-ifdef-able.                                  *
 * 7. No use of third-party libraries/units as possible, but if needed, make  *
 *    it out-ifdef-able.                                                      *
 * 8. Try to use const when possible.                                         *
 * 9. Make sure to comment out writeln, used while debugging.                 *
 * 10. Make sure the code compiles on 32-bit and 64-bit platforms (x86-32,    *
 *     x86-64, ARM, ARM64, etc.).                                             *
 * 11. Make sure the code runs on all platforms with Vulkan support           *
 *                                                                            *
 ******************************************************************************)

unit Vulkan_Components_Lookups;
    (*    Handles conversion from std Enum values to custom for use in PUBLISHED properties


    *)
interface

Uses
  Vulkan,
  PasVulkan.Framework;

Var
  PortabilityOn : Boolean = False;

Type

  TvgInstanceResult = (VC_UNKNOWN_STATUS,
                       VC_VULKAN_OK,
                       VC_VULKAN_NOT_AVAILABLE);

  TvgAllocationMode = (VG_SELF_MANAGE,
                       VG_VULKAN_MANAGE);

  TvgLayerRequireMode = (VGL_NOT_REQUIRED ,  //do not need to initialize default
                         VGL_MUST_HAVE,     //Instance initialization MUST have this layer
                         VGL_OPTIONAL,     //Instance may have the layer
                         VGL_ON_VALIDATION);  //ONLY if Validation is ON

  TvgExtensionRequireMode = (VGE_NOT_REQUIRED,
                             VGE_MUST_HAVE,
                             VGE_OPTIONAL,     //Instance may have the layer
                         VGE_ON_VALIDATION);

  TvgQueueFamilyMode = (VGQ_NOT_REQUIRED,
                           VGQ_MUST_HAVE,
                           VGQ_OPTIONAL);

  TvgQueueFamilyType = (VGT_UNIVERSAL,
                        VGT_PRESENT,
                        VGT_GRAPHIC,
                        VGT_COMPUTE,
                        VGT_TRANSFER );

  TvgAPI_Version = (VG_API_VERSION,
                    VG_API_VERSION_1_0,
                    VG_API_VERSION_1_1,
                    VG_API_VERSION_1_2,
                    VG_API_VERSION_1_3);


     TvgColorSpaceKHR=
      (
       SRGB_NONLINEAR_KHR,
       DISPLAY_P3_NONLINEAR_EXT,
       EXTENDED_SRGB_LINEAR_EXT,
       DISPLAY_P3_LINEAR_EXT,
       DCI_P3_NONLINEAR_EXT,
       BT709_LINEAR_EXT,
       BT709_NONLINEAR_EXT,
       BT2020_LINEAR_EXT,
       HDR10_ST2084_EXT,
       DOLBYVISION_EXT,
       HDR10_HLG_EXT,
       ADOBERGB_LINEAR_EXT,
       ADOBERGB_NONLINEAR_EXT,
       PASS_THROUGH_EXT,
       EXTENDED_SRGB_NONLINEAR_EXT,
       DISPLAY_NATIVE_AMD       //< Backwards-compatible alias containing a typo
      );

     TvgFormat =
      (
       UNDEFINED,
       R4G4_UNORM_PACK8,
       R4G4B4A4_UNORM_PACK16,
       B4G4R4A4_UNORM_PACK16,
       R5G6B5_UNORM_PACK16,
       B5G6R5_UNORM_PACK16,
       R5G5B5A1_UNORM_PACK16,
       B5G5R5A1_UNORM_PACK16,
       A1R5G5B5_UNORM_PACK16,
       R8_UNORM,
       R8_SNORM,
       R8_USCALED,
       R8_SSCALED,
       R8_UINT,
       R8_SINT,
       R8_SRGB,
       R8G8_UNORM,
       R8G8_SNORM,
       R8G8_USCALED,
       R8G8_SSCALED,
       R8G8_UINT,
       R8G8_SINT,
       R8G8_SRGB,
       R8G8B8_UNORM,
       R8G8B8_SNORM,
       R8G8B8_USCALED,
       R8G8B8_SSCALED,
       R8G8B8_UINT,
       R8G8B8_SINT,
       R8G8B8_SRGB,
       B8G8R8_UNORM,
       B8G8R8_SNORM,
       B8G8R8_USCALED,
       B8G8R8_SSCALED,
       B8G8R8_UINT,
       B8G8R8_SINT,
       B8G8R8_SRGB,
       R8G8B8A8_UNORM,
       R8G8B8A8_SNORM,
       R8G8B8A8_USCALED,
       R8G8B8A8_SSCALED,
       R8G8B8A8_UINT,
       R8G8B8A8_SINT,
       R8G8B8A8_SRGB,
       B8G8R8A8_UNORM,
       B8G8R8A8_SNORM,
       B8G8R8A8_USCALED,
       B8G8R8A8_SSCALED,
       B8G8R8A8_UINT,
       B8G8R8A8_SINT,
       B8G8R8A8_SRGB,
       A8B8G8R8_UNORM_PACK32,
       A8B8G8R8_SNORM_PACK32,
       A8B8G8R8_USCALED_PACK32,
       A8B8G8R8_SSCALED_PACK32,
       A8B8G8R8_UINT_PACK32,
       A8B8G8R8_SINT_PACK32,
       A8B8G8R8_SRGB_PACK32,
       A2R10G10B10_UNORM_PACK32,
       A2R10G10B10_SNORM_PACK32,
       A2R10G10B10_USCALED_PACK32,
       A2R10G10B10_SSCALED_PACK32,
       A2R10G10B10_UINT_PACK32,
       A2R10G10B10_SINT_PACK32,
       A2B10G10R10_UNORM_PACK32,
       A2B10G10R10_SNORM_PACK32,
       A2B10G10R10_USCALED_PACK32,
       A2B10G10R10_SSCALED_PACK32,
       A2B10G10R10_UINT_PACK32,
       A2B10G10R10_SINT_PACK32,
       R16_UNORM,
       R16_SNORM,
       R16_USCALED,
       R16_SSCALED,
       R16_UINT,
       R16_SINT,
       R16_SFLOAT,
       R16G16_UNORM,
       R16G16_SNORM,
       R16G16_USCALED,
       R16G16_SSCALED,
       R16G16_UINT,
       R16G16_SINT,
       R16G16_SFLOAT,
       R16G16B16_UNORM,
       R16G16B16_SNORM,
       R16G16B16_USCALED,
       R16G16B16_SSCALED,
       R16G16B16_UINT,
       R16G16B16_SINT,
       R16G16B16_SFLOAT,
       R16G16B16A16_UNORM,
       R16G16B16A16_SNORM,
       R16G16B16A16_USCALED,
       R16G16B16A16_SSCALED,
       R16G16B16A16_UINT,
       R16G16B16A16_SINT,
       R16G16B16A16_SFLOAT,
       R32_UINT,
       R32_SINT,
       R32_SFLOAT,
       R32G32_UINT,
       R32G32_SINT,
       R32G32_SFLOAT,
       R32G32B32_UINT,
       R32G32B32_SINT,
       R32G32B32_SFLOAT,
       R32G32B32A32_UINT,
       R32G32B32A32_SINT,
       R32G32B32A32_SFLOAT,
       R64_UINT,
       R64_SINT,
       R64_SFLOAT,
       R64G64_UINT,
       R64G64_SINT,
       R64G64_SFLOAT,
       R64G64B64_UINT,
       R64G64B64_SINT,
       R64G64B64_SFLOAT,
       R64G64B64A64_UINT,
       R64G64B64A64_SINT,
       R64G64B64A64_SFLOAT,
       B10G11R11_UFLOAT_PACK32,
       E5B9G9R9_UFLOAT_PACK32,
       D16_UNORM,
       X8_D24_UNORM_PACK32,
       D32_SFLOAT,
       S8_UINT,
       D16_UNORM_S8_UINT,
       D24_UNORM_S8_UINT,
       D32_SFLOAT_S8_UINT,
       BC1_RGB_UNORM_BLOCK,
       BC1_RGB_SRGB_BLOCK,
       BC1_RGBA_UNORM_BLOCK,
       BC1_RGBA_SRGB_BLOCK,
       BC2_UNORM_BLOCK,
       BC2_SRGB_BLOCK,
       BC3_UNORM_BLOCK,
       BC3_SRGB_BLOCK,
       BC4_UNORM_BLOCK,
       BC4_SNORM_BLOCK,
       BC5_UNORM_BLOCK,
       BC5_SNORM_BLOCK,
       BC6H_UFLOAT_BLOCK,
       BC6H_SFLOAT_BLOCK,
       BC7_UNORM_BLOCK,
       BC7_SRGB_BLOCK,
       ETC2_R8G8B8_UNORM_BLOCK,
       ETC2_R8G8B8_SRGB_BLOCK,
       ETC2_R8G8B8A1_UNORM_BLOCK,
       ETC2_R8G8B8A1_SRGB_BLOCK,
       ETC2_R8G8B8A8_UNORM_BLOCK,
       ETC2_R8G8B8A8_SRGB_BLOCK,
       EAC_R11_UNORM_BLOCK,
       EAC_R11_SNORM_BLOCK,
       EAC_R11G11_UNORM_BLOCK,
       EAC_R11G11_SNORM_BLOCK,
       ASTC_4x4_UNORM_BLOCK,
       ASTC_4x4_SRGB_BLOCK,
       ASTC_5x4_UNORM_BLOCK,
       ASTC_5x4_SRGB_BLOCK,
       ASTC_5x5_UNORM_BLOCK,
       ASTC_5x5_SRGB_BLOCK,
       ASTC_6x5_UNORM_BLOCK,
       ASTC_6x5_SRGB_BLOCK,
       ASTC_6x6_UNORM_BLOCK,
       ASTC_6x6_SRGB_BLOCK,
       ASTC_8x5_UNORM_BLOCK,
       ASTC_8x5_SRGB_BLOCK,
       ASTC_8x6_UNORM_BLOCK,
       ASTC_8x6_SRGB_BLOCK,
       ASTC_8x8_UNORM_BLOCK,
       ASTC_8x8_SRGB_BLOCK,
       ASTC_10x5_UNORM_BLOCK,
       ASTC_10x5_SRGB_BLOCK,
       ASTC_10x6_UNORM_BLOCK,
       ASTC_10x6_SRGB_BLOCK,
       ASTC_10x8_UNORM_BLOCK,
       ASTC_10x8_SRGB_BLOCK,
       ASTC_10x10_UNORM_BLOCK,
       ASTC_10x10_SRGB_BLOCK,
       ASTC_12x10_UNORM_BLOCK,
       ASTC_12x10_SRGB_BLOCK,
       ASTC_12x12_UNORM_BLOCK,
       ASTC_12x12_SRGB_BLOCK,
       PVRTC1_2BPP_UNORM_BLOCK_IMG,
       PVRTC1_4BPP_UNORM_BLOCK_IMG,
       PVRTC2_2BPP_UNORM_BLOCK_IMG,
       PVRTC2_4BPP_UNORM_BLOCK_IMG,
       PVRTC1_2BPP_SRGB_BLOCK_IMG,
       PVRTC1_4BPP_SRGB_BLOCK_IMG,
       PVRTC2_2BPP_SRGB_BLOCK_IMG,
       PVRTC2_4BPP_SRGB_BLOCK_IMG,
       ASTC_4x4_SFLOAT_BLOCK_EXT,
       ASTC_5x4_SFLOAT_BLOCK_EXT,
       ASTC_5x5_SFLOAT_BLOCK_EXT,
       ASTC_6x5_SFLOAT_BLOCK_EXT,
       ASTC_6x6_SFLOAT_BLOCK_EXT,
       ASTC_8x5_SFLOAT_BLOCK_EXT,
       ASTC_8x6_SFLOAT_BLOCK_EXT,
       ASTC_8x8_SFLOAT_BLOCK_EXT,
       ASTC_10x5_SFLOAT_BLOCK_EXT,
       ASTC_10x6_SFLOAT_BLOCK_EXT,
       ASTC_10x8_SFLOAT_BLOCK_EXT,
       ASTC_10x10_SFLOAT_BLOCK_EXT,
       ASTC_12x10_SFLOAT_BLOCK_EXT,
       ASTC_12x12_SFLOAT_BLOCK_EXT,
       G8B8G8R8_422_UNORM,
       B8G8R8G8_422_UNORM,
       G8_B8_R8_3PLANE_420_UNORM,
       G8_B8R8_2PLANE_420_UNORM,
       G8_B8_R8_3PLANE_422_UNORM,
       G8_B8R8_2PLANE_422_UNORM,
       G8_B8_R8_3PLANE_444_UNORM,
       R10X6_UNORM_PACK16,
       R10X6G10X6_UNORM_2PACK16,
       R10X6G10X6B10X6A10X6_UNORM_4PACK16,
       G10X6B10X6G10X6R10X6_422_UNORM_4PACK16,
       B10X6G10X6R10X6G10X6_422_UNORM_4PACK16,
       G10X6_B10X6_R10X6_3PLANE_420_UNORM_3PACK16,
       G10X6_B10X6R10X6_2PLANE_420_UNORM_3PACK16,
       G10X6_B10X6_R10X6_3PLANE_422_UNORM_3PACK16,
       G10X6_B10X6R10X6_2PLANE_422_UNORM_3PACK16,
       G10X6_B10X6_R10X6_3PLANE_444_UNORM_3PACK16,
       R12X4_UNORM_PACK16,
       R12X4G12X4_UNORM_2PACK16,
       R12X4G12X4B12X4A12X4_UNORM_4PACK16,
       G12X4B12X4G12X4R12X4_422_UNORM_4PACK16,
       B12X4G12X4R12X4G12X4_422_UNORM_4PACK16,
       G12X4_B12X4_R12X4_3PLANE_420_UNORM_3PACK16,
       G12X4_B12X4R12X4_2PLANE_420_UNORM_3PACK16,
       G12X4_B12X4_R12X4_3PLANE_422_UNORM_3PACK16,
       G12X4_B12X4R12X4_2PLANE_422_UNORM_3PACK16,
       G12X4_B12X4_R12X4_3PLANE_444_UNORM_3PACK16,
       G16B16G16R16_422_UNORM,
       B16G16R16G16_422_UNORM,
       G16_B16_R16_3PLANE_420_UNORM,
       G16_B16R16_2PLANE_420_UNORM,
       G16_B16_R16_3PLANE_422_UNORM,
       G16_B16R16_2PLANE_422_UNORM,
       G16_B16_R16_3PLANE_444_UNORM,
       ASTC_3x3x3_UNORM_BLOCK_EXT,
       ASTC_3x3x3_SRGB_BLOCK_EXT,
       ASTC_3x3x3_SFLOAT_BLOCK_EXT,
       ASTC_4x3x3_UNORM_BLOCK_EXT,
       ASTC_4x3x3_SRGB_BLOCK_EXT,
       ASTC_4x3x3_SFLOAT_BLOCK_EXT,
       ASTC_4x4x3_UNORM_BLOCK_EXT,
       ASTC_4x4x3_SRGB_BLOCK_EXT,
       ASTC_4x4x3_SFLOAT_BLOCK_EXT,
       ASTC_4x4x4_UNORM_BLOCK_EXT,
       ASTC_4x4x4_SRGB_BLOCK_EXT,
       ASTC_4x4x4_SFLOAT_BLOCK_EXT,
       ASTC_5x4x4_UNORM_BLOCK_EXT,
       ASTC_5x4x4_SRGB_BLOCK_EXT,
       ASTC_5x4x4_SFLOAT_BLOCK_EXT,
       ASTC_5x5x4_UNORM_BLOCK_EXT,
       ASTC_5x5x4_SRGB_BLOCK_EXT,
       ASTC_5x5x4_SFLOAT_BLOCK_EXT,
       ASTC_5x5x5_UNORM_BLOCK_EXT,
       ASTC_5x5x5_SRGB_BLOCK_EXT,
       ASTC_5x5x5_SFLOAT_BLOCK_EXT,
       ASTC_6x5x5_UNORM_BLOCK_EXT,
       ASTC_6x5x5_SRGB_BLOCK_EXT,
       ASTC_6x5x5_SFLOAT_BLOCK_EXT,
       ASTC_6x6x5_UNORM_BLOCK_EXT,
       ASTC_6x6x5_SRGB_BLOCK_EXT,
       ASTC_6x6x5_SFLOAT_BLOCK_EXT,
       ASTC_6x6x6_UNORM_BLOCK_EXT,
       ASTC_6x6x6_SRGB_BLOCK_EXT,
       ASTC_6x6x6_SFLOAT_BLOCK_EXT,
       A4R4G4B4_UNORM_PACK16_EXT,
       A4B4G4R4_UNORM_PACK16_EXT,
       B10X6G10X6R10X6G10X6_422_UNORM_4PACK16_KHR,
       B12X4G12X4R12X4G12X4_422_UNORM_4PACK16_KHR,
       B16G16R16G16_422_UNORM_KHR,
       B8G8R8G8_422_UNORM_KHR,
       G10X6B10X6G10X6R10X6_422_UNORM_4PACK16_KHR,
       G10X6_B10X6R10X6_2PLANE_420_UNORM_3PACK16_KHR,
       G10X6_B10X6R10X6_2PLANE_422_UNORM_3PACK16_KHR,
       G10X6_B10X6_R10X6_3PLANE_420_UNORM_3PACK16_KHR,
       G10X6_B10X6_R10X6_3PLANE_422_UNORM_3PACK16_KHR,
       G10X6_B10X6_R10X6_3PLANE_444_UNORM_3PACK16_KHR,
       G12X4B12X4G12X4R12X4_422_UNORM_4PACK16_KHR,
       G12X4_B12X4R12X4_2PLANE_420_UNORM_3PACK16_KHR,
       G12X4_B12X4R12X4_2PLANE_422_UNORM_3PACK16_KHR,
       G12X4_B12X4_R12X4_3PLANE_420_UNORM_3PACK16_KHR,
       G12X4_B12X4_R12X4_3PLANE_422_UNORM_3PACK16_KHR,
       G12X4_B12X4_R12X4_3PLANE_444_UNORM_3PACK16_KHR,
       G16B16G16R16_422_UNORM_KHR,
       G16_B16R16_2PLANE_420_UNORM_KHR,
       G16_B16R16_2PLANE_422_UNORM_KHR,
       G16_B16_R16_3PLANE_420_UNORM_KHR,
       G16_B16_R16_3PLANE_422_UNORM_KHR,
       G16_B16_R16_3PLANE_444_UNORM_KHR,
       G8B8G8R8_422_UNORM_KHR,
       G8_B8R8_2PLANE_420_UNORM_KHR,
       G8_B8R8_2PLANE_422_UNORM_KHR,
       G8_B8_R8_3PLANE_420_UNORM_KHR,
       G8_B8_R8_3PLANE_422_UNORM_KHR,
       G8_B8_R8_3PLANE_444_UNORM_KHR,
       R10X6G10X6B10X6A10X6_UNORM_4PACK16_KHR,
       R10X6G10X6_UNORM_2PACK16_KHR,
       R10X6_UNORM_PACK16_KHR,
       R12X4G12X4B12X4A12X4_UNORM_4PACK16_KHR,
       R12X4G12X4_UNORM_2PACK16_KHR,
       R12X4_UNORM_PACK16_KHR
      )  ;

     TvgPresentModeKHR=
      (
       PM_IMMEDIATE,
       PM_MAILBOX,
       PM_FIFO,
       PM_FIFO_RELAXED,
       PM_SHARED_DEMAND_REFRESH,
       PM_SHARED_CONTINUOUS_REFRESH
      );

     TvgSharingMode=
      (
       SM_EXCLUSIVE,
       SM_CONCURRENT
      );

     TvgImageUsageFlagsSet = Set of
     (
       IU_TRANSFER_SRC,//$00000001,                                 //< Can be used as a source of transfer operations
       IU_TRANSFER_DST,//$00000002,                                //< Can be used as a destination of transfer operations
       IU_SAMPLED,//$00000004,                                     //< Can be sampled from (SAMPLED_IMAGE and COMBINED_IMAGE_SAMPLER descriptor types)
       IU_STORAGE,//$00000008,                                     //< Can be used as storage image (STORAGE_IMAGE descriptor type)
       IU_COLOR_ATTACHMENT,//$00000010,                            //< Can be used as framebuffer color attachment
       IU_DEPTH_STENCIL_ATTACHMENT,//$00000020,                    //< Can be used as framebuffer depth/stencil attachment
       IU_TRANSIENT_ATTACHMENT,//$00000040,                        //< Image data not needed outside of rendering
       IU_INPUT_ATTACHMENT,//$00000080,                            //< Can be used as framebuffer input attachment
       IU_SHADING_RATE_IMAGE_NV,//$00000100,
       IU_FRAGMENT_DENSITY_MAP_EXT,//$00000200,

       IU_RESERVED_10,//$00000400,
       IU_RESERVED_11,//$00000800,
       IU_RESERVED_12,//$00001000,
       IU_RESERVED_13,//$00002000,
       IU_RESERVED_14,//$00004000,
       IU_RESERVED_15,//$00008000,
       IU_RESERVED_16_QCOM,//$00010000,
       IU_RESERVED_17_QCOM  //$00020000,

       );

     TVgCompositeAlphaFlagBitsKHRSet = Set of
      (
       CA_OPAQUE,             //=$00000001,
       CA_PRE_MULTIPLIED,     //=$00000002,
       CA_POST_MULTIPLIED,    //=$00000004,
       CA_ALPHA_INHERIT       //=$00000008
      );

     TVgSurfaceTransformFlagBitsKHRSet= Set of
      (
       ST_IDENTITY,//=$00000001,
       ST_ROTATE_90,//=$00000002,
       ST_ROTATE_180,//=$00000004,
       ST_ROTATE_270,//=$00000008,
       ST_HORIZONTAL_MIRROR,//=$00000010,
       ST_HORIZONTAL_MIRROR_ROTATE_90,//=$00000020,
       ST_HORIZONTAL_MIRROR_ROTATE_180,//=$00000040,
       ST_HORIZONTAL_MIRROR_ROTATE_270,//=$00000080,
       ST_TRANSFORM_INHERIT//=$00000100
      );

    TVgCommandPoolCreateFlag=  Set of
      (
       CP_TRANSIENT,                           //< Command buffers have a short lifetime
       CP_RESET_COMMAND_BUFFER,                //< Command buffers may release their memory individually
       CP_PROTECTED
      );

     TvgCommandBufferLevel=
      (
       CB_PRIMARY,
       CB_SECONDARY
      );

      TvgImageType   =
      (
       IT_1D,
       IT_2D,
       IT_3D
      );

     TvgImageViewType=
      (
       IVT_1D,
       IVT_2D,
       IVT_3D,
       IVT_CUBE,
       IVT_1D_ARRAY,
       IVT_2D_ARRAY,
       IVT_CUBE_ARRAY
      );

      TvgComponentSwizzle=
      (
       CS_IDENTITY,
       CS_ZERO,
       CS_ONE,
       CS_RED,
       CS_GREEN,
       CS_BLUE,
       CS_ALPHA
      );

      TvgImageAspectFlagBits=  Set of
      (
       IA_COLOR_BIT,
       IA_DEPTH_BIT,
       IA_STENCIL_BIT,
       IA_METADATA_BIT,
       IA_PLANE_0_BIT,
       IA_PLANE_1_BIT,
       IA_PLANE_2_BIT,
       IA_MEMORY_PLANE_0_BIT_EXT,
       IA_MEMORY_PLANE_1_BIT_EXT,
       IA_MEMORY_PLANE_2_BIT_EXT,
       IA_MEMORY_PLANE_3_BIT_EXT
      );

     TvgVertexInputRate=
      (
       IR_VERTEX,
       IR_INSTANCE
      );

     TvgPrimitiveTopology=
      (
       POINT_LIST,
       LINE_LIST,
       LINE_STRIP,
       TRIANGLE_LIST,
       TRIANGLE_STRIP,
       TRIANGLE_FAN,
       LINE_LIST_WITH_ADJACENCY,
       LINE_STRIP_WITH_ADJACENCY,
       TRIANGLE_LIST_WITH_ADJACENCY,
       TRIANGLE_STRIP_WITH_ADJACENCY,
       PATCH_LIST
      );

      TvgWinSize =
      (
        AUTO_SIZE,
        CUSTOM_SIZE
      );

     TvgPolygonMode=
      (
       POLYGON_FILL,
       POLYGON_LINE,
       POLYGON_POINT,
       POLYGON_RECTANGLE_NV
      );

     TvgCullMode=
      (
       CULL_NONE,
       CULL_FRONT,
       CULL_BACK,
       CULL_FRONT_AND_BACK
      );

     TvgFrontFace=
      (
       FF_COUNTER_CLOCKWISE,
       FF_CLOCKWISE
      );

     TvgSampleCountFlagBits=
      (
       COUNT_01_BIT,
       COUNT_02_BIT,
       COUNT_04_BIT,
       COUNT_08_BIT,
       COUNT_16_BIT,
       COUNT_32_BIT,
       COUNT_64_BIT
      );

     TvgBlendFactor=
      (
       BF_ZERO,
       BF_ONE,
       BF_SRC_COLOR,
       BF_ONE_MINUS_SRC_COLOR,
       BF_DST_COLOR,
       BF_ONE_MINUS_DST_COLOR,
       BF_SRC_ALPHA,
       BF_ONE_MINUS_SRC_ALPHA,
       BF_DST_ALPHA,
       BF_ONE_MINUS_DST_ALPHA,
       BF_CONSTANT_COLOR,
       BF_ONE_MINUS_CONSTANT_COLOR,
       BF_CONSTANT_ALPHA,
       BF_ONE_MINUS_CONSTANT_ALPHA,
       BF_SRC_ALPHA_SATURATE,
       BF_SRC1_COLOR,
       BF_ONE_MINUS_SRC1_COLOR,
       BF_SRC1_ALPHA,
       BF_ONE_MINUS_SRC1_ALPHA
      );

     TvgBlendOp=
      (
       BO_ADD,
       BO_SUBTRACT,
       BO_REVERSE_SUBTRACT,
       BO_MIN,
       BO_MAX,
       BO_ZERO_EXT,
       BO_SRC_EXT,
       BO_DST_EXT,
       BO_SRC_OVER_EXT,
       BO_DST_OVER_EXT,
       BO_SRC_IN_EXT,
       BO_DST_IN_EXT,
       BO_SRC_OUT_EXT,
       BO_DST_OUT_EXT,
       BO_SRC_ATOP_EXT,
       BO_DST_ATOP_EXT,
       BO_XOR_EXT,
       BO_MULTIPLY_EXT,
       BO_SCREEN_EXT,
       BO_OVERLAY_EXT,
       BO_DARKEN_EXT,
       BO_LIGHTEN_EXT,
       BO_COLORDODGE_EXT,
       BO_COLORBURN_EXT,
       BO_HARDLIGHT_EXT,
       BO_SOFTLIGHT_EXT,
       BO_DIFFERENCE_EXT,
       BO_EXCLUSION_EXT,
       BO_INVERT_EXT,
       BO_INVERT_RGB_EXT,
       BO_LINEARDODGE_EXT,
       BO_LINEARBURN_EXT,
       BO_VIVIDLIGHT_EXT,
       BO_LINEARLIGHT_EXT,
       BO_PINLIGHT_EXT,
       BO_HARDMIX_EXT,
       BO_HSL_HUE_EXT,
       BO_HSL_SATURATION_EXT,
       BO_HSL_COLOR_EXT,
       BO_HSL_LUMINOSITY_EXT,
       BO_PLUS_EXT,
       BO_PLUS_CLAMPED_EXT,
       BO_PLUS_CLAMPED_ALPHA_EXT,
       BO_PLUS_DARKER_EXT,
       BO_MINUS_EXT,
       BO_MINUS_CLAMPED_EXT,
       BO_CONTRAST_EXT,
       BO_INVERT_OVG_EXT,
       BO_RED_EXT,
       BO_GREEN_EXT,
       BO_BLUE_EXT
      );

     TvgColorComponentFlagBits=  set of
      (
       R_BIT,
       G_BIT,
       B_BIT,
       A_BIT
      );

    //cant be a set as it is too large >4k
     TvgDynamicStateBit=
      (
       DS_VIEWPORT,
       DS_SCISSOR,
       DS_LINE_WIDTH,
       DS_DEPTH_BIAS,
       DS_BLEND_CONSTANTS,
       DS_DEPTH_BOUNDS,
       DS_STENCIL_COMPARE_MASK,
       DS_STENCIL_WRITE_MASK,
       DS_STENCIL_REFERENCE,
       DS_CULL_MODE,
       DS_FRONT_FACE,
       DS_PRIMITIVE_TOPOLOGY,
       DS_VIEWPORT_WITH_COUNT,
       DS_SCISSOR_WITH_COUNT,
       DS_VERTEX_INPUT_BINDING_STRIDE,
       DS_DEPTH_TEST_ENABLE,
       DS_DEPTH_WRITE_ENABLE,
       DS_DEPTH_COMPARE_OP,
       DS_DEPTH_BOUNDS_TEST_ENABLE,
       DS_STENCIL_TEST_ENABLE,
       DS_STENCIL_OP,
       DS_RASTERIZER_DISCARD_ENABLE,
       DS_DEPTH_BIAS_ENABLE,
       DS_PRIMITIVE_RESTART_ENABLE,
       DS_VIEWPORT_W_SCALING,
       DS_DISCARD_RECTANGLE,
       DS_SAMPLE_LOCATIONS,
       DS_VIEWPORT_SHADING_RATE_PALETTE,
       DS_VIEWPORT_COARSE_SAMPLE_ORDER,
       DS_EXCLUSIVE_SCISSOR,
       DS_FRAGMENT_SHADING_RATE,
       DS_LINE_STIPPLE,
       DS_RAY_TRACING_PIPELINE_STACK_SIZE,
       DS_VERTEX_INPUT,
       DS_PATCH_CONTROL_POINTS,
       DS_LOGIC_OP,
       DS_COLOR_WRITE_ENABLE
      );

     TvgAttachmentLoadOp=
      (
       LOAD_OP_LOAD,
       LOAD_OP_CLEAR,
       LOAD_OP_DONT_CARE
      );

     TvgAttachmentStoreOp=
      (
       STORE_OP_STORE,
       STORE_OP_DONT_CARE,
       STORE_OP_NONE_QCOM
      );

     TvgAttachmentType=
      ( atNone,
        atScreen,
        atFrame,
        atColour,
        atDepthStencil,
        atMSAA,          //Multi sampling AntiAliasing attachment
        atSelect,        //attachment to handle Object selection from the an image
        atCustom       //a manual setup attachment resource
      );

     TvgRenderPassTarget =
     (
      RT_NONE,
      RT_SCREEN,
      RT_FRAME
     );

     TvgImageLayout=
      (
       IMAGE_UNDEFINED,                                              //< Implicit layout an image is when its contents are undefined due to various reasons (e.g. right after creation)
       GENERAL,                                                //< General layout when image can be used for any kind of access
       COLOR_ATTACHMENT_OPTIMAL,              //< Optimal layout when image is only used for color attachment read/write
       DEPTH_STENCIL_ATTACHMENT_OPTIMAL,      //< Optimal layout when image is only used for depth/stencil attachment read/write
       DEPTH_STENCIL_READ_ONLY_OPTIMAL,       //< Optimal layout when image is used for read only depth/stencil attachment and shader access
       SHADER_READ_ONLY_OPTIMAL,              //< Optimal layout when image is used for read only shader access
       TRANSFER_SRC_OPTIMAL,                  //< Optimal layout when image is used only as source of transfer operations
       TRANSFER_DST_OPTIMAL,                  //< Optimal layout when image is used only as destination of transfer operations
       PREINITIALIZED,                        //< Initial layout used when the data is populated by the CPU
       PRESENT_SRC_KHR,
       VIDEO_DECODE_DST_KHR,
       VIDEO_DECODE_SRC_KHR,
       VIDEO_DECODE_DPB_KHR,
       SHARED_PRESENT_KHR,
       DEPTH_READ_ONLY_STENCIL_ATTACHMENT_OPTIMAL,
       DEPTH_ATTACHMENT_STENCIL_READ_ONLY_OPTIMAL,
       FRAGMENT_SHADING_RATE_ATTACHMENT_OPTIMAL_KHR,
       FRAGMENT_DENSITY_MAP_OPTIMAL_EXT,
       DEPTH_ATTACHMENT_OPTIMAL,
       DEPTH_READ_ONLY_OPTIMAL,
       STENCIL_ATTACHMENT_OPTIMAL,
       STENCIL_READ_ONLY_OPTIMAL,
       VIDEO_ENCODE_DST_KHR,
       VIDEO_ENCODE_SRC_KHR,
       VIDEO_ENCODE_DPB_KHR,
       READ_ONLY_OPTIMAL_KHR,
       ATTACHMENT_OPTIMAL_KHR
      );

     TvgPipelineStageFlagBits=   set of
      (
       TOP_OF_PIPE_BIT,                              //< Before subsequent commands are processed
       DRAW_INDIRECT_BIT,                            //< Draw/DispatchIndirect command fetch
       VERTEX_INPUT_BIT,                             //< Vertex/index fetch
       VERTEX_SHADER_BIT,                            //< Vertex shading
       TESSELLATION_CONTROL_SHADER_BIT,              //< Tessellation control shading
       TESSELLATION_EVALUATION_SHADER_BIT,           //< Tessellation evaluation shading
       GEOMETRY_SHADER_BIT,                          //< Geometry shading
       FRAGMENT_SHADER_BIT,                          //< Fragment shading
       EARLY_FRAGMENT_TESTS_BIT,                     //< Early fragment (depth and stencil) tests
       LATE_FRAGMENT_TESTS_BIT,                      //< Late fragment (depth and stencil) tests
       COLOR_ATTACHMENT_OUTPUT_BIT,                  //< Color attachment writes
       COMPUTE_SHADER_BIT,                           //< Compute shading
       TRANSFER_BIT,                                 //< Transfer/copy operations
       BOTTOM_OF_PIPE_BIT,                           //< After previous commands have completed
       HOST_BIT,                                     //< Indicates host (CPU) is a source/sink of the dependency
       ALL_GRAPHICS_BIT,                             //< All stages of the graphics pipeline
       ALL_COMMANDS_BIT,                             //< All stages supported on the queue
       COMMAND_PREPROCESS_BIT_NV,
       CONDITIONAL_RENDERING_BIT_EXT,
       TASK_SHADER_BIT_NV,
       MESH_SHADER_BIT_NV,
       RAY_TRACING_SHADER_BIT_KHR,
       FRAGMENT_SHADING_RATE_ATTACHMENT_BIT_KHR,
       FRAGMENT_DENSITY_PROCESS_BIT_EXT,
       TRANSFORM_FEEDBACK_BIT_EXT,
       ACCELERATION_STRUCTURE_BUILD_BIT_KHR,
       ACCELERATION_STRUCTURE_BUILD_BIT_NV,
       SHADING_RATE_IMAGE_BIT_NV,
       RAY_TRACING_SHADER_BIT_NV
      );

     TvgAccessFlagBits=  Set Of
      (
       INDIRECT_COMMAND_READ_BIT,                            //< Controls coherency of indirect command reads
       INDEX_READ_BIT,                                       //< Controls coherency of index reads
       VERTEX_ATTRIBUTE_READ_BIT,                            //< Controls coherency of vertex attribute reads
       UNIFORM_READ_BIT,                                     //< Controls coherency of uniform buffer reads
       INPUT_ATTACHMENT_READ_BIT,                            //< Controls coherency of input attachment reads
       SHADER_READ_BIT,                                      //< Controls coherency of shader reads
       SHADER_WRITE_BIT,                                     //< Controls coherency of shader writes
       COLOR_ATTACHMENT_READ_BIT,                            //< Controls coherency of color attachment reads
       COLOR_ATTACHMENT_WRITE_BIT,                           //< Controls coherency of color attachment writes
       DEPTH_STENCIL_ATTACHMENT_READ_BIT,                    //< Controls coherency of depth/stencil attachment reads
       DEPTH_STENCIL_ATTACHMENT_WRITE_BIT,                   //< Controls coherency of depth/stencil attachment writes
       TRANSFER_READ_BIT,                                    //< Controls coherency of transfer reads
       TRANSFER_WRITE_BIT,                                   //< Controls coherency of transfer writes
       HOST_READ_BIT,                                        //< Controls coherency of host reads
       HOST_WRITE_BIT,                                       //< Controls coherency of host writes
       MEMORY_READ_BIT,                                      //< Controls coherency of memory reads
       MEMORY_WRITE_BIT,                                     //< Controls coherency of memory writes
       COMMAND_PREPROCESS_READ_BIT_NV,
       COMMAND_PREPROCESS_WRITE_BIT_NV,
       COLOR_ATTACHMENT_READ_NONCOHERENT_BIT_EXT,
       CONDITIONAL_RENDERING_READ_BIT_EXT,
       ACCELERATION_STRUCTURE_READ_BIT_KHR,
       ACCELERATION_STRUCTURE_WRITE_BIT_KHR,
       FRAGMENT_SHADING_RATE_ATTACHMENT_READ_BIT_KHR,
       FRAGMENT_DENSITY_MAP_READ_BIT_EXT,
       TRANSFORM_FEEDBACK_WRITE_BIT_EXT,
       TRANSFORM_FEEDBACK_COUNTER_READ_BIT_EXT,
       TRANSFORM_FEEDBACK_COUNTER_WRITE_BIT_EXT,
       ACCELERATION_STRUCTURE_READ_BIT_NV,
       ACCELERATION_STRUCTURE_WRITE_BIT_NV,
       SHADING_RATE_IMAGE_READ_BIT_NV
       );

     TvgDependencyFlagBits=  Set Of
      (
       BY_REGION_BIT,                                    //< Dependency is per pixel region
       VIEW_LOCAL_BIT,
       DEVICE_GROUP_BIT,
       DEVICE_GROUP_BIT_KHR,
       VIEW_LOCAL_BIT_KHR
      );

     TvgPipelineBindPoint=
      (
       BP_GRAPHICS,
       BP_COMPUTE,
       BP_RAY_TRACING_KHR,
       BP_SUBPASS_SHADING_HUAWEI,
       BP_RAY_TRACING_NV
      );

       TvgDepthBufferFormat =
       (
         DB_D32_SFLOAT,
         DB_D32_SFLOAT_S8_UINT,
         DB_D24_UNORM_S8_UINT,
         DB_D16_UNORM,
         DB_D16_UNORM_S8_UINT
       );

       TvgDepthStencilBufferFormat =
       (
         DS_D32_SFLOAT_S8_UINT,
         DS_D24_UNORM_S8_UINT,
         DS_D16_UNORM_S8_UINT
       );

     TvgImageUsageFlagBits= Set Of
      (
       IU_TRANSFER_SRC_BIT,                                //< Can be used as a source of transfer operations
       IU_TRANSFER_DST_BIT,                                //< Can be used as a destination of transfer operations
       IU_SAMPLED_BIT,                                     //< Can be sampled from (SAMPLED_IMAGE and COMBINED_IMAGE_SAMPLER descriptor types)
       IU_STORAGE_BIT,                                     //< Can be used as storage image (STORAGE_IMAGE descriptor type)
       IU_COLOR_ATTACHMENT_BIT,                            //< Can be used as framebuffer color attachment
       IU_DEPTH_STENCIL_ATTACHMENT_BIT,                    //< Can be used as framebuffer depth/stencil attachment
       IU_TRANSIENT_ATTACHMENT_BIT,                        //< Image data not needed outside of rendering
       IU_INPUT_ATTACHMENT_BIT,                            //< Can be used as framebuffer input attachment
       IU_FRAGMENT_SHADING_RATE_ATTACHMENT_BIT_KHR,
       IU_FRAGMENT_DENSITY_MAP_BIT_EXT,
       IU_VIDEO_DECODE_DST_BIT_KHR,
       IU_VIDEO_DECODE_SRC_BIT_KHR,
       IU_VIDEO_DECODE_DPB_BIT_KHR,
       IU_VIDEO_ENCODE_DST_BIT_KHR,
       IU_VIDEO_ENCODE_SRC_BIT_KHR,
       IU_VIDEO_ENCODE_DPB_BIT_KHR,
       IU_RESERVED_16_BIT_QCOM,
       IU_RESERVED_17_BIT_QCOM,
       IU_INVOCATION_MASK_BIT_HUAWEI
     //  IU_RESERVED_19_BIT_EXT
      );

      TvgImageTiling =
      (
       TL_OPTIMAL,
       TL_LINEAR
     //  TL_DRM_FORMAT_MODIFIER_EXT
      );

      TvgMemoryPropertyFlagBits= Set Of
      (
       MP_DEVICE_LOCAL_BIT,                            //< If otherwise stated, then allocate memory on device
       MP_HOST_VISIBLE_BIT,                            //< Memory is mappable by host
       MP_HOST_COHERENT_BIT,                           //< Memory will have i/o coherency. If not set, application may need to use vkFlushMappedMemoryRanges and vkInvalidateMappedMemoryRanges to flush/invalidate host cache
       MP_HOST_CACHED_BIT,                             //< Memory will be cached by the host
       MP_LAZILY_ALLOCATED_BIT,                        //< Memory may be allocated by the driver when it is required
       MP_PROTECTED_BIT,
       MP_DEVICE_COHERENT_BIT_AMD,
       MP_DEVICE_UNCACHED_BIT_AMD,
       MP_RDMA_CAPABLE_BIT_NV
      );

      TvgImageMemoryType =
      (IM_OPTIMAL,
       IM_LINEAR
       );

     TvgBufferUsageFlagBits=  Set Of
      (
       BU_TRANSFER_SRC_BIT,                               //< Can be used as a source of transfer operations
       BU_TRANSFER_DST_BIT,                               //< Can be used as a destination of transfer operations
       BU_UNIFORM_TEXEL_BUFFER_BIT,                       //< Can be used as TBO
       BU_STORAGE_TEXEL_BUFFER_BIT,                       //< Can be used as IBO
       BU_UNIFORM_BUFFER_BIT,                             //< Can be used as UBO
       BU_STORAGE_BUFFER_BIT,                             //< Can be used as SSBO
       BU_INDEX_BUFFER_BIT,                               //< Can be used as source of fixed-function index fetch (index buffer)
       BU_VERTEX_BUFFER_BIT,                              //< Can be used as source of fixed-function vertex fetch (VBO)
       BU_INDIRECT_BUFFER_BIT,                            //< Can be the source of indirect parameters (e.g. indirect buffer, parameter buffer)
       BU_CONDITIONAL_RENDERING_BIT_EXT,
       BU_SHADER_BINDING_TABLE_BIT_KHR,
       BU_TRANSFORM_FEEDBACK_BUFFER_BIT_EXT,
       BU_TRANSFORM_FEEDBACK_COUNTER_BUFFER_BIT_EXT,
       BU_VIDEO_DECODE_SRC_BIT_KHR,
       BU_VIDEO_DECODE_DST_BIT_KHR,
       BU_VIDEO_ENCODE_DST_BIT_KHR,
       BU_VIDEO_ENCODE_SRC_BIT_KHR,
       BU_SHADER_DEVICE_ADDRESS_BIT,
       BU_RESERVED_18_BIT_QCOM,
       BU_ACCELERATION_STRUCTURE_BUILD_INPUT_READ_ONLY_BIT_KHR,
       BU_ACCELERATION_STRUCTURE_STORAGE_BIT_KHR,
       BU_RESERVED_21_BIT_AMD,
       BU_RESERVED_22_BIT_AMD,
       BU_RESERVED_23_BIT_NV,
       BU_RESERVED_24_BIT_NV,
       BU_RAY_TRACING_BIT_NV,
       BU_SHADER_DEVICE_ADDRESS_BIT_EXT,
       BU_SHADER_DEVICE_ADDRESS_BIT_KHR
      );

     TvgDescriptorEnumType=
      (
       DT_SAMPLER,
       DT_COMBINED_IMAGE_SAMPLER,
       DT_SAMPLED_IMAGE,
       DT_STORAGE_IMAGE,
       DT_UNIFORM_TEXEL_BUFFER,
       DT_STORAGE_TEXEL_BUFFER,
       DT_UNIFORM_BUFFER,
       DT_STORAGE_BUFFER,
       DT_UNIFORM_BUFFER_DYNAMIC,
       DT_STORAGE_BUFFER_DYNAMIC,
       DT_INPUT_ATTACHMENT,
       DT_INLINE_UNIFORM_BLOCK,
       DT_ACCELERATION_STRUCTURE_KHR,
       DT_ACCELERATION_STRUCTURE_NV,
       DT_MUTABLE_VALVE,
       DT_INLINE_UNIFORM_BLOCK_EXT
      );

     TvgShaderStageFlagBits=  set of
      (
       SS_VERTEX_BIT,
       SS_TESSELLATION_CONTROL_BIT,
       SS_TESSELLATION_EVALUATION_BIT,
       SS_GEOMETRY_BIT,
       SS_FRAGMENT_BIT,
//       SS_ALL_GRAPHICS, doesn't work in set
       SS_COMPUTE_BIT,
       SS_TASK_BIT_NV,
       SS_MESH_BIT_NV,
       SS_RAYGEN_BIT_KHR,
       SS_ANY_HIT_BIT_KHR,
       SS_CLOSEST_HIT_BIT_KHR,
       SS_MISS_BIT_KHR,
       SS_INTERSECTION_BIT_KHR,
       SS_CALLABLE_BIT_KHR,
       SS_SUBPASS_SHADING_BIT_HUAWEI,
 //      SS_ALL,               doesn't work in set
       SS_ANY_HIT_BIT_NV,
       SS_CALLABLE_BIT_NV,
       SS_CLOSEST_HIT_BIT_NV,
       SS_INTERSECTION_BIT_NV,
       SS_MISS_BIT_NV,
       SS_RAYGEN_BIT_NV
      );

     TvgDescriptorBindingFlagBits=  set of
      (
       DB_UPDATE_AFTER_BIND_BIT,
       DB_UPDATE_UNUSED_WHILE_PENDING_BIT,
       DB_PARTIALLY_BOUND_BIT,
       DB_VARIABLE_DESCRIPTOR_COUNT_BIT,
       DB_RESERVED_4_BIT_QCOM,
       DB_PARTIALLY_BOUND_BIT_EXT,
       DB_UPDATE_AFTER_BIND_BIT_EXT,
       DB_UPDATE_UNUSED_WHILE_PENDING_BIT_EXT,
       DB_VARIABLE_DESCRIPTOR_COUNT_BIT_EXT
      );

     TvgDescriptorSetLayoutCreateFlagBits= Set Of
      (
       DSL_PUSH_DESCRIPTOR_BIT_KHR,
       DSL_UPDATE_AFTER_BIND_POOL_BIT,
       DSL_HOST_ONLY_POOL_BIT_VALVE,
       DSL_RESERVED_3_BIT_AMD,
       DSL_RESERVED_4_BIT_AMD,
       DSL_UPDATE_AFTER_BIND_POOL_BIT_EXT
      );

     TvgPipelineCreateFlagBits= set of
      (
       PC_DISABLE_OPTIMIZATION_BIT,
       PC_ALLOW_DERIVATIVES_BIT,
       PC_DERIVATIVE_BIT,
       PC_VIEW_INDEX_FROM_DEVICE_INDEX_BIT,
       PC_DISPATCH_BASE_BIT,
       PC_DEFER_COMPILE_BIT_NV,
       PC_CAPTURE_STATISTICS_BIT_KHR,
       PC_CAPTURE_INTERNAL_REPRESENTATIONS_BIT_KHR,
       PC_FAIL_ON_PIPELINE_COMPILE_REQUIRED_BIT,
       PC_EARLY_RETURN_ON_FAILURE_BIT,
       PC_LINK_TIME_OPTIMIZATION_BIT_EXT,
       PC_LIBRARY_BIT_KHR,
       PC_RAY_TRACING_SKIP_TRIANGLES_BIT_KHR,
       PC_RAY_TRACING_SKIP_AABBS_BIT_KHR,
       PC_RAY_TRACING_NO_NULL_ANY_HIT_SHADERS_BIT_KHR,
       PC_RAY_TRACING_NO_NULL_CLOSEST_HIT_SHADERS_BIT_KHR,
       PC_RAY_TRACING_NO_NULL_MISS_SHADERS_BIT_KHR,
       PC_RAY_TRACING_NO_NULL_INTERSECTION_SHADERS_BIT_KHR,
       PC_INDIRECT_BINDABLE_BIT_NV,
       PC_RAY_TRACING_SHADER_GROUP_HANDLE_CAPTURE_REPLAY_BIT_KHR,
       PC_RAY_TRACING_ALLOW_MOTION_BIT_NV,
       PC_RENDERING_FRAGMENT_SHADING_RATE_ATTACHMENT_BIT_KHR,
       PC_RENDERING_FRAGMENT_DENSITY_MAP_ATTACHMENT_BIT_EXT,
       PC_RETAIN_LINK_TIME_OPTIMIZATION_INFO_BIT_EXT,
       PC_RESERVED_24_BIT_NV,
       PC_RESERVED_25_BIT_EXT,
       PC_RESERVED_26_BIT_EXT,
       PC_RESERVED_27_BIT_EXT
      // PC_DISPATCH_BASE=PC_DISPATCH_BASE_BIT,
      // PC_DISPATCH_BASE_KHR=PC_DISPATCH_BASE,
      // PC_EARLY_RETURN_ON_FAILURE_BIT_EXT=PC_EARLY_RETURN_ON_FAILURE_BIT,
     //  PC_FAIL_ON_PIPELINE_COMPILE_REQUIRED_BIT_EXT=PC_FAIL_ON_PIPELINE_COMPILE_REQUIRED_BIT,
     //  VK_PIPELINE_RASTERIZATION_STATE_CREATE_FRAGMENT_DENSITY_MAP_ATTACHMENT_BIT_EXT=PC_RENDERING_FRAGMENT_DENSITY_MAP_ATTACHMENT_BIT_EXT,
     //  VK_PIPELINE_RASTERIZATION_STATE_CREATE_FRAGMENT_SHADING_RATE_ATTACHMENT_BIT_KHR=PC_RENDERING_FRAGMENT_SHADING_RATE_ATTACHMENT_BIT_KHR,
     //  PC_VIEW_INDEX_FROM_DEVICE_INDEX_BIT_KHR=PC_VIEW_INDEX_FROM_DEVICE_INDEX_BIT
      );

     TvgStencilOpBit =
      (
       SO_KEEP,
       SO_ZERO,
       SO_REPLACE,
       SO_INCREMENT_AND_CLAMP,
       SO_DECREMENT_AND_CLAMP,
       SO_INVERT,
       SO_INCREMENT_AND_WRAP,
       SO_DECREMENT_AND_WRAP
      );

     TvgCompareOpBit=
      (
       CO_NEVER,
       CO_LESS,
       CO_EQUAL,
       CO_LESS_OR_EQUAL,
       CO_GREATER,
       CO_NOT_EQUAL,
       CO_GREATER_OR_EQUAL,
       CO_ALWAYS
      );

     TvgLogicOp=
      (
       LO_CLEAR,
       LO_AND,
       LO_AND_REVERSE,
       LO_COPY,
       LO_AND_INVERTED,
       LO_NO_OP,
       LO_XOR,
       LO_OR,
       LO_NOR,
       LO_EQUIVALENT,
       LO_INVERT,
       LO_OR_REVERSE,
       LO_COPY_INVERTED,
       LO_OR_INVERTED,
       LO_NAND,
       LO_SET
      );

  TvgNodeType = (NT_NONE,
                 NT_CUSTOM,
                 NT_POINTS,
                 NT_LINE_STRIP,
                 NT_TRIANGLE_LIST,
                 NT_TRIANGLE_STRIP,
                 NT_TRIANGLE_FAN);

  TvgResourceUse = Set of
                  (RU_GLOBAL,
                   RU_GRAPHICPIPE,
                   RU_MATERIAL,
                   RU_MODEL
                   );
    //SHOULD only use MAX of Four Descriptor Sets

 TvgTextureFileType = (FT_UNKNOWN,
                       FT_BITMAP,
                       FT_JPEG,
                       FT_PNG,
                       FT_QOI,
                       FT_TGA,
                       FT_HDR,
                       FT_DDS,
                       FT_KTX,
                       FT_KTX2
                       );

     TvgBorderColor=
      (
       BC_FLOAT_TRANSPARENT_BLACK,
       BC_INT_TRANSPARENT_BLACK,
       BC_FLOAT_OPAQUE_BLACK,
       BC_INT_OPAQUE_BLACK,
       BC_FLOAT_OPAQUE_WHITE,
       BC_INT_OPAQUE_WHITE,
       BC_FLOAT_CUSTOM_EXT,
       BC_INT_CUSTOM_EXT
      );


      TvgDataType =

      (
      DT_VEC1,
      DT_VEC2,
      DT_VEC3,
      DT_VEC4,
      DT_MAT1,
      DT_MAT2,
      DT_MAT3,
      DT_MAT4
      );


      TvgAttributeType =
      (
      AT_UNKNOWN,
      AT_POSITION,
      AT_COLOR,
      AT_TEXTURE,
      AT_NORMAL
      );


      TvgResourceType =
      (
      RT_UNKNOWN,
      RT_VIEWPROJECTMAT,
      RT_VIEWMAT,
      RT_PROJECTMAT,
      RT_MODELMAT,
      RT_GROUPTEX,
      RT_MATERIALTEX
      );


      TvgFilter =
      (
       FT_NEAREST,
       FT_LINEAR,
       FT_CUBIC_EXT,
       FT_CUBIC_IMG
       );


     TvgSamplerMipmapMode=
      (
       MM_NEAREST,                                         //< Choose nearest mip level
       MM_LINEAR                                           //< Linear filter between mip levels
      );

     TvgSamplerAddressMode=
      (
       SA_REPEAT=0,
       SA_MIRRORED_REPEAT,
       SA_CLAMP_TO_EDGE,
       SA_CLAMP_TO_BORDER,
       SA_MIRROR_CLAMP_TO_EDGE
      );

     TvgSamplerReductionMode=
      (
       SR_WEIGHTED_AVERAGE,
       SR_MIN,
       SR_MAX,
       SR_WEIGHTED_AVERAGE_RANGECLAMP_QCOM,
       SR_MAX_EXT,
       SR_MIN_EXT,
       SR_WEIGHTED_AVERAGE_EXT
      );

      TvgBufferState =
      (BS_INACTIVE,
       BS_INITIAL,
       BS_RECORDING,
       BS_EXECUTABLE,
       BS_PENDING,
       BS_INVALID);

      TvgCommandBufferUsageFlags= Set of
      (
       BU_ONE_TIME_SUBMIT_BIT,
       BU_RENDER_PASS_CONTINUE_BIT,
       BU_SIMULTANEOUS_USE_BIT                    //< Command buffer may be submitted/executed more than once simultaneously
      );

      TvgRenderPassMode =
      (
        RP_CUSTOM,
        RP_SCENE,               //used to render data to the screen
        RP_UI,                 //used to add User info Cursor/text to screen
        RP_OFFSCREENTOSCREEN   //used to copy OffScreen image to the Screen
      );

      Function GetVKCommandBufferUsageFlags(Value: TvgCommandBufferUsageFlags) : TVkCommandBufferUsageFlags;
      Function TestCommandBufferUsageFlagsValue(aVal , TestVal: TVkCommandBufferUsageFlags):Boolean;
      Function GetVGCommandBufferUsageFlags(Value: TVkCommandBufferUsageFlags) : TvgCommandBufferUsageFlags;

      Function GetVKSamplerReductionMode(Value: TvgSamplerReductionMode) : TVkSamplerReductionMode;
      Function GetVGSamplerReductionMode(Value: TVkSamplerReductionMode) : TvgSamplerReductionMode;

      Function GetVKSamplerMipmapMode(Value: TvgSamplerMipmapMode) : TvkSamplerMipmapMode;

      Function GetVGSamplerMipmapMode(Value: TvkSamplerMipmapMode) : TvgSamplerMipmapMode;

      Function GetVKSamplerAddressMode(Value: TvgSamplerAddressMode) : TVkSamplerAddressMode;

      Function GetVGSamplerAddressMode(Value: TVkSamplerAddressMode) : TvgSamplerAddressMode;


      Function GetVKFilter(Value: TvgFilter) : TVkFilter;

      Function GetVGFilkter(Value: TVkFilter) : TvgFilter;


      Function GetDataTypeAsString(aType: TvgDataType):String;

      Function GetVKBorderColor(Value: TvgBorderColor) : TVkBorderColor;
      Function GetVGBorderColor(Value: TVkBorderColor) : TvgBorderColor;

      Function GetVKLogicOp(Value: TvgLogicOp) : TVkLogicOp;
      Function GetVGLogicOp(Value: TVkLogicOp) : TvgLogicOp;

      Function GetVKStencilOp(Value: TvgStencilOpBit) : TVkStencilOp;
      Function GetVGStencilOp(Value: TVkStencilOp) : TvgStencilOpBit;

      Function GetVKCompareOp(Value: TvgCompareOpBit) : TVkCompareOp;
      Function GetVGCompareOp(Value: TVkCompareOp) : TvgCompareOpBit;

      Function GetVKPipelineCreateFlags(Value: TvgPipelineCreateFlagBits) : TVkPipelineCreateFlags;
      Function GetVGPipelineCreateFlags(Value: TVkPipelineCreateFlags) : TvgPipelineCreateFlagBits;

      Function GetVKDescriptorSetLayoutCreateFlags(Value: TvgDescriptorSetLayoutCreateFlagBits) : TVkDescriptorSetLayoutCreateFlags;
      Function GetVGDescriptorSetLayoutCreateFlags(Value: TVkDescriptorSetLayoutCreateFlags) : TvgDescriptorSetLayoutCreateFlagBits;

      Function GetVKDescriptorBindingFlags(Value: TvgDescriptorBindingFlagBits) : TVkDescriptorBindingFlags;
      Function GetVGDescriptorBindingeFlags(Value: TVkDescriptorBindingFlags)   : TvgDescriptorBindingFlagBits;

      Function GetVKStageFlags(Value: TvgShaderStageFlagBits) : TVkShaderStageFlags;
      Function GetVGStageFlags(Value: TVkShaderStageFlags) : TvgShaderStageFlagBits;

      Function GetVKDescriptorType(Value: TvgDescriptorEnumType) : TVkDescriptorType;
      Function GetVGDescriptorType(Value: TVkDescriptorType) : TvgDescriptorEnumType;

      Function GetVKDynamicState(Value: TvgDynamicStateBit) : TVkDynamicState;
      Function GetVGDynamicState(Value: TVkDynamicState) : TvgDynamicStateBit;

      Function GetVKBufferUsageFlags(Value: TvgBufferUsageFlagBits) : TVkBufferUsageFlags;
      Function GetVGBufferUsageFlags(Value: TVkBufferUsageFlags) : TvgBufferUsageFlagBits;

      Function GetVKImageMemoryType(Value: TvgImageMemoryType) : TpvVulkanDeviceMemoryAllocationType;
      Function GetVGImageMemoryType(Value: TpvVulkanDeviceMemoryAllocationType) : TvgImageMemoryType;

      Function GetVKMemoryPropertyFlagBits(Value: TvgMemoryPropertyFlagBits) : TVkMemoryPropertyFlags;
      Function GetVGMemoryPropertyFlagBits(Value: TVkMemoryPropertyFlags) : TvgMemoryPropertyFlagBits;

      Function GetVKImageTiling(Value: TvgImageTiling) : TVkImageTiling;
      Function GetVGImageTiling(Value: TVkImageTiling) : TvgImageTiling;

      Function GetVKImageType(Value: TvgImageType) : TVkImageType;
      Function GetVGImageType(Value: TVkImageType) : TvgImageType ;

      Function GetVKImageUsageFlagBits(Value: TvgImageUsageFlagBits) : TVkImageUsageFlags;
      Function GetVGImageUsageFlagBits(Value: TVkImageUsageFlags) : TvgImageUsageFlagBits ;

      Function GetVKDeptBufferFormat(Value: TvgDepthBufferFormat) : TVkFormat;
      Function GetVGDeptBufferFormat(Value: TVkFormat) : TvgDepthBufferFormat ;

      Function GetVKPipelineBindPoint(Value: TvgPipelineBindPoint) : TVkPipelineBindPoint;
      Function GetVGPipelineBindPoint(Value: TVkPipelineBindPoint) : TvgPipelineBindPoint ;

      Function GetVKDependencyFlagBits(Value: TvgDependencyFlagBits) : TVkDependencyFlags;
      Function GetVGDependencyFlagBits(Value: TVkDependencyFlags) : TvgDependencyFlagBits ;

      Function GetVKAccessFlagBits(Value: TvgAccessFlagBits) : TVkAccessFlags;
      Function GetVGAccessFlagBits(Value: TVkAccessFlags) : TvgAccessFlagBits ;

      Function GetVKPipelineStageFlagBits(Value: TvgPipelineStageFlagBits) : TVkPipelineStageFlags;
      Function GetVGPipelineStageFlagBits(Value: TVkPipelineStageFlags) : TvgPipelineStageFlagBits ;

      Function GetVKImageLayout(Value: TvgImageLayout) : TVkImageLayout;
      Function GetVGImageLayout(Value: TVkImageLayout) : TvgImageLayout ;

      Function GetVKLOadOp(Value: TvgAttachmentLoadOp) : TVkAttachmentLoadOp;
      Function GetVGLoadOp(Value: TVkAttachmentLoadOp) : TvgAttachmentLoadOp ;

      Function GetVKStoreOp(Value: TvgAttachmentStoreOp) : TVkAttachmentStoreOp;
      Function GetVGStoreOp(Value: TVkAttachmentStoreOp) : TvgAttachmentStoreOp ;

      Function GetVKColorComponent(Value: TvgColorComponentFlagBits) : TVkColorComponentFlags;
      Function GetVGColorComponent(Value: TVkColorComponentFlags) : TvgColorComponentFlagBits ;

      Function GetVKBlendOp(Value: TvgBlendOp) : TVkBlendOp;
      Function GetVGBlendOp(Value: TVkBlendOp) : TvgBlendOp ;

      Function GetVKBlendFactor(Value: TvgBlendFactor) : TVkBlendFactor;
      Function GetVGBlendFactor(Value: TVkBlendFactor) : TvgBlendFactor ;

      Function GetVKSampleCountFlagBit(Value: TvgSampleCountFlagBits) : TVkSampleCountFlagBits;
      Function GetVGSampleCountFlagBit(Value: TVkSampleCountFlagBits) : TvgSampleCountFlagBits ;

      Function GetVKFrontFace(Value: TvgFrontFace) : TVkFrontFace;
      Function GetVGFrontFace(Value: TVkFrontFace) : TvgFrontFace ;

      Function GetVKCullMode(Value: TvgCullMode)     : TVkCullModeFlags;
      Function GetVGCullMode(Value: TVkCullModeFlags): TvgCullMode ;

      Function GetVKPolygonMode(Value: TvgPolygonMode): TVkPolygonMode;
      Function GetVGPolygonMode(Value: TVkPolygonMode): TvgPolygonMode ;

      Function GetVKPrimitiveTopology(Value: TvgPrimitiveTopology): TVkPrimitiveTopology;
      Function GetVGPrimitiveTopology(Value: TVkPrimitiveTopology): TvgPrimitiveTopology ;

      Function GetVKVertexInputRate(Value: TvgVertexInputRate): TVkVertexInputRate;
      Function GetVGVertexInputRate(Value: TVkVertexInputRate): TvgVertexInputRate ;

      Function GetVKImageViewType(Value: TvgImageViewType): TVkImageViewType;
      Function GetVGImageViewType(Value: TVkImageViewType): TvgImageViewType ;

      Function GetVKImageAspectFlags(Value: TvgImageAspectFlagBits): TVkImageAspectFlags;
      Function GetVGImageAspectFlags(Value: TVkImageAspectFlags): TvgImageAspectFlagBits ;

      Function GetVKComponentSwizzle(Value: TvgComponentSwizzle): TVkComponentSwizzle;
      Function GetVGComponentSwizzle(Value: TVkComponentSwizzle):TvgComponentSwizzle ;

      Function GetVKCommandPoolCreateFlags(Value: TVgCommandPoolCreateFlag): TVkCommandPoolCreateFlags;
      Function GetVGCommandPoolCreateFlags(Value: TVkCommandPoolCreateFlags):TVgCommandPoolCreateFlag ;

      Function GetVKImageUseFlags(Value:TvgImageUsageFlagsSet):TVkImageUsageFlags;
      Function GetVGImageUseFlags(Value: TVkImageUsageFlags):TvgImageUsageFlagsSet ;

      Function GetVKSharingMode(Value:TvgSharingMode):TVKSharingMode;
      Function GetVGSharingMode(Value:TVKSharingMode):TvgSharingMode;

      Function GetVKPresentMode(Value:TvgPresentModeKHR):TVKPresentModeKHR;
      Function GetVGPresentMode(Value:TVKPresentModeKHR):TvgPresentModeKHR;

      Function GetVKColorSpace(Value:TvgColorSpaceKHR):TVKColorSpaceKHR;
      Function GetVGColorSpace(Value:TVKColorSpaceKHR):TvgColorSpaceKHR;

      Function GetVKFormat(Value:TvgFormat):TVkFormat;
      Function GetVGFormat(Value:TVkFormat):TVgFormat;

      Function GetVKTransform(Value:TVgSurfaceTransformFlagBitsKHRSet):TVkSurfaceTransformFlagsKHR;
      Function GetVGTransform(Value:TVkSurfaceTransformFlagsKHR):TVgSurfaceTransformFlagBitsKHRSet;

  procedure SplitPointer(const Value: Pointer; var LowPart, HighPart: LongWord);
  function JoinPointer(const LowPart, HighPart: LongWord): Pointer;

implementation


  Function GetVKCommandBufferUsageFlags(Value: TvgCommandBufferUsageFlags) : TVkCommandBufferUsageFlags;
  Begin
    Result := 0;
    If (BU_ONE_TIME_SUBMIT_BIT in Value)      then Result := Result OR TVkCommandBufferUsageFlags(VK_COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT) ;
    If (BU_RENDER_PASS_CONTINUE_BIT in Value) then Result := Result OR TVkCommandBufferUsageFlags(VK_COMMAND_BUFFER_USAGE_RENDER_PASS_CONTINUE_BIT) ;
    If (BU_SIMULTANEOUS_USE_BIT in Value)     then Result := Result OR TVkCommandBufferUsageFlags(VK_COMMAND_BUFFER_USAGE_SIMULTANEOUS_USE_BIT) ;

  End;

  Function TestCommandBufferUsageFlagsValue(aVal , TestVal: TVkCommandBufferUsageFlags):Boolean;
  Begin
    Result:= ((aVal and TestVal) = TestVal);
  End;

  Function GetVGCommandBufferUsageFlags(Value: TVkCommandBufferUsageFlags) : TvgCommandBufferUsageFlags;
        Function TestValue(TestVal: TVkCommandBufferUsageFlagBits):Boolean;
        Begin
          Result:= ((Value and TVkCommandBufferUsageFlags(TestVal)) = TVkCommandBufferUsageFlags(TestVal));
        End;
  Begin
    Result := [];
    If TestValue(VK_COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT)       then include(Result, BU_ONE_TIME_SUBMIT_BIT) ;
    If TestValue(VK_COMMAND_BUFFER_USAGE_RENDER_PASS_CONTINUE_BIT)  then include(Result, BU_RENDER_PASS_CONTINUE_BIT) ;
    If TestValue(VK_COMMAND_BUFFER_USAGE_SIMULTANEOUS_USE_BIT   )   then include(Result, BU_SIMULTANEOUS_USE_BIT) ;
  End;


  Function GetDataTypeAsString(aType: TvgDataType):String;
  Begin
    Case  aType of
      DT_VEC1 : Result := 'vec1';
      DT_VEC2 : Result := 'vec2';
      DT_VEC3 : Result := 'vec3';
      DT_VEC4 : Result := 'vec4';
      DT_MAT1 : Result := 'mat1';
      DT_MAT2 : Result := 'mat2';
      DT_MAT3 : Result := 'mat3';
      DT_MAT4 : Result := 'mat4';
     else
       Result := '';
    End;
  End;

  procedure SplitPointer(const Value: Pointer; var LowPart, HighPart: LongWord);
    Var I64:Int64;
        PtrSize : Integer;
  begin
    PtrSize:=SizeOf(Pointer);
    If PtrSize=32 then
    Begin
      LowPart  := Longword(Value) ;
      HighPart := 0;
    End else
    Begin
      I64 := Int64(Value);
      LowPart  := LongWord(I64);             // Get the lower 32 bits
      HighPart := LongWord(I64 shr 32);      // Get the upper 32 bits
    end;
  end;

  function JoinPointer(const LowPart, HighPart: LongWord): Pointer;
    Var I:Int64;
        PtrSize : Integer;
  begin
    PtrSize:=SizeOf(Pointer);
    If PtrSize=32 then
    Begin
      Result := Pointer(LowPart);
    end else
    Begin
      I := Int64(HighPart) shl 32 or LowPart;
      Result := Pointer(I);
    End;
  end;
(*
      Function GetVKBorderColor(Value: TvgBorderColor) : TVkBorderColor;
      Begin
        Case Value of
            BC_FLOAT_TRANSPARENT_BLACK  : Result :=  VK_BORDER_COLOR_FLOAT_TRANSPARENT_BLACK;
            BC_INT_TRANSPARENT_BLACK    : Result :=  VK_BORDER_COLOR_INT_TRANSPARENT_BLACK;
            BC_FLOAT_OPAQUE_BLACK       : Result :=  VK_BORDER_COLOR_FLOAT_OPAQUE_BLACK;
            BC_INT_OPAQUE_BLACK         : Result :=  VK_BORDER_COLOR_INT_OPAQUE_BLACK;
            BC_FLOAT_OPAQUE_WHITE       : Result :=  VK_BORDER_COLOR_FLOAT_OPAQUE_WHITE;
            BC_INT_OPAQUE_WHITE         : Result :=  VK_BORDER_COLOR_INT_OPAQUE_WHITE;
            BC_FLOAT_CUSTOM_EXT         : Result :=  VK_BORDER_COLOR_FLOAT_CUSTOM_EXT;
            BC_INT_CUSTOM_EXT           : Result :=  VK_BORDER_COLOR_INT_CUSTOM_EXT;
         else
            Result :=  VK_BORDER_COLOR_FLOAT_TRANSPARENT_BLACK;
        End;

      End;

      Function GetVGBorderColor(Value: TVkBorderColor) : TvgBorderColor;
      Begin
        Case Value of
          VK_BORDER_COLOR_FLOAT_TRANSPARENT_BLACK    : Result := BC_FLOAT_TRANSPARENT_BLACK ;
          VK_BORDER_COLOR_INT_TRANSPARENT_BLACK      : Result := BC_INT_TRANSPARENT_BLACK ;
          VK_BORDER_COLOR_FLOAT_OPAQUE_BLACK         : Result := BC_FLOAT_OPAQUE_BLACK ;
          VK_BORDER_COLOR_INT_OPAQUE_BLACK           : Result := BC_INT_OPAQUE_BLACK ;
          VK_BORDER_COLOR_FLOAT_OPAQUE_WHITE         : Result := BC_FLOAT_OPAQUE_WHITE ;
          VK_BORDER_COLOR_INT_OPAQUE_WHITE           : Result := BC_INT_OPAQUE_WHITE ;
          VK_BORDER_COLOR_FLOAT_CUSTOM_EXT           : Result := BC_FLOAT_CUSTOM_EXT ;
          VK_BORDER_COLOR_INT_CUSTOM_EXT             : Result := BC_INT_CUSTOM_EXT ;
         else
            Result :=  BC_FLOAT_TRANSPARENT_BLACK;
        End;
      End;
  *)
      Function GetVKSamplerReductionMode(Value: TvgSamplerReductionMode) : TVkSamplerReductionMode;
      Begin
        Case Value of
           SR_WEIGHTED_AVERAGE    : Result :=  VK_SAMPLER_REDUCTION_MODE_WEIGHTED_AVERAGE;
           SR_MIN                 : Result :=  VK_SAMPLER_REDUCTION_MODE_MIN;
           SR_MAX                 : Result :=  VK_SAMPLER_REDUCTION_MODE_MAX;
           SR_WEIGHTED_AVERAGE_RANGECLAMP_QCOM   : Result :=  VK_SAMPLER_REDUCTION_MODE_WEIGHTED_AVERAGE_RANGECLAMP_QCOM;
           SR_MAX_EXT             : Result :=  VK_SAMPLER_REDUCTION_MODE_MAX_EXT;
           SR_MIN_EXT             : Result :=  VK_SAMPLER_REDUCTION_MODE_MIN_EXT;
           SR_WEIGHTED_AVERAGE_EXT: Result :=  VK_SAMPLER_REDUCTION_MODE_WEIGHTED_AVERAGE;
         else
           Result := VK_SAMPLER_REDUCTION_MODE_WEIGHTED_AVERAGE;
        End;
      end;

      Function GetVGSamplerReductionMode(Value: TVkSamplerReductionMode) : TvgSamplerReductionMode;
      Begin
        Case Value of
         VK_SAMPLER_REDUCTION_MODE_WEIGHTED_AVERAGE      : Result :=  SR_WEIGHTED_AVERAGE;
         VK_SAMPLER_REDUCTION_MODE_MIN                   : Result :=  SR_MIN;
         VK_SAMPLER_REDUCTION_MODE_MAX                   : Result :=  SR_MAX;
         VK_SAMPLER_REDUCTION_MODE_WEIGHTED_AVERAGE_RANGECLAMP_QCOM     : Result :=  SR_WEIGHTED_AVERAGE_RANGECLAMP_QCOM;
      (*
         VK_SAMPLER_REDUCTION_MODE_MAX_EXT               : Result :=  SR_MAX_EXT;
         VK_SAMPLER_REDUCTION_MODE_MIN_EXT               : Result :=  SR_MIN_EXT;
         VK_SAMPLER_REDUCTION_MODE_WEIGHTED_AVERAGE  : Result :=  SR_WEIGHTED_AVERAGE_EXT;
      *)
         else
           Result := SR_WEIGHTED_AVERAGE;
        End;
      end;

      Function GetVKSamplerMipmapMode(Value: TvgSamplerMipmapMode) : TvkSamplerMipmapMode;
      Begin
        Case Value of
            MM_NEAREST  : Result :=  VK_SAMPLER_MIPMAP_MODE_NEAREST;
            MM_LINEAR   : Result :=  VK_SAMPLER_MIPMAP_MODE_LINEAR;
         else
           Result := VK_SAMPLER_MIPMAP_MODE_NEAREST;
        End;
      End;

      Function GetVGSamplerMipmapMode(Value: TvkSamplerMipmapMode) : TvgSamplerMipmapMode;
      Begin
        Case Value of
          VK_SAMPLER_MIPMAP_MODE_NEAREST    : Result :=  MM_NEAREST;
          VK_SAMPLER_MIPMAP_MODE_LINEAR     : Result :=  MM_LINEAR;
         else
           Result := MM_NEAREST;
        End;
      End;

      Function GetVKSamplerAddressMode(Value: TvgSamplerAddressMode) : TVkSamplerAddressMode;

      Begin
        Case Value of
           SA_REPEAT                     : Result :=  VK_SAMPLER_ADDRESS_MODE_REPEAT;
           SA_MIRRORED_REPEAT            : Result :=  VK_SAMPLER_ADDRESS_MODE_MIRRORED_REPEAT;
           SA_CLAMP_TO_EDGE              : Result :=  VK_SAMPLER_ADDRESS_MODE_CLAMP_TO_EDGE;
           SA_CLAMP_TO_BORDER            : Result :=  VK_SAMPLER_ADDRESS_MODE_CLAMP_TO_BORDER;
           SA_MIRROR_CLAMP_TO_EDGE       : Result :=  VK_SAMPLER_ADDRESS_MODE_MIRROR_CLAMP_TO_EDGE;
         else
           Result := VK_SAMPLER_ADDRESS_MODE_REPEAT;
        End;
      End;

      Function GetVGSamplerAddressMode(Value: TVkSamplerAddressMode) : TvgSamplerAddressMode;
      Begin
        Case Value of

            VK_SAMPLER_ADDRESS_MODE_REPEAT                    : Result := SA_REPEAT ;
            VK_SAMPLER_ADDRESS_MODE_MIRRORED_REPEAT           : Result := SA_MIRRORED_REPEAT ;
            VK_SAMPLER_ADDRESS_MODE_CLAMP_TO_EDGE             : Result := SA_CLAMP_TO_EDGE ;
            VK_SAMPLER_ADDRESS_MODE_CLAMP_TO_BORDER           : Result := SA_CLAMP_TO_BORDER ;
            VK_SAMPLER_ADDRESS_MODE_MIRROR_CLAMP_TO_EDGE      : Result := SA_MIRROR_CLAMP_TO_EDGE ;
           // VK_SAMPLER_ADDRESS_MODE_MIRROR_CLAMP_TO_EDGE_KHR  : Result := SA_MIRROR_CLAMP_TO_EDGE ;
         else
           Result := SA_REPEAT;
        End;
      End;


      Function GetVKFilter(Value: TvgFilter) : TVkFilter;
      Begin
        Case Value of
             FT_NEAREST  : Result := VK_FILTER_NEAREST ;
             FT_LINEAR   : Result := VK_FILTER_LINEAR ;
             FT_CUBIC_EXT: Result := VK_FILTER_CUBIC_EXT ;
             FT_CUBIC_IMG: Result := VK_FILTER_CUBIC_IMG ;
         else
           Result := VK_FILTER_NEAREST;
        End;
      End;

      Function GetVGFilkter(Value: TVkFilter) : TvgFilter;
      Begin
        Case Value of
          VK_FILTER_NEAREST     : Result :=  FT_NEAREST;
          VK_FILTER_LINEAR      : Result :=  FT_LINEAR;
          VK_FILTER_CUBIC_EXT   : Result :=  FT_CUBIC_EXT;
        //  VK_FILTER_CUBIC_IMG   : Result :=  FT_CUBIC_EXT;
         else
           Result := FT_NEAREST;
        End;
      End;


      Function GetVKBorderColor(Value: TvgBorderColor) : TVkBorderColor;
      Begin
        Case Value of
             BC_FLOAT_TRANSPARENT_BLACK : Result := VK_BORDER_COLOR_FLOAT_TRANSPARENT_BLACK;
             BC_INT_TRANSPARENT_BLACK   : Result := VK_BORDER_COLOR_INT_TRANSPARENT_BLACK;
             BC_FLOAT_OPAQUE_BLACK      : Result := VK_BORDER_COLOR_FLOAT_OPAQUE_BLACK;
             BC_INT_OPAQUE_BLACK        : Result := VK_BORDER_COLOR_INT_OPAQUE_BLACK;
             BC_FLOAT_OPAQUE_WHITE      : Result := VK_BORDER_COLOR_FLOAT_OPAQUE_WHITE;
             BC_INT_OPAQUE_WHITE        : Result := VK_BORDER_COLOR_INT_OPAQUE_WHITE;
             BC_FLOAT_CUSTOM_EXT        : Result := VK_BORDER_COLOR_FLOAT_CUSTOM_EXT;
             BC_INT_CUSTOM_EXT          : Result := VK_BORDER_COLOR_INT_CUSTOM_EXT;
        else
          Result := VK_BORDER_COLOR_FLOAT_TRANSPARENT_BLACK;
        end;
      End;

      Function GetVGBorderColor(Value: TVkBorderColor) : TvgBorderColor;
      Begin
        Case Value of
         VK_BORDER_COLOR_FLOAT_TRANSPARENT_BLACK     : Result := BC_FLOAT_TRANSPARENT_BLACK;
         VK_BORDER_COLOR_INT_TRANSPARENT_BLACK       : Result := BC_INT_TRANSPARENT_BLACK;
         VK_BORDER_COLOR_FLOAT_OPAQUE_BLACK          : Result := BC_FLOAT_OPAQUE_BLACK;
         VK_BORDER_COLOR_INT_OPAQUE_BLACK            : Result := BC_INT_OPAQUE_BLACK;
         VK_BORDER_COLOR_FLOAT_OPAQUE_WHITE          : Result := BC_FLOAT_OPAQUE_WHITE;
         VK_BORDER_COLOR_INT_OPAQUE_WHITE            : Result := BC_INT_OPAQUE_WHITE;
         VK_BORDER_COLOR_FLOAT_CUSTOM_EXT            : Result := BC_FLOAT_CUSTOM_EXT;
         VK_BORDER_COLOR_INT_CUSTOM_EXT              : Result := BC_INT_CUSTOM_EXT;
        else
          Result := BC_FLOAT_TRANSPARENT_BLACK;
        End;
      End;


      Function GetVKLogicOp(Value: TvgLogicOp) : TVkLogicOp;
      Begin
        Case Value of
             LO_CLEAR         : Result := VK_LOGIC_OP_CLEAR;
             LO_AND           : Result := VK_LOGIC_OP_AND;
             LO_AND_REVERSE   : Result := VK_LOGIC_OP_AND_REVERSE;
             LO_COPY          : Result := VK_LOGIC_OP_COPY;
             LO_AND_INVERTED  : Result := VK_LOGIC_OP_AND_INVERTED;
             LO_NO_OP         : Result := VK_LOGIC_OP_NO_OP;
             LO_XOR           : Result := VK_LOGIC_OP_XOR;
             LO_OR            : Result := VK_LOGIC_OP_OR;
             LO_NOR           : Result := VK_LOGIC_OP_NOR;
             LO_EQUIVALENT    : Result := VK_LOGIC_OP_EQUIVALENT;
             LO_INVERT        : Result := VK_LOGIC_OP_INVERT;
             LO_OR_REVERSE    : Result := VK_LOGIC_OP_OR_REVERSE;
             LO_COPY_INVERTED : Result := VK_LOGIC_OP_COPY_INVERTED;
             LO_OR_INVERTED   : Result := VK_LOGIC_OP_OR_INVERTED;
             LO_NAND          : Result := VK_LOGIC_OP_NAND;
             LO_SET           : Result := VK_LOGIC_OP_SET;
             else
               Result := VK_LOGIC_OP_CLEAR;
        End;
      End;
      Function GetVGLogicOp(Value: TVkLogicOp) : TvgLogicOp;
      Begin
        Case Value of
           VK_LOGIC_OP_CLEAR           : Result := LO_CLEAR;
           VK_LOGIC_OP_AND             : Result := LO_AND;
           VK_LOGIC_OP_AND_REVERSE     : Result := LO_AND_REVERSE;
           VK_LOGIC_OP_COPY            : Result := LO_COPY;
           VK_LOGIC_OP_AND_INVERTED    : Result := LO_AND_INVERTED;
           VK_LOGIC_OP_NO_OP           : Result := LO_NO_OP;
           VK_LOGIC_OP_XOR             : Result := LO_XOR;
           VK_LOGIC_OP_OR              : Result := LO_OR;
           VK_LOGIC_OP_NOR             : Result := LO_NOR;
           VK_LOGIC_OP_EQUIVALENT      : Result := LO_EQUIVALENT;
           VK_LOGIC_OP_INVERT          : Result := LO_INVERT;
           VK_LOGIC_OP_OR_REVERSE      : Result := LO_OR_REVERSE;
           VK_LOGIC_OP_COPY_INVERTED   : Result := LO_COPY_INVERTED;
           VK_LOGIC_OP_OR_INVERTED     : Result := LO_OR_INVERTED;
           VK_LOGIC_OP_NAND            : Result := LO_NAND;
           VK_LOGIC_OP_SET             : Result := LO_SET;
           else
             Result := LO_CLEAR;
        End;
      End;


      Function GetVKStencilOp(Value: TvgStencilOpBit) : TVkStencilOp;
      Begin
        Case Value of
           SO_KEEP                : Result := VK_STENCIL_OP_KEEP;
           SO_ZERO                : Result := VK_STENCIL_OP_ZERO;
           SO_REPLACE             : Result := VK_STENCIL_OP_REPLACE;
           SO_INCREMENT_AND_CLAMP : Result := VK_STENCIL_OP_INCREMENT_AND_CLAMP;
           SO_DECREMENT_AND_CLAMP : Result := VK_STENCIL_OP_DECREMENT_AND_CLAMP;
           SO_INVERT              : Result := VK_STENCIL_OP_INVERT;
           SO_INCREMENT_AND_WRAP  : Result := VK_STENCIL_OP_INCREMENT_AND_WRAP;
           SO_DECREMENT_AND_WRAP  : Result := VK_STENCIL_OP_DECREMENT_AND_WRAP;
        else
          Result := VK_STENCIL_OP_KEEP;
        End;
      end;

      Function GetVGStencilOp(Value: TVkStencilOp) : TvgStencilOpBit;
      Begin
        Case Value of
          VK_STENCIL_OP_KEEP                 : Result := SO_KEEP;
          VK_STENCIL_OP_ZERO                 : Result := SO_ZERO;
          VK_STENCIL_OP_REPLACE              : Result := SO_REPLACE;
          VK_STENCIL_OP_INCREMENT_AND_CLAMP  : Result := SO_INCREMENT_AND_CLAMP;
          VK_STENCIL_OP_DECREMENT_AND_CLAMP  : Result := SO_DECREMENT_AND_CLAMP;
          VK_STENCIL_OP_INVERT               : Result := SO_INVERT;
          VK_STENCIL_OP_INCREMENT_AND_WRAP   : Result := SO_INCREMENT_AND_WRAP;
          VK_STENCIL_OP_DECREMENT_AND_WRAP   : Result := SO_DECREMENT_AND_WRAP;
        else
          Result := SO_KEEP;
        End;
      end;

      Function GetVKCompareOp(Value: TvgCompareOpBit) : TVkCompareOp;
      Begin
        Case Value of
             CO_NEVER           : Result := VK_COMPARE_OP_NEVER;
             CO_LESS            : Result := VK_COMPARE_OP_LESS;
             CO_EQUAL           : Result := VK_COMPARE_OP_EQUAL;
             CO_LESS_OR_EQUAL   : Result := VK_COMPARE_OP_LESS_OR_EQUAL;
             CO_GREATER         : Result := VK_COMPARE_OP_GREATER;
             CO_NOT_EQUAL       : Result := VK_COMPARE_OP_NOT_EQUAL;
             CO_GREATER_OR_EQUAL: Result := VK_COMPARE_OP_GREATER_OR_EQUAL;
             CO_ALWAYS          : Result := VK_COMPARE_OP_ALWAYS;
        else
           Result := VK_COMPARE_OP_NEVER;
        End;
      end;
      Function GetVGCompareOp(Value: TVkCompareOp) : TvgCompareOpBit;
      Begin
        Case Value of
           VK_COMPARE_OP_NEVER             : Result := CO_NEVER;
           VK_COMPARE_OP_LESS              : Result := CO_LESS;
           VK_COMPARE_OP_EQUAL             : Result := CO_EQUAL;
           VK_COMPARE_OP_LESS_OR_EQUAL     : Result := CO_LESS_OR_EQUAL;
           VK_COMPARE_OP_GREATER           : Result := CO_GREATER;
           VK_COMPARE_OP_NOT_EQUAL         : Result := CO_NOT_EQUAL;
           VK_COMPARE_OP_GREATER_OR_EQUAL  : Result := CO_GREATER_OR_EQUAL;
           VK_COMPARE_OP_ALWAYS            : Result := CO_ALWAYS;
        else
           Result := CO_NEVER;
        End;
      end;


      Function GetVKPipelineCreateFlags(Value: TvgPipelineCreateFlagBits) : TVkPipelineCreateFlags;
      Begin
        Result := 0;
        If (PC_DISABLE_OPTIMIZATION_BIT in Value)                               then Result := Result OR TVkPipelineCreateFlags(VK_PIPELINE_CREATE_DISABLE_OPTIMIZATION_BIT) ;
        If (PC_ALLOW_DERIVATIVES_BIT in Value)                                  then Result := Result OR TVkPipelineCreateFlags(VK_PIPELINE_CREATE_ALLOW_DERIVATIVES_BIT) ;
        If (PC_DERIVATIVE_BIT in Value)                                         then Result := Result OR TVkPipelineCreateFlags(VK_PIPELINE_CREATE_DERIVATIVE_BIT) ;
        If (PC_VIEW_INDEX_FROM_DEVICE_INDEX_BIT in Value)                       then Result := Result OR TVkPipelineCreateFlags(VK_PIPELINE_CREATE_VIEW_INDEX_FROM_DEVICE_INDEX_BIT) ;
        If (PC_DISPATCH_BASE_BIT in Value)                                      then Result := Result OR TVkPipelineCreateFlags(VK_PIPELINE_CREATE_DISPATCH_BASE_BIT) ;
        If (PC_DEFER_COMPILE_BIT_NV in Value)                                   then Result := Result OR TVkPipelineCreateFlags(VK_PIPELINE_CREATE_DEFER_COMPILE_BIT_NV) ;
        If (PC_CAPTURE_STATISTICS_BIT_KHR in Value)                             then Result := Result OR TVkPipelineCreateFlags(VK_PIPELINE_CREATE_CAPTURE_STATISTICS_BIT_KHR) ;
        If (PC_CAPTURE_INTERNAL_REPRESENTATIONS_BIT_KHR in Value)               then Result := Result OR TVkPipelineCreateFlags(VK_PIPELINE_CREATE_CAPTURE_INTERNAL_REPRESENTATIONS_BIT_KHR) ;
        If (PC_FAIL_ON_PIPELINE_COMPILE_REQUIRED_BIT in Value)                  then Result := Result OR TVkPipelineCreateFlags(VK_PIPELINE_CREATE_FAIL_ON_PIPELINE_COMPILE_REQUIRED_BIT) ;
        If (PC_EARLY_RETURN_ON_FAILURE_BIT in Value)                            then Result := Result OR TVkPipelineCreateFlags(VK_PIPELINE_CREATE_EARLY_RETURN_ON_FAILURE_BIT) ;
        If (PC_LINK_TIME_OPTIMIZATION_BIT_EXT in Value)                         then Result := Result OR TVkPipelineCreateFlags(VK_PIPELINE_CREATE_LINK_TIME_OPTIMIZATION_BIT_EXT) ;
        If (PC_LIBRARY_BIT_KHR in Value)                                        then Result := Result OR TVkPipelineCreateFlags(VK_PIPELINE_CREATE_LIBRARY_BIT_KHR) ;
        If (PC_RAY_TRACING_SKIP_TRIANGLES_BIT_KHR in Value)                     then Result := Result OR TVkPipelineCreateFlags(VK_PIPELINE_CREATE_RAY_TRACING_SKIP_TRIANGLES_BIT_KHR) ;
        If (PC_RAY_TRACING_SKIP_AABBS_BIT_KHR in Value)                         then Result := Result OR TVkPipelineCreateFlags(VK_PIPELINE_CREATE_RAY_TRACING_SKIP_AABBS_BIT_KHR) ;
        If (PC_RAY_TRACING_NO_NULL_ANY_HIT_SHADERS_BIT_KHR in Value)            then Result := Result OR TVkPipelineCreateFlags(VK_PIPELINE_CREATE_RAY_TRACING_NO_NULL_ANY_HIT_SHADERS_BIT_KHR) ;
        If (PC_RAY_TRACING_NO_NULL_CLOSEST_HIT_SHADERS_BIT_KHR in Value)        then Result := Result OR TVkPipelineCreateFlags(VK_PIPELINE_CREATE_RAY_TRACING_NO_NULL_CLOSEST_HIT_SHADERS_BIT_KHR) ;
        If (PC_RAY_TRACING_NO_NULL_MISS_SHADERS_BIT_KHR in Value)               then Result := Result OR TVkPipelineCreateFlags(VK_PIPELINE_CREATE_RAY_TRACING_NO_NULL_MISS_SHADERS_BIT_KHR) ;
        If (PC_RAY_TRACING_NO_NULL_INTERSECTION_SHADERS_BIT_KHR in Value)       then Result := Result OR TVkPipelineCreateFlags(VK_PIPELINE_CREATE_RAY_TRACING_NO_NULL_INTERSECTION_SHADERS_BIT_KHR) ;
        If (PC_INDIRECT_BINDABLE_BIT_NV in Value)                               then Result := Result OR TVkPipelineCreateFlags(VK_PIPELINE_CREATE_INDIRECT_BINDABLE_BIT_NV) ;
        If (PC_RAY_TRACING_SHADER_GROUP_HANDLE_CAPTURE_REPLAY_BIT_KHR in Value) then Result := Result OR TVkPipelineCreateFlags(VK_PIPELINE_CREATE_RAY_TRACING_SHADER_GROUP_HANDLE_CAPTURE_REPLAY_BIT_KHR) ;
        If (PC_RAY_TRACING_ALLOW_MOTION_BIT_NV in Value)                        then Result := Result OR TVkPipelineCreateFlags(VK_PIPELINE_CREATE_RAY_TRACING_ALLOW_MOTION_BIT_NV) ;
        If (PC_RENDERING_FRAGMENT_SHADING_RATE_ATTACHMENT_BIT_KHR in Value)     then Result := Result OR TVkPipelineCreateFlags(VK_PIPELINE_CREATE_RENDERING_FRAGMENT_SHADING_RATE_ATTACHMENT_BIT_KHR) ;
        If (PC_RENDERING_FRAGMENT_DENSITY_MAP_ATTACHMENT_BIT_EXT in Value)      then Result := Result OR TVkPipelineCreateFlags(VK_PIPELINE_CREATE_RENDERING_FRAGMENT_DENSITY_MAP_ATTACHMENT_BIT_EXT) ;
        If (PC_RETAIN_LINK_TIME_OPTIMIZATION_INFO_BIT_EXT in Value)             then Result := Result OR TVkPipelineCreateFlags(VK_PIPELINE_CREATE_RETAIN_LINK_TIME_OPTIMIZATION_INFO_BIT_EXT) ;
     //   If (PC_RESERVED_24_BIT_NV in Value)                                     then Result := Result OR TVkPipelineCreateFlags(VK_PIPELINE_CREATE_RESERVED_24_BIT_NV) ;
     //   If (PC_RESERVED_25_BIT_EXT in Value)                                    then Result := Result OR TVkPipelineCreateFlags(VK_PIPELINE_CREATE_RESERVED_25_BIT_EXT) ;
     //   If (PC_RESERVED_26_BIT_EXT in Value)                                    then Result := Result OR TVkPipelineCreateFlags(VK_PIPELINE_CREATE_RESERVED_26_BIT_EXT) ;
     //   If (PC_RESERVED_27_BIT_EXT in Value)                                    then Result := Result OR TVkPipelineCreateFlags(VK_PIPELINE_CREATE_RESERVED_27_BIT_EXT) ;
      End;

      Function GetVGPipelineCreateFlags(Value: TVkPipelineCreateFlags) : TvgPipelineCreateFlagBits;
        Function TestValue(TestVal: TVkPipelineCreateFlagBits):Boolean;
        Begin
          Result:= ((Value and TVkPipelineCreateFlags(TestVal)) = TVkPipelineCreateFlags(TestVal));
        End;
      Begin
        Result := [];
        If TestValue(VK_PIPELINE_CREATE_DISABLE_OPTIMIZATION_BIT)                             then include(Result, PC_DISABLE_OPTIMIZATION_BIT) ;
        If TestValue(VK_PIPELINE_CREATE_ALLOW_DERIVATIVES_BIT)                                then include(Result, PC_ALLOW_DERIVATIVES_BIT) ;
        If TestValue(VK_PIPELINE_CREATE_DERIVATIVE_BIT)                                       then include(Result, PC_DERIVATIVE_BIT) ;
        If TestValue(VK_PIPELINE_CREATE_VIEW_INDEX_FROM_DEVICE_INDEX_BIT)                     then include(Result, PC_VIEW_INDEX_FROM_DEVICE_INDEX_BIT) ;
        If TestValue(VK_PIPELINE_CREATE_DISPATCH_BASE_BIT)                                    then include(Result, PC_DISPATCH_BASE_BIT) ;
        If TestValue(VK_PIPELINE_CREATE_DEFER_COMPILE_BIT_NV)                                 then include(Result, PC_DEFER_COMPILE_BIT_NV) ;
        If TestValue(VK_PIPELINE_CREATE_CAPTURE_STATISTICS_BIT_KHR)                           then include(Result, PC_CAPTURE_STATISTICS_BIT_KHR) ;
        If TestValue(VK_PIPELINE_CREATE_CAPTURE_INTERNAL_REPRESENTATIONS_BIT_KHR)             then include(Result, PC_CAPTURE_INTERNAL_REPRESENTATIONS_BIT_KHR) ;
        If TestValue(VK_PIPELINE_CREATE_FAIL_ON_PIPELINE_COMPILE_REQUIRED_BIT)                then include(Result, PC_FAIL_ON_PIPELINE_COMPILE_REQUIRED_BIT) ;
        If TestValue(VK_PIPELINE_CREATE_EARLY_RETURN_ON_FAILURE_BIT)                          then include(Result, PC_EARLY_RETURN_ON_FAILURE_BIT) ;
        If TestValue(VK_PIPELINE_CREATE_LINK_TIME_OPTIMIZATION_BIT_EXT)                       then include(Result, PC_LINK_TIME_OPTIMIZATION_BIT_EXT) ;
        If TestValue(VK_PIPELINE_CREATE_LIBRARY_BIT_KHR)                                      then include(Result, PC_LIBRARY_BIT_KHR) ;
        If TestValue(VK_PIPELINE_CREATE_RAY_TRACING_SKIP_TRIANGLES_BIT_KHR)                   then include(Result, PC_RAY_TRACING_SKIP_TRIANGLES_BIT_KHR) ;
        If TestValue(VK_PIPELINE_CREATE_RAY_TRACING_SKIP_AABBS_BIT_KHR)                       then include(Result, PC_RAY_TRACING_SKIP_AABBS_BIT_KHR) ;
        If TestValue(VK_PIPELINE_CREATE_RAY_TRACING_NO_NULL_ANY_HIT_SHADERS_BIT_KHR)          then include(Result, PC_RAY_TRACING_NO_NULL_ANY_HIT_SHADERS_BIT_KHR) ;
        If TestValue(VK_PIPELINE_CREATE_RAY_TRACING_NO_NULL_CLOSEST_HIT_SHADERS_BIT_KHR)        then include(Result, PC_RAY_TRACING_NO_NULL_CLOSEST_HIT_SHADERS_BIT_KHR) ;
        If TestValue(VK_PIPELINE_CREATE_RAY_TRACING_NO_NULL_MISS_SHADERS_BIT_KHR)             then include(Result, PC_RAY_TRACING_NO_NULL_MISS_SHADERS_BIT_KHR) ;
        If TestValue(VK_PIPELINE_CREATE_RAY_TRACING_NO_NULL_INTERSECTION_SHADERS_BIT_KHR)        then include(Result, PC_RAY_TRACING_NO_NULL_INTERSECTION_SHADERS_BIT_KHR) ;
        If TestValue(VK_PIPELINE_CREATE_INDIRECT_BINDABLE_BIT_NV)                             then include(Result, PC_INDIRECT_BINDABLE_BIT_NV) ;
        If TestValue(VK_PIPELINE_CREATE_RAY_TRACING_SHADER_GROUP_HANDLE_CAPTURE_REPLAY_BIT_KHR)then include(Result, PC_RAY_TRACING_SHADER_GROUP_HANDLE_CAPTURE_REPLAY_BIT_KHR) ;
        If TestValue(VK_PIPELINE_CREATE_RAY_TRACING_ALLOW_MOTION_BIT_NV)                      then include(Result, PC_RAY_TRACING_ALLOW_MOTION_BIT_NV) ;
        If TestValue(VK_PIPELINE_CREATE_RENDERING_FRAGMENT_SHADING_RATE_ATTACHMENT_BIT_KHR)   then include(Result, PC_RENDERING_FRAGMENT_SHADING_RATE_ATTACHMENT_BIT_KHR) ;
        If TestValue(VK_PIPELINE_CREATE_RENDERING_FRAGMENT_DENSITY_MAP_ATTACHMENT_BIT_EXT)    then include(Result, PC_RENDERING_FRAGMENT_DENSITY_MAP_ATTACHMENT_BIT_EXT) ;
        If TestValue(VK_PIPELINE_CREATE_RETAIN_LINK_TIME_OPTIMIZATION_INFO_BIT_EXT)           then include(Result, PC_RETAIN_LINK_TIME_OPTIMIZATION_INFO_BIT_EXT) ;
   //     If TestValue(VK_PIPELINE_CREATE_RESERVED_24_BIT_NV)                                   then include(Result, PC_RESERVED_24_BIT_NV) ;
   //     If TestValue(VK_PIPELINE_CREATE_RESERVED_25_BIT_EXT)                                  then include(Result, PC_RESERVED_25_BIT_EXT) ;
   //     If TestValue(VK_PIPELINE_CREATE_RESERVED_26_BIT_EXT)                                  then include(Result, PC_RESERVED_26_BIT_EXT) ;
   //     If TestValue(VK_PIPELINE_CREATE_RESERVED_27_BIT_EXT)                                  then include(Result, PC_RESERVED_27_BIT_EXT) ;

      End;


      Function GetVKDescriptorSetLayoutCreateFlags(Value: TvgDescriptorSetLayoutCreateFlagBits) : TVkDescriptorSetLayoutCreateFlags;
      Begin
        Result := 0;
        If (DSL_PUSH_DESCRIPTOR_BIT_KHR in Value)            then Result := Result OR TVkDescriptorSetLayoutCreateFlags(VK_DESCRIPTOR_SET_LAYOUT_CREATE_PUSH_DESCRIPTOR_BIT_KHR) ;
        If (DSL_UPDATE_AFTER_BIND_POOL_BIT in Value)         then Result := Result OR TVkDescriptorSetLayoutCreateFlags(VK_DESCRIPTOR_SET_LAYOUT_CREATE_UPDATE_AFTER_BIND_POOL_BIT) ;
        If (DSL_HOST_ONLY_POOL_BIT_VALVE in Value)           then Result := Result OR TVkDescriptorSetLayoutCreateFlags(VK_DESCRIPTOR_SET_LAYOUT_CREATE_HOST_ONLY_POOL_BIT_VALVE) ;
   //     If (DSL_RESERVED_3_BIT_AMD in Value)                 then Result := Result OR TVkDescriptorSetLayoutCreateFlags(VK_DESCRIPTOR_SET_LAYOUT_CREATE_RESERVED_3_BIT_AMD) ;
   //     If (DSL_RESERVED_4_BIT_AMD in Value)                 then Result := Result OR TVkDescriptorSetLayoutCreateFlags(VK_DESCRIPTOR_SET_LAYOUT_CREATE_RESERVED_4_BIT_AMD) ;
        If (DSL_UPDATE_AFTER_BIND_POOL_BIT_EXT in Value)     then Result := Result OR TVkDescriptorSetLayoutCreateFlags(VK_DESCRIPTOR_SET_LAYOUT_CREATE_UPDATE_AFTER_BIND_POOL_BIT_EXT) ;
      End;

      Function GetVGDescriptorSetLayoutCreateFlags(Value: TVkDescriptorSetLayoutCreateFlags) : TvgDescriptorSetLayoutCreateFlagBits;
        Function TestValue(TestVal: TVkDescriptorSetLayoutCreateFlagBits):Boolean;
        Begin
          Result:= ((Value and TVkDescriptorSetLayoutCreateFlags(TestVal)) = TVkDescriptorSetLayoutCreateFlags(TestVal));
        End;
      Begin
        Result := [];
        If TestValue(VK_DESCRIPTOR_SET_LAYOUT_CREATE_PUSH_DESCRIPTOR_BIT_KHR)        then include(Result, DSL_PUSH_DESCRIPTOR_BIT_KHR) ;
        If TestValue(VK_DESCRIPTOR_SET_LAYOUT_CREATE_UPDATE_AFTER_BIND_POOL_BIT)     then include(Result, DSL_UPDATE_AFTER_BIND_POOL_BIT) ;
        If TestValue(VK_DESCRIPTOR_SET_LAYOUT_CREATE_HOST_ONLY_POOL_BIT_VALVE)       then include(Result, DSL_HOST_ONLY_POOL_BIT_VALVE) ;
        If TestValue(VK_DESCRIPTOR_SET_LAYOUT_CREATE_RESERVED_3_BIT_AMD)             then include(Result, DSL_RESERVED_3_BIT_AMD) ;
      //  If TestValue(VK_DESCRIPTOR_SET_LAYOUT_CREATE_RESERVED_4_BIT_AMD)             then include(Result, DSL_RESERVED_4_BIT_AMD) ;
        If TestValue(VK_DESCRIPTOR_SET_LAYOUT_CREATE_UPDATE_AFTER_BIND_POOL_BIT_EXT) then include(Result, DSL_UPDATE_AFTER_BIND_POOL_BIT_EXT) ;
      End;

      Function GetVKDescriptorBindingFlags(Value: TvgDescriptorBindingFlagBits) : TVkDescriptorBindingFlags;
      Begin
        Result := 0;
        If (DB_UPDATE_AFTER_BIND_BIT in Value)                then Result := Result OR TVkDescriptorBindingFlags(VK_DESCRIPTOR_BINDING_UPDATE_AFTER_BIND_BIT) ;
        If (DB_UPDATE_UNUSED_WHILE_PENDING_BIT in Value)      then Result := Result OR TVkDescriptorBindingFlags(VK_DESCRIPTOR_BINDING_UPDATE_UNUSED_WHILE_PENDING_BIT) ;
        If (DB_PARTIALLY_BOUND_BIT in Value)                  then Result := Result OR TVkDescriptorBindingFlags(VK_DESCRIPTOR_BINDING_PARTIALLY_BOUND_BIT) ;
        If (DB_VARIABLE_DESCRIPTOR_COUNT_BIT in Value)        then Result := Result OR TVkDescriptorBindingFlags(VK_DESCRIPTOR_BINDING_VARIABLE_DESCRIPTOR_COUNT_BIT) ;
        If (DB_RESERVED_4_BIT_QCOM in Value)                  then Result := Result OR TVkDescriptorBindingFlags(VK_DESCRIPTOR_BINDING_RESERVED_4_BIT_QCOM) ;
        If (DB_PARTIALLY_BOUND_BIT_EXT in Value)              then Result := Result OR TVkDescriptorBindingFlags(VK_DESCRIPTOR_BINDING_PARTIALLY_BOUND_BIT_EXT) ;
        If (DB_UPDATE_AFTER_BIND_BIT_EXT in Value)            then Result := Result OR TVkDescriptorBindingFlags(VK_DESCRIPTOR_BINDING_UPDATE_AFTER_BIND_BIT_EXT) ;
        If (DB_UPDATE_UNUSED_WHILE_PENDING_BIT_EXT in Value)  then Result := Result OR TVkDescriptorBindingFlags(VK_DESCRIPTOR_BINDING_UPDATE_UNUSED_WHILE_PENDING_BIT_EXT) ;
        If (DB_VARIABLE_DESCRIPTOR_COUNT_BIT_EXT in Value)    then Result := Result OR TVkDescriptorBindingFlags(VK_DESCRIPTOR_BINDING_VARIABLE_DESCRIPTOR_COUNT_BIT_EXT) ;
      End;

      Function GetVGDescriptorBindingeFlags(Value: TVkDescriptorBindingFlags) : TvgDescriptorBindingFlagBits;
        Function TestValue(TestVal: TVkDescriptorBindingFlagBits):Boolean;
        Begin
          Result:= ((Value and TVkDescriptorBindingFlags(TestVal)) = TVkDescriptorBindingFlags(TestVal));
        End;
      Begin
        Result := [];
        If TestValue(VK_DESCRIPTOR_BINDING_UPDATE_AFTER_BIND_BIT)                 then include(Result, DB_UPDATE_AFTER_BIND_BIT) ;
        If TestValue(VK_DESCRIPTOR_BINDING_UPDATE_UNUSED_WHILE_PENDING_BIT)       then include(Result, DB_UPDATE_UNUSED_WHILE_PENDING_BIT) ;
        If TestValue(VK_DESCRIPTOR_BINDING_PARTIALLY_BOUND_BIT)                   then include(Result, DB_PARTIALLY_BOUND_BIT) ;
        If TestValue(VK_DESCRIPTOR_BINDING_VARIABLE_DESCRIPTOR_COUNT_BIT)         then include(Result, DB_VARIABLE_DESCRIPTOR_COUNT_BIT) ;
        If TestValue(VK_DESCRIPTOR_BINDING_RESERVED_4_BIT_QCOM)                   then include(Result, DB_RESERVED_4_BIT_QCOM) ;
        If TestValue(VK_DESCRIPTOR_BINDING_PARTIALLY_BOUND_BIT_EXT)               then include(Result, DB_PARTIALLY_BOUND_BIT_EXT) ;
        If TestValue(VK_DESCRIPTOR_BINDING_UPDATE_AFTER_BIND_BIT_EXT)             then include(Result, DB_UPDATE_AFTER_BIND_BIT_EXT) ;
        If TestValue(VK_DESCRIPTOR_BINDING_UPDATE_UNUSED_WHILE_PENDING_BIT_EXT)   then include(Result, DB_UPDATE_UNUSED_WHILE_PENDING_BIT_EXT) ;
        If TestValue(VK_DESCRIPTOR_BINDING_VARIABLE_DESCRIPTOR_COUNT_BIT_EXT)     then include(Result, DB_VARIABLE_DESCRIPTOR_COUNT_BIT_EXT) ;
      End;

      Function GetVKStageFlags(Value: TvgShaderStageFlagBits) : TVkShaderStageFlags;
      Begin
        Result := 0;

        If (SS_VERTEX_BIT in Value)                 then Result := Result OR TVkShaderStageFlags(VK_SHADER_STAGE_VERTEX_BIT) ;
        If (SS_TESSELLATION_CONTROL_BIT in Value)   then Result := Result OR TVkShaderStageFlags(VK_SHADER_STAGE_TESSELLATION_CONTROL_BIT) ;
        If (SS_TESSELLATION_EVALUATION_BIT in Value)then Result := Result OR TVkShaderStageFlags(VK_SHADER_STAGE_TESSELLATION_EVALUATION_BIT) ;
        If (SS_GEOMETRY_BIT in Value)               then Result := Result OR TVkShaderStageFlags(VK_SHADER_STAGE_GEOMETRY_BIT) ;
        If (SS_FRAGMENT_BIT in Value)               then Result := Result OR TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT) ;
      //  If (SS_ALL_GRAPHICS in Value)               then Result := Result OR TVkShaderStageFlags(VK_SHADER_STAGE_ALL_GRAPHICS) ;
        If (SS_COMPUTE_BIT in Value)                then Result := Result OR TVkShaderStageFlags(VK_SHADER_STAGE_COMPUTE_BIT) ;
        If (SS_TASK_BIT_NV in Value)                then Result := Result OR TVkShaderStageFlags(VK_SHADER_STAGE_TASK_BIT_NV) ;
        If (SS_MESH_BIT_NV in Value)                then Result := Result OR TVkShaderStageFlags(VK_SHADER_STAGE_MESH_BIT_NV) ;
        If (SS_RAYGEN_BIT_KHR in Value)             then Result := Result OR TVkShaderStageFlags(VK_SHADER_STAGE_RAYGEN_BIT_KHR) ;
        If (SS_ANY_HIT_BIT_KHR in Value)            then Result := Result OR TVkShaderStageFlags(VK_SHADER_STAGE_ANY_HIT_BIT_KHR) ;
        If (SS_CLOSEST_HIT_BIT_KHR in Value)        then Result := Result OR TVkShaderStageFlags(VK_SHADER_STAGE_CLOSEST_HIT_BIT_KHR) ;
        If (SS_MISS_BIT_KHR in Value)               then Result := Result OR TVkShaderStageFlags(VK_SHADER_STAGE_MISS_BIT_KHR) ;
        If (SS_INTERSECTION_BIT_KHR in Value)       then Result := Result OR TVkShaderStageFlags(VK_SHADER_STAGE_INTERSECTION_BIT_KHR) ;
        If (SS_CALLABLE_BIT_KHR in Value)           then Result := Result OR TVkShaderStageFlags(VK_SHADER_STAGE_CALLABLE_BIT_KHR) ;
        If (SS_SUBPASS_SHADING_BIT_HUAWEI in Value) then Result := Result OR TVkShaderStageFlags(VK_SHADER_STAGE_SUBPASS_SHADING_BIT_HUAWEI) ;
      //  If (SS_ALL in Value)                        then Result := Result OR TVkShaderStageFlags(VK_SHADER_STAGE_ALL) ;
        If (SS_ANY_HIT_BIT_NV in Value)             then Result := Result OR TVkShaderStageFlags(VK_SHADER_STAGE_ANY_HIT_BIT_NV) ;
        If (SS_CALLABLE_BIT_NV in Value)            then Result := Result OR TVkShaderStageFlags(VK_SHADER_STAGE_CALLABLE_BIT_NV) ;
        If (SS_CLOSEST_HIT_BIT_NV in Value)         then Result := Result OR TVkShaderStageFlags(VK_SHADER_STAGE_CLOSEST_HIT_BIT_NV) ;
        If (SS_INTERSECTION_BIT_NV in Value)        then Result := Result OR TVkShaderStageFlags(VK_SHADER_STAGE_INTERSECTION_BIT_NV) ;
        If (SS_MISS_BIT_NV in Value)                then Result := Result OR TVkShaderStageFlags(VK_SHADER_STAGE_MISS_BIT_NV) ;
        If (SS_RAYGEN_BIT_NV in Value)              then Result := Result OR TVkShaderStageFlags(VK_SHADER_STAGE_RAYGEN_BIT_NV) ;
      End;

      Function GetVGStageFlags(Value: TVkShaderStageFlags) : TvgShaderStageFlagBits;
        Function TestValue(TestVal: TVKShaderStageFlagBits):Boolean;
        Begin
          Result:= ((Value and TVkShaderStageFlags(TestVal)) = TVkShaderStageFlags(TestVal));
        End;
      Begin
        Result := [];

        If TestValue(VK_SHADER_STAGE_VERTEX_BIT)            then include(Result, SS_VERTEX_BIT) ;
        If TestValue(VK_SHADER_STAGE_TESSELLATION_CONTROL_BIT)     then include(Result, SS_TESSELLATION_CONTROL_BIT) ;
        If TestValue(VK_SHADER_STAGE_TESSELLATION_EVALUATION_BIT)  then include(Result, SS_TESSELLATION_EVALUATION_BIT) ;
        If TestValue(VK_SHADER_STAGE_GEOMETRY_BIT)          then include(Result, SS_GEOMETRY_BIT) ;
        If TestValue(VK_SHADER_STAGE_FRAGMENT_BIT)          then include(Result, SS_FRAGMENT_BIT) ;
        (*
        If TestValue(VK_SHADER_STAGE_ALL_GRAPHICS)          then
        Begin
          include(Result, SS_VERTEX_BIT) ;
          include(Result, SS_TESSELLATION_CONTROL_BIT) ;
          include(Result, SS_TESSELLATION_EVALUATION_BIT) ;
          include(Result, SS_GEOMETRY_BIT) ;
          include(Result, SS_FRAGMENT_BIT) ;
        end ;
        *)
        If TestValue(VK_SHADER_STAGE_COMPUTE_BIT)           then include(Result, SS_COMPUTE_BIT) ;
        If TestValue(VK_SHADER_STAGE_TASK_BIT_NV)           then include(Result, SS_TASK_BIT_NV) ;
        If TestValue(VK_SHADER_STAGE_MESH_BIT_NV)           then include(Result, SS_MESH_BIT_NV) ;
        If TestValue(VK_SHADER_STAGE_RAYGEN_BIT_KHR)        then include(Result, SS_RAYGEN_BIT_KHR) ;
        If TestValue(VK_SHADER_STAGE_ANY_HIT_BIT_KHR)       then include(Result, SS_ANY_HIT_BIT_KHR) ;
        If TestValue(VK_SHADER_STAGE_CLOSEST_HIT_BIT_KHR)   then include(Result, SS_CLOSEST_HIT_BIT_KHR) ;
        If TestValue(VK_SHADER_STAGE_MISS_BIT_KHR)          then include(Result, SS_MISS_BIT_KHR) ;
        If TestValue(VK_SHADER_STAGE_INTERSECTION_BIT_KHR)  then include(Result, SS_INTERSECTION_BIT_KHR) ;
        If TestValue(VK_SHADER_STAGE_CALLABLE_BIT_KHR)      then include(Result, SS_CALLABLE_BIT_KHR) ;
        If TestValue(VK_SHADER_STAGE_SUBPASS_SHADING_BIT_HUAWEI)  then include(Result, SS_SUBPASS_SHADING_BIT_HUAWEI) ;
        (*
        If TestValue(VK_SHADER_STAGE_ALL)                   then
        Begin
          include(Result, SS_VERTEX_BIT) ;
          include(Result, SS_TESSELLATION_CONTROL_BIT) ;
          include(Result, SS_TESSELLATION_EVALUATION_BIT) ;
          include(Result, SS_GEOMETRY_BIT) ;
          include(Result, SS_FRAGMENT_BIT) ;
          include(Result, SS_COMPUTE_BIT) ;
          include(Result, SS_TASK_BIT_NV) ;
          include(Result, SS_MESH_BIT_NV) ;
          include(Result, SS_RAYGEN_BIT_KHR) ;
          include(Result, SS_ANY_HIT_BIT_KHR) ;
          include(Result, SS_CLOSEST_HIT_BIT_KHR) ;
          include(Result, SS_MISS_BIT_KHR) ;
          include(Result, SS_INTERSECTION_BIT_KHR) ;
          include(Result, SS_INTERSECTION_BIT_KHR) ;
          include(Result, SS_CALLABLE_BIT_KHR) ;
          include(Result, SS_SUBPASS_SHADING_BIT_HUAWEI) ;
          include(Result, SS_ANY_HIT_BIT_NV) ;
          include(Result, SS_CALLABLE_BIT_NV) ;
          include(Result, SS_CLOSEST_HIT_BIT_NV) ;
          include(Result, SS_INTERSECTION_BIT_NV) ;
          include(Result, SS_INTERSECTION_BIT_NV) ;
          include(Result, SS_MISS_BIT_NV) ;
          include(Result, SS_RAYGEN_BIT_NV) ;
        end;
        *)
        If TestValue(VK_SHADER_STAGE_ANY_HIT_BIT_NV)        then include(Result, SS_ANY_HIT_BIT_NV) ;
        If TestValue(VK_SHADER_STAGE_CALLABLE_BIT_NV)       then include(Result, SS_CALLABLE_BIT_NV) ;
        If TestValue(VK_SHADER_STAGE_CLOSEST_HIT_BIT_NV)    then include(Result, SS_CLOSEST_HIT_BIT_NV) ;
        If TestValue(VK_SHADER_STAGE_INTERSECTION_BIT_NV)   then include(Result, SS_INTERSECTION_BIT_NV) ;
        If TestValue(VK_SHADER_STAGE_MISS_BIT_NV)           then include(Result, SS_MISS_BIT_NV) ;
        If TestValue(VK_SHADER_STAGE_RAYGEN_BIT_NV)         then include(Result, SS_RAYGEN_BIT_NV) ;

      End;

      Function GetVKDescriptorType(Value: TvgDescriptorEnumType) : TVkDescriptorType;
      Begin
        Case Value of
           DT_SAMPLER                  : Result := VK_DESCRIPTOR_TYPE_SAMPLER;
           DT_COMBINED_IMAGE_SAMPLER   : Result := VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER;
           DT_SAMPLED_IMAGE            : Result := VK_DESCRIPTOR_TYPE_SAMPLED_IMAGE ;
           DT_STORAGE_IMAGE            : Result := VK_DESCRIPTOR_TYPE_STORAGE_IMAGE;
           DT_UNIFORM_TEXEL_BUFFER     : Result := VK_DESCRIPTOR_TYPE_UNIFORM_TEXEL_BUFFER;
           DT_STORAGE_TEXEL_BUFFER     : Result := VK_DESCRIPTOR_TYPE_STORAGE_TEXEL_BUFFER;
           DT_UNIFORM_BUFFER           : Result := VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER;
           DT_STORAGE_BUFFER           : Result := VK_DESCRIPTOR_TYPE_STORAGE_BUFFER;
           DT_UNIFORM_BUFFER_DYNAMIC   : Result := VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER_DYNAMIC;
           DT_STORAGE_BUFFER_DYNAMIC   : Result := VK_DESCRIPTOR_TYPE_STORAGE_BUFFER_DYNAMIC;
           DT_INPUT_ATTACHMENT         : Result := VK_DESCRIPTOR_TYPE_INPUT_ATTACHMENT;
           DT_INLINE_UNIFORM_BLOCK     : Result := VK_DESCRIPTOR_TYPE_INLINE_UNIFORM_BLOCK;
           DT_ACCELERATION_STRUCTURE_KHR : Result := VK_DESCRIPTOR_TYPE_ACCELERATION_STRUCTURE_KHR;
           DT_ACCELERATION_STRUCTURE_NV  : Result := VK_DESCRIPTOR_TYPE_ACCELERATION_STRUCTURE_NV;
           DT_MUTABLE_VALVE            : Result := VK_DESCRIPTOR_TYPE_MUTABLE_VALVE;
           DT_INLINE_UNIFORM_BLOCK_EXT : Result := VK_DESCRIPTOR_TYPE_INLINE_UNIFORM_BLOCK_EXT;
           else
             Result:=  VK_DESCRIPTOR_TYPE_SAMPLER;
        End;
      End;

      Function GetVGDescriptorType(Value: TVkDescriptorType) : TvgDescriptorEnumType;
      Begin
        Case Value of
          VK_DESCRIPTOR_TYPE_SAMPLER                   : Result := DT_SAMPLER;
          VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER    : Result := DT_COMBINED_IMAGE_SAMPLER;
          VK_DESCRIPTOR_TYPE_SAMPLED_IMAGE             : Result := DT_SAMPLED_IMAGE;
          VK_DESCRIPTOR_TYPE_STORAGE_IMAGE             : Result := DT_STORAGE_IMAGE;
          VK_DESCRIPTOR_TYPE_UNIFORM_TEXEL_BUFFER      : Result := DT_UNIFORM_TEXEL_BUFFER;
          VK_DESCRIPTOR_TYPE_STORAGE_TEXEL_BUFFER      : Result := DT_STORAGE_TEXEL_BUFFER;
          VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER            : Result := DT_UNIFORM_BUFFER;
          VK_DESCRIPTOR_TYPE_STORAGE_BUFFER            : Result := DT_STORAGE_BUFFER;
          VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER_DYNAMIC    : Result := DT_UNIFORM_BUFFER_DYNAMIC;
          VK_DESCRIPTOR_TYPE_STORAGE_BUFFER_DYNAMIC    : Result := DT_STORAGE_BUFFER_DYNAMIC;
          VK_DESCRIPTOR_TYPE_INPUT_ATTACHMENT          : Result := DT_INPUT_ATTACHMENT;
          VK_DESCRIPTOR_TYPE_INLINE_UNIFORM_BLOCK      : Result := DT_INLINE_UNIFORM_BLOCK;
          VK_DESCRIPTOR_TYPE_ACCELERATION_STRUCTURE_KHR  : Result := DT_ACCELERATION_STRUCTURE_KHR;
          VK_DESCRIPTOR_TYPE_ACCELERATION_STRUCTURE_NV   : Result := DT_ACCELERATION_STRUCTURE_NV;
          VK_DESCRIPTOR_TYPE_MUTABLE_VALVE             : Result := DT_MUTABLE_VALVE;
         // VK_DESCRIPTOR_TYPE_INLINE_UNIFORM_BLOCK_EXT  : Result := DT_INLINE_UNIFORM_BLOCK_EXT;
          else
            Result:= DT_SAMPLER;
        End;
      End;


      Function GetVKDynamicState(Value: TvgDynamicStateBit) : TVkDynamicState;
      Begin
        Case Value of
           DS_VIEWPORT              : Result := VK_DYNAMIC_STATE_VIEWPORT;
           DS_SCISSOR               : Result := VK_DYNAMIC_STATE_SCISSOR;
           DS_LINE_WIDTH            : Result := VK_DYNAMIC_STATE_LINE_WIDTH;
           DS_DEPTH_BIAS            : Result := VK_DYNAMIC_STATE_DEPTH_BIAS;
           DS_BLEND_CONSTANTS       : Result := VK_DYNAMIC_STATE_BLEND_CONSTANTS;
           DS_DEPTH_BOUNDS          : Result := VK_DYNAMIC_STATE_DEPTH_BOUNDS;
           DS_STENCIL_COMPARE_MASK  : Result := VK_DYNAMIC_STATE_STENCIL_COMPARE_MASK;
           DS_STENCIL_WRITE_MASK    : Result := VK_DYNAMIC_STATE_STENCIL_WRITE_MASK;
           DS_STENCIL_REFERENCE     : Result := VK_DYNAMIC_STATE_STENCIL_REFERENCE;
        //   DS_VIEWPORT_W_SCALING    : Result := VK_DYNAMIC_STATE_VIEWPORT_W_SCALING_NV;
        //   DS_DISCARD_RECTANGLE     : Result := VK_DYNAMIC_STATE_DISCARD_RECTANGLE_EXT;
        //   DS_SAMPLE_LOCATIONS      : Result := VK_DYNAMIC_STATE_SAMPLE_LOCATIONS_EXT;
        //   DS_VIEWPORT_SHADING_RATE_PALETTE : Result := VK_DYNAMIC_STATE_VIEWPORT_SHADING_RATE_PALETTE_NV;
        //   DS_VIEWPORT_COARSE_SAMPLE_ORDER  : Result := VK_DYNAMIC_STATE_VIEWPORT_COARSE_SAMPLE_ORDER_NV;
        //   DS_EXCLUSIVE_SCISSOR             : Result := VK_DYNAMIC_STATE_EXCLUSIVE_SCISSOR_NV;
        //   DS_FRAGMENT_SHADING_RATE         : Result := VK_DYNAMIC_STATE_FRAGMENT_SHADING_RATE_KHR;
        //   DS_LINE_STIPPLE                  : Result    := VK_DYNAMIC_STATE_LINE_STIPPLE_EXT;
           DS_CULL_MODE                     : Result    := VK_DYNAMIC_STATE_CULL_MODE;
           DS_FRONT_FACE                    : Result    := VK_DYNAMIC_STATE_FRONT_FACE;
           DS_PRIMITIVE_TOPOLOGY        : Result    := VK_DYNAMIC_STATE_PRIMITIVE_TOPOLOGY;
           DS_VIEWPORT_WITH_COUNT       : Result := VK_DYNAMIC_STATE_VIEWPORT_WITH_COUNT;
           DS_SCISSOR_WITH_COUNT        : Result := VK_DYNAMIC_STATE_SCISSOR_WITH_COUNT;
           DS_VERTEX_INPUT_BINDING_STRIDE : Result := VK_DYNAMIC_STATE_VERTEX_INPUT_BINDING_STRIDE;
           DS_DEPTH_TEST_ENABLE         : Result := VK_DYNAMIC_STATE_DEPTH_TEST_ENABLE;
           DS_DEPTH_WRITE_ENABLE        : Result := VK_DYNAMIC_STATE_DEPTH_WRITE_ENABLE;
           DS_DEPTH_COMPARE_OP          : Result := VK_DYNAMIC_STATE_DEPTH_COMPARE_OP;
           DS_DEPTH_BOUNDS_TEST_ENABLE  : Result := VK_DYNAMIC_STATE_DEPTH_BOUNDS_TEST_ENABLE;
           DS_STENCIL_TEST_ENABLE       : Result := VK_DYNAMIC_STATE_STENCIL_TEST_ENABLE;
           DS_STENCIL_OP                : Result := VK_DYNAMIC_STATE_STENCIL_OP;
           //DS_RAY_TRACING_PIPELINE_STACK_SIZE : Result := VK_DYNAMIC_STATE_RAY_TRACING_PIPELINE_STACK_SIZE_KHR;
           //DS_VERTEX_INPUT              : Result := VK_DYNAMIC_STATE_VERTEX_INPUT_EXT;
           //DS_PATCH_CONTROL_POINTS      : Result := VK_DYNAMIC_STATE_PATCH_CONTROL_POINTS_EXT;
           DS_RASTERIZER_DISCARD_ENABLE : Result := VK_DYNAMIC_STATE_RASTERIZER_DISCARD_ENABLE;
           DS_DEPTH_BIAS_ENABLE         : Result := VK_DYNAMIC_STATE_DEPTH_BIAS_ENABLE;
           //DS_LOGIC_OP                  : Result := VK_DYNAMIC_STATE_LOGIC_OP_EXT;
           DS_PRIMITIVE_RESTART_ENABLE  : Result := VK_DYNAMIC_STATE_PRIMITIVE_RESTART_ENABLE;
           //DS_COLOR_WRITE_ENABLE        : Result := VK_DYNAMIC_STATE_COLOR_WRITE_ENABLE_EXT;
           else
             Result := VK_DYNAMIC_STATE_VIEWPORT;
        End;
      End;

      Function GetVGDynamicState(Value: TVkDynamicState) : TvgDynamicStateBit;
      Begin
        Case Value of
          VK_DYNAMIC_STATE_VIEWPORT                 : Result := DS_VIEWPORT;
          VK_DYNAMIC_STATE_SCISSOR                  : Result := DS_SCISSOR;
          VK_DYNAMIC_STATE_LINE_WIDTH               : Result := DS_LINE_WIDTH;
          VK_DYNAMIC_STATE_DEPTH_BIAS               : Result := DS_DEPTH_BIAS;
          VK_DYNAMIC_STATE_BLEND_CONSTANTS          : Result := DS_BLEND_CONSTANTS;
          VK_DYNAMIC_STATE_DEPTH_BOUNDS             : Result := DS_DEPTH_BOUNDS;
          VK_DYNAMIC_STATE_STENCIL_COMPARE_MASK     : Result := DS_STENCIL_COMPARE_MASK;
          VK_DYNAMIC_STATE_STENCIL_WRITE_MASK       : Result := DS_STENCIL_WRITE_MASK;
          VK_DYNAMIC_STATE_STENCIL_REFERENCE        : Result := DS_STENCIL_REFERENCE;
          VK_DYNAMIC_STATE_VIEWPORT_W_SCALING_NV    : Result := DS_VIEWPORT_W_SCALING;
          VK_DYNAMIC_STATE_DISCARD_RECTANGLE_EXT    : Result := DS_DISCARD_RECTANGLE;
          VK_DYNAMIC_STATE_SAMPLE_LOCATIONS_EXT     : Result := DS_SAMPLE_LOCATIONS;
          VK_DYNAMIC_STATE_VIEWPORT_SHADING_RATE_PALETTE_NV     : Result := DS_VIEWPORT_SHADING_RATE_PALETTE;
          VK_DYNAMIC_STATE_VIEWPORT_COARSE_SAMPLE_ORDER_NV       : Result := DS_VIEWPORT_COARSE_SAMPLE_ORDER;
          VK_DYNAMIC_STATE_EXCLUSIVE_SCISSOR_NV     : Result := DS_EXCLUSIVE_SCISSOR;
          VK_DYNAMIC_STATE_FRAGMENT_SHADING_RATE_KHR: Result := DS_FRAGMENT_SHADING_RATE;
         // VK_DYNAMIC_STATE_LINE_STIPPLE_EXT         : Result := DS_LINE_STIPPLE;
          VK_DYNAMIC_STATE_CULL_MODE                : Result := DS_CULL_MODE;
          VK_DYNAMIC_STATE_FRONT_FACE               : Result := DS_FRONT_FACE;
          VK_DYNAMIC_STATE_PRIMITIVE_TOPOLOGY       : Result := DS_PRIMITIVE_TOPOLOGY;
          VK_DYNAMIC_STATE_VIEWPORT_WITH_COUNT          : Result := DS_VIEWPORT_WITH_COUNT;
          VK_DYNAMIC_STATE_SCISSOR_WITH_COUNT           : Result := DS_SCISSOR_WITH_COUNT;
          VK_DYNAMIC_STATE_VERTEX_INPUT_BINDING_STRIDE  : Result := DS_VERTEX_INPUT_BINDING_STRIDE;
          VK_DYNAMIC_STATE_DEPTH_TEST_ENABLE            : Result := DS_DEPTH_TEST_ENABLE;
          VK_DYNAMIC_STATE_DEPTH_WRITE_ENABLE           : Result := DS_DEPTH_WRITE_ENABLE;
          VK_DYNAMIC_STATE_DEPTH_COMPARE_OP             : Result := DS_DEPTH_COMPARE_OP;
          VK_DYNAMIC_STATE_DEPTH_BOUNDS_TEST_ENABLE     : Result := DS_DEPTH_BOUNDS_TEST_ENABLE;
          VK_DYNAMIC_STATE_STENCIL_TEST_ENABLE          : Result := DS_STENCIL_TEST_ENABLE;
          VK_DYNAMIC_STATE_STENCIL_OP                   : Result := DS_STENCIL_OP;
         // VK_DYNAMIC_STATE_RAY_TRACING_PIPELINE_STACK_SIZE_KHR    : Result := DS_RAY_TRACING_PIPELINE_STACK_SIZE;
         // VK_DYNAMIC_STATE_VERTEX_INPUT_EXT             : Result := DS_VERTEX_INPUT;
         // VK_DYNAMIC_STATE_PATCH_CONTROL_POINTS_EXT     : Result := DS_PATCH_CONTROL_POINTS;
         // VK_DYNAMIC_STATE_RASTERIZER_DISCARD_ENABLE    : Result := DS_RASTERIZER_DISCARD_ENABLE;
          VK_DYNAMIC_STATE_DEPTH_BIAS_ENABLE            : Result := DS_DEPTH_BIAS_ENABLE;
         // VK_DYNAMIC_STATE_LOGIC_OP_EXT                 : Result := DS_LOGIC_OP;
          VK_DYNAMIC_STATE_PRIMITIVE_RESTART_ENABLE     : Result := DS_PRIMITIVE_RESTART_ENABLE;
         // VK_DYNAMIC_STATE_COLOR_WRITE_ENABLE_EXT       : Result := DS_COLOR_WRITE_ENABLE;
          else
            Result := DS_VIEWPORT;
        End;
      End;

      Function GetVKBufferUsageFlags(Value: TvgBufferUsageFlagBits) : TVkBufferUsageFlags;
      Begin
        Result := 0;
        If (BU_TRANSFER_SRC_BIT in Value)                 then Result := Result OR TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_SRC_BIT) ;
        If (BU_TRANSFER_DST_BIT in Value)                 then Result := Result or TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_DST_BIT) ;
        If (BU_UNIFORM_TEXEL_BUFFER_BIT in Value)         then Result := Result or TVkBufferUsageFlags(VK_BUFFER_USAGE_UNIFORM_TEXEL_BUFFER_BIT) ;
        If (BU_STORAGE_TEXEL_BUFFER_BIT in Value)         then Result := Result or TVkBufferUsageFlags(VK_BUFFER_USAGE_STORAGE_TEXEL_BUFFER_BIT) ;
        If (BU_UNIFORM_BUFFER_BIT in Value)               then Result := Result or TVkBufferUsageFlags(VK_BUFFER_USAGE_UNIFORM_BUFFER_BIT) ;
        If (BU_STORAGE_BUFFER_BIT in Value)               then Result := Result or TVkBufferUsageFlags(VK_BUFFER_USAGE_STORAGE_BUFFER_BIT) ;
        If (BU_INDEX_BUFFER_BIT in Value)                 then Result := Result or TVkBufferUsageFlags(VK_BUFFER_USAGE_INDEX_BUFFER_BIT) ;
        If (BU_VERTEX_BUFFER_BIT in Value)                then Result := Result or TVkBufferUsageFlags(VK_BUFFER_USAGE_VERTEX_BUFFER_BIT) ;
        If (BU_INDIRECT_BUFFER_BIT in Value)              then Result := Result or TVkBufferUsageFlags(VK_BUFFER_USAGE_INDIRECT_BUFFER_BIT) ;
        If (BU_CONDITIONAL_RENDERING_BIT_EXT in Value)    then Result := Result or TVkBufferUsageFlags(VK_BUFFER_USAGE_CONDITIONAL_RENDERING_BIT_EXT) ;
        If (BU_SHADER_BINDING_TABLE_BIT_KHR in Value)     then Result := Result or TVkBufferUsageFlags(VK_BUFFER_USAGE_SHADER_BINDING_TABLE_BIT_KHR) ;
        If (BU_TRANSFORM_FEEDBACK_BUFFER_BIT_EXT in Value)then Result := Result or TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFORM_FEEDBACK_BUFFER_BIT_EXT) ;
        If (BU_TRANSFORM_FEEDBACK_COUNTER_BUFFER_BIT_EXT in Value) then Result := Result or TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFORM_FEEDBACK_COUNTER_BUFFER_BIT_EXT) ;
        If (BU_VIDEO_DECODE_SRC_BIT_KHR in Value)        then Result := Result or TVkBufferUsageFlags(VK_BUFFER_USAGE_VIDEO_DECODE_SRC_BIT_KHR) ;
        If (BU_VIDEO_DECODE_DST_BIT_KHR in Value)        then Result := Result or TVkBufferUsageFlags(VK_BUFFER_USAGE_VIDEO_DECODE_DST_BIT_KHR) ;
        If (BU_VIDEO_ENCODE_DST_BIT_KHR in Value)        then Result := Result or TVkBufferUsageFlags(VK_BUFFER_USAGE_VIDEO_ENCODE_DST_BIT_KHR) ;
        If (BU_VIDEO_ENCODE_SRC_BIT_KHR in Value)        then Result := Result or TVkBufferUsageFlags(VK_BUFFER_USAGE_VIDEO_ENCODE_SRC_BIT_KHR) ;
        If (BU_SHADER_DEVICE_ADDRESS_BIT in Value)       then Result := Result or TVkBufferUsageFlags(VK_BUFFER_USAGE_SHADER_DEVICE_ADDRESS_BIT) ;
        If (BU_RESERVED_18_BIT_QCOM in Value)            then Result := Result or TVkBufferUsageFlags(VK_BUFFER_USAGE_RESERVED_18_BIT_QCOM) ;
        If (BU_ACCELERATION_STRUCTURE_BUILD_INPUT_READ_ONLY_BIT_KHR in Value)  then Result := Result or TVkBufferUsageFlags(VK_BUFFER_USAGE_ACCELERATION_STRUCTURE_BUILD_INPUT_READ_ONLY_BIT_KHR) ;
        If (BU_ACCELERATION_STRUCTURE_STORAGE_BIT_KHR in Value)                then Result := Result or TVkBufferUsageFlags(VK_BUFFER_USAGE_ACCELERATION_STRUCTURE_STORAGE_BIT_KHR) ;
      //  If (BU_RESERVED_21_BIT_AMD in Value)             then Result := Result or TVkBufferUsageFlags(VK_BUFFER_USAGE_RESERVED_21_BIT_AMD) ;
      //  If (BU_RESERVED_22_BIT_AMD in Value)             then Result := Result or TVkBufferUsageFlags(VK_BUFFER_USAGE_RESERVED_22_BIT_AMD) ;
      //  If (BU_RESERVED_23_BIT_NV in Value)              then Result := Result or TVkBufferUsageFlags(VK_BUFFER_USAGE_RESERVED_23_BIT_NV) ;
      //  If (BU_RESERVED_24_BIT_NV in Value)              then Result := Result or TVkBufferUsageFlags(VK_BUFFER_USAGE_RESERVED_24_BIT_NV) ;
        If (BU_RAY_TRACING_BIT_NV in Value)              then Result := Result or TVkBufferUsageFlags(VK_BUFFER_USAGE_RAY_TRACING_BIT_NV) ;
        If (BU_SHADER_DEVICE_ADDRESS_BIT_EXT in Value)   then Result := Result or TVkBufferUsageFlags(VK_BUFFER_USAGE_SHADER_DEVICE_ADDRESS_BIT_EXT) ;
        If (BU_SHADER_DEVICE_ADDRESS_BIT_KHR in Value)   then Result := Result or TVkBufferUsageFlags(VK_BUFFER_USAGE_SHADER_DEVICE_ADDRESS_BIT_KHR) ;
      End;

      Function GetVGBufferUsageFlags(Value: TVkBufferUsageFlags) : TvgBufferUsageFlagBits;
        Function TestValue(TestVal: TVkBufferUsageFlagBits):Boolean;
        Begin
          Result:= ((Value and TVkBufferUsageFlags(TestVal)) = TVkBufferUsageFlags(TestVal));
        End;
      Begin
        Result := [];
        If TestValue(VK_BUFFER_USAGE_TRANSFER_SRC_BIT)        then include(Result, BU_TRANSFER_SRC_BIT) ;
        If TestValue(VK_BUFFER_USAGE_TRANSFER_DST_BIT)        then include(Result, BU_TRANSFER_DST_BIT) ;
        If TestValue(VK_BUFFER_USAGE_UNIFORM_TEXEL_BUFFER_BIT)        then include(Result, BU_UNIFORM_TEXEL_BUFFER_BIT) ;
        If TestValue(VK_BUFFER_USAGE_STORAGE_TEXEL_BUFFER_BIT)        then include(Result, BU_STORAGE_TEXEL_BUFFER_BIT) ;
        If TestValue(VK_BUFFER_USAGE_UNIFORM_BUFFER_BIT)        then include(Result, BU_UNIFORM_BUFFER_BIT) ;
        If TestValue(VK_BUFFER_USAGE_STORAGE_BUFFER_BIT)        then include(Result, BU_STORAGE_BUFFER_BIT) ;
        If TestValue(VK_BUFFER_USAGE_INDEX_BUFFER_BIT)        then include(Result, BU_INDEX_BUFFER_BIT) ;
        If TestValue(VK_BUFFER_USAGE_VERTEX_BUFFER_BIT)        then include(Result, BU_VERTEX_BUFFER_BIT) ;
        If TestValue(VK_BUFFER_USAGE_INDIRECT_BUFFER_BIT)        then include(Result, BU_INDIRECT_BUFFER_BIT) ;
        If TestValue(VK_BUFFER_USAGE_CONDITIONAL_RENDERING_BIT_EXT)        then include(Result, BU_CONDITIONAL_RENDERING_BIT_EXT) ;
        If TestValue(VK_BUFFER_USAGE_SHADER_BINDING_TABLE_BIT_KHR)        then include(Result, BU_SHADER_BINDING_TABLE_BIT_KHR) ;
        If TestValue(VK_BUFFER_USAGE_TRANSFORM_FEEDBACK_BUFFER_BIT_EXT)        then include(Result, BU_TRANSFORM_FEEDBACK_BUFFER_BIT_EXT) ;
        If TestValue(VK_BUFFER_USAGE_TRANSFORM_FEEDBACK_COUNTER_BUFFER_BIT_EXT)        then include(Result, BU_TRANSFORM_FEEDBACK_COUNTER_BUFFER_BIT_EXT) ;
        If TestValue(VK_BUFFER_USAGE_VIDEO_DECODE_SRC_BIT_KHR)        then include(Result, BU_VIDEO_DECODE_SRC_BIT_KHR) ;
        If TestValue(VK_BUFFER_USAGE_VIDEO_DECODE_DST_BIT_KHR)        then include(Result, BU_VIDEO_DECODE_DST_BIT_KHR) ;
        If TestValue(VK_BUFFER_USAGE_VIDEO_ENCODE_DST_BIT_KHR)        then include(Result, BU_VIDEO_ENCODE_DST_BIT_KHR) ;
        If TestValue(VK_BUFFER_USAGE_VIDEO_ENCODE_SRC_BIT_KHR)        then include(Result, BU_VIDEO_ENCODE_SRC_BIT_KHR) ;
        If TestValue(VK_BUFFER_USAGE_SHADER_DEVICE_ADDRESS_BIT)        then include(Result,BU_SHADER_DEVICE_ADDRESS_BIT ) ;
        If TestValue(VK_BUFFER_USAGE_RESERVED_18_BIT_QCOM)        then include(Result, BU_RESERVED_18_BIT_QCOM) ;
        If TestValue(VK_BUFFER_USAGE_ACCELERATION_STRUCTURE_BUILD_INPUT_READ_ONLY_BIT_KHR)        then include(Result, BU_ACCELERATION_STRUCTURE_BUILD_INPUT_READ_ONLY_BIT_KHR) ;
        If TestValue(VK_BUFFER_USAGE_ACCELERATION_STRUCTURE_STORAGE_BIT_KHR)        then include(Result, BU_ACCELERATION_STRUCTURE_STORAGE_BIT_KHR) ;
      //  If TestValue(VK_BUFFER_USAGE_RESERVED_21_BIT_AMD)        then include(Result,BU_RESERVED_21_BIT_AMD ) ;
      //  If TestValue(VK_BUFFER_USAGE_RESERVED_22_BIT_AMD)        then include(Result, BU_RESERVED_22_BIT_AMD) ;
      //  If TestValue(VK_BUFFER_USAGE_RESERVED_23_BIT_NV)        then include(Result, BU_RESERVED_23_BIT_NV) ;
      //  If TestValue(VK_BUFFER_USAGE_RESERVED_24_BIT_NV)        then include(Result, BU_RESERVED_24_BIT_NV) ;
        If TestValue(VK_BUFFER_USAGE_RAY_TRACING_BIT_NV)        then include(Result, BU_RAY_TRACING_BIT_NV) ;
        If TestValue(VK_BUFFER_USAGE_SHADER_DEVICE_ADDRESS_BIT_EXT)        then include(Result, BU_SHADER_DEVICE_ADDRESS_BIT_EXT) ;
        If TestValue(VK_BUFFER_USAGE_SHADER_DEVICE_ADDRESS_BIT_KHR)        then include(Result, BU_SHADER_DEVICE_ADDRESS_BIT_KHR) ;
      End;


      Function GetVKImageMemoryType(Value: TvgImageMemoryType) : TpvVulkanDeviceMemoryAllocationType;
      Begin
        Case Value of
           IM_OPTIMAL  : Result := TpvVulkanDeviceMemoryAllocationType.ImageOptimal;
           IM_LINEAR   : Result := TpvVulkanDeviceMemoryAllocationType.ImageLinear;
         else
           Result := TpvVulkanDeviceMemoryAllocationType.ImageOptimal;
        End;
      End;

      Function GetVGImageMemoryType(Value: TpvVulkanDeviceMemoryAllocationType) : TvgImageMemoryType;
      Begin
        Case Value of
          TpvVulkanDeviceMemoryAllocationType.ImageOptimal   : Result := IM_OPTIMAL;
          TpvVulkanDeviceMemoryAllocationType.ImageLinear    : Result := IM_LINEAR;
         else
           Result := IM_OPTIMAL;
        End;
      End;


      Function GetVKMemoryPropertyFlagBits(Value: TvgMemoryPropertyFlagBits) :  TVkMemoryPropertyFlags;
      Begin
        Result := 0;
        If (MP_DEVICE_LOCAL_BIT in Value)        then Result := Result or TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT) ;
        If (MP_HOST_VISIBLE_BIT in Value)        then Result := Result or TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT) ;
        If (MP_HOST_COHERENT_BIT in Value)       then Result := Result or TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_COHERENT_BIT) ;
        If (MP_HOST_CACHED_BIT in Value)         then Result := Result or TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_CACHED_BIT) ;
        If (MP_LAZILY_ALLOCATED_BIT in Value)    then Result := Result or TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_LAZILY_ALLOCATED_BIT) ;
        If (MP_PROTECTED_BIT in Value)           then Result := Result or TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_PROTECTED_BIT) ;
        If (MP_DEVICE_COHERENT_BIT_AMD in Value) then Result := Result or TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_COHERENT_BIT_AMD) ;
        If (MP_DEVICE_UNCACHED_BIT_AMD in Value) then Result := Result or TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_UNCACHED_BIT_AMD) ;
        If (MP_RDMA_CAPABLE_BIT_NV in Value)     then Result := Result or TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_RDMA_CAPABLE_BIT_NV) ;

      End;
      Function GetVGMemoryPropertyFlagBits(Value: TVkMemoryPropertyFlags) : TvgMemoryPropertyFlagBits;
        Function TestValue(TestVal: TVkMemoryPropertyFlagBits):Boolean;
        Begin
          Result:= ((Value and TVkMemoryPropertyFlags(TestVal)) = TVkMemoryPropertyFlags(TestVal));
        End;
      Begin
        Result := [];
        If TestValue(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT)        then include(Result, MP_DEVICE_LOCAL_BIT) ;
        If TestValue(VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT)        then include(Result, MP_HOST_VISIBLE_BIT) ;
        If TestValue(VK_MEMORY_PROPERTY_HOST_COHERENT_BIT)       then include(Result, MP_HOST_COHERENT_BIT) ;
        If TestValue(VK_MEMORY_PROPERTY_HOST_CACHED_BIT)         then include(Result, MP_HOST_CACHED_BIT) ;
        If TestValue(VK_MEMORY_PROPERTY_LAZILY_ALLOCATED_BIT)    then include(Result, MP_LAZILY_ALLOCATED_BIT) ;
        If TestValue(VK_MEMORY_PROPERTY_PROTECTED_BIT)           then include(Result, MP_PROTECTED_BIT) ;
        If TestValue(VK_MEMORY_PROPERTY_DEVICE_COHERENT_BIT_AMD) then include(Result, MP_DEVICE_COHERENT_BIT_AMD) ;
        If TestValue(VK_MEMORY_PROPERTY_DEVICE_UNCACHED_BIT_AMD) then include(Result, MP_DEVICE_UNCACHED_BIT_AMD) ;
        If TestValue(VK_MEMORY_PROPERTY_RDMA_CAPABLE_BIT_NV)     then include(Result, MP_RDMA_CAPABLE_BIT_NV) ;

      End;

      Function GetVKImageTiling(Value: TvgImageTiling) : TVkImageTiling;
      Begin
        Case Value of
            TL_OPTIMAL                  : Result :=  VK_IMAGE_TILING_OPTIMAL;
            TL_LINEAR                   : Result :=  VK_IMAGE_TILING_LINEAR;
         //   TL_DRM_FORMAT_MODIFIER_EXT  : Result :=  VK_IMAGE_TILING_DRM_FORMAT_MODIFIER_EXT;
         Else
           Result := VK_IMAGE_TILING_OPTIMAL ;
        End;
      End;

      Function GetVGImageTiling(Value: TVkImageTiling) : TvgImageTiling ;
      Begin
        Case Value of
           VK_IMAGE_TILING_OPTIMAL                   : Result :=  TL_OPTIMAL;
           VK_IMAGE_TILING_LINEAR                    : Result :=  TL_LINEAR;
         //  VK_IMAGE_TILING_DRM_FORMAT_MODIFIER_EXT   : Result :=  TL_DRM_FORMAT_MODIFIER_EXT;
         Else
           Result := TL_OPTIMAL ;
        End;
      End;


      Function GetVKImageType(Value: TvgImageType) : TVkImageType;
      Begin
        Case Value of
           IT_1D   : Result :=  VK_IMAGE_TYPE_1D;
           IT_2D   : Result :=  VK_IMAGE_TYPE_2D;
           IT_3D   : Result :=  VK_IMAGE_TYPE_3D;
         Else
           Result := VK_IMAGE_TYPE_1D ;
        End;
      End;

      Function GetVGImageType(Value: TVkImageType) : TvgImageType ;
      Begin
        Case Value of
          VK_IMAGE_TYPE_1D    : Result :=  IT_1D;
          VK_IMAGE_TYPE_2D    : Result :=  IT_2D;
          VK_IMAGE_TYPE_3D    : Result :=  IT_3D;
         Else
           Result := IT_1D ;
        End;
      End;

      Function GetVKImageUsageFlagBits(Value: TvgImageUsageFlagBits) : TVkImageUsageFlags;
      Begin
        Result := 0;
        If (IU_TRANSFER_SRC_BIT in Value)                 then Result:= Result OR TVkImageUsageFlags(VK_IMAGE_USAGE_TRANSFER_SRC_BIT);
        If (IU_TRANSFER_DST_BIT in Value)                 then Result:= Result OR TVkImageUsageFlags(VK_IMAGE_USAGE_TRANSFER_DST_BIT);
        If (IU_SAMPLED_BIT in Value)                      then Result:= Result OR TVkImageUsageFlags(VK_IMAGE_USAGE_SAMPLED_BIT);
        If (IU_STORAGE_BIT in Value)                      then Result:= Result OR TVkImageUsageFlags(VK_IMAGE_USAGE_STORAGE_BIT);
        If (IU_COLOR_ATTACHMENT_BIT in Value)             then Result:= Result OR TVkImageUsageFlags(VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT);
        If (IU_DEPTH_STENCIL_ATTACHMENT_BIT in Value)     then Result:= Result OR TVkImageUsageFlags(VK_IMAGE_USAGE_DEPTH_STENCIL_ATTACHMENT_BIT);
        If (IU_TRANSIENT_ATTACHMENT_BIT in Value)         then Result:= Result OR TVkImageUsageFlags(VK_IMAGE_USAGE_TRANSIENT_ATTACHMENT_BIT);
        If (IU_INPUT_ATTACHMENT_BIT in Value)             then Result:= Result OR TVkImageUsageFlags(VK_IMAGE_USAGE_INPUT_ATTACHMENT_BIT);
        If (IU_FRAGMENT_SHADING_RATE_ATTACHMENT_BIT_KHR in Value) then Result:= Result OR TVkImageUsageFlags(VK_IMAGE_USAGE_FRAGMENT_SHADING_RATE_ATTACHMENT_BIT_KHR);
        If (IU_FRAGMENT_DENSITY_MAP_BIT_EXT in Value)     then Result:= Result OR TVkImageUsageFlags(VK_IMAGE_USAGE_FRAGMENT_DENSITY_MAP_BIT_EXT);
        If (IU_VIDEO_DECODE_DST_BIT_KHR in Value)         then Result:= Result OR TVkImageUsageFlags(VK_IMAGE_USAGE_VIDEO_DECODE_DST_BIT_KHR);
        If (IU_VIDEO_DECODE_SRC_BIT_KHR in Value)         then Result:= Result OR TVkImageUsageFlags(VK_IMAGE_USAGE_VIDEO_DECODE_SRC_BIT_KHR);
        If (IU_VIDEO_DECODE_DPB_BIT_KHR in Value)         then Result:= Result OR TVkImageUsageFlags(VK_IMAGE_USAGE_VIDEO_DECODE_DPB_BIT_KHR);
        If (IU_VIDEO_ENCODE_DST_BIT_KHR in Value)         then Result:= Result OR TVkImageUsageFlags(VK_IMAGE_USAGE_VIDEO_ENCODE_DST_BIT_KHR);
        If (IU_VIDEO_ENCODE_SRC_BIT_KHR in Value)         then Result:= Result OR TVkImageUsageFlags(VK_IMAGE_USAGE_VIDEO_ENCODE_SRC_BIT_KHR);
        If (IU_VIDEO_ENCODE_DPB_BIT_KHR in Value)         then Result:= Result OR TVkImageUsageFlags(VK_IMAGE_USAGE_VIDEO_ENCODE_DPB_BIT_KHR);
        If (IU_RESERVED_16_BIT_QCOM in Value)             then Result:= Result OR TVkImageUsageFlags(VK_IMAGE_USAGE_RESERVED_16_BIT_QCOM);
        If (IU_RESERVED_17_BIT_QCOM in Value)             then Result:= Result OR TVkImageUsageFlags(VK_IMAGE_USAGE_RESERVED_17_BIT_QCOM);
        If (IU_INVOCATION_MASK_BIT_HUAWEI in Value)       then Result:= Result OR TVkImageUsageFlags(VK_IMAGE_USAGE_INVOCATION_MASK_BIT_HUAWEI);
      //  If (IU_RESERVED_19_BIT_EXT in Value)              then Result:= Result OR TVkImageUsageFlags(VK_IMAGE_USAGE_RESERVED_19_BIT_EXT);
      //  If (IU_SHADING_RATE_IMAGE_BIT_NV in Value)        then Result:= Result + TVkImageUsageFlags(VK_IMAGE_USAGE_SHADING_RATE_IMAGE_BIT_NV);

      End;

      Function GetVGImageUsageFlagBits(Value: TVkImageUsageFlags) : TvgImageUsageFlagBits ;
        Function TestValue(TestVal: TVkImageUsageFlagBits):Boolean;
        Begin
          Result:= ((Value and TVkImageUsageFlags(TestVal)) = TVkImageUsageFlags(TestVal));
        End;
      Begin
        Result:=[];

        If TestValue(VK_IMAGE_USAGE_TRANSFER_SRC_BIT)                 then Include(Result , IU_TRANSFER_SRC_BIT);
        If TestValue(VK_IMAGE_USAGE_TRANSFER_DST_BIT)                 then Include(Result , IU_TRANSFER_DST_BIT);
        If TestValue(VK_IMAGE_USAGE_SAMPLED_BIT)                      then Include(Result , IU_SAMPLED_BIT);
        If TestValue(VK_IMAGE_USAGE_STORAGE_BIT)                      then Include(Result , IU_STORAGE_BIT);
        If TestValue(VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT)             then Include(Result , IU_COLOR_ATTACHMENT_BIT);
        If TestValue(VK_IMAGE_USAGE_DEPTH_STENCIL_ATTACHMENT_BIT)     then Include(Result , IU_DEPTH_STENCIL_ATTACHMENT_BIT);
        If TestValue(VK_IMAGE_USAGE_TRANSIENT_ATTACHMENT_BIT)         then Include(Result , IU_TRANSIENT_ATTACHMENT_BIT);
        If TestValue(VK_IMAGE_USAGE_INPUT_ATTACHMENT_BIT)             then Include(Result , IU_INPUT_ATTACHMENT_BIT);
        If TestValue(VK_IMAGE_USAGE_FRAGMENT_SHADING_RATE_ATTACHMENT_BIT_KHR) then Include(Result , IU_FRAGMENT_SHADING_RATE_ATTACHMENT_BIT_KHR);
        If TestValue(VK_IMAGE_USAGE_FRAGMENT_DENSITY_MAP_BIT_EXT)     then Include(Result , IU_FRAGMENT_DENSITY_MAP_BIT_EXT);
        If TestValue(VK_IMAGE_USAGE_VIDEO_DECODE_DST_BIT_KHR)         then Include(Result , IU_VIDEO_DECODE_DST_BIT_KHR);
        If TestValue(VK_IMAGE_USAGE_VIDEO_DECODE_SRC_BIT_KHR)         then Include(Result , IU_VIDEO_DECODE_SRC_BIT_KHR);
        If TestValue(VK_IMAGE_USAGE_VIDEO_DECODE_DPB_BIT_KHR)         then Include(Result , IU_VIDEO_DECODE_DPB_BIT_KHR);
        If TestValue(VK_IMAGE_USAGE_VIDEO_ENCODE_DST_BIT_KHR)         then Include(Result , IU_VIDEO_ENCODE_DST_BIT_KHR);
        If TestValue(VK_IMAGE_USAGE_VIDEO_ENCODE_SRC_BIT_KHR)         then Include(Result , IU_VIDEO_ENCODE_SRC_BIT_KHR);
        If TestValue(VK_IMAGE_USAGE_VIDEO_ENCODE_DPB_BIT_KHR)         then Include(Result , IU_VIDEO_ENCODE_DPB_BIT_KHR);
        If TestValue(VK_IMAGE_USAGE_RESERVED_16_BIT_QCOM)             then Include(Result , IU_RESERVED_16_BIT_QCOM);
        If TestValue(VK_IMAGE_USAGE_RESERVED_17_BIT_QCOM)             then Include(Result , IU_RESERVED_17_BIT_QCOM);
        If TestValue(VK_IMAGE_USAGE_INVOCATION_MASK_BIT_HUAWEI)        then Include(Result , IU_INVOCATION_MASK_BIT_HUAWEI);
      //  If TestValue(VK_IMAGE_USAGE_RESERVED_19_BIT_EXT)              then Include(Result , IU_RESERVED_19_BIT_EXT);
      //  If TestValue(VK_IMAGE_USAGE_SHADING_RATE_IMAGE_BIT_NV)        then Include(Result , IU_SHADING_RATE_IMAGE_BIT_NV);

      End;


      Function GetVKDeptBufferFormat(Value: TvgDepthBufferFormat) : TVkFormat;
      begin
        Case Value of
           DB_D16_UNORM           : Result := VK_FORMAT_D16_UNORM ;
           DB_D32_SFLOAT          : Result := VK_FORMAT_D32_SFLOAT ;
           DB_D16_UNORM_S8_UINT   : Result := VK_FORMAT_D16_UNORM_S8_UINT ;
           DB_D24_UNORM_S8_UINT   : Result := VK_FORMAT_D24_UNORM_S8_UINT ;
           DB_D32_SFLOAT_S8_UINT  : Result := VK_FORMAT_D32_SFLOAT_S8_UINT ;
         Else
           Result := VK_FORMAT_D16_UNORM ;
        End;
      end;

      Function GetVGDeptBufferFormat(Value: TVkFormat) : TvgDepthBufferFormat ;
      Begin
        Case Value of
          VK_FORMAT_D16_UNORM            : Result :=  DB_D16_UNORM;
          VK_FORMAT_D32_SFLOAT           : Result :=  DB_D32_SFLOAT;
          VK_FORMAT_D16_UNORM_S8_UINT    : Result :=  DB_D16_UNORM_S8_UINT;
          VK_FORMAT_D24_UNORM_S8_UINT    : Result :=  DB_D24_UNORM_S8_UINT;
          VK_FORMAT_D32_SFLOAT_S8_UINT   : Result :=  DB_D32_SFLOAT_S8_UINT;
         Else
           Result := DB_D16_UNORM ;
        End;
      End;


      Function GetVKPipelineBindPoint(Value: TvgPipelineBindPoint) : TVkPipelineBindPoint;
      Begin
        Case Value of
          BP_GRAPHICS               : Result := VK_PIPELINE_BIND_POINT_GRAPHICS;
          BP_COMPUTE                : Result := VK_PIPELINE_BIND_POINT_COMPUTE ;
          BP_RAY_TRACING_KHR        : Result := VK_PIPELINE_BIND_POINT_RAY_TRACING_KHR;
          BP_SUBPASS_SHADING_HUAWEI : Result := VK_PIPELINE_BIND_POINT_SUBPASS_SHADING_HUAWEI;
          BP_RAY_TRACING_NV         : Result := VK_PIPELINE_BIND_POINT_RAY_TRACING_NV;
          else
            Result:= VK_PIPELINE_BIND_POINT_GRAPHICS;
        End;
      End;

      Function GetVGPipelineBindPoint(Value: TVkPipelineBindPoint) : TvgPipelineBindPoint ;
      Begin
        Case Value of
          VK_PIPELINE_BIND_POINT_GRAPHICS               : Result := BP_GRAPHICS;
          VK_PIPELINE_BIND_POINT_COMPUTE                : Result := BP_COMPUTE;
          VK_PIPELINE_BIND_POINT_RAY_TRACING_KHR        : Result := BP_RAY_TRACING_KHR;
          VK_PIPELINE_BIND_POINT_SUBPASS_SHADING_HUAWEI : Result := BP_SUBPASS_SHADING_HUAWEI;
         // VK_PIPELINE_BIND_POINT_RAY_TRACING_NV         : Result := RAY_TRACING_NV;
          else
            Result:= BP_GRAPHICS;
        End;
      End;


      Function GetVKDependencyFlagBits(Value: TvgDependencyFlagBits) : TVkDependencyFlags;
      Begin
        Result := 0;
        If (BY_REGION_BIT in Value)         then Result:= Result OR TVkDependencyFlags(VK_DEPENDENCY_BY_REGION_BIT);
        If (VIEW_LOCAL_BIT in Value)        then Result:= Result OR TVkDependencyFlags(VK_DEPENDENCY_VIEW_LOCAL_BIT);
        If (DEVICE_GROUP_BIT in Value)      then Result:= Result OR TVkDependencyFlags(VK_DEPENDENCY_DEVICE_GROUP_BIT);
        If (DEVICE_GROUP_BIT_KHR in Value)  then Result:= Result OR TVkDependencyFlags(VK_DEPENDENCY_DEVICE_GROUP_BIT_KHR);
        If (VIEW_LOCAL_BIT_KHR in Value)    then Result:= Result OR TVkDependencyFlags(VK_DEPENDENCY_VIEW_LOCAL_BIT_KHR);
      End;

      Function GetVGDependencyFlagBits(Value: TVkDependencyFlags) : TvgDependencyFlagBits ;
        Function TestValue(TestVal: TVkDependencyFlagBits):Boolean;
        Begin
          Result:= ((Value and TVkDependencyFlags(TestVal)) = TVkDependencyFlags(TestVal));
        End;
      Begin
        Result:=[];

        If TestValue(VK_DEPENDENCY_BY_REGION_BIT)         then Include(Result , BY_REGION_BIT);
        If TestValue(VK_DEPENDENCY_VIEW_LOCAL_BIT)        then Include(Result , VIEW_LOCAL_BIT);
        If TestValue(VK_DEPENDENCY_DEVICE_GROUP_BIT)      then Include(Result , DEVICE_GROUP_BIT);
        If TestValue(VK_DEPENDENCY_DEVICE_GROUP_BIT_KHR)  then Include(Result , DEVICE_GROUP_BIT_KHR);
        If TestValue(VK_DEPENDENCY_VIEW_LOCAL_BIT_KHR)    then Include(Result , VIEW_LOCAL_BIT_KHR);
      End;


      Function GetVKAccessFlagBits(Value: TvgAccessFlagBits) : TVkAccessFlags;
      Begin
        Result := 0;
        //if (AC_NONE_KHR in Value)                               then Result:= Result + TVkPipelineStageFlags(VK_ACCESS_NONE_KHR);
        If (INDIRECT_COMMAND_READ_BIT in Value)                 then Result:= Result OR TVkPipelineStageFlags(VK_ACCESS_INDIRECT_COMMAND_READ_BIT);
        If (INDEX_READ_BIT in Value)                            then Result:= Result OR TVkPipelineStageFlags(VK_ACCESS_INDEX_READ_BIT);
        If (VERTEX_ATTRIBUTE_READ_BIT in Value)                 then Result:= Result OR TVkPipelineStageFlags(VK_ACCESS_VERTEX_ATTRIBUTE_READ_BIT);
        If (UNIFORM_READ_BIT in Value)                          then Result:= Result OR TVkPipelineStageFlags(VK_ACCESS_UNIFORM_READ_BIT);
        If (INPUT_ATTACHMENT_READ_BIT in Value)                 then Result:= Result OR TVkPipelineStageFlags(VK_ACCESS_INPUT_ATTACHMENT_READ_BIT);
        If (SHADER_READ_BIT in Value)                           then Result:= Result OR TVkPipelineStageFlags(VK_ACCESS_SHADER_READ_BIT);
        If (SHADER_WRITE_BIT in Value)                          then Result:= Result OR TVkPipelineStageFlags(VK_ACCESS_SHADER_WRITE_BIT);
        If (COLOR_ATTACHMENT_READ_BIT in Value)                 then Result:= Result OR TVkPipelineStageFlags(VK_ACCESS_COLOR_ATTACHMENT_READ_BIT);
        If (COLOR_ATTACHMENT_WRITE_BIT in Value)                then Result:= Result OR TVkPipelineStageFlags(VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT);
        If (DEPTH_STENCIL_ATTACHMENT_READ_BIT in Value)         then Result:= Result OR TVkPipelineStageFlags(VK_ACCESS_DEPTH_STENCIL_ATTACHMENT_READ_BIT);
        If (DEPTH_STENCIL_ATTACHMENT_WRITE_BIT in Value)        then Result:= Result OR TVkPipelineStageFlags(VK_ACCESS_DEPTH_STENCIL_ATTACHMENT_WRITE_BIT);
        If (TRANSFER_READ_BIT in Value)                         then Result:= Result OR TVkPipelineStageFlags(VK_ACCESS_TRANSFER_READ_BIT);
        If (TRANSFER_WRITE_BIT in Value)                        then Result:= Result OR TVkPipelineStageFlags(VK_ACCESS_TRANSFER_WRITE_BIT);
        If (HOST_READ_BIT in Value)                             then Result:= Result OR TVkPipelineStageFlags(VK_ACCESS_HOST_READ_BIT);
        If (HOST_WRITE_BIT in Value)                            then Result:= Result OR TVkPipelineStageFlags(VK_ACCESS_HOST_WRITE_BIT);
        If (MEMORY_READ_BIT in Value)                           then Result:= Result OR TVkPipelineStageFlags(VK_ACCESS_MEMORY_READ_BIT);
        If (MEMORY_WRITE_BIT in Value)                          then Result:= Result OR TVkPipelineStageFlags(VK_ACCESS_MEMORY_WRITE_BIT);
        If (COMMAND_PREPROCESS_READ_BIT_NV in Value)            then Result:= Result OR TVkPipelineStageFlags(VK_ACCESS_COMMAND_PREPROCESS_READ_BIT_NV);
        If (COMMAND_PREPROCESS_WRITE_BIT_NV in Value)           then Result:= Result OR TVkPipelineStageFlags(VK_ACCESS_COMMAND_PREPROCESS_WRITE_BIT_NV);
        If (COLOR_ATTACHMENT_READ_NONCOHERENT_BIT_EXT in Value) then Result:= Result OR TVkPipelineStageFlags(VK_ACCESS_COLOR_ATTACHMENT_READ_NONCOHERENT_BIT_EXT);
        If (CONDITIONAL_RENDERING_READ_BIT_EXT in Value)        then Result:= Result OR TVkPipelineStageFlags(VK_ACCESS_CONDITIONAL_RENDERING_READ_BIT_EXT);
        If (ACCELERATION_STRUCTURE_READ_BIT_KHR in Value)       then Result:= Result OR TVkPipelineStageFlags(VK_ACCESS_ACCELERATION_STRUCTURE_READ_BIT_KHR);
        If (ACCELERATION_STRUCTURE_WRITE_BIT_KHR in Value)      then Result:= Result OR TVkPipelineStageFlags(VK_ACCESS_ACCELERATION_STRUCTURE_WRITE_BIT_KHR);
        If (FRAGMENT_SHADING_RATE_ATTACHMENT_READ_BIT_KHR in Value) then Result:= Result OR TVkPipelineStageFlags(VK_ACCESS_FRAGMENT_SHADING_RATE_ATTACHMENT_READ_BIT_KHR);
        If (FRAGMENT_DENSITY_MAP_READ_BIT_EXT in Value)         then Result:= Result OR TVkPipelineStageFlags(VK_ACCESS_FRAGMENT_DENSITY_MAP_READ_BIT_EXT);
        If (TRANSFORM_FEEDBACK_WRITE_BIT_EXT in Value)          then Result:= Result OR TVkPipelineStageFlags(VK_ACCESS_TRANSFORM_FEEDBACK_WRITE_BIT_EXT);
        If (TRANSFORM_FEEDBACK_COUNTER_READ_BIT_EXT in Value)   then Result:= Result OR TVkPipelineStageFlags(VK_ACCESS_TRANSFORM_FEEDBACK_COUNTER_READ_BIT_EXT);
        If (TRANSFORM_FEEDBACK_COUNTER_WRITE_BIT_EXT in Value)  then Result:= Result OR TVkPipelineStageFlags(VK_ACCESS_TRANSFORM_FEEDBACK_COUNTER_WRITE_BIT_EXT);
        If (ACCELERATION_STRUCTURE_READ_BIT_NV in Value)        then Result:= Result OR TVkPipelineStageFlags(VK_ACCESS_ACCELERATION_STRUCTURE_READ_BIT_NV);
        If (ACCELERATION_STRUCTURE_WRITE_BIT_NV in Value)       then Result:= Result OR TVkPipelineStageFlags(VK_ACCESS_ACCELERATION_STRUCTURE_WRITE_BIT_NV);
        If (SHADING_RATE_IMAGE_READ_BIT_NV in Value)            then Result:= Result OR TVkPipelineStageFlags(VK_ACCESS_SHADING_RATE_IMAGE_READ_BIT_NV);
      End;

      Function GetVGAccessFlagBits(Value: TVkAccessFlags) : TvgAccessFlagBits ;
        Function TestValue(TestVal: TVkAccessFlagBits):Boolean;
        Begin
          Result:= ((Value and TVkAccessFlags(TestVal)) = TVkAccessFlags(TestVal));
        End;
      Begin
        Result:=[];

      //  If TestValue(VK_ACCESS_NONE_KHR)                                then Include(Result , AC_NONE_KHR);
        If TestValue(VK_ACCESS_INDIRECT_COMMAND_READ_BIT)               then Include(Result , INDIRECT_COMMAND_READ_BIT);
        If TestValue(VK_ACCESS_INDEX_READ_BIT)                          then Include(Result , INDEX_READ_BIT);
        If TestValue(VK_ACCESS_VERTEX_ATTRIBUTE_READ_BIT)               then Include(Result , VERTEX_ATTRIBUTE_READ_BIT);
        If TestValue(VK_ACCESS_UNIFORM_READ_BIT)                        then Include(Result , UNIFORM_READ_BIT);
        If TestValue(VK_ACCESS_INPUT_ATTACHMENT_READ_BIT)               then Include(Result , INPUT_ATTACHMENT_READ_BIT);
        If TestValue(VK_ACCESS_SHADER_READ_BIT)                         then Include(Result , SHADER_READ_BIT);
        If TestValue(VK_ACCESS_SHADER_WRITE_BIT)                        then Include(Result , SHADER_WRITE_BIT);
        If TestValue(VK_ACCESS_COLOR_ATTACHMENT_READ_BIT)               then Include(Result , COLOR_ATTACHMENT_READ_BIT);
        If TestValue(VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT)              then Include(Result , COLOR_ATTACHMENT_WRITE_BIT);
        If TestValue(VK_ACCESS_DEPTH_STENCIL_ATTACHMENT_READ_BIT)       then Include(Result , DEPTH_STENCIL_ATTACHMENT_READ_BIT);
        If TestValue(VK_ACCESS_DEPTH_STENCIL_ATTACHMENT_WRITE_BIT)      then Include(Result , DEPTH_STENCIL_ATTACHMENT_WRITE_BIT);
        If TestValue(VK_ACCESS_TRANSFER_READ_BIT)                       then Include(Result , TRANSFER_READ_BIT);
        If TestValue(VK_ACCESS_TRANSFER_WRITE_BIT)                      then Include(Result , TRANSFER_WRITE_BIT);
        If TestValue(VK_ACCESS_HOST_READ_BIT)                           then Include(Result , HOST_READ_BIT);
        If TestValue(VK_ACCESS_HOST_WRITE_BIT)                          then Include(Result , HOST_WRITE_BIT);
        If TestValue(VK_ACCESS_MEMORY_READ_BIT)                         then Include(Result , MEMORY_READ_BIT);
        If TestValue(VK_ACCESS_MEMORY_WRITE_BIT)                        then Include(Result , MEMORY_WRITE_BIT);
        If TestValue(VK_ACCESS_COMMAND_PREPROCESS_READ_BIT_NV)          then Include(Result , COMMAND_PREPROCESS_READ_BIT_NV);
        If TestValue(VK_ACCESS_COMMAND_PREPROCESS_WRITE_BIT_NV)         then Include(Result , COMMAND_PREPROCESS_WRITE_BIT_NV);
        If TestValue(VK_ACCESS_COLOR_ATTACHMENT_READ_NONCOHERENT_BIT_EXT) then Include(Result , COLOR_ATTACHMENT_READ_NONCOHERENT_BIT_EXT);
        If TestValue(VK_ACCESS_CONDITIONAL_RENDERING_READ_BIT_EXT)      then Include(Result , CONDITIONAL_RENDERING_READ_BIT_EXT);
        If TestValue(VK_ACCESS_ACCELERATION_STRUCTURE_READ_BIT_KHR)     then Include(Result , ACCELERATION_STRUCTURE_READ_BIT_KHR);
        If TestValue(VK_ACCESS_ACCELERATION_STRUCTURE_WRITE_BIT_KHR)    then Include(Result , ACCELERATION_STRUCTURE_WRITE_BIT_KHR);
        If TestValue(VK_ACCESS_FRAGMENT_SHADING_RATE_ATTACHMENT_READ_BIT_KHR) then Include(Result , FRAGMENT_SHADING_RATE_ATTACHMENT_READ_BIT_KHR);
        If TestValue(VK_ACCESS_FRAGMENT_DENSITY_MAP_READ_BIT_EXT)       then Include(Result , FRAGMENT_DENSITY_MAP_READ_BIT_EXT);
        If TestValue(VK_ACCESS_TRANSFORM_FEEDBACK_WRITE_BIT_EXT)        then Include(Result , TRANSFORM_FEEDBACK_WRITE_BIT_EXT);
        If TestValue(VK_ACCESS_TRANSFORM_FEEDBACK_COUNTER_READ_BIT_EXT) then Include(Result , TRANSFORM_FEEDBACK_COUNTER_READ_BIT_EXT);
        If TestValue(VK_ACCESS_TRANSFORM_FEEDBACK_COUNTER_WRITE_BIT_EXT)then Include(Result , TRANSFORM_FEEDBACK_COUNTER_WRITE_BIT_EXT);
        If TestValue(VK_ACCESS_ACCELERATION_STRUCTURE_READ_BIT_NV)      then Include(Result , ACCELERATION_STRUCTURE_READ_BIT_NV);
        If TestValue(VK_ACCESS_ACCELERATION_STRUCTURE_WRITE_BIT_NV)     then Include(Result , ACCELERATION_STRUCTURE_WRITE_BIT_NV);
        If TestValue(VK_ACCESS_SHADING_RATE_IMAGE_READ_BIT_NV)          then Include(Result , SHADING_RATE_IMAGE_READ_BIT_NV);
      End;


      Function GetVKPipelineStageFlagBits(Value: TvgPipelineStageFlagBits) : TVkPipelineStageFlags;
      Begin
        Result := 0;
      //  If (PS_NONE_KHR in Value)                       then Result:= Result + TVkPipelineStageFlags(VK_PIPELINE_STAGE_NONE_KHR);
        If (TOP_OF_PIPE_BIT in Value)                   then Result:= Result OR TVkPipelineStageFlags(VK_PIPELINE_STAGE_TOP_OF_PIPE_BIT);
        If (DRAW_INDIRECT_BIT in Value)                 then Result:= Result OR TVkPipelineStageFlags(VK_PIPELINE_STAGE_DRAW_INDIRECT_BIT);
        If (VERTEX_INPUT_BIT in Value)                  then Result:= Result OR TVkPipelineStageFlags(VK_PIPELINE_STAGE_VERTEX_INPUT_BIT);
        If (VERTEX_SHADER_BIT in Value)                 then Result:= Result OR TVkPipelineStageFlags(VK_PIPELINE_STAGE_VERTEX_SHADER_BIT);
        If (TESSELLATION_CONTROL_SHADER_BIT in Value)   then Result:= Result OR TVkPipelineStageFlags(VK_PIPELINE_STAGE_TESSELLATION_CONTROL_SHADER_BIT);
        If (TESSELLATION_EVALUATION_SHADER_BIT in Value)then Result:= Result OR TVkPipelineStageFlags(VK_PIPELINE_STAGE_TESSELLATION_EVALUATION_SHADER_BIT);
        If (GEOMETRY_SHADER_BIT in Value)               then Result:= Result OR TVkPipelineStageFlags(VK_PIPELINE_STAGE_GEOMETRY_SHADER_BIT);
        If (FRAGMENT_SHADER_BIT in Value)               then Result:= Result OR TVkPipelineStageFlags(VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT);
        If (EARLY_FRAGMENT_TESTS_BIT in Value)          then Result:= Result OR TVkPipelineStageFlags(VK_PIPELINE_STAGE_EARLY_FRAGMENT_TESTS_BIT);
        If (LATE_FRAGMENT_TESTS_BIT in Value)           then Result:= Result OR TVkPipelineStageFlags(VK_PIPELINE_STAGE_LATE_FRAGMENT_TESTS_BIT);
        If (COLOR_ATTACHMENT_OUTPUT_BIT in Value)       then Result:= Result OR TVkPipelineStageFlags(VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT);
        If (COMPUTE_SHADER_BIT in Value)                then Result:= Result OR TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT);
        If (TRANSFER_BIT in Value)                      then Result:= Result OR TVkPipelineStageFlags(VK_PIPELINE_STAGE_TRANSFER_BIT);
        If (BOTTOM_OF_PIPE_BIT in Value)                then Result:= Result OR TVkPipelineStageFlags(VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT);
        If (HOST_BIT in Value)                          then Result:= Result OR TVkPipelineStageFlags(VK_PIPELINE_STAGE_HOST_BIT);
        If (ALL_GRAPHICS_BIT in Value)                  then Result:= Result OR TVkPipelineStageFlags(VK_PIPELINE_STAGE_ALL_GRAPHICS_BIT);
        If (ALL_COMMANDS_BIT in Value)                  then Result:= Result OR TVkPipelineStageFlags(VK_PIPELINE_STAGE_ALL_COMMANDS_BIT);
        If (COMMAND_PREPROCESS_BIT_NV in Value)         then Result:= Result OR TVkPipelineStageFlags(VK_PIPELINE_STAGE_COMMAND_PREPROCESS_BIT_NV);
        If (CONDITIONAL_RENDERING_BIT_EXT in Value)     then Result:= Result OR TVkPipelineStageFlags(VK_PIPELINE_STAGE_CONDITIONAL_RENDERING_BIT_EXT);
        If (TASK_SHADER_BIT_NV in Value)                then Result:= Result OR TVkPipelineStageFlags(VK_PIPELINE_STAGE_TASK_SHADER_BIT_NV);
        If (MESH_SHADER_BIT_NV in Value)                then Result:= Result OR TVkPipelineStageFlags(VK_PIPELINE_STAGE_MESH_SHADER_BIT_NV);
        If (RAY_TRACING_SHADER_BIT_KHR in Value)        then Result:= Result OR TVkPipelineStageFlags(VK_PIPELINE_STAGE_RAY_TRACING_SHADER_BIT_KHR);
        If (FRAGMENT_SHADING_RATE_ATTACHMENT_BIT_KHR in Value)  then Result:= Result OR TVkPipelineStageFlags(VK_PIPELINE_STAGE_FRAGMENT_SHADING_RATE_ATTACHMENT_BIT_KHR);
        If (FRAGMENT_DENSITY_PROCESS_BIT_EXT in Value)  then Result:= Result OR TVkPipelineStageFlags(VK_PIPELINE_STAGE_FRAGMENT_DENSITY_PROCESS_BIT_EXT);
        If (TRANSFORM_FEEDBACK_BIT_EXT in Value)        then Result:= Result OR TVkPipelineStageFlags(VK_PIPELINE_STAGE_TRANSFORM_FEEDBACK_BIT_EXT);
        If (ACCELERATION_STRUCTURE_BUILD_BIT_KHR in Value)  then Result:= Result OR TVkPipelineStageFlags(VK_PIPELINE_STAGE_ACCELERATION_STRUCTURE_BUILD_BIT_KHR);
        If (ACCELERATION_STRUCTURE_BUILD_BIT_NV in Value)  then Result:= Result OR TVkPipelineStageFlags(VK_PIPELINE_STAGE_ACCELERATION_STRUCTURE_BUILD_BIT_NV);
        If (SHADING_RATE_IMAGE_BIT_NV in Value)         then Result:= Result OR TVkPipelineStageFlags(VK_PIPELINE_STAGE_SHADING_RATE_IMAGE_BIT_NV);
        If (RAY_TRACING_SHADER_BIT_NV in Value)         then Result:= Result OR TVkPipelineStageFlags(VK_PIPELINE_STAGE_RAY_TRACING_SHADER_BIT_NV);
      End;

      Function GetVGPipelineStageFlagBits(Value: TVkPipelineStageFlags) : TvgPipelineStageFlagBits ;
        Function TestValue(TestVal: TVkPipelineStageFlagBits):Boolean;
        Begin
          Result:= ((Value and TVkPipelineStageFlags(TestVal)) = TVkPipelineStageFlags(TestVal));
        End;
      Begin
        Result:=[];

      //  If TestValue(VK_PIPELINE_STAGE_NONE_KHR)                            then Include(Result , PS_NONE_KHR);
        If TestValue(VK_PIPELINE_STAGE_TOP_OF_PIPE_BIT)                     then Include(Result , TOP_OF_PIPE_BIT);
        If TestValue(VK_PIPELINE_STAGE_DRAW_INDIRECT_BIT)                   then Include(Result , DRAW_INDIRECT_BIT);
        If TestValue(VK_PIPELINE_STAGE_VERTEX_INPUT_BIT)                    then Include(Result , VERTEX_INPUT_BIT);
        If TestValue(VK_PIPELINE_STAGE_VERTEX_SHADER_BIT)                   then Include(Result , VERTEX_SHADER_BIT);
        If TestValue(VK_PIPELINE_STAGE_TESSELLATION_CONTROL_SHADER_BIT)     then Include(Result , TESSELLATION_CONTROL_SHADER_BIT);
        If TestValue(VK_PIPELINE_STAGE_TESSELLATION_EVALUATION_SHADER_BIT)  then Include(Result , TESSELLATION_EVALUATION_SHADER_BIT);
        If TestValue(VK_PIPELINE_STAGE_GEOMETRY_SHADER_BIT)                 then Include(Result , GEOMETRY_SHADER_BIT);
        If TestValue(VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT)                 then Include(Result , FRAGMENT_SHADER_BIT);
        If TestValue(VK_PIPELINE_STAGE_EARLY_FRAGMENT_TESTS_BIT)            then Include(Result , EARLY_FRAGMENT_TESTS_BIT);
        If TestValue(VK_PIPELINE_STAGE_LATE_FRAGMENT_TESTS_BIT)             then Include(Result , LATE_FRAGMENT_TESTS_BIT);
        If TestValue(VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT)         then Include(Result , COLOR_ATTACHMENT_OUTPUT_BIT);
        If TestValue(VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT)                  then Include(Result , COMPUTE_SHADER_BIT);
        If TestValue(VK_PIPELINE_STAGE_TRANSFER_BIT)                        then Include(Result , TRANSFER_BIT);
        If TestValue(VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT)                  then Include(Result , BOTTOM_OF_PIPE_BIT);
        If TestValue(VK_PIPELINE_STAGE_HOST_BIT)                            then Include(Result , HOST_BIT);
        If TestValue(VK_PIPELINE_STAGE_ALL_GRAPHICS_BIT)                    then Include(Result , ALL_GRAPHICS_BIT);
        If TestValue(VK_PIPELINE_STAGE_ALL_COMMANDS_BIT)                    then Include(Result , ALL_COMMANDS_BIT);
        If TestValue(VK_PIPELINE_STAGE_COMMAND_PREPROCESS_BIT_NV)           then Include(Result , COMMAND_PREPROCESS_BIT_NV);
        If TestValue(VK_PIPELINE_STAGE_CONDITIONAL_RENDERING_BIT_EXT)       then Include(Result , CONDITIONAL_RENDERING_BIT_EXT);
        If TestValue(VK_PIPELINE_STAGE_TASK_SHADER_BIT_NV)                  then Include(Result , TASK_SHADER_BIT_NV);
        If TestValue(VK_PIPELINE_STAGE_MESH_SHADER_BIT_NV)                  then Include(Result , MESH_SHADER_BIT_NV);
        If TestValue(VK_PIPELINE_STAGE_RAY_TRACING_SHADER_BIT_KHR)          then Include(Result , RAY_TRACING_SHADER_BIT_KHR);
        If TestValue(VK_PIPELINE_STAGE_FRAGMENT_SHADING_RATE_ATTACHMENT_BIT_KHR) then Include(Result , FRAGMENT_SHADING_RATE_ATTACHMENT_BIT_KHR);
        If TestValue(VK_PIPELINE_STAGE_FRAGMENT_DENSITY_PROCESS_BIT_EXT)    then Include(Result , FRAGMENT_DENSITY_PROCESS_BIT_EXT);
        If TestValue(VK_PIPELINE_STAGE_TRANSFORM_FEEDBACK_BIT_EXT)          then Include(Result , TRANSFORM_FEEDBACK_BIT_EXT);
        If TestValue(VK_PIPELINE_STAGE_ACCELERATION_STRUCTURE_BUILD_BIT_KHR) then Include(Result , ACCELERATION_STRUCTURE_BUILD_BIT_KHR);
        If TestValue(VK_PIPELINE_STAGE_ACCELERATION_STRUCTURE_BUILD_BIT_NV) then Include(Result , ACCELERATION_STRUCTURE_BUILD_BIT_NV);
        If TestValue(VK_PIPELINE_STAGE_SHADING_RATE_IMAGE_BIT_NV)           then Include(Result , SHADING_RATE_IMAGE_BIT_NV);
        If TestValue(VK_PIPELINE_STAGE_RAY_TRACING_SHADER_BIT_NV)           then Include(Result , RAY_TRACING_SHADER_BIT_NV);
      End;


      Function GetVKImageLayout(Value: TvgImageLayout) : TVkImageLayout;
      Begin
        Case Value of
           IMAGE_UNDEFINED                            : Result := VK_IMAGE_LAYOUT_UNDEFINED;
           GENERAL                                    : Result := VK_IMAGE_LAYOUT_GENERAL;
           COLOR_ATTACHMENT_OPTIMAL                   : Result := VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL;                               //< Optimal layout when image is only used for color attachment read/write
           DEPTH_STENCIL_ATTACHMENT_OPTIMAL           : Result := VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL;                       //< Optimal layout when image is only used for depth/stencil attachment read/write
           DEPTH_STENCIL_READ_ONLY_OPTIMAL            : Result := VK_IMAGE_LAYOUT_DEPTH_STENCIL_READ_ONLY_OPTIMAL;                        //< Optimal layout when image is used for read only depth/stencil attachment and shader access
           SHADER_READ_ONLY_OPTIMAL                   : Result := VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL;                               //< Optimal layout when image is used for read only shader access
           TRANSFER_SRC_OPTIMAL                       : Result := VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL;                                   //< Optimal layout when image is used only as source of transfer operations
           TRANSFER_DST_OPTIMAL                       : Result := VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL;                                   //< Optimal layout when image is used only as destination of transfer operations
           PREINITIALIZED                             : Result :=VK_IMAGE_LAYOUT_PREINITIALIZED ;                                         //< Initial layout used when the data is populated by the CPU
           PRESENT_SRC_KHR                            : Result := VK_IMAGE_LAYOUT_PRESENT_SRC_KHR;
           VIDEO_DECODE_DST_KHR                       : Result := VK_IMAGE_LAYOUT_VIDEO_DECODE_DST_KHR;
           VIDEO_DECODE_SRC_KHR                       : Result := VK_IMAGE_LAYOUT_VIDEO_DECODE_SRC_KHR;
           VIDEO_DECODE_DPB_KHR                       : Result := VK_IMAGE_LAYOUT_VIDEO_DECODE_DPB_KHR;
           SHARED_PRESENT_KHR                         : Result := VK_IMAGE_LAYOUT_SHARED_PRESENT_KHR;
           DEPTH_READ_ONLY_STENCIL_ATTACHMENT_OPTIMAL : Result := VK_IMAGE_LAYOUT_DEPTH_READ_ONLY_STENCIL_ATTACHMENT_OPTIMAL;
           DEPTH_ATTACHMENT_STENCIL_READ_ONLY_OPTIMAL : Result := VK_IMAGE_LAYOUT_DEPTH_ATTACHMENT_STENCIL_READ_ONLY_OPTIMAL;
           FRAGMENT_SHADING_RATE_ATTACHMENT_OPTIMAL_KHR : Result := VK_IMAGE_LAYOUT_FRAGMENT_SHADING_RATE_ATTACHMENT_OPTIMAL_KHR;
           FRAGMENT_DENSITY_MAP_OPTIMAL_EXT           : Result := VK_IMAGE_LAYOUT_FRAGMENT_DENSITY_MAP_OPTIMAL_EXT;
           DEPTH_ATTACHMENT_OPTIMAL                   : Result := VK_IMAGE_LAYOUT_DEPTH_ATTACHMENT_OPTIMAL;
           DEPTH_READ_ONLY_OPTIMAL                    : Result := VK_IMAGE_LAYOUT_DEPTH_READ_ONLY_OPTIMAL;
           STENCIL_ATTACHMENT_OPTIMAL                 : Result := VK_IMAGE_LAYOUT_STENCIL_ATTACHMENT_OPTIMAL;
           STENCIL_READ_ONLY_OPTIMAL                  : Result := VK_IMAGE_LAYOUT_STENCIL_READ_ONLY_OPTIMAL;
           VIDEO_ENCODE_DST_KHR                       : Result := VK_IMAGE_LAYOUT_VIDEO_ENCODE_DST_KHR;
           VIDEO_ENCODE_SRC_KHR                       : Result := VK_IMAGE_LAYOUT_VIDEO_ENCODE_SRC_KHR;
           VIDEO_ENCODE_DPB_KHR                       : Result := VK_IMAGE_LAYOUT_VIDEO_ENCODE_DPB_KHR;
           READ_ONLY_OPTIMAL_KHR                      : Result := VK_IMAGE_LAYOUT_READ_ONLY_OPTIMAL_KHR;
           ATTACHMENT_OPTIMAL_KHR                     : Result := VK_IMAGE_LAYOUT_ATTACHMENT_OPTIMAL_KHR;
           Else
             Result:= VK_IMAGE_LAYOUT_UNDEFINED;
        End;
      End;
      Function GetVGImageLayout(Value: TVkImageLayout) : TvgImageLayout ;
      Begin
        Case Value of
          VK_IMAGE_LAYOUT_UNDEFINED                                   : Result := IMAGE_UNDEFINED;
          VK_IMAGE_LAYOUT_GENERAL                                     : Result := GENERAL;
          VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL                    : Result := COLOR_ATTACHMENT_OPTIMAL;                               //< Optimal layout when image is only used for color attachment read/write
          VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL            : Result := DEPTH_STENCIL_ATTACHMENT_OPTIMAL;                       //< Optimal layout when image is only used for depth/stencil attachment read/write
          VK_IMAGE_LAYOUT_DEPTH_STENCIL_READ_ONLY_OPTIMAL             : Result := DEPTH_STENCIL_READ_ONLY_OPTIMAL;                        //< Optimal layout when image is used for read only depth/stencil attachment and shader access
          VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL                    : Result := SHADER_READ_ONLY_OPTIMAL;                               //< Optimal layout when image is used for read only shader access
          VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL                        : Result := TRANSFER_SRC_OPTIMAL;                                   //< Optimal layout when image is used only as source of transfer operations
          VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL                        : Result := TRANSFER_DST_OPTIMAL;                                   //< Optimal layout when image is used only as destination of transfer operations
          VK_IMAGE_LAYOUT_PREINITIALIZED                              : Result := PREINITIALIZED;                                         //< Initial layout used when the data is populated by the CPU
          VK_IMAGE_LAYOUT_PRESENT_SRC_KHR                             : Result := PRESENT_SRC_KHR;
          VK_IMAGE_LAYOUT_VIDEO_DECODE_DST_KHR                        : Result := VIDEO_DECODE_DST_KHR;
          VK_IMAGE_LAYOUT_VIDEO_DECODE_SRC_KHR                        : Result := VIDEO_DECODE_SRC_KHR;
          VK_IMAGE_LAYOUT_VIDEO_DECODE_DPB_KHR                        : Result := VIDEO_DECODE_DPB_KHR;
          VK_IMAGE_LAYOUT_SHARED_PRESENT_KHR                          : Result := SHARED_PRESENT_KHR;
          VK_IMAGE_LAYOUT_DEPTH_READ_ONLY_STENCIL_ATTACHMENT_OPTIMAL  : Result := DEPTH_READ_ONLY_STENCIL_ATTACHMENT_OPTIMAL;
          VK_IMAGE_LAYOUT_DEPTH_ATTACHMENT_STENCIL_READ_ONLY_OPTIMAL  : Result := DEPTH_ATTACHMENT_STENCIL_READ_ONLY_OPTIMAL;
          VK_IMAGE_LAYOUT_FRAGMENT_SHADING_RATE_ATTACHMENT_OPTIMAL_KHR  : Result := FRAGMENT_SHADING_RATE_ATTACHMENT_OPTIMAL_KHR;
          VK_IMAGE_LAYOUT_FRAGMENT_DENSITY_MAP_OPTIMAL_EXT            : Result := FRAGMENT_DENSITY_MAP_OPTIMAL_EXT;
          VK_IMAGE_LAYOUT_DEPTH_ATTACHMENT_OPTIMAL                    : Result := DEPTH_ATTACHMENT_OPTIMAL;
          VK_IMAGE_LAYOUT_DEPTH_READ_ONLY_OPTIMAL                     : Result := DEPTH_READ_ONLY_OPTIMAL;
          VK_IMAGE_LAYOUT_STENCIL_ATTACHMENT_OPTIMAL                  : Result := STENCIL_ATTACHMENT_OPTIMAL;
          VK_IMAGE_LAYOUT_STENCIL_READ_ONLY_OPTIMAL                   : Result := STENCIL_READ_ONLY_OPTIMAL;
          VK_IMAGE_LAYOUT_VIDEO_ENCODE_DST_KHR                        : Result := VIDEO_ENCODE_DST_KHR;
          VK_IMAGE_LAYOUT_VIDEO_ENCODE_SRC_KHR                        : Result := VIDEO_ENCODE_SRC_KHR;
          VK_IMAGE_LAYOUT_VIDEO_ENCODE_DPB_KHR                         : Result := VIDEO_ENCODE_DPB_KHR;
          VK_IMAGE_LAYOUT_READ_ONLY_OPTIMAL_KHR                       : Result := READ_ONLY_OPTIMAL_KHR;
          VK_IMAGE_LAYOUT_ATTACHMENT_OPTIMAL_KHR                      : Result := ATTACHMENT_OPTIMAL_KHR;
           Else
             Result:= IMAGE_UNDEFINED;
        End;
      End;


      Function GetVKLOadOp(Value: TvgAttachmentLoadOp) : TVkAttachmentLoadOp;
      Begin
        Case Value of
          LOAD_OP_LOAD      : Result :=  VK_ATTACHMENT_LOAD_OP_LOAD;
          LOAD_OP_CLEAR     : Result :=  VK_ATTACHMENT_LOAD_OP_CLEAR;
          LOAD_OP_DONT_CARE : Result :=  VK_ATTACHMENT_LOAD_OP_DONT_CARE;
           Else
             Result:= VK_ATTACHMENT_LOAD_OP_DONT_CARE;

        End;
      End;
      Function GetVGLoadOp(Value: TVkAttachmentLoadOp) : TvgAttachmentLoadOp ;
      Begin
        Case Value of
          VK_ATTACHMENT_LOAD_OP_LOAD       : Result :=  LOAD_OP_LOAD;
          VK_ATTACHMENT_LOAD_OP_CLEAR      : Result :=  LOAD_OP_CLEAR;
          VK_ATTACHMENT_LOAD_OP_DONT_CARE  : Result :=  LOAD_OP_DONT_CARE;
           Else
             Result:= LOAD_OP_DONT_CARE;
        End;
      End;

      Function GetVKStoreOp(Value: TvgAttachmentStoreOp) : TVkAttachmentStoreOp;
      Begin
        Case Value of
           STORE_OP_STORE     : Result :=  VK_ATTACHMENT_STORE_OP_STORE;
           STORE_OP_DONT_CARE : Result :=  VK_ATTACHMENT_STORE_OP_DONT_CARE;
           STORE_OP_NONE_QCOM : Result :=  VK_ATTACHMENT_STORE_OP_NONE_QCOM;
           Else
             Result:= VK_ATTACHMENT_STORE_OP_DONT_CARE;
        End;
      End;
      Function GetVGStoreOp(Value: TVkAttachmentStoreOp) : TvgAttachmentStoreOp ;
      Begin
        Case Value of
          VK_ATTACHMENT_STORE_OP_STORE      : Result :=  STORE_OP_STORE;
          VK_ATTACHMENT_STORE_OP_DONT_CARE  : Result :=  STORE_OP_DONT_CARE;
          VK_ATTACHMENT_STORE_OP_NONE_QCOM  : Result :=  STORE_OP_NONE_QCOM;
           Else
             Result:= STORE_OP_DONT_CARE;
        End;
      End;


      Function GetVKColorComponent(Value: TvgColorComponentFlagBits) : TVkColorComponentFlags;
      Begin
        Result:=0;
        If (R_BIT in Value)  then Result:= Result OR TVkColorComponentFlags(VK_COLOR_COMPONENT_R_BIT);
        If (G_BIT in Value)  then Result:= Result OR TVkColorComponentFlags(VK_COLOR_COMPONENT_G_BIT);
        If (B_BIT in Value)  then Result:= Result OR TVkColorComponentFlags(VK_COLOR_COMPONENT_B_BIT);
        If (A_BIT in Value)  then Result:= Result OR TVkColorComponentFlags(VK_COLOR_COMPONENT_A_BIT);

      End;
      Function GetVGColorComponent(Value: TVkColorComponentFlags) : TvgColorComponentFlagBits ;
        Function TestValue(TestVal: TVkColorComponentFlagBits):Boolean;
        Begin
          Result:= ((Value and TVkColorComponentFlags(TestVal)) = TVkColorComponentFlags(TestVal));
        End;
      Begin
        Result:=[];

        If TestValue(VK_COLOR_COMPONENT_R_BIT)               then Include(Result , R_BIT);
        If TestValue(VK_COLOR_COMPONENT_G_BIT)               then Include(Result , G_BIT);
        If TestValue(VK_COLOR_COMPONENT_B_BIT)               then Include(Result , B_BIT);
        If TestValue(VK_COLOR_COMPONENT_A_BIT)               then Include(Result , A_BIT);
      End;

      Function GetVKBlendOp(Value: TvgBlendOp) : TVkBlendOp;
      Begin
        Case Value of
             BO_ADD                     : Result := VK_BLEND_OP_ADD;
             BO_SUBTRACT                : Result := VK_BLEND_OP_SUBTRACT;
             BO_REVERSE_SUBTRACT        : Result := VK_BLEND_OP_REVERSE_SUBTRACT;
             BO_MIN                     : Result := VK_BLEND_OP_MIN;
             BO_MAX                     : Result := VK_BLEND_OP_MAX;
             BO_ZERO_EXT                : Result := VK_BLEND_OP_ZERO_EXT;
             BO_SRC_EXT                 : Result := VK_BLEND_OP_SRC_EXT;
             BO_DST_EXT                 : Result := VK_BLEND_OP_DST_EXT;
             BO_SRC_OVER_EXT            : Result := VK_BLEND_OP_SRC_OVER_EXT;
             BO_DST_OVER_EXT            : Result := VK_BLEND_OP_DST_OVER_EXT;
             BO_SRC_IN_EXT              : Result := VK_BLEND_OP_SRC_IN_EXT;
             BO_DST_IN_EXT              : Result := VK_BLEND_OP_DST_IN_EXT;
             BO_SRC_OUT_EXT             : Result := VK_BLEND_OP_SRC_OUT_EXT;
             BO_DST_OUT_EXT             : Result := VK_BLEND_OP_DST_OUT_EXT;
             BO_SRC_ATOP_EXT            : Result := VK_BLEND_OP_SRC_ATOP_EXT;
             BO_DST_ATOP_EXT            : Result := VK_BLEND_OP_DST_ATOP_EXT;
             BO_XOR_EXT                 : Result := VK_BLEND_OP_XOR_EXT;
             BO_MULTIPLY_EXT            : Result := VK_BLEND_OP_MULTIPLY_EXT;
             BO_SCREEN_EXT              : Result := VK_BLEND_OP_SCREEN_EXT;
             BO_OVERLAY_EXT             : Result := VK_BLEND_OP_OVERLAY_EXT;
             BO_DARKEN_EXT              : Result := VK_BLEND_OP_DARKEN_EXT;
             BO_LIGHTEN_EXT             : Result := VK_BLEND_OP_LIGHTEN_EXT;
             BO_COLORDODGE_EXT          : Result := VK_BLEND_OP_COLORDODGE_EXT;
             BO_COLORBURN_EXT           : Result := VK_BLEND_OP_COLORBURN_EXT;
             BO_HARDLIGHT_EXT           : Result := VK_BLEND_OP_HARDLIGHT_EXT;
             BO_SOFTLIGHT_EXT           : Result := VK_BLEND_OP_SOFTLIGHT_EXT;
             BO_DIFFERENCE_EXT          : Result := VK_BLEND_OP_DIFFERENCE_EXT;
             BO_EXCLUSION_EXT           : Result := VK_BLEND_OP_EXCLUSION_EXT;
             BO_INVERT_EXT              : Result := VK_BLEND_OP_INVERT_EXT;
             BO_INVERT_RGB_EXT          : Result := VK_BLEND_OP_INVERT_RGB_EXT;
             BO_LINEARDODGE_EXT         : Result := VK_BLEND_OP_LINEARDODGE_EXT;
             BO_LINEARBURN_EXT          : Result := VK_BLEND_OP_LINEARBURN_EXT;
             BO_VIVIDLIGHT_EXT          : Result := VK_BLEND_OP_VIVIDLIGHT_EXT;
             BO_LINEARLIGHT_EXT         : Result := VK_BLEND_OP_LINEARLIGHT_EXT;
             BO_PINLIGHT_EXT            : Result := VK_BLEND_OP_PINLIGHT_EXT;
             BO_HARDMIX_EXT             : Result := VK_BLEND_OP_HARDMIX_EXT;
             BO_HSL_HUE_EXT             : Result := VK_BLEND_OP_HSL_HUE_EXT;
             BO_HSL_SATURATION_EXT      : Result := VK_BLEND_OP_HSL_SATURATION_EXT;
             BO_HSL_COLOR_EXT           : Result := VK_BLEND_OP_HSL_COLOR_EXT;
             BO_HSL_LUMINOSITY_EXT      : Result := VK_BLEND_OP_HSL_LUMINOSITY_EXT;
             BO_PLUS_EXT                : Result := VK_BLEND_OP_PLUS_EXT;
             BO_PLUS_CLAMPED_EXT        : Result := VK_BLEND_OP_PLUS_CLAMPED_EXT;
             BO_PLUS_CLAMPED_ALPHA_EXT  : Result := VK_BLEND_OP_PLUS_CLAMPED_ALPHA_EXT;
             BO_PLUS_DARKER_EXT         : Result := VK_BLEND_OP_PLUS_DARKER_EXT;
             BO_MINUS_EXT               : Result := VK_BLEND_OP_MINUS_EXT;
             BO_MINUS_CLAMPED_EXT       : Result := VK_BLEND_OP_MINUS_CLAMPED_EXT;
             BO_CONTRAST_EXT            : Result := VK_BLEND_OP_CONTRAST_EXT;
             BO_INVERT_OVG_EXT          : Result := VK_BLEND_OP_INVERT_OVG_EXT;
             BO_RED_EXT                 : Result := VK_BLEND_OP_RED_EXT;
             BO_GREEN_EXT               : Result := VK_BLEND_OP_GREEN_EXT;
             BO_BLUE_EXT                : Result := VK_BLEND_OP_BLUE_EXT;
             Else
               Result:=   VK_BLEND_OP_ADD;
        End;
      End;
      Function GetVGBlendOp(Value: TVkBlendOp) : TvgBlendOp ;
      Begin
        Case Value of
          VK_BLEND_OP_ADD                        : Result := BO_ADD;
          VK_BLEND_OP_SUBTRACT                   : Result := BO_SUBTRACT;
          VK_BLEND_OP_REVERSE_SUBTRACT           : Result := BO_REVERSE_SUBTRACT;
          VK_BLEND_OP_MIN                        : Result := BO_MIN;
          VK_BLEND_OP_MAX                        : Result := BO_MAX;
          VK_BLEND_OP_ZERO_EXT                   : Result := BO_ZERO_EXT;
          VK_BLEND_OP_SRC_EXT                    : Result := BO_SRC_EXT;
          VK_BLEND_OP_DST_EXT                    : Result := BO_DST_EXT;
          VK_BLEND_OP_SRC_OVER_EXT               : Result := BO_SRC_OVER_EXT;
          VK_BLEND_OP_DST_OVER_EXT               : Result := BO_DST_OVER_EXT;
          VK_BLEND_OP_SRC_IN_EXT                 : Result := BO_SRC_IN_EXT;
          VK_BLEND_OP_DST_IN_EXT                 : Result := BO_DST_IN_EXT;
          VK_BLEND_OP_SRC_OUT_EXT                : Result := BO_SRC_OUT_EXT;
          VK_BLEND_OP_DST_OUT_EXT                : Result := BO_DST_OUT_EXT;
          VK_BLEND_OP_SRC_ATOP_EXT               : Result := BO_SRC_ATOP_EXT;
          VK_BLEND_OP_DST_ATOP_EXT               : Result := BO_DST_ATOP_EXT;
          VK_BLEND_OP_XOR_EXT                    : Result := BO_XOR_EXT;
          VK_BLEND_OP_MULTIPLY_EXT               : Result := BO_MULTIPLY_EXT;
          VK_BLEND_OP_SCREEN_EXT                 : Result := BO_SCREEN_EXT;
          VK_BLEND_OP_OVERLAY_EXT                : Result := BO_OVERLAY_EXT;
          VK_BLEND_OP_DARKEN_EXT                 : Result := BO_DARKEN_EXT;
          VK_BLEND_OP_LIGHTEN_EXT                : Result := BO_LIGHTEN_EXT;
          VK_BLEND_OP_COLORDODGE_EXT             : Result := BO_COLORDODGE_EXT;
          VK_BLEND_OP_COLORBURN_EXT              : Result := BO_COLORBURN_EXT;
          VK_BLEND_OP_HARDLIGHT_EXT              : Result := BO_HARDLIGHT_EXT;
          VK_BLEND_OP_SOFTLIGHT_EXT              : Result := BO_SOFTLIGHT_EXT;
          VK_BLEND_OP_DIFFERENCE_EXT             : Result := BO_DIFFERENCE_EXT;
          VK_BLEND_OP_EXCLUSION_EXT              : Result := BO_EXCLUSION_EXT;
          VK_BLEND_OP_INVERT_EXT                 : Result := BO_INVERT_EXT;
          VK_BLEND_OP_INVERT_RGB_EXT             : Result := BO_INVERT_RGB_EXT;
          VK_BLEND_OP_LINEARDODGE_EXT            : Result := BO_LINEARDODGE_EXT;
          VK_BLEND_OP_LINEARBURN_EXT             : Result := BO_LINEARBURN_EXT;
          VK_BLEND_OP_VIVIDLIGHT_EXT             : Result := BO_VIVIDLIGHT_EXT;
          VK_BLEND_OP_LINEARLIGHT_EXT            : Result := BO_LINEARLIGHT_EXT;
          VK_BLEND_OP_PINLIGHT_EXT               : Result := BO_PINLIGHT_EXT;
          VK_BLEND_OP_HARDMIX_EXT                : Result := BO_HARDMIX_EXT;
          VK_BLEND_OP_HSL_HUE_EXT                : Result := BO_HSL_HUE_EXT;
          VK_BLEND_OP_HSL_SATURATION_EXT         : Result := BO_HSL_SATURATION_EXT;
          VK_BLEND_OP_HSL_COLOR_EXT              : Result := BO_HSL_COLOR_EXT;
          VK_BLEND_OP_HSL_LUMINOSITY_EXT         : Result := BO_HSL_LUMINOSITY_EXT;
          VK_BLEND_OP_PLUS_EXT                   : Result := BO_PLUS_EXT;
          VK_BLEND_OP_PLUS_CLAMPED_EXT           : Result := BO_PLUS_CLAMPED_EXT;
          VK_BLEND_OP_PLUS_CLAMPED_ALPHA_EXT     : Result := BO_PLUS_CLAMPED_ALPHA_EXT;
          VK_BLEND_OP_PLUS_DARKER_EXT            : Result := BO_PLUS_DARKER_EXT;
          VK_BLEND_OP_MINUS_EXT                  : Result := BO_MINUS_EXT;
          VK_BLEND_OP_MINUS_CLAMPED_EXT          : Result := BO_MINUS_CLAMPED_EXT;
          VK_BLEND_OP_CONTRAST_EXT               : Result := BO_CONTRAST_EXT;
          VK_BLEND_OP_INVERT_OVG_EXT             : Result := BO_INVERT_OVG_EXT;
          VK_BLEND_OP_RED_EXT                    : Result := BO_RED_EXT;
          VK_BLEND_OP_GREEN_EXT                  : Result := BO_GREEN_EXT;
          VK_BLEND_OP_BLUE_EXT                   : Result := BO_BLUE_EXT;
             Else
               Result:=   BO_ADD;

        End;
      End;

      Function GetVKBlendFactor(Value: TvgBlendFactor) : TVkBlendFactor;
      Begin
        Case Value of
             BF_ZERO                      : Result := VK_BLEND_FACTOR_ZERO;
             BF_ONE                       : Result := VK_BLEND_FACTOR_ONE;
             BF_SRC_COLOR                 : Result := VK_BLEND_FACTOR_SRC_COLOR;
             BF_ONE_MINUS_SRC_COLOR       : Result := VK_BLEND_FACTOR_ONE_MINUS_SRC_COLOR;
             BF_DST_COLOR                 : Result := VK_BLEND_FACTOR_DST_COLOR;
             BF_ONE_MINUS_DST_COLOR       : Result := VK_BLEND_FACTOR_ONE_MINUS_DST_COLOR;
             BF_SRC_ALPHA                 : Result := VK_BLEND_FACTOR_SRC_ALPHA;
             BF_ONE_MINUS_SRC_ALPHA       : Result := VK_BLEND_FACTOR_ONE_MINUS_SRC_ALPHA;
             BF_DST_ALPHA                 : Result := VK_BLEND_FACTOR_DST_ALPHA ;
             BF_ONE_MINUS_DST_ALPHA       : Result := VK_BLEND_FACTOR_ONE_MINUS_DST_ALPHA;
             BF_CONSTANT_COLOR            : Result := VK_BLEND_FACTOR_CONSTANT_COLOR;
             BF_ONE_MINUS_CONSTANT_COLOR  : Result := VK_BLEND_FACTOR_ONE_MINUS_CONSTANT_COLOR;
             BF_CONSTANT_ALPHA            : Result := VK_BLEND_FACTOR_CONSTANT_ALPHA;
             BF_ONE_MINUS_CONSTANT_ALPHA  : Result := VK_BLEND_FACTOR_ONE_MINUS_CONSTANT_ALPHA;
             BF_SRC_ALPHA_SATURATE        : Result := VK_BLEND_FACTOR_SRC_ALPHA_SATURATE;
             BF_SRC1_COLOR                : Result := VK_BLEND_FACTOR_SRC1_COLOR;
             BF_ONE_MINUS_SRC1_COLOR      : Result := VK_BLEND_FACTOR_ONE_MINUS_SRC1_COLOR;
             BF_SRC1_ALPHA                : Result := VK_BLEND_FACTOR_SRC1_ALPHA;
             BF_ONE_MINUS_SRC1_ALPHA      : Result := VK_BLEND_FACTOR_ONE_MINUS_SRC1_ALPHA;
           Else
             Result:=  VK_BLEND_FACTOR_ZERO;
        End;
      End;
      Function GetVGBlendFactor(Value: TVkBlendFactor) : TvgBlendFactor ;
      Begin
        Case Value of
          VK_BLEND_FACTOR_ZERO                         : Result := BF_ZERO;
          VK_BLEND_FACTOR_ONE                          : Result := BF_ONE;
          VK_BLEND_FACTOR_SRC_COLOR                    : Result := BF_SRC_COLOR;
          VK_BLEND_FACTOR_ONE_MINUS_SRC_COLOR          : Result := BF_ONE_MINUS_SRC_COLOR;
          VK_BLEND_FACTOR_DST_COLOR                    : Result := BF_DST_COLOR;
          VK_BLEND_FACTOR_ONE_MINUS_DST_COLOR          : Result := BF_ONE_MINUS_DST_COLOR;
          VK_BLEND_FACTOR_SRC_ALPHA                    : Result := BF_SRC_ALPHA;
          VK_BLEND_FACTOR_ONE_MINUS_SRC_ALPHA          : Result := BF_ONE_MINUS_SRC_ALPHA;
          VK_BLEND_FACTOR_DST_ALPHA                    : Result := BF_DST_ALPHA;
          VK_BLEND_FACTOR_ONE_MINUS_DST_ALPHA          : Result := BF_ONE_MINUS_DST_ALPHA;
          VK_BLEND_FACTOR_CONSTANT_COLOR               : Result := BF_CONSTANT_COLOR;
          VK_BLEND_FACTOR_ONE_MINUS_CONSTANT_COLOR     : Result := BF_ONE_MINUS_CONSTANT_COLOR;
          VK_BLEND_FACTOR_CONSTANT_ALPHA               : Result := BF_CONSTANT_ALPHA;
          VK_BLEND_FACTOR_ONE_MINUS_CONSTANT_ALPHA     : Result := BF_ONE_MINUS_CONSTANT_ALPHA;
          VK_BLEND_FACTOR_SRC_ALPHA_SATURATE           : Result := BF_SRC_ALPHA_SATURATE;
          VK_BLEND_FACTOR_SRC1_COLOR                   : Result := BF_SRC1_COLOR;
          VK_BLEND_FACTOR_ONE_MINUS_SRC1_COLOR         : Result := BF_ONE_MINUS_SRC1_COLOR;
          VK_BLEND_FACTOR_SRC1_ALPHA                   : Result := BF_SRC1_ALPHA;
          VK_BLEND_FACTOR_ONE_MINUS_SRC1_ALPHA         : Result := BF_ONE_MINUS_SRC1_ALPHA;
           Else
             Result:=  BF_ZERO;
        End;
      End;

      Function GetVKSampleCountFlagBit(Value: TvgSampleCountFlagBits) : TVkSampleCountFlagBits;
      Begin
        Case Value of
           COUNT_01_BIT  : Result := VK_SAMPLE_COUNT_1_BIT;
           COUNT_02_BIT  : Result := VK_SAMPLE_COUNT_2_BIT;
           COUNT_04_BIT  : Result := VK_SAMPLE_COUNT_4_BIT;
           COUNT_08_BIT  : Result := VK_SAMPLE_COUNT_8_BIT;
           COUNT_16_BIT : Result := VK_SAMPLE_COUNT_16_BIT;
           COUNT_32_BIT : Result := VK_SAMPLE_COUNT_32_BIT;
           COUNT_64_BIT : Result := VK_SAMPLE_COUNT_64_BIT;
           Else
             Result:=  VK_SAMPLE_COUNT_1_BIT;
        End;
      End;
      Function GetVGSampleCountFlagBit(Value: TVkSampleCountFlagBits) : TvgSampleCountFlagBits ;
      Begin
        Case Value of
          VK_SAMPLE_COUNT_1_BIT   : Result := COUNT_01_BIT;
          VK_SAMPLE_COUNT_2_BIT   : Result := COUNT_02_BIT;
          VK_SAMPLE_COUNT_4_BIT   : Result := COUNT_04_BIT;
          VK_SAMPLE_COUNT_8_BIT   : Result := COUNT_08_BIT;
          VK_SAMPLE_COUNT_16_BIT  : Result := COUNT_16_BIT;
          VK_SAMPLE_COUNT_32_BIT  : Result := COUNT_32_BIT;
          VK_SAMPLE_COUNT_64_BIT  : Result := COUNT_64_BIT;
           Else
             Result:=  COUNT_01_BIT;
        End;
      End;

      Function GetVKFrontFace(Value: TvgFrontFace) : TVkFrontFace;
      Begin
        Case Value of
          FF_COUNTER_CLOCKWISE : Result := VK_FRONT_FACE_COUNTER_CLOCKWISE;
          FF_CLOCKWISE         : Result := VK_FRONT_FACE_CLOCKWISE;
          Else
            Result:= VK_FRONT_FACE_COUNTER_CLOCKWISE;
        End;
      End;
      Function GetVGFrontFace(Value: TVkFrontFace) : TvgFrontFace ;
      Begin
        Case Value of
          VK_FRONT_FACE_COUNTER_CLOCKWISE  : Result := FF_COUNTER_CLOCKWISE;
          VK_FRONT_FACE_CLOCKWISE          : Result := FF_CLOCKWISE;
          Else
            Result:= FF_COUNTER_CLOCKWISE;
        End;
      End;

      Function GetVKCullMode(Value: TvgCullMode)     : TVkCullModeFlags;
      Begin
        Case Value of
           CULL_NONE          :Result := TVkCullModeFlags(VK_CULL_MODE_NONE);
           CULL_FRONT         :Result := TVkCullModeFlags(VK_CULL_MODE_FRONT_BIT);
           CULL_BACK          :Result := TVkCullModeFlags(VK_CULL_MODE_BACK_BIT);
           CULL_FRONT_AND_BACK:Result := TVkCullModeFlags(VK_CULL_MODE_FRONT_AND_BACK);
          Else
            Result:= TVkCullModeFlags(VK_CULL_MODE_NONE);
        End;
      End;

      Function GetVGCullMode(Value: TVkCullModeFlags): TvgCullMode ;
        Function TestValue(TestVal: TVkCullModeFlags):Boolean;
        Begin
          Result:= ((Value and TestVal) = TestVal);
        End;
      Begin
        Result:=  CULL_NONE;
        If TestValue(TVkCullModeFlags(VK_CULL_MODE_NONE))           then Result:= CULL_NONE;
        If TestValue(TVkCullModeFlags(VK_CULL_MODE_FRONT_BIT))      then Result:= CULL_FRONT;
        If TestValue(TVkCullModeFlags(VK_CULL_MODE_BACK_BIT))       then Result:= CULL_BACK;
        If TestValue(TVkCullModeFlags(VK_CULL_MODE_FRONT_AND_BACK)) then Result:= CULL_FRONT_AND_BACK;
      End;

      Function GetVKPolygonMode(Value: TvgPolygonMode): TVkPolygonMode;
      Begin
        Case Value of
           POLYGON_FILL         :Result:= VK_POLYGON_MODE_FILL;
           POLYGON_LINE         :Result:= VK_POLYGON_MODE_LINE;
           POLYGON_POINT        :Result:= VK_POLYGON_MODE_POINT;
           POLYGON_RECTANGLE_NV :Result:= VK_POLYGON_MODE_FILL_RECTANGLE_NV;
          Else
            Result:= VK_POLYGON_MODE_FILL;
        End;
      End;

      Function GetVGPolygonMode(Value: TVkPolygonMode): TvgPolygonMode ;
      Begin
        Case Value of
          VK_POLYGON_MODE_FILL               :Result:= POLYGON_FILL;
          VK_POLYGON_MODE_LINE               :Result:= POLYGON_LINE;
          VK_POLYGON_MODE_POINT              :Result:= POLYGON_POINT;
          VK_POLYGON_MODE_FILL_RECTANGLE_NV  :Result:= POLYGON_RECTANGLE_NV;
          Else
            Result:= POLYGON_FILL;
        End;
      End;


      Function GetVKPrimitiveTopology(Value: TvgPrimitiveTopology): TVkPrimitiveTopology;
      Begin
        Case Value of
          POINT_LIST                    : Result := VK_PRIMITIVE_TOPOLOGY_POINT_LIST;
          LINE_LIST                     : Result := VK_PRIMITIVE_TOPOLOGY_LINE_LIST;
          LINE_STRIP                    : Result := VK_PRIMITIVE_TOPOLOGY_LINE_STRIP;
          TRIANGLE_LIST                 : Result := VK_PRIMITIVE_TOPOLOGY_TRIANGLE_LIST;
          TRIANGLE_STRIP                : Result := VK_PRIMITIVE_TOPOLOGY_TRIANGLE_STRIP;
          TRIANGLE_FAN                  : Result := VK_PRIMITIVE_TOPOLOGY_TRIANGLE_FAN;
          LINE_LIST_WITH_ADJACENCY      : Result := VK_PRIMITIVE_TOPOLOGY_LINE_LIST_WITH_ADJACENCY;
          LINE_STRIP_WITH_ADJACENCY     : Result := VK_PRIMITIVE_TOPOLOGY_LINE_STRIP_WITH_ADJACENCY;
          TRIANGLE_LIST_WITH_ADJACENCY  : Result := VK_PRIMITIVE_TOPOLOGY_TRIANGLE_LIST_WITH_ADJACENCY;
          TRIANGLE_STRIP_WITH_ADJACENCY : Result := VK_PRIMITIVE_TOPOLOGY_TRIANGLE_STRIP_WITH_ADJACENCY;
          PATCH_LIST                    : Result := VK_PRIMITIVE_TOPOLOGY_PATCH_LIST;
          else
            Result:= VK_PRIMITIVE_TOPOLOGY_POINT_LIST;
        End;
      End;
      Function GetVGPrimitiveTopology(Value: TVkPrimitiveTopology): TvgPrimitiveTopology ;
      Begin
        Case Value of
        VK_PRIMITIVE_TOPOLOGY_POINT_LIST                      : Result := POINT_LIST;
        VK_PRIMITIVE_TOPOLOGY_LINE_LIST                       : Result := LINE_LIST;
        VK_PRIMITIVE_TOPOLOGY_LINE_STRIP                      : Result := LINE_STRIP;
        VK_PRIMITIVE_TOPOLOGY_TRIANGLE_LIST                   : Result := TRIANGLE_LIST;
        VK_PRIMITIVE_TOPOLOGY_TRIANGLE_STRIP                  : Result := TRIANGLE_STRIP;
        VK_PRIMITIVE_TOPOLOGY_TRIANGLE_FAN                    : Result := TRIANGLE_FAN;
        VK_PRIMITIVE_TOPOLOGY_LINE_LIST_WITH_ADJACENCY        : Result := LINE_LIST_WITH_ADJACENCY;
        VK_PRIMITIVE_TOPOLOGY_LINE_STRIP_WITH_ADJACENCY       : Result := LINE_STRIP_WITH_ADJACENCY;
        VK_PRIMITIVE_TOPOLOGY_TRIANGLE_LIST_WITH_ADJACENCY    : Result := TRIANGLE_LIST_WITH_ADJACENCY;
        VK_PRIMITIVE_TOPOLOGY_TRIANGLE_STRIP_WITH_ADJACENCY   : Result := TRIANGLE_STRIP_WITH_ADJACENCY;
        VK_PRIMITIVE_TOPOLOGY_PATCH_LIST                      : Result := PATCH_LIST;
          else
            Result:= POINT_LIST;
        End;
      End;

      Function GetVKVertexInputRate(Value: TvgVertexInputRate): TVkVertexInputRate;
      Begin
        Case Value of
          IR_VERTEX   :  Result:=  VK_VERTEX_INPUT_RATE_VERTEX;
          IR_INSTANCE :  Result:=  VK_VERTEX_INPUT_RATE_INSTANCE;
          else
            Result:= VK_VERTEX_INPUT_RATE_VERTEX;
        End;
      End;
      Function GetVGVertexInputRate(Value: TVkVertexInputRate): TvgVertexInputRate ;
      Begin
        Case Value of
          VK_VERTEX_INPUT_RATE_VERTEX    :  Result:=  IR_VERTEX;
          VK_VERTEX_INPUT_RATE_INSTANCE  :  Result:=  IR_INSTANCE;
          else
            Result:= IR_VERTEX;
        End;
      End;


      Function GetVKImageViewType(Value: TvgImageViewType): TVkImageViewType;
      Begin
        Case Value of
          IVT_1D         : Result := VK_IMAGE_VIEW_TYPE_1D;
          IVT_2D         : Result := VK_IMAGE_VIEW_TYPE_2D;
          IVT_3D         : Result := VK_IMAGE_VIEW_TYPE_3D;
          IVT_CUBE       : Result := VK_IMAGE_VIEW_TYPE_CUBE;
          IVT_1D_ARRAY   : Result := VK_IMAGE_VIEW_TYPE_1D_ARRAY;
          IVT_2D_ARRAY   : Result := VK_IMAGE_VIEW_TYPE_2D_ARRAY;
          IVT_CUBE_ARRAY : Result := VK_IMAGE_VIEW_TYPE_CUBE_ARRAY;
          else
            Result:= VK_IMAGE_VIEW_TYPE_1D;
        End;
      End;

      Function GetVGImageViewType(Value: TVkImageViewType): TvgImageViewType ;
      Begin
        Case Value of
          VK_IMAGE_VIEW_TYPE_1D         : Result :=   IVT_1D;
          VK_IMAGE_VIEW_TYPE_2D         : Result :=   IVT_2D;
          VK_IMAGE_VIEW_TYPE_3D         : Result :=   IVT_3D;
          VK_IMAGE_VIEW_TYPE_CUBE       : Result :=   IVT_CUBE;
          VK_IMAGE_VIEW_TYPE_1D_ARRAY   : Result :=   IVT_1D_ARRAY;
          VK_IMAGE_VIEW_TYPE_2D_ARRAY   : Result :=   IVT_2D_ARRAY;
          VK_IMAGE_VIEW_TYPE_CUBE_ARRAY : Result :=   IVT_CUBE_ARRAY;
          else
            Result:= IVT_1D;
        End;
      End;

      Function GetVKImageAspectFlags(Value: TvgImageAspectFlagBits): TVkImageAspectFlags;
      Begin
        Result:=0;
        If (IA_COLOR_BIT in Value)                 then Result:= Result OR TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT);
        If (IA_DEPTH_BIT in Value)                 then Result:= Result OR TVkImageAspectFlags(VK_IMAGE_ASPECT_DEPTH_BIT);
        If (IA_STENCIL_BIT in Value)               then Result:= Result OR TVkImageAspectFlags(VK_IMAGE_ASPECT_STENCIL_BIT);
        If (IA_METADATA_BIT in Value)              then Result:= Result OR TVkImageAspectFlags(VK_IMAGE_ASPECT_METADATA_BIT);
        If (IA_PLANE_0_BIT in Value)               then Result:= Result OR TVkImageAspectFlags(VK_IMAGE_ASPECT_PLANE_0_BIT);
        If (IA_PLANE_1_BIT in Value)               then Result:= Result OR TVkImageAspectFlags(VK_IMAGE_ASPECT_PLANE_1_BIT);
        If (IA_PLANE_2_BIT in Value)               then Result:= Result OR TVkImageAspectFlags(VK_IMAGE_ASPECT_PLANE_2_BIT);
        If (IA_MEMORY_PLANE_0_BIT_EXT in Value)    then Result:= Result OR TVkImageAspectFlags(VK_IMAGE_ASPECT_MEMORY_PLANE_0_BIT_EXT);
        If (IA_MEMORY_PLANE_1_BIT_EXT in Value)    then Result:= Result OR TVkImageAspectFlags(VK_IMAGE_ASPECT_MEMORY_PLANE_1_BIT_EXT);
        If (IA_MEMORY_PLANE_2_BIT_EXT in Value)    then Result:= Result OR TVkImageAspectFlags(VK_IMAGE_ASPECT_MEMORY_PLANE_2_BIT_EXT);
        If (IA_MEMORY_PLANE_3_BIT_EXT in Value)    then Result:= Result OR TVkImageAspectFlags(VK_IMAGE_ASPECT_MEMORY_PLANE_3_BIT_EXT);

      End;

      Function GetVGImageAspectFlags(Value: TVkImageAspectFlags):TvgImageAspectFlagBits ;
        Function TestValue(TestVal: TVkImageAspectFlagBits):Boolean;
        Begin
          Result:= ((Value and TVkImageAspectFlags(TestVal)) = TVkImageAspectFlags(TestVal));
        End;
      Begin
        Result:=[];

        If TestValue(VK_IMAGE_ASPECT_COLOR_BIT)               then Include(Result , IA_COLOR_BIT);
        If TestValue(VK_IMAGE_ASPECT_DEPTH_BIT)               then Include(Result , IA_DEPTH_BIT);
        If TestValue(VK_IMAGE_ASPECT_STENCIL_BIT)             then Include(Result , IA_STENCIL_BIT);
        If TestValue(VK_IMAGE_ASPECT_METADATA_BIT)            then Include(Result , IA_METADATA_BIT);
        If TestValue(VK_IMAGE_ASPECT_PLANE_0_BIT)             then Include(Result , IA_PLANE_0_BIT);
        If TestValue(VK_IMAGE_ASPECT_PLANE_1_BIT)             then Include(Result , IA_PLANE_1_BIT);
        If TestValue(VK_IMAGE_ASPECT_PLANE_2_BIT)             then Include(Result , IA_PLANE_2_BIT);
        If TestValue(VK_IMAGE_ASPECT_MEMORY_PLANE_0_BIT_EXT)  then Include(Result , IA_MEMORY_PLANE_0_BIT_EXT);
        If TestValue(VK_IMAGE_ASPECT_MEMORY_PLANE_1_BIT_EXT)  then Include(Result , IA_MEMORY_PLANE_1_BIT_EXT);
        If TestValue(VK_IMAGE_ASPECT_MEMORY_PLANE_2_BIT_EXT)  then Include(Result , IA_MEMORY_PLANE_2_BIT_EXT);
        If TestValue(VK_IMAGE_ASPECT_MEMORY_PLANE_3_BIT_EXT)  then Include(Result , IA_MEMORY_PLANE_3_BIT_EXT);
      End;


      Function GetVKComponentSwizzle(Value: TvgComponentSwizzle): TVkComponentSwizzle;
      Begin
        Case Value of
             CS_IDENTITY: Result := VK_COMPONENT_SWIZZLE_IDENTITY;
             CS_ZERO    : Result := VK_COMPONENT_SWIZZLE_ZERO;
             CS_ONE     : Result := VK_COMPONENT_SWIZZLE_ONE;
             CS_RED     : Result := VK_COMPONENT_SWIZZLE_R;
             CS_GREEN   : Result := VK_COMPONENT_SWIZZLE_G;
             CS_BLUE    : Result := VK_COMPONENT_SWIZZLE_B;
             CS_ALPHA   : Result := VK_COMPONENT_SWIZZLE_A;
          else
            Result:= VK_COMPONENT_SWIZZLE_IDENTITY;
        End;
      End;

      Function GetVGComponentSwizzle(Value: TVkComponentSwizzle):TvgComponentSwizzle ;
      Begin
        Case Value of
            VK_COMPONENT_SWIZZLE_IDENTITY : Result :=  CS_IDENTITY;
            VK_COMPONENT_SWIZZLE_ZERO     : Result :=  CS_ZERO;
            VK_COMPONENT_SWIZZLE_ONE      : Result :=  CS_ONE;
            VK_COMPONENT_SWIZZLE_R        : Result :=  CS_RED;
            VK_COMPONENT_SWIZZLE_G        : Result :=  CS_GREEN;
            VK_COMPONENT_SWIZZLE_B        : Result :=  CS_BLUE;
            VK_COMPONENT_SWIZZLE_A        : Result :=  CS_ALPHA;
          else
            Result:= CS_IDENTITY;
        End;
      End;

      Function GetVKCommandPoolCreateFlags(Value: TVgCommandPoolCreateFlag): TVkCommandPoolCreateFlags;
      Begin
        Result:=0;
        If (CP_TRANSIENT in Value)            then Result:=Result OR TVkCommandPoolCreateFlags(VK_COMMAND_POOL_CREATE_TRANSIENT_BIT);
        If (CP_RESET_COMMAND_BUFFER in Value) then Result:=Result OR TVkCommandPoolCreateFlags(VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT);
        If (CP_PROTECTED in Value)            then Result:=Result OR TVkCommandPoolCreateFlags(VK_COMMAND_POOL_CREATE_PROTECTED_BIT);
      End;

      Function GetVGCommandPoolCreateFlags(Value: TVkCommandPoolCreateFlags):TVgCommandPoolCreateFlag ;
        Function TestValue(TestVal: TVkCommandPoolCreateFlagBits):Boolean;
        Begin
          Result:= ((Value and TVkCommandPoolCreateFlags(TestVal)) = TVkCommandPoolCreateFlags(TestVal));
        End;
      Begin
        Result:=[];

        If TestValue(VK_COMMAND_POOL_CREATE_TRANSIENT_BIT)             then Include(Result , CP_TRANSIENT);
        If TestValue(VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT)  then Include(Result , CP_RESET_COMMAND_BUFFER);
        If TestValue(VK_COMMAND_POOL_CREATE_PROTECTED_BIT)             then Include(Result , CP_PROTECTED);
      End;


      Function GetVKTransform(Value:TVgSurfaceTransformFlagBitsKHRSet):TVkSurfaceTransformFlagsKHR;
      Begin
        Result:=0;
        If (ST_IDENTITY in Value)                     then Result := Result OR TVkSurfaceTransformFlagsKHR(VK_SURFACE_TRANSFORM_IDENTITY_BIT_KHR);
        If (ST_ROTATE_90 in Value)                    then Result := Result OR TVkSurfaceTransformFlagsKHR(VK_SURFACE_TRANSFORM_ROTATE_90_BIT_KHR);
        If (ST_ROTATE_180 in Value)                   then Result := Result OR TVkSurfaceTransformFlagsKHR(VK_SURFACE_TRANSFORM_ROTATE_180_BIT_KHR);
        If (ST_ROTATE_270 in Value)                   then Result := Result OR TVkSurfaceTransformFlagsKHR(VK_SURFACE_TRANSFORM_ROTATE_270_BIT_KHR);
        If (ST_HORIZONTAL_MIRROR in Value)            then Result := Result OR TVkSurfaceTransformFlagsKHR(VK_SURFACE_TRANSFORM_HORIZONTAL_MIRROR_BIT_KHR);
        If (ST_HORIZONTAL_MIRROR_ROTATE_90 in Value)  then Result := Result OR TVkSurfaceTransformFlagsKHR(VK_SURFACE_TRANSFORM_HORIZONTAL_MIRROR_ROTATE_90_BIT_KHR);
        If (ST_HORIZONTAL_MIRROR_ROTATE_180 in Value) then Result := Result OR TVkSurfaceTransformFlagsKHR(VK_SURFACE_TRANSFORM_HORIZONTAL_MIRROR_ROTATE_180_BIT_KHR);
        If (ST_HORIZONTAL_MIRROR_ROTATE_270 in Value) then Result := Result OR TVkSurfaceTransformFlagsKHR(VK_SURFACE_TRANSFORM_HORIZONTAL_MIRROR_ROTATE_270_BIT_KHR);
        If (ST_TRANSFORM_INHERIT in Value)            then Result := Result OR TVkSurfaceTransformFlagsKHR(VK_SURFACE_TRANSFORM_INHERIT_BIT_KHR);

      End;

      Function GetVGTransform(Value:TVkSurfaceTransformFlagsKHR):TVgSurfaceTransformFlagBitsKHRSet;

        Function TestValue(TestVal: TVkSurfaceTransformFlagBitsKHR):Boolean;
        Begin
          Result:= ((Value and TVkSurfaceTransformFlagsKHR(TestVal)) = TVkSurfaceTransformFlagsKHR(TestVal));
        End;

      Begin
        Result:=[];

        If TestValue(VK_SURFACE_TRANSFORM_IDENTITY_BIT_KHR)                     then Include(Result , ST_IDENTITY);
        If TestValue(VK_SURFACE_TRANSFORM_ROTATE_90_BIT_KHR)                    then Include(Result , ST_ROTATE_90);
        If TestValue(VK_SURFACE_TRANSFORM_ROTATE_180_BIT_KHR)                   then Include(Result , ST_ROTATE_180);
        If TestValue(VK_SURFACE_TRANSFORM_ROTATE_270_BIT_KHR)                   then Include(Result , ST_ROTATE_270);
        If TestValue(VK_SURFACE_TRANSFORM_HORIZONTAL_MIRROR_BIT_KHR)            then Include(Result , ST_HORIZONTAL_MIRROR);
        If TestValue(VK_SURFACE_TRANSFORM_HORIZONTAL_MIRROR_ROTATE_90_BIT_KHR)  then Include(Result , ST_HORIZONTAL_MIRROR_ROTATE_90);
        If TestValue(VK_SURFACE_TRANSFORM_HORIZONTAL_MIRROR_ROTATE_180_BIT_KHR) then Include(Result , ST_HORIZONTAL_MIRROR_ROTATE_180);
        If TestValue(VK_SURFACE_TRANSFORM_HORIZONTAL_MIRROR_ROTATE_270_BIT_KHR) then Include(Result , ST_HORIZONTAL_MIRROR_ROTATE_270);
        If TestValue(VK_SURFACE_TRANSFORM_INHERIT_BIT_KHR)                      then Include(Result , ST_TRANSFORM_INHERIT);


      End;

      Function GetVKImageUseFlags(Value:TvgImageUsageFlagsSet):TVkImageUsageFlags;
      Begin
        Result:=0;
        If (IU_TRANSFER_SRC in Value)             then Result := Result OR TVkImageUsageFlags(VK_IMAGE_USAGE_TRANSFER_SRC_BIT);//  Include(Result, VK_IMAGE_USAGE_TRANSFER_SRC_BIT) ;
        If (IU_TRANSFER_DST in Value)             then Result := Result OR TVkImageUsageFlags(VK_IMAGE_USAGE_TRANSFER_DST_BIT);//Include(Result, VK_IMAGE_USAGE_TRANSFER_DST_BIT) ;
        If (IU_SAMPLED in Value)                  then Result := Result OR TVkImageUsageFlags(VK_IMAGE_USAGE_SAMPLED_BIT);//Include(Result, VK_IMAGE_USAGE_SAMPLED_BIT) ;
        If (IU_STORAGE in Value)                  then Result := Result OR TVkImageUsageFlags(VK_IMAGE_USAGE_STORAGE_BIT);//Include(Result, VK_IMAGE_USAGE_STORAGE_BIT) ;
        If (IU_COLOR_ATTACHMENT in Value)         then Result := Result OR TVkImageUsageFlags(VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT);//Include(Result, VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT) ;
        If (IU_DEPTH_STENCIL_ATTACHMENT in Value) then Result := Result OR TVkImageUsageFlags(VK_IMAGE_USAGE_DEPTH_STENCIL_ATTACHMENT_BIT);//Include(Result, VK_IMAGE_USAGE_DEPTH_STENCIL_ATTACHMENT_BIT) ;
        If (IU_TRANSIENT_ATTACHMENT in Value)     then Result := Result OR TVkImageUsageFlags(VK_IMAGE_USAGE_TRANSIENT_ATTACHMENT_BIT);//Include(Result, VK_IMAGE_USAGE_TRANSIENT_ATTACHMENT_BIT) ;
        If (IU_INPUT_ATTACHMENT in Value)         then Result := Result OR TVkImageUsageFlags(VK_IMAGE_USAGE_INPUT_ATTACHMENT_BIT);//Include(Result, VK_IMAGE_USAGE_INPUT_ATTACHMENT_BIT) ;
        If (IU_SHADING_RATE_IMAGE_NV in Value)    then Result := Result OR TVkImageUsageFlags(VK_IMAGE_USAGE_SHADING_RATE_IMAGE_BIT_NV);//Include(Result, VK_IMAGE_USAGE_SHADING_RATE_IMAGE_BIT_NV) ;
        If (IU_FRAGMENT_DENSITY_MAP_EXT in Value) then Result := Result OR TVkImageUsageFlags(VK_IMAGE_USAGE_FRAGMENT_DENSITY_MAP_BIT_EXT);//Include(Result, VK_IMAGE_USAGE_FRAGMENT_DENSITY_MAP_BIT_EXT) ;
      End;

      Function GetVGImageUseFlags(Value: TVkImageUsageFlags):TvgImageUsageFlagsSet;

        Function TestValue(TestVal: TVkImageUsageFlagBits):Boolean;
        Begin
          Result:= ((Value and TVkImageUsageFlags(TestVal)) = TVkImageUsageFlags(TestVal));
        End;

      Begin
        Result := [];

        If TestValue(VK_IMAGE_USAGE_TRANSFER_SRC_BIT)             then Include(Result , IU_TRANSFER_SRC);
        If TestValue(VK_IMAGE_USAGE_TRANSFER_DST_BIT)             then Include(Result , IU_TRANSFER_DST);
        If TestValue(VK_IMAGE_USAGE_SAMPLED_BIT)                  then Include(Result , IU_SAMPLED);
        If TestValue(VK_IMAGE_USAGE_STORAGE_BIT)                  then Include(Result , IU_STORAGE);
        If TestValue(VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT)         then Include(Result , IU_COLOR_ATTACHMENT );
        If TestValue(VK_IMAGE_USAGE_DEPTH_STENCIL_ATTACHMENT_BIT) then Include(Result , IU_DEPTH_STENCIL_ATTACHMENT);
        If TestValue(VK_IMAGE_USAGE_TRANSIENT_ATTACHMENT_BIT)     then Include(Result , IU_TRANSIENT_ATTACHMENT);
        If TestValue(VK_IMAGE_USAGE_INPUT_ATTACHMENT_BIT)         then Include(Result , IU_INPUT_ATTACHMENT);
        If TestValue(VK_IMAGE_USAGE_SHADING_RATE_IMAGE_BIT_NV)    then Include(Result , IU_SHADING_RATE_IMAGE_NV);
        If TestValue(VK_IMAGE_USAGE_FRAGMENT_DENSITY_MAP_BIT_EXT) then Include(Result , IU_FRAGMENT_DENSITY_MAP_EXT);
(*
        If Value and TVkImageUsageFlags(VK_IMAGE_USAGE_RESERVED_10_BIT_KHR) = TVkImageUsageFlags(VK_IMAGE_USAGE_RESERVED_10_BIT_KHR)   then Include(Result , VG_RESERVED_10_BIT_KHR);
        If Value and TVkImageUsageFlags(VK_IMAGE_USAGE_RESERVED_11_BIT_KHR) = TVkImageUsageFlags(VK_IMAGE_USAGE_RESERVED_11_BIT_KHR)   then Include(Result , VG_RESERVED_11_BIT_KHR);
        If Value and TVkImageUsageFlags(VK_IMAGE_USAGE_RESERVED_12_BIT_KHR) = TVkImageUsageFlags(VK_IMAGE_USAGE_RESERVED_12_BIT_KHR)   then Include(Result , VG_RESERVED_12_BIT_KHR);
        If Value and TVkImageUsageFlags(VK_IMAGE_USAGE_RESERVED_13_BIT_KHR) = TVkImageUsageFlags(VK_IMAGE_USAGE_RESERVED_13_BIT_KHR)   then Include(Result , VG_RESERVED_13_BIT_KHR);
        If Value and TVkImageUsageFlags(VK_IMAGE_USAGE_RESERVED_14_BIT_KHR) = TVkImageUsageFlags(VK_IMAGE_USAGE_RESERVED_14_BIT_KHR)   then Include(Result , VG_RESERVED_14_BIT_KHR);
        If Value and TVkImageUsageFlags(VK_IMAGE_USAGE_RESERVED_15_BIT_KHR) = TVkImageUsageFlags(VK_IMAGE_USAGE_RESERVED_15_BIT_KHR)   then Include(Result , VG_RESERVED_15_BIT_KHR);
        If Value and TVkImageUsageFlags(VK_IMAGE_USAGE_RESERVED_16_BIT_QCOM) = TVkImageUsageFlags(VK_IMAGE_USAGE_RESERVED_16_BIT_QCOM) then Include(Result , VG_RESERVED_16_BIT_QCOM);
        If Value and TVkImageUsageFlags(VK_IMAGE_USAGE_RESERVED_17_BIT_QCOM) = TVkImageUsageFlags(VK_IMAGE_USAGE_RESERVED_17_BIT_QCOM) then Include(Result , VG_RESERVED_17_BIT_QCOM);
*)
      End;



      Function GetVKSharingMode(Value:TvgSharingMode):TVKSharingMode;
      Begin
        Case Value of
           SM_EXCLUSIVE  : Result := VK_SHARING_MODE_EXCLUSIVE;
           SM_CONCURRENT : Result := VK_SHARING_MODE_CONCURRENT;
          else
            Result:=  VK_SHARING_MODE_CONCURRENT;
        end;
      End;

      Function GetVGSharingMode(Value:TVKSharingMode):TvgSharingMode;
      Begin
        Case Value of
           VK_SHARING_MODE_EXCLUSIVE  : Result := SM_EXCLUSIVE;
           VK_SHARING_MODE_CONCURRENT : Result := SM_CONCURRENT;
          else
            Result:=  SM_CONCURRENT;
        End;
      end;

      Function GetVKPresentMode(Value:TvgPresentModeKHR):TVKPresentModeKHR;
      Begin
        Case Value of
             PM_IMMEDIATE                : Result := VK_PRESENT_MODE_IMMEDIATE_KHR;
             PM_MAILBOX                  : Result := VK_PRESENT_MODE_MAILBOX_KHR;
             PM_FIFO                     : Result := VK_PRESENT_MODE_FIFO_KHR;
             PM_FIFO_RELAXED             : Result := VK_PRESENT_MODE_FIFO_RELAXED_KHR;
             PM_SHARED_DEMAND_REFRESH    : Result := VK_PRESENT_MODE_SHARED_DEMAND_REFRESH_KHR;
             PM_SHARED_CONTINUOUS_REFRESH: Result := VK_PRESENT_MODE_SHARED_CONTINUOUS_REFRESH_KHR;
           else
             Result:=  VK_PRESENT_MODE_FIFO_KHR; //always available
      End;
      End;

      Function GetVGPresentMode(Value:TVKPresentModeKHR):TvgPresentModeKHR;
      Begin
        Case Value of
             VK_PRESENT_MODE_IMMEDIATE_KHR                : Result := PM_IMMEDIATE;
             VK_PRESENT_MODE_MAILBOX_KHR                  : Result := PM_MAILBOX;
             VK_PRESENT_MODE_FIFO_KHR                     : Result := PM_FIFO;
             VK_PRESENT_MODE_FIFO_RELAXED_KHR             : Result := PM_FIFO_RELAXED;
             VK_PRESENT_MODE_SHARED_DEMAND_REFRESH_KHR    : Result := PM_SHARED_DEMAND_REFRESH;
             VK_PRESENT_MODE_SHARED_CONTINUOUS_REFRESH_KHR: Result := PM_SHARED_CONTINUOUS_REFRESH;
           else
             Result:=  PM_FIFO;      //always available
        end;
      End;

      Function GetVKColorSpace(Value:TvgColorSpaceKHR):TVkColorSpaceKHR;
      Begin
          Case Value of
               SRGB_NONLINEAR_KHR         :  Result := VK_COLOR_SPACE_SRGB_NONLINEAR_KHR  ;
               DISPLAY_P3_NONLINEAR_EXT   :  Result := VK_COLOR_SPACE_DISPLAY_P3_NONLINEAR_EXT ;
               EXTENDED_SRGB_LINEAR_EXT   :  Result := VK_COLOR_SPACE_EXTENDED_SRGB_LINEAR_EXT ;
               DISPLAY_P3_LINEAR_EXT      :  Result := VK_COLOR_SPACE_DISPLAY_P3_LINEAR_EXT ;
               DCI_P3_NONLINEAR_EXT       :  Result := VK_COLOR_SPACE_DCI_P3_NONLINEAR_EXT ;
               BT709_LINEAR_EXT           :  Result := VK_COLOR_SPACE_BT709_LINEAR_EXT ;
               BT709_NONLINEAR_EXT        :  Result := VK_COLOR_SPACE_BT709_NONLINEAR_EXT ;
               BT2020_LINEAR_EXT          :  Result := VK_COLOR_SPACE_BT2020_LINEAR_EXT ;
               HDR10_ST2084_EXT           :  Result := VK_COLOR_SPACE_HDR10_ST2084_EXT ;
               DOLBYVISION_EXT            :  Result := VK_COLOR_SPACE_DOLBYVISION_EXT ;
               HDR10_HLG_EXT              :  Result := VK_COLOR_SPACE_HDR10_HLG_EXT ;
               ADOBERGB_LINEAR_EXT        :  Result := VK_COLOR_SPACE_ADOBERGB_LINEAR_EXT ;
               ADOBERGB_NONLINEAR_EXT     :  Result := VK_COLOR_SPACE_ADOBERGB_NONLINEAR_EXT ;
               PASS_THROUGH_EXT           :  Result := VK_COLOR_SPACE_PASS_THROUGH_EXT ;
               EXTENDED_SRGB_NONLINEAR_EXT:  Result := VK_COLOR_SPACE_EXTENDED_SRGB_NONLINEAR_EXT ;
               DISPLAY_NATIVE_AMD         :  Result := VK_COLOR_SPACE_DISPLAY_NATIVE_AMD ;
            else
              Result := VK_COLOR_SPACE_SRGB_NONLINEAR_KHR;
          End;
      End;

      Function GetVGColorSpace(Value:TVkColorSpaceKHR):TvgColorSpaceKHR;
      Begin
          Case Value of
               VK_COLOR_SPACE_SRGB_NONLINEAR_KHR         :  Result := SRGB_NONLINEAR_KHR  ;
               VK_COLOR_SPACE_DISPLAY_P3_NONLINEAR_EXT   :  Result := DISPLAY_P3_NONLINEAR_EXT ;
               VK_COLOR_SPACE_EXTENDED_SRGB_LINEAR_EXT   :  Result := EXTENDED_SRGB_LINEAR_EXT ;
               VK_COLOR_SPACE_DISPLAY_P3_LINEAR_EXT      :  Result := DISPLAY_P3_LINEAR_EXT ;
               VK_COLOR_SPACE_DCI_P3_NONLINEAR_EXT       :  Result := DCI_P3_NONLINEAR_EXT ;
               VK_COLOR_SPACE_BT709_LINEAR_EXT           :  Result := BT709_LINEAR_EXT ;
               VK_COLOR_SPACE_BT709_NONLINEAR_EXT        :  Result := BT709_NONLINEAR_EXT ;
               VK_COLOR_SPACE_BT2020_LINEAR_EXT          :  Result := BT2020_LINEAR_EXT ;
               VK_COLOR_SPACE_HDR10_ST2084_EXT           :  Result := HDR10_ST2084_EXT ;
               VK_COLOR_SPACE_DOLBYVISION_EXT            :  Result := DOLBYVISION_EXT ;
               VK_COLOR_SPACE_HDR10_HLG_EXT              :  Result := HDR10_HLG_EXT ;
               VK_COLOR_SPACE_ADOBERGB_LINEAR_EXT        :  Result := ADOBERGB_LINEAR_EXT ;
               VK_COLOR_SPACE_ADOBERGB_NONLINEAR_EXT     :  Result := ADOBERGB_NONLINEAR_EXT ;
               VK_COLOR_SPACE_PASS_THROUGH_EXT           :  Result := PASS_THROUGH_EXT ;
               VK_COLOR_SPACE_EXTENDED_SRGB_NONLINEAR_EXT:  Result := EXTENDED_SRGB_NONLINEAR_EXT ;
               VK_COLOR_SPACE_DISPLAY_NATIVE_AMD         :  Result := DISPLAY_NATIVE_AMD ;
            else
              Result := SRGB_NONLINEAR_KHR;
          End;
      End;

      Function GetVKFormat(Value:TvgFormat):TVkFormat;
      Begin
        Case Value of
             UNDEFINED                  : Result := VK_FORMAT_UNDEFINED;
             R4G4_UNORM_PACK8           : Result := VK_FORMAT_R4G4_UNORM_PACK8;
             R4G4B4A4_UNORM_PACK16      : Result := VK_FORMAT_R4G4B4A4_UNORM_PACK16;
             B4G4R4A4_UNORM_PACK16      : Result := VK_FORMAT_B4G4R4A4_UNORM_PACK16;
             R5G6B5_UNORM_PACK16        : Result := VK_FORMAT_R5G6B5_UNORM_PACK16;
             B5G6R5_UNORM_PACK16        : Result := VK_FORMAT_B5G6R5_UNORM_PACK16;
             R5G5B5A1_UNORM_PACK16      : Result := VK_FORMAT_R5G5B5A1_UNORM_PACK16;
             B5G5R5A1_UNORM_PACK16      : Result := VK_FORMAT_B5G5R5A1_UNORM_PACK16;
             A1R5G5B5_UNORM_PACK16      : Result := VK_FORMAT_A1R5G5B5_UNORM_PACK16;
             R8_UNORM                   : Result := VK_FORMAT_R8_UNORM;
             R8_SNORM                   : Result := VK_FORMAT_R8_SNORM;
             R8_USCALED                 : Result := VK_FORMAT_R8_USCALED;
             R8_SSCALED                 : Result := VK_FORMAT_R8_SSCALED;
             R8_UINT                    : Result := VK_FORMAT_R8_UINT;
             R8_SINT                    : Result := VK_FORMAT_R8_SINT;
             R8_SRGB                    : Result := VK_FORMAT_R8_SRGB;
             R8G8_UNORM                 : Result := VK_FORMAT_R8G8_UNORM;
             R8G8_SNORM                 : Result := VK_FORMAT_R8G8_SNORM;
             R8G8_USCALED               : Result := VK_FORMAT_R8G8_USCALED;
             R8G8_SSCALED               : Result := VK_FORMAT_R8G8_SSCALED;
             R8G8_UINT                  : Result := VK_FORMAT_R8G8_UINT;
             R8G8_SINT                  : Result := VK_FORMAT_R8G8_SINT;
             R8G8_SRGB                  : Result := VK_FORMAT_R8G8_SRGB;
             R8G8B8_UNORM               : Result := VK_FORMAT_R8G8B8_UNORM;
             R8G8B8_SNORM               : Result := VK_FORMAT_R8G8B8_SNORM;
             R8G8B8_USCALED             : Result := VK_FORMAT_R8G8B8_USCALED;
             R8G8B8_SSCALED             : Result := VK_FORMAT_R8G8B8_SSCALED;
             R8G8B8_UINT                : Result := VK_FORMAT_R8G8B8_UINT;
             R8G8B8_SINT                : Result := VK_FORMAT_R8G8B8_SINT;
             R8G8B8_SRGB                : Result := VK_FORMAT_B8G8R8_UNORM;
             B8G8R8_UNORM               : Result := VK_FORMAT_B8G8R8_UNORM;
             B8G8R8_SNORM               : Result := VK_FORMAT_B8G8R8_SNORM;
             B8G8R8_USCALED             : Result := VK_FORMAT_B8G8R8_USCALED;
             B8G8R8_SSCALED             : Result := VK_FORMAT_B8G8R8_SSCALED;
             B8G8R8_UINT                : Result := VK_FORMAT_B8G8R8_UINT;
             B8G8R8_SINT                : Result := VK_FORMAT_B8G8R8_SINT;
             B8G8R8_SRGB                : Result := VK_FORMAT_B8G8R8_SRGB;
             R8G8B8A8_UNORM             : Result := VK_FORMAT_R8G8B8A8_UNORM;
             R8G8B8A8_SNORM             : Result := VK_FORMAT_R8G8B8A8_SNORM;
             R8G8B8A8_USCALED           : Result := VK_FORMAT_R8G8B8A8_USCALED;
             R8G8B8A8_SSCALED           : Result := VK_FORMAT_R8G8B8A8_SSCALED;
             R8G8B8A8_UINT              : Result := VK_FORMAT_R8G8B8A8_UINT;
             R8G8B8A8_SINT              : Result := VK_FORMAT_R8G8B8A8_SINT;
             R8G8B8A8_SRGB              : Result := VK_FORMAT_R8G8B8A8_SRGB;
             B8G8R8A8_UNORM             : Result := VK_FORMAT_B8G8R8A8_UNORM;
             B8G8R8A8_SNORM             : Result := VK_FORMAT_B8G8R8A8_SNORM;
             B8G8R8A8_USCALED           : Result := VK_FORMAT_B8G8R8A8_USCALED;
             B8G8R8A8_SSCALED           : Result := VK_FORMAT_B8G8R8A8_SSCALED;
             B8G8R8A8_UINT              : Result := VK_FORMAT_B8G8R8A8_UINT;
             B8G8R8A8_SINT              : Result := VK_FORMAT_B8G8R8A8_SINT;
             B8G8R8A8_SRGB              : Result := VK_FORMAT_B8G8R8A8_SRGB;
             A8B8G8R8_UNORM_PACK32      : Result := VK_FORMAT_A8B8G8R8_UNORM_PACK32;
             A8B8G8R8_SNORM_PACK32      : Result := VK_FORMAT_A8B8G8R8_SNORM_PACK32;
             A8B8G8R8_USCALED_PACK32    : Result := VK_FORMAT_A8B8G8R8_USCALED_PACK32;
             A8B8G8R8_SSCALED_PACK32    : Result := VK_FORMAT_A8B8G8R8_SSCALED_PACK32;
             A8B8G8R8_UINT_PACK32       : Result := VK_FORMAT_A8B8G8R8_UINT_PACK32;
             A8B8G8R8_SINT_PACK32       : Result := VK_FORMAT_A8B8G8R8_SINT_PACK32;
             A8B8G8R8_SRGB_PACK32       : Result := VK_FORMAT_A8B8G8R8_SRGB_PACK32;
             A2R10G10B10_UNORM_PACK32   : Result := VK_FORMAT_A2R10G10B10_UNORM_PACK32;
             A2R10G10B10_SNORM_PACK32   : Result := VK_FORMAT_A2R10G10B10_SNORM_PACK32;
             A2R10G10B10_USCALED_PACK32 : Result := VK_FORMAT_A2R10G10B10_USCALED_PACK32;
             A2R10G10B10_SSCALED_PACK32 : Result := VK_FORMAT_A2R10G10B10_SSCALED_PACK32;
             A2R10G10B10_UINT_PACK32    : Result := VK_FORMAT_A2R10G10B10_UINT_PACK32;
             A2R10G10B10_SINT_PACK32    : Result := VK_FORMAT_A2R10G10B10_SINT_PACK32;
             A2B10G10R10_UNORM_PACK32   : Result := VK_FORMAT_A2B10G10R10_UNORM_PACK32;
             A2B10G10R10_SNORM_PACK32   : Result := VK_FORMAT_A2B10G10R10_SNORM_PACK32;
             A2B10G10R10_USCALED_PACK32 : Result := VK_FORMAT_A2B10G10R10_USCALED_PACK32;
             A2B10G10R10_SSCALED_PACK32 : Result := VK_FORMAT_A2B10G10R10_SSCALED_PACK32;
             A2B10G10R10_UINT_PACK32    : Result := VK_FORMAT_A2B10G10R10_UINT_PACK32;
             A2B10G10R10_SINT_PACK32    : Result := VK_FORMAT_A2B10G10R10_SINT_PACK32;
             R16_UNORM                  : Result := VK_FORMAT_R16_UNORM;
             R16_SNORM                  : Result := VK_FORMAT_R16_SNORM;
             R16_USCALED                : Result := VK_FORMAT_R16_USCALED;
             R16_SSCALED                : Result := VK_FORMAT_R16_SSCALED;
             R16_UINT                   : Result := VK_FORMAT_R16_UINT;
             R16_SINT                   : Result := VK_FORMAT_R16_SINT;
             R16_SFLOAT                 : Result := VK_FORMAT_R16_SFLOAT;
             R16G16_UNORM               : Result := VK_FORMAT_R16G16_UNORM;
             R16G16_SNORM               : Result := VK_FORMAT_R16G16_SNORM;
             R16G16_USCALED             : Result := VK_FORMAT_R16G16_USCALED;
             R16G16_SSCALED             : Result := VK_FORMAT_R16G16_SSCALED;
             R16G16_UINT                : Result := VK_FORMAT_R16G16_UINT;
             R16G16_SINT                : Result := VK_FORMAT_R16G16_SINT;
             R16G16_SFLOAT              : Result := VK_FORMAT_R16G16_SFLOAT;
             R16G16B16_UNORM            : Result := VK_FORMAT_R16G16B16_UNORM;
             R16G16B16_SNORM            : Result := VK_FORMAT_R16G16B16_SNORM;
             R16G16B16_USCALED          : Result := VK_FORMAT_R16G16B16_USCALED;
             R16G16B16_SSCALED          : Result := VK_FORMAT_R16G16B16_SSCALED;
             R16G16B16_UINT             : Result := VK_FORMAT_R16G16B16_UINT;
             R16G16B16_SINT             : Result := VK_FORMAT_R16G16B16_SINT;
             R16G16B16_SFLOAT           : Result := VK_FORMAT_R16G16B16_SFLOAT;
             R16G16B16A16_UNORM         : Result := VK_FORMAT_R16G16B16A16_UNORM;
             R16G16B16A16_SNORM         : Result := VK_FORMAT_R16G16B16A16_SNORM;
             R16G16B16A16_USCALED       : Result := VK_FORMAT_R16G16B16A16_USCALED;
             R16G16B16A16_SSCALED       : Result := VK_FORMAT_R16G16B16A16_SSCALED;
             R16G16B16A16_UINT          : Result := VK_FORMAT_R16G16B16A16_UINT;
             R16G16B16A16_SINT          : Result := VK_FORMAT_R16G16B16A16_SINT;
             R16G16B16A16_SFLOAT        : Result := VK_FORMAT_R16G16B16A16_SFLOAT;
             R32_UINT                   : Result := VK_FORMAT_R32_UINT;
             R32_SINT                   : Result := VK_FORMAT_R32_SINT;
             R32_SFLOAT                 : Result := VK_FORMAT_R32_SFLOAT;
             R32G32_UINT                : Result := VK_FORMAT_R32G32_UINT;
             R32G32_SINT                : Result := VK_FORMAT_R32G32_SINT;
             R32G32_SFLOAT              : Result := VK_FORMAT_R32G32_SFLOAT;
             R32G32B32_UINT             : Result := VK_FORMAT_R32G32B32_UINT;
             R32G32B32_SINT             : Result := VK_FORMAT_R32G32B32_SINT;
             R32G32B32_SFLOAT           : Result := VK_FORMAT_R32G32B32_SFLOAT;
             R32G32B32A32_UINT          : Result := VK_FORMAT_R32G32B32A32_UINT;
             R32G32B32A32_SINT          : Result := VK_FORMAT_R32G32B32A32_SINT;
             R32G32B32A32_SFLOAT        : Result := VK_FORMAT_R32G32B32A32_SFLOAT;
             R64_UINT                   : Result := VK_FORMAT_R64_UINT;
             R64_SINT                   : Result := VK_FORMAT_R64_SINT;
             R64_SFLOAT                 : Result := VK_FORMAT_R64_SFLOAT;
             R64G64_UINT                : Result := VK_FORMAT_R64G64_UINT;
             R64G64_SINT                : Result := VK_FORMAT_R64G64_SINT;
             R64G64_SFLOAT              : Result := VK_FORMAT_R64G64_SFLOAT;
             R64G64B64_UINT             : Result := VK_FORMAT_R64G64B64_UINT;
             R64G64B64_SINT             : Result := VK_FORMAT_R64G64B64_SINT;
             R64G64B64_SFLOAT           : Result := VK_FORMAT_R64G64B64_SFLOAT;
             R64G64B64A64_UINT          : Result := VK_FORMAT_R64G64B64A64_UINT;
             R64G64B64A64_SINT          : Result := VK_FORMAT_R64G64B64A64_SINT;
             R64G64B64A64_SFLOAT        : Result := VK_FORMAT_R64G64B64A64_SFLOAT;
             B10G11R11_UFLOAT_PACK32    : Result := VK_FORMAT_B10G11R11_UFLOAT_PACK32;
             E5B9G9R9_UFLOAT_PACK32     : Result := VK_FORMAT_E5B9G9R9_UFLOAT_PACK32;
             D16_UNORM                  : Result := VK_FORMAT_D16_UNORM;
             X8_D24_UNORM_PACK32        : Result := VK_FORMAT_X8_D24_UNORM_PACK32;
             D32_SFLOAT                 : Result := VK_FORMAT_D32_SFLOAT;
             S8_UINT                    : Result := VK_FORMAT_S8_UINT;
             D16_UNORM_S8_UINT          : Result := VK_FORMAT_D16_UNORM_S8_UINT;
             D24_UNORM_S8_UINT          : Result := VK_FORMAT_D24_UNORM_S8_UINT;
             D32_SFLOAT_S8_UINT         : Result := VK_FORMAT_D32_SFLOAT_S8_UINT;
             BC1_RGB_UNORM_BLOCK        : Result := VK_FORMAT_BC1_RGB_UNORM_BLOCK;
             BC1_RGB_SRGB_BLOCK         : Result := VK_FORMAT_BC1_RGB_SRGB_BLOCK;
             BC1_RGBA_UNORM_BLOCK       : Result := VK_FORMAT_BC1_RGBA_UNORM_BLOCK;
             BC1_RGBA_SRGB_BLOCK        : Result := VK_FORMAT_BC1_RGBA_SRGB_BLOCK;
             BC2_UNORM_BLOCK            : Result := VK_FORMAT_BC2_UNORM_BLOCK;
             BC2_SRGB_BLOCK             : Result := VK_FORMAT_BC2_SRGB_BLOCK;
             BC3_UNORM_BLOCK            : Result := VK_FORMAT_BC3_UNORM_BLOCK;
             BC3_SRGB_BLOCK             : Result := VK_FORMAT_BC3_SRGB_BLOCK;
             BC4_UNORM_BLOCK            : Result := VK_FORMAT_BC4_UNORM_BLOCK;
             BC4_SNORM_BLOCK            : Result := VK_FORMAT_BC4_SNORM_BLOCK;
             BC5_UNORM_BLOCK            : Result := VK_FORMAT_BC5_UNORM_BLOCK;
             BC5_SNORM_BLOCK            : Result := VK_FORMAT_BC5_SNORM_BLOCK;
             BC6H_UFLOAT_BLOCK          : Result := VK_FORMAT_BC6H_UFLOAT_BLOCK;
             BC6H_SFLOAT_BLOCK          : Result := VK_FORMAT_BC6H_SFLOAT_BLOCK;
             BC7_UNORM_BLOCK            : Result := VK_FORMAT_BC7_UNORM_BLOCK;
             BC7_SRGB_BLOCK             : Result := VK_FORMAT_BC7_SRGB_BLOCK;
             ETC2_R8G8B8_UNORM_BLOCK    : Result := VK_FORMAT_ETC2_R8G8B8_UNORM_BLOCK;
             ETC2_R8G8B8_SRGB_BLOCK     : Result := VK_FORMAT_ETC2_R8G8B8_SRGB_BLOCK;
             ETC2_R8G8B8A1_UNORM_BLOCK  : Result := VK_FORMAT_ETC2_R8G8B8A1_UNORM_BLOCK;
             ETC2_R8G8B8A1_SRGB_BLOCK   : Result := VK_FORMAT_ETC2_R8G8B8A1_SRGB_BLOCK;
             ETC2_R8G8B8A8_UNORM_BLOCK  : Result := VK_FORMAT_ETC2_R8G8B8A8_UNORM_BLOCK;
             ETC2_R8G8B8A8_SRGB_BLOCK   : Result := VK_FORMAT_ETC2_R8G8B8A8_SRGB_BLOCK;
             EAC_R11_UNORM_BLOCK        : Result := VK_FORMAT_EAC_R11_UNORM_BLOCK;
             EAC_R11_SNORM_BLOCK        : Result := VK_FORMAT_EAC_R11_SNORM_BLOCK;
             EAC_R11G11_UNORM_BLOCK     : Result := VK_FORMAT_EAC_R11G11_UNORM_BLOCK;
             EAC_R11G11_SNORM_BLOCK     : Result := VK_FORMAT_EAC_R11G11_SNORM_BLOCK;
             ASTC_4x4_UNORM_BLOCK       : Result := VK_FORMAT_ASTC_4x4_UNORM_BLOCK;
             ASTC_4x4_SRGB_BLOCK        : Result := VK_FORMAT_ASTC_4x4_SRGB_BLOCK;
             ASTC_5x4_UNORM_BLOCK       : Result := VK_FORMAT_ASTC_5x4_UNORM_BLOCK;
             ASTC_5x4_SRGB_BLOCK        : Result := VK_FORMAT_ASTC_5x4_SRGB_BLOCK;
             ASTC_5x5_UNORM_BLOCK       : Result := VK_FORMAT_ASTC_5x5_UNORM_BLOCK;
             ASTC_5x5_SRGB_BLOCK        : Result := VK_FORMAT_ASTC_5x5_SRGB_BLOCK;
             ASTC_6x5_UNORM_BLOCK       : Result := VK_FORMAT_ASTC_6x5_UNORM_BLOCK;
             ASTC_6x5_SRGB_BLOCK        : Result := VK_FORMAT_ASTC_6x5_SRGB_BLOCK;
             ASTC_6x6_UNORM_BLOCK       : Result := VK_FORMAT_ASTC_6x6_UNORM_BLOCK;
             ASTC_6x6_SRGB_BLOCK        : Result := VK_FORMAT_ASTC_6x6_SRGB_BLOCK;
             ASTC_8x5_UNORM_BLOCK       : Result := VK_FORMAT_ASTC_8x5_UNORM_BLOCK;
             ASTC_8x5_SRGB_BLOCK        : Result := VK_FORMAT_ASTC_8x5_SRGB_BLOCK;
             ASTC_8x6_UNORM_BLOCK       : Result := VK_FORMAT_ASTC_8x6_UNORM_BLOCK;
             ASTC_8x6_SRGB_BLOCK        : Result := VK_FORMAT_ASTC_8x6_SRGB_BLOCK;
             ASTC_8x8_UNORM_BLOCK       : Result := VK_FORMAT_ASTC_8x8_UNORM_BLOCK;
             ASTC_8x8_SRGB_BLOCK        : Result := VK_FORMAT_ASTC_8x8_SRGB_BLOCK;
             ASTC_10x5_UNORM_BLOCK      : Result := VK_FORMAT_ASTC_10x5_UNORM_BLOCK;
             ASTC_10x5_SRGB_BLOCK       : Result := VK_FORMAT_ASTC_10x5_SRGB_BLOCK;
             ASTC_10x6_UNORM_BLOCK      : Result := VK_FORMAT_ASTC_10x6_UNORM_BLOCK;
             ASTC_10x6_SRGB_BLOCK       : Result := VK_FORMAT_ASTC_10x6_SRGB_BLOCK;
             ASTC_10x8_UNORM_BLOCK      : Result := VK_FORMAT_ASTC_10x8_UNORM_BLOCK;
             ASTC_10x8_SRGB_BLOCK       : Result := VK_FORMAT_ASTC_10x8_SRGB_BLOCK;
             ASTC_10x10_UNORM_BLOCK     : Result := VK_FORMAT_ASTC_10x10_UNORM_BLOCK;
             ASTC_10x10_SRGB_BLOCK      : Result := VK_FORMAT_ASTC_10x10_SRGB_BLOCK;
             ASTC_12x10_UNORM_BLOCK     : Result := VK_FORMAT_ASTC_12x10_UNORM_BLOCK;
             ASTC_12x10_SRGB_BLOCK      : Result := VK_FORMAT_ASTC_12x10_SRGB_BLOCK;
             ASTC_12x12_UNORM_BLOCK     : Result := VK_FORMAT_ASTC_12x12_UNORM_BLOCK;
             ASTC_12x12_SRGB_BLOCK      : Result := VK_FORMAT_ASTC_12x12_SRGB_BLOCK;
             PVRTC1_2BPP_UNORM_BLOCK_IMG: Result := VK_FORMAT_PVRTC1_2BPP_UNORM_BLOCK_IMG;
             PVRTC1_4BPP_UNORM_BLOCK_IMG: Result := VK_FORMAT_PVRTC1_4BPP_UNORM_BLOCK_IMG;
             PVRTC2_2BPP_UNORM_BLOCK_IMG: Result := VK_FORMAT_PVRTC2_2BPP_UNORM_BLOCK_IMG;
             PVRTC2_4BPP_UNORM_BLOCK_IMG: Result := VK_FORMAT_PVRTC2_4BPP_UNORM_BLOCK_IMG;
             PVRTC1_2BPP_SRGB_BLOCK_IMG : Result := VK_FORMAT_PVRTC1_2BPP_SRGB_BLOCK_IMG;
             PVRTC1_4BPP_SRGB_BLOCK_IMG : Result := VK_FORMAT_PVRTC1_4BPP_SRGB_BLOCK_IMG;
             PVRTC2_2BPP_SRGB_BLOCK_IMG : Result := VK_FORMAT_PVRTC2_2BPP_SRGB_BLOCK_IMG;
             PVRTC2_4BPP_SRGB_BLOCK_IMG : Result := VK_FORMAT_PVRTC2_4BPP_SRGB_BLOCK_IMG;
             ASTC_4x4_SFLOAT_BLOCK_EXT  : Result := VK_FORMAT_ASTC_4x4_SFLOAT_BLOCK_EXT;
             ASTC_5x4_SFLOAT_BLOCK_EXT  : Result := VK_FORMAT_ASTC_5x4_SFLOAT_BLOCK_EXT;
             ASTC_5x5_SFLOAT_BLOCK_EXT  : Result := VK_FORMAT_ASTC_5x5_SFLOAT_BLOCK_EXT;
             ASTC_6x5_SFLOAT_BLOCK_EXT  : Result := VK_FORMAT_ASTC_6x5_SFLOAT_BLOCK_EXT;
             ASTC_6x6_SFLOAT_BLOCK_EXT  : Result := VK_FORMAT_ASTC_6x6_SFLOAT_BLOCK_EXT;
             ASTC_8x5_SFLOAT_BLOCK_EXT  : Result := VK_FORMAT_ASTC_8x5_SFLOAT_BLOCK_EXT;
             ASTC_8x6_SFLOAT_BLOCK_EXT  : Result := VK_FORMAT_ASTC_8x6_SFLOAT_BLOCK_EXT;
             ASTC_8x8_SFLOAT_BLOCK_EXT  : Result := VK_FORMAT_ASTC_8x8_SFLOAT_BLOCK_EXT;
             ASTC_10x5_SFLOAT_BLOCK_EXT : Result := VK_FORMAT_ASTC_10x5_SFLOAT_BLOCK_EXT;
             ASTC_10x6_SFLOAT_BLOCK_EXT : Result := VK_FORMAT_ASTC_10x6_SFLOAT_BLOCK_EXT;
             ASTC_10x8_SFLOAT_BLOCK_EXT : Result := VK_FORMAT_ASTC_10x8_SFLOAT_BLOCK_EXT;
             ASTC_10x10_SFLOAT_BLOCK_EXT: Result := VK_FORMAT_ASTC_10x10_SFLOAT_BLOCK_EXT;
             ASTC_12x10_SFLOAT_BLOCK_EXT: Result := VK_FORMAT_ASTC_12x10_SFLOAT_BLOCK_EXT;
             ASTC_12x12_SFLOAT_BLOCK_EXT: Result := VK_FORMAT_ASTC_12x12_SFLOAT_BLOCK_EXT;
             G8B8G8R8_422_UNORM         : Result := VK_FORMAT_G8B8G8R8_422_UNORM;
             B8G8R8G8_422_UNORM         : Result := VK_FORMAT_B8G8R8G8_422_UNORM;
             G8_B8_R8_3PLANE_420_UNORM  : Result := VK_FORMAT_G8_B8_R8_3PLANE_420_UNORM;
             G8_B8R8_2PLANE_420_UNORM   : Result := VK_FORMAT_G8_B8R8_2PLANE_420_UNORM;
             G8_B8_R8_3PLANE_422_UNORM  : Result := VK_FORMAT_G8_B8_R8_3PLANE_422_UNORM;
             G8_B8R8_2PLANE_422_UNORM   : Result := VK_FORMAT_G8_B8R8_2PLANE_422_UNORM;
             G8_B8_R8_3PLANE_444_UNORM  : Result := VK_FORMAT_G8_B8_R8_3PLANE_444_UNORM;
             R10X6_UNORM_PACK16         : Result := VK_FORMAT_R10X6_UNORM_PACK16;
             R10X6G10X6_UNORM_2PACK16   : Result := VK_FORMAT_R10X6_UNORM_PACK16;
             R10X6G10X6B10X6A10X6_UNORM_4PACK16         : Result := VK_FORMAT_R10X6G10X6B10X6A10X6_UNORM_4PACK16;
             G10X6B10X6G10X6R10X6_422_UNORM_4PACK16     : Result := VK_FORMAT_G10X6B10X6G10X6R10X6_422_UNORM_4PACK16;
             B10X6G10X6R10X6G10X6_422_UNORM_4PACK16     : Result := VK_FORMAT_B10X6G10X6R10X6G10X6_422_UNORM_4PACK16;
             G10X6_B10X6_R10X6_3PLANE_420_UNORM_3PACK16 : Result := VK_FORMAT_G10X6_B10X6_R10X6_3PLANE_420_UNORM_3PACK16;
             G10X6_B10X6R10X6_2PLANE_420_UNORM_3PACK16  : Result := VK_FORMAT_G10X6_B10X6R10X6_2PLANE_420_UNORM_3PACK16;
             G10X6_B10X6_R10X6_3PLANE_422_UNORM_3PACK16 : Result := VK_FORMAT_G10X6_B10X6_R10X6_3PLANE_422_UNORM_3PACK16;
             G10X6_B10X6R10X6_2PLANE_422_UNORM_3PACK16  : Result := VK_FORMAT_G10X6_B10X6R10X6_2PLANE_422_UNORM_3PACK16;
             G10X6_B10X6_R10X6_3PLANE_444_UNORM_3PACK16 : Result := VK_FORMAT_G10X6_B10X6_R10X6_3PLANE_444_UNORM_3PACK16;
             R12X4_UNORM_PACK16         : Result := VK_FORMAT_R12X4_UNORM_PACK16;
             R12X4G12X4_UNORM_2PACK16   : Result := VK_FORMAT_R12X4G12X4_UNORM_2PACK16;
             R12X4G12X4B12X4A12X4_UNORM_4PACK16         : Result := VK_FORMAT_R12X4G12X4B12X4A12X4_UNORM_4PACK16;
             G12X4B12X4G12X4R12X4_422_UNORM_4PACK16     : Result := VK_FORMAT_G12X4B12X4G12X4R12X4_422_UNORM_4PACK16;
             B12X4G12X4R12X4G12X4_422_UNORM_4PACK16     : Result := VK_FORMAT_B12X4G12X4R12X4G12X4_422_UNORM_4PACK16;
             G12X4_B12X4_R12X4_3PLANE_420_UNORM_3PACK16 : Result := VK_FORMAT_G12X4_B12X4_R12X4_3PLANE_420_UNORM_3PACK16;
             G12X4_B12X4R12X4_2PLANE_420_UNORM_3PACK16  : Result := VK_FORMAT_G12X4_B12X4R12X4_2PLANE_420_UNORM_3PACK16;
             G12X4_B12X4_R12X4_3PLANE_422_UNORM_3PACK16 : Result := VK_FORMAT_G12X4_B12X4_R12X4_3PLANE_422_UNORM_3PACK16;
             G12X4_B12X4R12X4_2PLANE_422_UNORM_3PACK16  : Result := VK_FORMAT_G12X4_B12X4R12X4_2PLANE_422_UNORM_3PACK16;
             G12X4_B12X4_R12X4_3PLANE_444_UNORM_3PACK16 : Result := VK_FORMAT_G12X4_B12X4_R12X4_3PLANE_444_UNORM_3PACK16;
             G16B16G16R16_422_UNORM         : Result := VK_FORMAT_G16B16G16R16_422_UNORM;
             B16G16R16G16_422_UNORM         : Result := VK_FORMAT_B16G16R16G16_422_UNORM;
             G16_B16_R16_3PLANE_420_UNORM   : Result := VK_FORMAT_G16_B16_R16_3PLANE_420_UNORM;
             G16_B16R16_2PLANE_420_UNORM    : Result := VK_FORMAT_G16_B16R16_2PLANE_420_UNORM;
             G16_B16_R16_3PLANE_422_UNORM   : Result := VK_FORMAT_G16_B16_R16_3PLANE_422_UNORM;
             G16_B16R16_2PLANE_422_UNORM    : Result := VK_FORMAT_G16_B16R16_2PLANE_422_UNORM;
             G16_B16_R16_3PLANE_444_UNORM   : Result := VK_FORMAT_G16_B16_R16_3PLANE_444_UNORM;
             ASTC_3x3x3_UNORM_BLOCK_EXT     : Result := VK_FORMAT_ASTC_3x3x3_UNORM_BLOCK_EXT;
             ASTC_3x3x3_SRGB_BLOCK_EXT      : Result := VK_FORMAT_ASTC_3x3x3_SRGB_BLOCK_EXT;
             ASTC_3x3x3_SFLOAT_BLOCK_EXT    : Result := VK_FORMAT_ASTC_3x3x3_SFLOAT_BLOCK_EXT;
             ASTC_4x3x3_UNORM_BLOCK_EXT     : Result := VK_FORMAT_ASTC_4x3x3_UNORM_BLOCK_EXT;
             ASTC_4x3x3_SRGB_BLOCK_EXT      : Result := VK_FORMAT_ASTC_4x3x3_SRGB_BLOCK_EXT;
             ASTC_4x3x3_SFLOAT_BLOCK_EXT    : Result := VK_FORMAT_ASTC_4x3x3_SFLOAT_BLOCK_EXT;
             ASTC_4x4x3_UNORM_BLOCK_EXT     : Result := VK_FORMAT_ASTC_4x4x3_UNORM_BLOCK_EXT;
             ASTC_4x4x3_SRGB_BLOCK_EXT      : Result := VK_FORMAT_ASTC_4x4x3_SRGB_BLOCK_EXT;
             ASTC_4x4x3_SFLOAT_BLOCK_EXT    : Result := VK_FORMAT_ASTC_4x4x3_SFLOAT_BLOCK_EXT;
             ASTC_4x4x4_UNORM_BLOCK_EXT     : Result := VK_FORMAT_ASTC_4x4x4_UNORM_BLOCK_EXT;
             ASTC_4x4x4_SRGB_BLOCK_EXT      : Result := VK_FORMAT_ASTC_4x4x4_SRGB_BLOCK_EXT;
             ASTC_4x4x4_SFLOAT_BLOCK_EXT    : Result := VK_FORMAT_ASTC_4x4x4_SFLOAT_BLOCK_EXT;
             ASTC_5x4x4_UNORM_BLOCK_EXT     : Result := VK_FORMAT_ASTC_5x4x4_UNORM_BLOCK_EXT;
             ASTC_5x4x4_SRGB_BLOCK_EXT      : Result := VK_FORMAT_ASTC_5x4x4_SRGB_BLOCK_EXT;
             ASTC_5x4x4_SFLOAT_BLOCK_EXT    : Result := VK_FORMAT_ASTC_5x4x4_SFLOAT_BLOCK_EXT;
             ASTC_5x5x4_UNORM_BLOCK_EXT     : Result := VK_FORMAT_ASTC_5x5x4_UNORM_BLOCK_EXT;
             ASTC_5x5x4_SRGB_BLOCK_EXT      : Result := VK_FORMAT_ASTC_5x5x4_SRGB_BLOCK_EXT;
             ASTC_5x5x4_SFLOAT_BLOCK_EXT    : Result := VK_FORMAT_ASTC_5x5x4_SFLOAT_BLOCK_EXT;
             ASTC_5x5x5_UNORM_BLOCK_EXT     : Result := VK_FORMAT_ASTC_5x5x5_UNORM_BLOCK_EXT;
             ASTC_5x5x5_SRGB_BLOCK_EXT      : Result := VK_FORMAT_ASTC_5x5x5_SRGB_BLOCK_EXT;
             ASTC_5x5x5_SFLOAT_BLOCK_EXT    : Result := VK_FORMAT_ASTC_5x5x5_SFLOAT_BLOCK_EXT;
             ASTC_6x5x5_UNORM_BLOCK_EXT     : Result := VK_FORMAT_ASTC_6x5x5_UNORM_BLOCK_EXT;
             ASTC_6x5x5_SRGB_BLOCK_EXT      : Result := VK_FORMAT_ASTC_6x5x5_SRGB_BLOCK_EXT;
             ASTC_6x5x5_SFLOAT_BLOCK_EXT    : Result := VK_FORMAT_ASTC_6x5x5_SFLOAT_BLOCK_EXT;
             ASTC_6x6x5_UNORM_BLOCK_EXT     : Result := VK_FORMAT_ASTC_6x6x5_UNORM_BLOCK_EXT;
             ASTC_6x6x5_SRGB_BLOCK_EXT      : Result := VK_FORMAT_ASTC_6x6x5_SRGB_BLOCK_EXT;
             ASTC_6x6x5_SFLOAT_BLOCK_EXT    : Result := VK_FORMAT_ASTC_6x6x5_SFLOAT_BLOCK_EXT;
             ASTC_6x6x6_UNORM_BLOCK_EXT     : Result := VK_FORMAT_ASTC_6x6x6_UNORM_BLOCK_EXT;
             ASTC_6x6x6_SRGB_BLOCK_EXT      : Result := VK_FORMAT_ASTC_6x6x6_SRGB_BLOCK_EXT;
             ASTC_6x6x6_SFLOAT_BLOCK_EXT    : Result := VK_FORMAT_ASTC_6x6x6_SFLOAT_BLOCK_EXT;
             A4R4G4B4_UNORM_PACK16_EXT      : Result := VK_FORMAT_A4R4G4B4_UNORM_PACK16_EXT;
             A4B4G4R4_UNORM_PACK16_EXT      : Result := VK_FORMAT_A4B4G4R4_UNORM_PACK16_EXT;
             B10X6G10X6R10X6G10X6_422_UNORM_4PACK16_KHR:             Result := VK_FORMAT_B10X6G10X6R10X6G10X6_422_UNORM_4PACK16;
             B12X4G12X4R12X4G12X4_422_UNORM_4PACK16_KHR:             Result := VK_FORMAT_B12X4G12X4R12X4G12X4_422_UNORM_4PACK16;
             B16G16R16G16_422_UNORM_KHR                :             Result := VK_FORMAT_B16G16R16G16_422_UNORM;
             B8G8R8G8_422_UNORM_KHR                    :             Result := VK_FORMAT_B16G16R16G16_422_UNORM;
             G10X6B10X6G10X6R10X6_422_UNORM_4PACK16_KHR:             Result := VK_FORMAT_G10X6B10X6G10X6R10X6_422_UNORM_4PACK16;
             G10X6_B10X6R10X6_2PLANE_420_UNORM_3PACK16_KHR :             Result := VK_FORMAT_G10X6_B10X6R10X6_2PLANE_420_UNORM_3PACK16;
             G10X6_B10X6R10X6_2PLANE_422_UNORM_3PACK16_KHR :             Result := VK_FORMAT_G10X6_B10X6R10X6_2PLANE_422_UNORM_3PACK16;
             G10X6_B10X6_R10X6_3PLANE_420_UNORM_3PACK16_KHR:             Result := VK_FORMAT_G10X6_B10X6_R10X6_3PLANE_420_UNORM_3PACK16;
             G10X6_B10X6_R10X6_3PLANE_422_UNORM_3PACK16_KHR:             Result := VK_FORMAT_G10X6_B10X6_R10X6_3PLANE_422_UNORM_3PACK16;
             G10X6_B10X6_R10X6_3PLANE_444_UNORM_3PACK16_KHR:             Result := VK_FORMAT_G10X6_B10X6_R10X6_3PLANE_444_UNORM_3PACK16;
             G12X4B12X4G12X4R12X4_422_UNORM_4PACK16_KHR    :             Result := VK_FORMAT_G12X4B12X4G12X4R12X4_422_UNORM_4PACK16;
             G12X4_B12X4R12X4_2PLANE_420_UNORM_3PACK16_KHR :             Result := VK_FORMAT_G12X4_B12X4R12X4_2PLANE_420_UNORM_3PACK16;
             G12X4_B12X4R12X4_2PLANE_422_UNORM_3PACK16_KHR :             Result := VK_FORMAT_G12X4_B12X4R12X4_2PLANE_422_UNORM_3PACK16;
             G12X4_B12X4_R12X4_3PLANE_420_UNORM_3PACK16_KHR:             Result := VK_FORMAT_G12X4_B12X4_R12X4_3PLANE_420_UNORM_3PACK16;
             G12X4_B12X4_R12X4_3PLANE_422_UNORM_3PACK16_KHR:             Result := VK_FORMAT_G12X4_B12X4_R12X4_3PLANE_422_UNORM_3PACK16;
             G12X4_B12X4_R12X4_3PLANE_444_UNORM_3PACK16_KHR:             Result := VK_FORMAT_G12X4_B12X4_R12X4_3PLANE_444_UNORM_3PACK16;
             G16B16G16R16_422_UNORM_KHR                    :             Result := VK_FORMAT_G16B16G16R16_422_UNORM;
             G16_B16R16_2PLANE_420_UNORM_KHR               :             Result := VK_FORMAT_G16_B16R16_2PLANE_420_UNORM;
             G16_B16R16_2PLANE_422_UNORM_KHR               :             Result := VK_FORMAT_G16_B16R16_2PLANE_422_UNORM;
             G16_B16_R16_3PLANE_420_UNORM_KHR              :             Result := VK_FORMAT_G16_B16_R16_3PLANE_420_UNORM;
             G16_B16_R16_3PLANE_422_UNORM_KHR              :             Result := VK_FORMAT_G16_B16_R16_3PLANE_422_UNORM;
             G16_B16_R16_3PLANE_444_UNORM_KHR              :             Result := VK_FORMAT_G16_B16_R16_3PLANE_444_UNORM;
             G8B8G8R8_422_UNORM_KHR                        :             Result := VK_FORMAT_G8B8G8R8_422_UNORM;
             G8_B8R8_2PLANE_420_UNORM_KHR                  :             Result := VK_FORMAT_G8_B8R8_2PLANE_420_UNORM;
             G8_B8R8_2PLANE_422_UNORM_KHR                  :             Result := VK_FORMAT_G8_B8R8_2PLANE_422_UNORM;
             G8_B8_R8_3PLANE_420_UNORM_KHR                 :             Result := VK_FORMAT_G8_B8_R8_3PLANE_420_UNORM;
             G8_B8_R8_3PLANE_422_UNORM_KHR                 :             Result := VK_FORMAT_G8_B8_R8_3PLANE_444_UNORM;
             G8_B8_R8_3PLANE_444_UNORM_KHR                 :             Result := VK_FORMAT_R10X6G10X6B10X6A10X6_UNORM_4PACK16;
             R10X6G10X6B10X6A10X6_UNORM_4PACK16_KHR        :             Result := VK_FORMAT_R10X6G10X6_UNORM_2PACK16;
             R10X6G10X6_UNORM_2PACK16_KHR                  :             Result := VK_FORMAT_R10X6G10X6_UNORM_2PACK16;
             R10X6_UNORM_PACK16_KHR                        :             Result := VK_FORMAT_R10X6_UNORM_PACK16;
             R12X4G12X4B12X4A12X4_UNORM_4PACK16_KHR        :             Result := VK_FORMAT_R12X4G12X4B12X4A12X4_UNORM_4PACK16;
             R12X4G12X4_UNORM_2PACK16_KHR                  :             Result := VK_FORMAT_R12X4G12X4_UNORM_2PACK16;
             R12X4_UNORM_PACK16_KHR                        :             Result := VK_FORMAT_R12X4_UNORM_PACK16;
           Else
             Result:=VK_FORMAT_UNDEFINED;

        End;
      End;

      Function GetVGFormat(Value:TVkFormat):TVgFormat;

      Begin
        Case Value of
             VK_FORMAT_UNDEFINED                  : Result := UNDEFINED;
             VK_FORMAT_R4G4_UNORM_PACK8           : Result := R4G4_UNORM_PACK8;
             VK_FORMAT_R4G4B4A4_UNORM_PACK16      : Result := R4G4B4A4_UNORM_PACK16;
             VK_FORMAT_B4G4R4A4_UNORM_PACK16      : Result := B4G4R4A4_UNORM_PACK16;
             VK_FORMAT_R5G6B5_UNORM_PACK16        : Result := R5G6B5_UNORM_PACK16;
             VK_FORMAT_B5G6R5_UNORM_PACK16        : Result := B5G6R5_UNORM_PACK16;
             VK_FORMAT_R5G5B5A1_UNORM_PACK16      : Result := R5G5B5A1_UNORM_PACK16;
             VK_FORMAT_B5G5R5A1_UNORM_PACK16      : Result := B5G5R5A1_UNORM_PACK16;
             VK_FORMAT_A1R5G5B5_UNORM_PACK16      : Result := A1R5G5B5_UNORM_PACK16;
             VK_FORMAT_R8_UNORM                   : Result := R8_UNORM;
             VK_FORMAT_R8_SNORM                   : Result := R8_SNORM;
             VK_FORMAT_R8_USCALED                 : Result := R8_USCALED;
             VK_FORMAT_R8_SSCALED                 : Result := R8_SSCALED;
             VK_FORMAT_R8_UINT                    : Result := R8_UINT;
             VK_FORMAT_R8_SINT                    : Result := R8_SINT;
             VK_FORMAT_R8_SRGB                    : Result := R8_SRGB;
             VK_FORMAT_R8G8_UNORM                 : Result := R8G8_UNORM;
             VK_FORMAT_R8G8_SNORM                 : Result := R8G8_SNORM;
             VK_FORMAT_R8G8_USCALED               : Result := R8G8_USCALED;
             VK_FORMAT_R8G8_SSCALED               : Result := R8G8_SSCALED;
             VK_FORMAT_R8G8_UINT                  : Result := R8G8_UINT;
             VK_FORMAT_R8G8_SINT                  : Result := R8G8_SINT;
             VK_FORMAT_R8G8_SRGB                  : Result := R8G8_SRGB;
             VK_FORMAT_R8G8B8_UNORM               : Result := R8G8B8_UNORM;
             VK_FORMAT_R8G8B8_SNORM               : Result := R8G8B8_SNORM;
             VK_FORMAT_R8G8B8_USCALED             : Result := R8G8B8_USCALED;
             VK_FORMAT_R8G8B8_SSCALED             : Result := R8G8B8_SSCALED;
             VK_FORMAT_R8G8B8_UINT                : Result := R8G8B8_UINT;
             VK_FORMAT_R8G8B8_SINT                : Result := R8G8B8_SINT;
             VK_FORMAT_R8G8B8_SRGB                : Result := B8G8R8_UNORM;
             VK_FORMAT_B8G8R8_UNORM               : Result := B8G8R8_UNORM;
             VK_FORMAT_B8G8R8_SNORM               : Result := B8G8R8_SNORM;
             VK_FORMAT_B8G8R8_USCALED             : Result := B8G8R8_USCALED;
             VK_FORMAT_B8G8R8_SSCALED             : Result := B8G8R8_SSCALED;
             VK_FORMAT_B8G8R8_UINT                : Result := B8G8R8_UINT;
             VK_FORMAT_B8G8R8_SINT                : Result := B8G8R8_SINT;
             VK_FORMAT_B8G8R8_SRGB                : Result := B8G8R8_SRGB;
             VK_FORMAT_R8G8B8A8_UNORM             : Result := R8G8B8A8_UNORM;
             VK_FORMAT_R8G8B8A8_SNORM             : Result := R8G8B8A8_SNORM;
             VK_FORMAT_R8G8B8A8_USCALED           : Result := R8G8B8A8_USCALED;
             VK_FORMAT_R8G8B8A8_SSCALED           : Result := R8G8B8A8_SSCALED;
             VK_FORMAT_R8G8B8A8_UINT              : Result := R8G8B8A8_UINT;
             VK_FORMAT_R8G8B8A8_SINT              : Result := R8G8B8A8_SINT;
             VK_FORMAT_R8G8B8A8_SRGB              : Result := R8G8B8A8_SRGB;
             VK_FORMAT_B8G8R8A8_UNORM             : Result := B8G8R8A8_UNORM;
             VK_FORMAT_B8G8R8A8_SNORM             : Result := B8G8R8A8_SNORM;
             VK_FORMAT_B8G8R8A8_USCALED           : Result := B8G8R8A8_USCALED;
             VK_FORMAT_B8G8R8A8_SSCALED           : Result := B8G8R8A8_SSCALED;
             VK_FORMAT_B8G8R8A8_UINT              : Result := B8G8R8A8_UINT;
             VK_FORMAT_B8G8R8A8_SINT              : Result := B8G8R8A8_SINT;
             VK_FORMAT_B8G8R8A8_SRGB              : Result := B8G8R8A8_SRGB;
             VK_FORMAT_A8B8G8R8_UNORM_PACK32      : Result := A8B8G8R8_UNORM_PACK32;
             VK_FORMAT_A8B8G8R8_SNORM_PACK32      : Result := A8B8G8R8_SNORM_PACK32;
             VK_FORMAT_A8B8G8R8_USCALED_PACK32    : Result := A8B8G8R8_USCALED_PACK32;
             VK_FORMAT_A8B8G8R8_SSCALED_PACK32    : Result := A8B8G8R8_SSCALED_PACK32;
             VK_FORMAT_A8B8G8R8_UINT_PACK32       : Result := A8B8G8R8_UINT_PACK32;
             VK_FORMAT_A8B8G8R8_SINT_PACK32       : Result := A8B8G8R8_SINT_PACK32;
             VK_FORMAT_A8B8G8R8_SRGB_PACK32       : Result := A8B8G8R8_SRGB_PACK32;
             VK_FORMAT_A2R10G10B10_UNORM_PACK32   : Result := A2R10G10B10_UNORM_PACK32;
             VK_FORMAT_A2R10G10B10_SNORM_PACK32   : Result := A2R10G10B10_SNORM_PACK32;
             VK_FORMAT_A2R10G10B10_USCALED_PACK32 : Result := A2R10G10B10_USCALED_PACK32;
             VK_FORMAT_A2R10G10B10_SSCALED_PACK32 : Result := A2R10G10B10_SSCALED_PACK32;
             VK_FORMAT_A2R10G10B10_UINT_PACK32    : Result := A2R10G10B10_UINT_PACK32;
             VK_FORMAT_A2R10G10B10_SINT_PACK32    : Result := A2R10G10B10_SINT_PACK32;
             VK_FORMAT_A2B10G10R10_UNORM_PACK32   : Result := A2B10G10R10_UNORM_PACK32;
             VK_FORMAT_A2B10G10R10_SNORM_PACK32   : Result := A2B10G10R10_SNORM_PACK32;
             VK_FORMAT_A2B10G10R10_USCALED_PACK32 : Result := A2B10G10R10_USCALED_PACK32;
             VK_FORMAT_A2B10G10R10_SSCALED_PACK32 : Result := A2B10G10R10_SSCALED_PACK32;
             VK_FORMAT_A2B10G10R10_UINT_PACK32    : Result := A2B10G10R10_UINT_PACK32;
             VK_FORMAT_A2B10G10R10_SINT_PACK32    : Result := A2B10G10R10_SINT_PACK32;
             VK_FORMAT_R16_UNORM                  : Result := R16_UNORM;
             VK_FORMAT_R16_SNORM                  : Result := R16_SNORM;
             VK_FORMAT_R16_USCALED                : Result := R16_USCALED;
             VK_FORMAT_R16_SSCALED                : Result := R16_SSCALED;
             VK_FORMAT_R16_UINT                   : Result := R16_UINT;
             VK_FORMAT_R16_SINT                   : Result := R16_SINT;
             VK_FORMAT_R16_SFLOAT                 : Result := R16_SFLOAT;
             VK_FORMAT_R16G16_UNORM               : Result := R16G16_UNORM;
             VK_FORMAT_R16G16_SNORM               : Result := R16G16_SNORM;
             VK_FORMAT_R16G16_USCALED             : Result := R16G16_USCALED;
             VK_FORMAT_R16G16_SSCALED             : Result := R16G16_SSCALED;
             VK_FORMAT_R16G16_UINT                : Result := R16G16_UINT;
             VK_FORMAT_R16G16_SINT                : Result := R16G16_SINT;
             VK_FORMAT_R16G16_SFLOAT              : Result := R16G16_SFLOAT;
             VK_FORMAT_R16G16B16_UNORM            : Result := R16G16B16_UNORM;
             VK_FORMAT_R16G16B16_SNORM            : Result := R16G16B16_SNORM;
             VK_FORMAT_R16G16B16_USCALED          : Result := R16G16B16_USCALED;
             VK_FORMAT_R16G16B16_SSCALED          : Result := R16G16B16_SSCALED;
             VK_FORMAT_R16G16B16_UINT             : Result := R16G16B16_UINT;
             VK_FORMAT_R16G16B16_SINT             : Result := R16G16B16_SINT;
             VK_FORMAT_R16G16B16_SFLOAT           : Result := R16G16B16_SFLOAT;
             VK_FORMAT_R16G16B16A16_UNORM         : Result := R16G16B16A16_UNORM;
             VK_FORMAT_R16G16B16A16_SNORM         : Result := R16G16B16A16_SNORM;
             VK_FORMAT_R16G16B16A16_USCALED       : Result := R16G16B16A16_USCALED;
             VK_FORMAT_R16G16B16A16_SSCALED       : Result := R16G16B16A16_SSCALED;
             VK_FORMAT_R16G16B16A16_UINT          : Result := R16G16B16A16_UINT;
             VK_FORMAT_R16G16B16A16_SINT          : Result := R16G16B16A16_SINT;
             VK_FORMAT_R16G16B16A16_SFLOAT        : Result := R16G16B16A16_SFLOAT;
             VK_FORMAT_R32_UINT                   : Result := R32_UINT;
             VK_FORMAT_R32_SINT                   : Result := R32_SINT;
             VK_FORMAT_R32_SFLOAT                 : Result := R32_SFLOAT;
             VK_FORMAT_R32G32_UINT                : Result := R32G32_UINT;
             VK_FORMAT_R32G32_SINT                : Result := R32G32_SINT;
             VK_FORMAT_R32G32_SFLOAT              : Result := R32G32_SFLOAT;
             VK_FORMAT_R32G32B32_UINT             : Result := R32G32B32_UINT;
             VK_FORMAT_R32G32B32_SINT             : Result := R32G32B32_SINT;
             VK_FORMAT_R32G32B32_SFLOAT           : Result := R32G32B32_SFLOAT;
             VK_FORMAT_R32G32B32A32_UINT          : Result := R32G32B32A32_UINT;
             VK_FORMAT_R32G32B32A32_SINT          : Result := R32G32B32A32_SINT;
             VK_FORMAT_R32G32B32A32_SFLOAT        : Result := R32G32B32A32_SFLOAT;
             VK_FORMAT_R64_UINT                   : Result := R64_UINT;
             VK_FORMAT_R64_SINT                   : Result := R64_SINT;
             VK_FORMAT_R64_SFLOAT                 : Result := R64_SFLOAT;
             VK_FORMAT_R64G64_UINT                : Result := R64G64_UINT;
             VK_FORMAT_R64G64_SINT                : Result := R64G64_SINT;
             VK_FORMAT_R64G64_SFLOAT              : Result := R64G64_SFLOAT;
             VK_FORMAT_R64G64B64_UINT             : Result := R64G64B64_UINT;
             VK_FORMAT_R64G64B64_SINT             : Result := R64G64B64_SINT;
             VK_FORMAT_R64G64B64_SFLOAT           : Result := R64G64B64_SFLOAT;
             VK_FORMAT_R64G64B64A64_UINT          : Result := R64G64B64A64_UINT;
             VK_FORMAT_R64G64B64A64_SINT          : Result := R64G64B64A64_SINT;
             VK_FORMAT_R64G64B64A64_SFLOAT        : Result := R64G64B64A64_SFLOAT;
             VK_FORMAT_B10G11R11_UFLOAT_PACK32    : Result := B10G11R11_UFLOAT_PACK32;
             VK_FORMAT_E5B9G9R9_UFLOAT_PACK32     : Result := E5B9G9R9_UFLOAT_PACK32;
             VK_FORMAT_D16_UNORM                  : Result := D16_UNORM;
             VK_FORMAT_X8_D24_UNORM_PACK32        : Result := X8_D24_UNORM_PACK32;
             VK_FORMAT_D32_SFLOAT                 : Result := D32_SFLOAT;
             VK_FORMAT_S8_UINT                    : Result := S8_UINT;
             VK_FORMAT_D16_UNORM_S8_UINT          : Result := D16_UNORM_S8_UINT;
             VK_FORMAT_D24_UNORM_S8_UINT          : Result := D24_UNORM_S8_UINT;
             VK_FORMAT_D32_SFLOAT_S8_UINT         : Result := D32_SFLOAT_S8_UINT;
             VK_FORMAT_BC1_RGB_UNORM_BLOCK        : Result := BC1_RGB_UNORM_BLOCK;
             VK_FORMAT_BC1_RGB_SRGB_BLOCK         : Result := BC1_RGB_SRGB_BLOCK;
             VK_FORMAT_BC1_RGBA_UNORM_BLOCK       : Result := BC1_RGBA_UNORM_BLOCK;
             VK_FORMAT_BC1_RGBA_SRGB_BLOCK        : Result := BC1_RGBA_SRGB_BLOCK;
             VK_FORMAT_BC2_UNORM_BLOCK            : Result := BC2_UNORM_BLOCK;
             VK_FORMAT_BC2_SRGB_BLOCK             : Result := BC2_SRGB_BLOCK;
             VK_FORMAT_BC3_UNORM_BLOCK            : Result := BC3_UNORM_BLOCK;
             VK_FORMAT_BC3_SRGB_BLOCK             : Result := BC3_SRGB_BLOCK;
             VK_FORMAT_BC4_UNORM_BLOCK            : Result := BC4_UNORM_BLOCK;
             VK_FORMAT_BC4_SNORM_BLOCK            : Result := BC4_SNORM_BLOCK;
             VK_FORMAT_BC5_UNORM_BLOCK            : Result := BC5_UNORM_BLOCK;
             VK_FORMAT_BC5_SNORM_BLOCK            : Result := BC5_SNORM_BLOCK;
             VK_FORMAT_BC6H_UFLOAT_BLOCK          : Result := BC6H_UFLOAT_BLOCK;
             VK_FORMAT_BC6H_SFLOAT_BLOCK          : Result := BC6H_SFLOAT_BLOCK;
             VK_FORMAT_BC7_UNORM_BLOCK            : Result := BC7_UNORM_BLOCK;
             VK_FORMAT_BC7_SRGB_BLOCK             : Result := BC7_SRGB_BLOCK;
             VK_FORMAT_ETC2_R8G8B8_UNORM_BLOCK    : Result := ETC2_R8G8B8_UNORM_BLOCK;
             VK_FORMAT_ETC2_R8G8B8_SRGB_BLOCK     : Result := ETC2_R8G8B8_SRGB_BLOCK;
             VK_FORMAT_ETC2_R8G8B8A1_UNORM_BLOCK  : Result := ETC2_R8G8B8A1_UNORM_BLOCK;
             VK_FORMAT_ETC2_R8G8B8A1_SRGB_BLOCK   : Result := ETC2_R8G8B8A1_SRGB_BLOCK;
             VK_FORMAT_ETC2_R8G8B8A8_UNORM_BLOCK  : Result := ETC2_R8G8B8A8_UNORM_BLOCK;
             VK_FORMAT_ETC2_R8G8B8A8_SRGB_BLOCK   : Result := ETC2_R8G8B8A8_SRGB_BLOCK;
             VK_FORMAT_EAC_R11_UNORM_BLOCK        : Result := EAC_R11_UNORM_BLOCK;
             VK_FORMAT_EAC_R11_SNORM_BLOCK        : Result := EAC_R11_SNORM_BLOCK;
             VK_FORMAT_EAC_R11G11_UNORM_BLOCK     : Result := EAC_R11G11_UNORM_BLOCK;
             VK_FORMAT_EAC_R11G11_SNORM_BLOCK     : Result := EAC_R11G11_SNORM_BLOCK;
             VK_FORMAT_ASTC_4x4_UNORM_BLOCK       : Result := ASTC_4x4_UNORM_BLOCK;
             VK_FORMAT_ASTC_4x4_SRGB_BLOCK        : Result := ASTC_4x4_SRGB_BLOCK;
             VK_FORMAT_ASTC_5x4_UNORM_BLOCK       : Result := ASTC_5x4_UNORM_BLOCK;
             VK_FORMAT_ASTC_5x4_SRGB_BLOCK        : Result := ASTC_5x4_SRGB_BLOCK;
             VK_FORMAT_ASTC_5x5_UNORM_BLOCK       : Result := ASTC_5x5_UNORM_BLOCK;
             VK_FORMAT_ASTC_5x5_SRGB_BLOCK        : Result := ASTC_5x5_SRGB_BLOCK;
             VK_FORMAT_ASTC_6x5_UNORM_BLOCK       : Result := ASTC_6x5_UNORM_BLOCK;
             VK_FORMAT_ASTC_6x5_SRGB_BLOCK        : Result := ASTC_6x5_SRGB_BLOCK;
             VK_FORMAT_ASTC_6x6_UNORM_BLOCK       : Result := ASTC_6x6_UNORM_BLOCK;
             VK_FORMAT_ASTC_6x6_SRGB_BLOCK        : Result := ASTC_6x6_SRGB_BLOCK;
             VK_FORMAT_ASTC_8x5_UNORM_BLOCK       : Result := ASTC_8x5_UNORM_BLOCK;
             VK_FORMAT_ASTC_8x5_SRGB_BLOCK        : Result := ASTC_8x5_SRGB_BLOCK;
             VK_FORMAT_ASTC_8x6_UNORM_BLOCK       : Result := ASTC_8x6_UNORM_BLOCK;
             VK_FORMAT_ASTC_8x6_SRGB_BLOCK        : Result := ASTC_8x6_SRGB_BLOCK;
             VK_FORMAT_ASTC_8x8_UNORM_BLOCK       : Result := ASTC_8x8_UNORM_BLOCK;
             VK_FORMAT_ASTC_8x8_SRGB_BLOCK        : Result := ASTC_8x8_SRGB_BLOCK;
             VK_FORMAT_ASTC_10x5_UNORM_BLOCK      : Result := ASTC_10x5_UNORM_BLOCK;
             VK_FORMAT_ASTC_10x5_SRGB_BLOCK       : Result := ASTC_10x5_SRGB_BLOCK;
             VK_FORMAT_ASTC_10x6_UNORM_BLOCK      : Result := ASTC_10x6_UNORM_BLOCK;
             VK_FORMAT_ASTC_10x6_SRGB_BLOCK       : Result := ASTC_10x6_SRGB_BLOCK;
             VK_FORMAT_ASTC_10x8_UNORM_BLOCK      : Result := ASTC_10x8_UNORM_BLOCK;
             VK_FORMAT_ASTC_10x8_SRGB_BLOCK       : Result := ASTC_10x8_SRGB_BLOCK;
             VK_FORMAT_ASTC_10x10_UNORM_BLOCK     : Result := ASTC_10x10_UNORM_BLOCK;
             VK_FORMAT_ASTC_10x10_SRGB_BLOCK      : Result := ASTC_10x10_SRGB_BLOCK;
             VK_FORMAT_ASTC_12x10_UNORM_BLOCK     : Result := ASTC_12x10_UNORM_BLOCK;
             VK_FORMAT_ASTC_12x10_SRGB_BLOCK      : Result := ASTC_12x10_SRGB_BLOCK;
             VK_FORMAT_ASTC_12x12_UNORM_BLOCK     : Result := ASTC_12x12_UNORM_BLOCK;
             VK_FORMAT_ASTC_12x12_SRGB_BLOCK      : Result := ASTC_12x12_SRGB_BLOCK;
             VK_FORMAT_PVRTC1_2BPP_UNORM_BLOCK_IMG: Result := PVRTC1_2BPP_UNORM_BLOCK_IMG;
             VK_FORMAT_PVRTC1_4BPP_UNORM_BLOCK_IMG: Result := PVRTC1_4BPP_UNORM_BLOCK_IMG;
             VK_FORMAT_PVRTC2_2BPP_UNORM_BLOCK_IMG: Result := PVRTC2_2BPP_UNORM_BLOCK_IMG;
             VK_FORMAT_PVRTC2_4BPP_UNORM_BLOCK_IMG: Result := PVRTC2_4BPP_UNORM_BLOCK_IMG;
             VK_FORMAT_PVRTC1_2BPP_SRGB_BLOCK_IMG : Result := PVRTC1_2BPP_SRGB_BLOCK_IMG;
             VK_FORMAT_PVRTC1_4BPP_SRGB_BLOCK_IMG : Result := PVRTC1_4BPP_SRGB_BLOCK_IMG;
             VK_FORMAT_PVRTC2_2BPP_SRGB_BLOCK_IMG : Result := PVRTC2_2BPP_SRGB_BLOCK_IMG;
             VK_FORMAT_PVRTC2_4BPP_SRGB_BLOCK_IMG : Result := PVRTC2_4BPP_SRGB_BLOCK_IMG;
             VK_FORMAT_ASTC_4x4_SFLOAT_BLOCK_EXT  : Result := ASTC_4x4_SFLOAT_BLOCK_EXT;
             VK_FORMAT_ASTC_5x4_SFLOAT_BLOCK_EXT  : Result := ASTC_5x4_SFLOAT_BLOCK_EXT;
             VK_FORMAT_ASTC_5x5_SFLOAT_BLOCK_EXT  : Result := ASTC_5x5_SFLOAT_BLOCK_EXT;
             VK_FORMAT_ASTC_6x5_SFLOAT_BLOCK_EXT  : Result := ASTC_6x5_SFLOAT_BLOCK_EXT;
             VK_FORMAT_ASTC_6x6_SFLOAT_BLOCK_EXT  : Result := ASTC_6x6_SFLOAT_BLOCK_EXT;
             VK_FORMAT_ASTC_8x5_SFLOAT_BLOCK_EXT  : Result := ASTC_8x5_SFLOAT_BLOCK_EXT;
             VK_FORMAT_ASTC_8x6_SFLOAT_BLOCK_EXT  : Result := ASTC_8x6_SFLOAT_BLOCK_EXT;
             VK_FORMAT_ASTC_8x8_SFLOAT_BLOCK_EXT  : Result := ASTC_8x8_SFLOAT_BLOCK_EXT;
             VK_FORMAT_ASTC_10x5_SFLOAT_BLOCK_EXT : Result := ASTC_10x5_SFLOAT_BLOCK_EXT;
             VK_FORMAT_ASTC_10x6_SFLOAT_BLOCK_EXT : Result := ASTC_10x6_SFLOAT_BLOCK_EXT;
             VK_FORMAT_ASTC_10x8_SFLOAT_BLOCK_EXT : Result := ASTC_10x8_SFLOAT_BLOCK_EXT;
             VK_FORMAT_ASTC_10x10_SFLOAT_BLOCK_EXT: Result := ASTC_10x10_SFLOAT_BLOCK_EXT;
             VK_FORMAT_ASTC_12x10_SFLOAT_BLOCK_EXT: Result := ASTC_12x10_SFLOAT_BLOCK_EXT;
             VK_FORMAT_ASTC_12x12_SFLOAT_BLOCK_EXT: Result := ASTC_12x12_SFLOAT_BLOCK_EXT;
             VK_FORMAT_G8B8G8R8_422_UNORM         : Result := G8B8G8R8_422_UNORM;
             VK_FORMAT_B8G8R8G8_422_UNORM         : Result := B8G8R8G8_422_UNORM;
             VK_FORMAT_G8_B8_R8_3PLANE_420_UNORM  : Result := G8_B8_R8_3PLANE_420_UNORM;
             VK_FORMAT_G8_B8R8_2PLANE_420_UNORM   : Result := G8_B8R8_2PLANE_420_UNORM;
             VK_FORMAT_G8_B8_R8_3PLANE_422_UNORM  : Result := G8_B8_R8_3PLANE_422_UNORM;
             VK_FORMAT_G8_B8R8_2PLANE_422_UNORM   : Result := G8_B8R8_2PLANE_422_UNORM;
             VK_FORMAT_G8_B8_R8_3PLANE_444_UNORM  : Result := G8_B8_R8_3PLANE_444_UNORM;
             VK_FORMAT_R10X6_UNORM_PACK16         : Result := R10X6_UNORM_PACK16;
             VK_FORMAT_R10X6G10X6_UNORM_2PACK16   : Result := R10X6_UNORM_PACK16;
             VK_FORMAT_R10X6G10X6B10X6A10X6_UNORM_4PACK16         : Result := R10X6G10X6B10X6A10X6_UNORM_4PACK16;
             VK_FORMAT_G10X6B10X6G10X6R10X6_422_UNORM_4PACK16     : Result := G10X6B10X6G10X6R10X6_422_UNORM_4PACK16;
             VK_FORMAT_B10X6G10X6R10X6G10X6_422_UNORM_4PACK16     : Result := B10X6G10X6R10X6G10X6_422_UNORM_4PACK16;
             VK_FORMAT_G10X6_B10X6_R10X6_3PLANE_420_UNORM_3PACK16 : Result := G10X6_B10X6_R10X6_3PLANE_420_UNORM_3PACK16;
             VK_FORMAT_G10X6_B10X6R10X6_2PLANE_420_UNORM_3PACK16  : Result := G10X6_B10X6R10X6_2PLANE_420_UNORM_3PACK16;
             VK_FORMAT_G10X6_B10X6_R10X6_3PLANE_422_UNORM_3PACK16 : Result := G10X6_B10X6_R10X6_3PLANE_422_UNORM_3PACK16;
             VK_FORMAT_G10X6_B10X6R10X6_2PLANE_422_UNORM_3PACK16  : Result := G10X6_B10X6R10X6_2PLANE_422_UNORM_3PACK16;
             VK_FORMAT_G10X6_B10X6_R10X6_3PLANE_444_UNORM_3PACK16 : Result := G10X6_B10X6_R10X6_3PLANE_444_UNORM_3PACK16;
             VK_FORMAT_R12X4_UNORM_PACK16                         : Result := R12X4_UNORM_PACK16;
             VK_FORMAT_R12X4G12X4_UNORM_2PACK16                   : Result := R12X4G12X4_UNORM_2PACK16;
             VK_FORMAT_R12X4G12X4B12X4A12X4_UNORM_4PACK16         : Result := R12X4G12X4B12X4A12X4_UNORM_4PACK16;
             VK_FORMAT_G12X4B12X4G12X4R12X4_422_UNORM_4PACK16     : Result := G12X4B12X4G12X4R12X4_422_UNORM_4PACK16;
             VK_FORMAT_B12X4G12X4R12X4G12X4_422_UNORM_4PACK16     : Result := B12X4G12X4R12X4G12X4_422_UNORM_4PACK16;
             VK_FORMAT_G12X4_B12X4_R12X4_3PLANE_420_UNORM_3PACK16 : Result := G12X4_B12X4_R12X4_3PLANE_420_UNORM_3PACK16;
             VK_FORMAT_G12X4_B12X4R12X4_2PLANE_420_UNORM_3PACK16  : Result := G12X4_B12X4R12X4_2PLANE_420_UNORM_3PACK16;
             VK_FORMAT_G12X4_B12X4_R12X4_3PLANE_422_UNORM_3PACK16 : Result := G12X4_B12X4_R12X4_3PLANE_422_UNORM_3PACK16;
             VK_FORMAT_G12X4_B12X4R12X4_2PLANE_422_UNORM_3PACK16  : Result := G12X4_B12X4R12X4_2PLANE_422_UNORM_3PACK16;
             VK_FORMAT_G12X4_B12X4_R12X4_3PLANE_444_UNORM_3PACK16 : Result := G12X4_B12X4_R12X4_3PLANE_444_UNORM_3PACK16;
             VK_FORMAT_G16B16G16R16_422_UNORM         : Result := G16B16G16R16_422_UNORM;
             VK_FORMAT_B16G16R16G16_422_UNORM         : Result := B16G16R16G16_422_UNORM;
             VK_FORMAT_G16_B16_R16_3PLANE_420_UNORM   : Result := G16_B16_R16_3PLANE_420_UNORM;
             VK_FORMAT_G16_B16R16_2PLANE_420_UNORM    : Result := G16_B16R16_2PLANE_420_UNORM;
             VK_FORMAT_G16_B16_R16_3PLANE_422_UNORM   : Result := G16_B16_R16_3PLANE_422_UNORM;
             VK_FORMAT_G16_B16R16_2PLANE_422_UNORM    : Result := G16_B16R16_2PLANE_422_UNORM;
             VK_FORMAT_G16_B16_R16_3PLANE_444_UNORM   : Result := G16_B16_R16_3PLANE_444_UNORM;
             VK_FORMAT_ASTC_3x3x3_UNORM_BLOCK_EXT     : Result := ASTC_3x3x3_UNORM_BLOCK_EXT;
             VK_FORMAT_ASTC_3x3x3_SRGB_BLOCK_EXT      : Result := ASTC_3x3x3_SRGB_BLOCK_EXT;
             VK_FORMAT_ASTC_3x3x3_SFLOAT_BLOCK_EXT    : Result := ASTC_3x3x3_SFLOAT_BLOCK_EXT;
             VK_FORMAT_ASTC_4x3x3_UNORM_BLOCK_EXT     : Result := ASTC_4x3x3_UNORM_BLOCK_EXT;
             VK_FORMAT_ASTC_4x3x3_SRGB_BLOCK_EXT      : Result := ASTC_4x3x3_SRGB_BLOCK_EXT;
             VK_FORMAT_ASTC_4x3x3_SFLOAT_BLOCK_EXT    : Result := ASTC_4x3x3_SFLOAT_BLOCK_EXT;
             VK_FORMAT_ASTC_4x4x3_UNORM_BLOCK_EXT     : Result := ASTC_4x4x3_UNORM_BLOCK_EXT;
             VK_FORMAT_ASTC_4x4x3_SRGB_BLOCK_EXT      : Result := ASTC_4x4x3_SRGB_BLOCK_EXT;
             VK_FORMAT_ASTC_4x4x3_SFLOAT_BLOCK_EXT    : Result := ASTC_4x4x3_SFLOAT_BLOCK_EXT;
             VK_FORMAT_ASTC_4x4x4_UNORM_BLOCK_EXT     : Result := ASTC_4x4x4_UNORM_BLOCK_EXT;
             VK_FORMAT_ASTC_4x4x4_SRGB_BLOCK_EXT      : Result := ASTC_4x4x4_SRGB_BLOCK_EXT;
             VK_FORMAT_ASTC_4x4x4_SFLOAT_BLOCK_EXT    : Result := ASTC_4x4x4_SFLOAT_BLOCK_EXT;
             VK_FORMAT_ASTC_5x4x4_UNORM_BLOCK_EXT     : Result := ASTC_5x4x4_UNORM_BLOCK_EXT;
             VK_FORMAT_ASTC_5x4x4_SRGB_BLOCK_EXT      : Result := ASTC_5x4x4_SRGB_BLOCK_EXT;
             VK_FORMAT_ASTC_5x4x4_SFLOAT_BLOCK_EXT    : Result := ASTC_5x4x4_SFLOAT_BLOCK_EXT;
             VK_FORMAT_ASTC_5x5x4_UNORM_BLOCK_EXT     : Result := ASTC_5x5x4_UNORM_BLOCK_EXT;
             VK_FORMAT_ASTC_5x5x4_SRGB_BLOCK_EXT      : Result := ASTC_5x5x4_SRGB_BLOCK_EXT;
             VK_FORMAT_ASTC_5x5x4_SFLOAT_BLOCK_EXT    : Result := ASTC_5x5x4_SFLOAT_BLOCK_EXT;
             VK_FORMAT_ASTC_5x5x5_UNORM_BLOCK_EXT     : Result := ASTC_5x5x5_UNORM_BLOCK_EXT;
             VK_FORMAT_ASTC_5x5x5_SRGB_BLOCK_EXT      : Result := ASTC_5x5x5_SRGB_BLOCK_EXT;
             VK_FORMAT_ASTC_5x5x5_SFLOAT_BLOCK_EXT    : Result := ASTC_5x5x5_SFLOAT_BLOCK_EXT;
             VK_FORMAT_ASTC_6x5x5_UNORM_BLOCK_EXT     : Result := ASTC_6x5x5_UNORM_BLOCK_EXT;
             VK_FORMAT_ASTC_6x5x5_SRGB_BLOCK_EXT      : Result := ASTC_6x5x5_SRGB_BLOCK_EXT;
             VK_FORMAT_ASTC_6x5x5_SFLOAT_BLOCK_EXT    : Result := ASTC_6x5x5_SFLOAT_BLOCK_EXT;
             VK_FORMAT_ASTC_6x6x5_UNORM_BLOCK_EXT     : Result := ASTC_6x6x5_UNORM_BLOCK_EXT;
             VK_FORMAT_ASTC_6x6x5_SRGB_BLOCK_EXT      : Result := ASTC_6x6x5_SRGB_BLOCK_EXT;
             VK_FORMAT_ASTC_6x6x5_SFLOAT_BLOCK_EXT    : Result := ASTC_6x6x5_SFLOAT_BLOCK_EXT;
             VK_FORMAT_ASTC_6x6x6_UNORM_BLOCK_EXT     : Result := ASTC_6x6x6_UNORM_BLOCK_EXT;
             VK_FORMAT_ASTC_6x6x6_SRGB_BLOCK_EXT      : Result := ASTC_6x6x6_SRGB_BLOCK_EXT;
             VK_FORMAT_ASTC_6x6x6_SFLOAT_BLOCK_EXT    : Result := ASTC_6x6x6_SFLOAT_BLOCK_EXT;
             VK_FORMAT_A4R4G4B4_UNORM_PACK16_EXT      : Result := A4R4G4B4_UNORM_PACK16_EXT;
             VK_FORMAT_A4B4G4R4_UNORM_PACK16_EXT      : Result := A4B4G4R4_UNORM_PACK16_EXT;

           Else
             Result:=UNDEFINED;
        End;

      End;

end.
