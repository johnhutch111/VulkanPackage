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

 unit Vulkan_Components;

interface

{*R *.res}

{$INCLUDE VulkanPackage.inc}

uses

  {$IFDEF FASTMM5}
  FastMM5,
  {$ENDIF}
  System.SysUtils,
  System.Generics.Collections,   //MUST STAY HERE
  System.Generics.Defaults,
  System.Classes,                //MUST STAY HERE
  System.Math,
  System.SyncObjs,
  {$IFDEF TIMINGON}
  System.Diagnostics,
  {$ENDIF}
  typinfo,
//  CommThread,
//  VCL.Dialogs,
  Vulkan,
  PasVulkan.Types,
  PasVulkan.Math,
  PasVulkan.Collections,
  PasVulkan.Framework,
  Vulkan_Components_Lookups;

Const
  DesignerTest       : Boolean = True;
  NotificationTestON : Boolean = True;

  MaxFramesInFlight  : TvkUint32 = 2;    //IMPORTANT  Used Everywhere


Var
  IgnorecsLoading    : Boolean = False;

  ShaderFolderPath     : String = 'C:\ProgramData\Datavis\VulkanShaders\';
  TextureFolderPath    : String = 'C:\ProgramData\Datavis\Textures\';
  ExecutableFolderPath : String = '';  //optional if Shaders in ShaderFolderPath

type

   EvgVulkanException=class(Exception);

   EvgVulkanResultException=class(EvgVulkanException)
    public
     constructor Create(const aResultCode: TVkResult; const aMsg: String);
     destructor Destroy; override;
   end;

   TvgCriticalSection = class(TCriticalSection)
      protected
         FDummy : array [0..95] of Byte;   //fixes issue of object size and  CPU cache.  Not used for anything else
      public
//         function WaitFor(Timeout: LongWord = INFINITE): TWaitResult; overload; override;   //promoted from ancester

   end;


  TvgInstance             = class;
  TvgPhysicalDevice       = class;
  TvgLogicalDevice        = Class;
  TvgScreenRenderDevice   = Class;
  TvgSurface              = Class;
  TvgSwapChain            = Class;
  TvgCommandBuffer        = Class;
  TvgCommandBufferPool    = Class;
  TvgVertexInputState     = Class;
  TvgColorBlendingState   = Class;
  TvgDescriptorCol        = Class;
  TvgDescriptorItem       = Class;
  TvgDescriptor           = Class;
  TvgPushConstantCol      = Class;
  TvgPushConstantItem     = Class;
  TvgPushConstant         = Class;
  TvgGraphicPipeline     = Class;
  TvgRenderPass           = Class;
  TvgFrame                = Class;
  TvgSubPass              = Class;
  TvgAttachment           = Class;
  TvgAttachmentCol        = Class;
  TvgSubPassAttachmentCol = Class;
  TvgLinker               = Class;
  TvgRenderEngine         = Class;
  TvgRenderNode           = Class;
  TvgRenderObject         = Class;

  TvgRenderPassType       = Class of TvgRenderPass;
  TvgRenderNodeType       = Class of TvgRenderNode;
  TvgGraphicsPipelineType = Class of TvgGraphicPipeline;  //for graph pipe registration


  TvgPipeTypeRec = Record
    fRenderPassType      : TvgRenderPassType;
    fSubPassRef          : Integer;
    fRenderNodeType      : TvgRenderNodeType;
    fGraphicPipelineType : TvgGraphicsPipelineType;
    fGraphicPipeline     : TvgGraphicPipeline;
  end;

  //base class for all Tvg... component descendants

  TvgBaseComponent = Class(TComponent )
  Protected
       fActive         : Boolean;
       fActiveChanging : Boolean;

       Procedure SetActiveState(aValue:Boolean);

       Procedure SetDisabled ; Virtual;
       Procedure SetDesigning; Virtual;
       Procedure SetEnabled(aComp:TvgBaseComponent=nil);   Virtual;  //if aComp Set then SetEnabled
       Procedure DisableParent(ToRoot:Boolean=False);      Virtual;  //If ToRoot True then disable will continue up to Root (Instance)


  End;

  IvgVulkanWindow = Interface(IInterface) ['{EC91ACF3-625C-4B72-87A4-56BC16E2EAF8}']

    function GetLinker: TvgLinker;
    procedure SetLinker(const Value: TvgLinker);

     Procedure SetDisabled ;
     Procedure SetDesigning;
     Procedure SetEnabled(aComp:TvgBaseComponent=nil);
 //    Procedure EnableParent;
     Procedure DisableParent(ToRoot:Boolean=False);


    Procedure vgWindowSizeCallback(var WinWidth, WinHeight : TvkUint32);  //pixels
    Procedure vgWindowInvalidate( DoPaint:Boolean);
    Procedure vgWindowBackgroundColor(Var aColor:TVkClearValue);
    Function  vgWindowGetSurface(var aSurface :TVkSurfaceKHR):Boolean;

  {$if defined(Android)}
    Procedure SurfaceWinPlatformCallback(Var aWindow:PVkAndroidANativeWindow);
{$ifend}
{$if defined(Wayland) and defined(Unix)}
    Procedure SurfaceWinPlatformCallback(var aDisplay:PVkWaylandDisplay;var aSurface:PVkWaylandSurface );
{$ifend}
{$if defined(Win32) or defined(Win64)}
    Procedure SurfaceWinPlatformCallback(var aWinInstance : TVkHWND;Var aModInstance : TVkHINSTANCE);
{$ifend}
{$if defined(XCB) and defined(Unix)}
    Procedure SurfaceWinPlatformCallback(Var aConnection:PVkXCBConnection; Var aWindow:TVkXCBWindow);
{$ifend}
{$if defined(XLIB) and defined(Unix)}
    Procedure SurfaceWinPlatformCallback(Var aDisplay:PVkXLIBDisplay; Var aWindow:TVkXLIBWindow);
{$ifend}
{$if defined(MoltenVK_IOS) and defined(Darwin)}
    Procedure SurfaceWinPlatformCallback(Var aView:PVkVoid );
{$ifend}
{$if defined(MoltenVK_MacOS) and defined(Darwin)}
    Procedure SurfaceWinPlatformCallback(Var aView:PVkVoid );
{$ifend}

   Property Linker : TvgLinker read GetLinker write SetLinker;

  End;

  TvgExtension = Class(TCollectionItem)
  private
    function GetExtensionName: TpvVulkanCharString;
    function GetExtMode: TvgExtensionRequireMode;
    function GetFullName: String;
    function GetLayerIndex: TvkUint32;
    function GetSpecVersion: TvkUint32;
    procedure SetExtMode(const Value: TvgExtensionRequireMode);
    function GetvgOwner: TComponent;
    procedure SetvgOwner(const Value: TComponent);

  protected
      fExtMode      : TvgExtensionRequireMode;
      fEnabled      : Boolean;
      fvgOwner      : TComponent;//fvgInstance or fvgDevice;

      fLayerIndex   : TvkUint32;
      fExtensionName: TpvVulkanCharString;
      fSpecVersion  : TvkUint32;

       procedure DefineProperties(Filer: TFiler); override;
       function GetDisplayName: string; override;

       procedure ReadLayerIndex(Reader: TReader);
       procedure WriteLayerIndex(Writer: TWriter);
       procedure ReadSpecVersion(Reader: TReader);
       procedure WriteSpecVersion(Writer: TWriter);
       procedure ReadExtName(Reader: TReader);
       procedure WriteExtName(Writer: TWriter);

  Public

      constructor Create(Collection: TCollection); override;
      procedure Assign(Source: TPersistent);   override;

      Procedure SetData(aExtRec:PpvVulkanAvailableExtension);

      Property FullName : String read GetFullName;
      Property vgOwner  : TComponent read GetvgOwner write SetvgOwner;

  published
      Property ExtMode      : TvgExtensionRequireMode read GetExtMode write SetExtMode default VGE_NOT_REQUIRED;
      Property VulkanEnabled: Boolean read fEnabled;                     //read only
      Property LayerIndex   : TvkUint32 read GetLayerIndex;              //read ONLY
      Property ExtensionName: TpvVulkanCharString read GetExtensionName;    //Read Only
      Property SpecVersion  : TvkUint32 read GetSpecVersion;              //Read Only

  End;

  TvgExtensions = class(TCollection)
  private
    fOwner     : TvgBaseComponent;
    fCollString: string;

    function GetItem(Index: Integer): TvgExtension;
    procedure SetItem(Index: Integer; const Value: TvgExtension);
//    function GetInstance: TvgInstance;

  Protected
    function GetOwner: TPersistent; override;
    procedure Update(Item: TCollectionItem); override;

  public
    constructor Create(aOwner: TvgBaseComponent);
    function Add: TvgExtension;
    function AddItem(Item: TvgExtension; Index: Integer): TvgExtension;
    function Insert(Index: Integer): TvgExtension;
    property Items[Index: Integer]: TvgExtension read GetItem write SetItem; default;

  end;

  TvgLayer = Class(TCollectionItem)
  private
    function GetDescription: String;
    function GetImplementationVersion: TvkUint32;
    function GetLayerMode: TvgLayerRequireMode;
    function GetLayerName: TpvVulkanCharString;
    function GetSpecVersion: TvkUint32;
    procedure SetDescription(const Value: String);
    procedure SetLayerMode(const Value: TvgLayerRequireMode);
    function GetFullName: String;
    function GetvgOwner: TComponent;
    procedure SetvgOwner(const Value: TComponent);

  Protected
      fLayerMode             : TvgLayerRequireMode;
      fEnabled               : Boolean;
      fvgOwner               : TComponent;//fvgInstance or fvgDevice;

      fDescription           : String;

      fLayerName             : TpvVulkanCharString;    //ansistring    //read ONLY
      fSpecVersion           : TvkUint32;                              //read ONLY
      fImplementationVersion : TvkUint32;                              //read ONLY

       procedure DefineProperties(Filer: TFiler); override;
       function GetDisplayName: string; override;

       procedure ReadLayer(Reader: TReader);
       procedure WriteLayer(Writer: TWriter);
       procedure ReadSpecVersion(Reader: TReader);
       procedure WriteSpecVersion(Writer: TWriter);
       procedure ReadImplementationVer(Reader: TReader);
       procedure WriteImplementationVer(Writer: TWriter);

  Public

      constructor Create(Collection: TCollection); override;
      procedure Assign(Source: TPersistent); override;

      Procedure SetData(aLayerRec:ppvVulkanAvailableLayer);

      Property FullName : String read GetFullName;
      Property vgOwner  : TComponent read GetvgOwner write SetvgOwner;

  Published

      Property Description          :String read GetDescription write SetDescription;
      Property Enabled              : Boolean read fEnabled;
      Property LayerMode            :TvgLayerRequireMode read GetLayerMode   write SetLayerMode default VGL_NOT_REQUIRED;

      Property ImplementationVersion:TvkUint32 read GetImplementationVersion stored False;
      Property LayerName            :TpvVulkanCharString read GetLayerName stored False;    //ansistring
      Property SpecVersion          :TvkUint32 read GetSpecVersion stored False;
  End;

  TvgLayers = class(TCollection)
  private
    FOwner      : TvgBaseComponent;
    FCollString : string;

    function GetItem(Index: Integer): TvgLayer;
    procedure SetItem(Index: Integer; const Value: TvgLayer);

  Protected
    function GetOwner: TPersistent; override;
    procedure Update(Item: TCollectionItem); override;

  public
    constructor Create (aOwner: TvgBaseComponent);

    function Add: TvgLayer;
    function AddItem(Item: TvgLayer; Index: Integer): TvgLayer;
    function Insert(Index: Integer): TvgLayer;
    property Items[Index: Integer]: TvgLayer read GetItem write SetItem; default;
  end;

  TvgPhysDevice = Class(TCollectionItem)
  private
    function GetDescription: String;

  protected
    fVulkanPhysicalDevice : TpvVulkanPhysicalDevice;
    fPhysicalDeviceName   : String;
    fDeviceType           : TVkPhysicalDeviceType;

    function GetDisplayName: string; override;

  public

    constructor Create(Collection: TCollection); override;

    Procedure SetData(aPhyDev : TpvVulkanPhysicalDevice);

    Property VulkanPhysicalDevice : TpvVulkanPhysicalDevice read fVulkanPhysicalDevice;

  published
    Property Description : String read GetDescription;
    Property DeviceType  : TVkPhysicalDeviceType read fDeviceType;


  End;

  TvgPhysDevices = class(TCollection)
    private
    FComp      : TvgInstance;
    FCollString: string;

    function GetItem(Index: Integer): TvgPhysDevice;
    procedure SetItem(Index: Integer; const Value: TvgPhysDevice);

  Protected
    function GetOwner: TPersistent; override;
    procedure Update(Item: TCollectionItem); override;

  public
    constructor Create (CollOwner: TvgInstance);

    property Items[Index: Integer]: TvgPhysDevice read GetItem write SetItem; default;
  end;

 TvgVulkanAllocationManager=class(TpvVulkanAllocationManager)

  protected

    fAllocatedList  : TList<Pointer>;

   function AllocationCallback(const Size:TVkSize;const Alignment:TVkSize;const Scope:TVkSystemAllocationScope):PVkVoid; Override;
   function ReallocationCallback(const Original:PVkVoid;const Size:TVkSize;const Alignment:TVkSize;const Scope:TVkSystemAllocationScope):PVkVoid; Override;
   procedure FreeCallback(const Memory:PVkVoid); Override;

   Procedure FreeAllMemory;

  public
   constructor Create;
   destructor Destroy; override;

 end;

  TvgLayerSetupCallback          = Procedure(aLayers:TvgLayers) of Object;
  TvgExtensionSetupCallback      = Procedure(aExtensions:TvgExtensions) of Object;
  TvgPhysicalDeviceSetupCallback = Procedure(aPhysicalDevices:TvgPhysDevices) of Object;

  TvgInstance = class(TvgBaseComponent)
  private
  //  function GetAPIVersion: TvkUint32;
    function GetApplicationName: TpvVulkanCharString;
    function GetApplicationVersion: TvkUint32;
    function GetEngineName: TpvVulkanCharString;
    function GetEngineVersion: TvkUint32;
 //   procedure SetAPIVersion(const Value: TvkUint32);
    procedure SetApplicationName(const Value: TpvVulkanCharString);
    procedure SetApplicationVersion(const Value: TvkUint32);
    procedure SetEngineName(const Value: TpvVulkanCharString);
    procedure SetEngineVersion(const Value: TvkUint32);
    function GetValidation: Boolean;
    procedure SetValidation(const Value: Boolean);
    function GetActive: Boolean;
    procedure SetActive(const Value: Boolean);
    function GetAllocationMode: TvgAllocationMode;
    procedure SetAllocationMode(const Value: TvgAllocationMode);
    procedure SetLayers(const Value: TvgLayers);
    procedure SetExtensions(const Value: TvgExtensions);
    function GetRenderToScreen: Boolean;
    procedure SetRenderToScreen(const Value: Boolean);
    function GetDevice(Index: Integer): TvgPhysicalDevice;
    function GetDevicesCount: Integer;
    procedure SetPhysicalDevices(const Value: TvgPhysDevices);
    function GetVulkanAPIVersion: TvgAPI_Version;
    procedure SetVulkanAPIVersion(const Value: TvgAPI_Version);

    { Private declarations }
  protected
    { Protected declarations }

       fVulkanInstance                : TpvVulkanInstance;
       fVulkanStatus                  : TvgInstanceResult;

       fApplicationName               : TpvVulkanCharString;
       fpplicationVersion             : TvkUint32;
       fEngineName                    : TpvVulkanCharString;
       fengineVersion                 : TvkUint32;
       fAPIVersion                    : TvgAPI_Version;

       fValidation                    : Boolean;
 //      fRenderDoc                     : Boolean;
       fRenderToScreen                : Boolean;

       fOnInstanceDebugReportCallback : TpvVulkanInstanceDebugReportCallback;

       fAllocationStatus    : TvgAllocationMode;
       fAllocationManager   : TpvVulkanAllocationManager;//TvgVulkanAllocationManager;

       fLayers              : TvgLayers;
       fExtensions          : TvgExtensions;
       fPhysicalDeviceList  : TvgPhysDevices;
       fPhysicalDevices     : TList<TvgPhysicalDevice>;

       fOnLayerSetup        : TvgLayerSetupCallback;
       fOnExtensionSetup    : TvgExtensionSetupCallback;

       procedure Notification(AComponent: TComponent; Operation: TOperation); override;
       Procedure Loaded;Override;

       Function GetAPIVersion : TvkUint32;
       Procedure SetAPIVersion(Value:TvkUint32);

       Procedure SetUpLayers;
       Procedure SetUpExtensions;
       Procedure SetUpScreenExtensions;
       Procedure SetUpValidationExtensions;
       Procedure SetUpValidationLayers;
       Procedure SetUpPortabilityExtensions;

       Procedure SetUpPhysicalDevices;

       Procedure EnableDevices;
       Procedure DisableDevices;

       Procedure SetUpMemoryAllocation;

       Procedure SetDisabled ; Override;
       Procedure SetDesigning; Override;
       Procedure SetEnabled(aComp:TvgBaseComponent=nil);   Override;
       Procedure DisableParent(ToRoot:Boolean=False); Override;

       Function CheckVulkanHardwareStatus : Boolean;

  public
    { Public declarations }
    constructor Create(AOwner: TComponent); Override;
    destructor Destroy; override;

    Procedure BuildAllExtensionsAndLayers;
    Procedure ClearAllExtensionsAndlayers;

    Procedure BuildALLLayers;
    Function BuildLayer(aLayer:ppvVulkanAvailableLayer):TvgLayer;
    Function DoesLayerExist(aLayer:ppvVulkanAvailableLayer):Boolean;
    Procedure RemoveALLLayers;

    Procedure BuildALLExtensions;
    Function BuildExtension(aExt:PpvVulkanAvailableExtension):TvgExtension;
    Function DoesExtensionExist(aExt:PpvVulkanAvailableExtension):Boolean;
    Procedure RemoveALLExtensions;

    Procedure AddDevice(aDevice:TvgPhysicalDevice);
    Procedure RemoveDevice(aDevice:TvgPhysicalDevice);

    property AllocationManager       : TpvVulkanAllocationManager read fAllocationManager;
    property Devices[Index: Integer] : TvgPhysicalDevice read GetDevice;
    property DevicesCount            : Integer read GetDevicesCount;

    property VulkanInstance          : TpvVulkanInstance read fVulkanInstance;

  published
    { Published declarations }

     Property Active            : Boolean  Read GetActive  write SetActive stored False;
     property ApplicationName   : TpvVulkanCharString read GetApplicationName write SetApplicationName ;
     property ApplicationVersion: TvkUint32 read GetApplicationVersion write SetApplicationVersion default 1;
     property APIVersion        : TvgAPI_Version read GetVulkanAPIVersion  write SetVulkanAPIVersion ;
     property EngineName        : TpvVulkanCharString read GetEngineName write SetEngineName ;
     property EngineVersion     : TvkUint32 read GetEngineVersion write SetEngineVersion default 1;
     property Extensions        : TvgExtensions read fExtensions write SetExtensions;
     property Layers            : TvgLayers read fLayers write SetLayers;
     property PhysicalDevices   : TvgPhysDevices read fPhysicalDeviceList write SetPhysicalDevices stored false;

     Property MemAllocation     : TvgAllocationMode Read GetAllocationMode write SetAllocationMode default VG_SELF_MANAGE;

     Property RenderToScreen    : Boolean read GetRenderToScreen write SetRenderToScreen default false;
     //if true the screen rendering extensions MUST be available and enabled
     property Validation        : Boolean read GetValidation write SetValidation default false;
     Property VulkanStatus      : TvgInstanceResult read fVulkanStatus;

     property OnExtensionSetup    : TvgExtensionSetupCallback read fOnExtensionSetup write fOnExtensionSetup;
     property OnInstanceDebugReportCallback:TpvVulkanInstanceDebugReportCallback read fOnInstanceDebugReportCallback write fOnInstanceDebugReportCallback;
     property OnLayerSetup        : TvgLayerSetupCallback read fOnLayerSetup write fOnLayerSetup;

  end;

  TvgQueueFamily = class(TPersistent)
  private
    function GetQueFamilyMode: TvgQueueFamilyMode;
    procedure SetQueFamilyMode(const Value: TvgQueueFamilyMode);
    function GetQueueCount: Integer;

  protected
    fQueueFamilyMode    : TvgQueueFamilyMode;
    fEnabled            : Boolean;

    fQueueFamilyIndex   : TvkInt32  ;
    fqueueFlags         : TVkQueueFlags;
    fqueueCount         : TvkUint32;
    ftimestampValidBits : TvkUint32;
    fminImageTransferGranularity : TVkExtent3D;
    fSupportSurface     : Boolean;

   procedure DefineProperties(Filer: TFiler); override;
   procedure ReadQueueFamilyValues(Reader: TReader);
   procedure WriteQueueFamilyValues(Writer: TWriter);

  Public

    constructor Create;

    Procedure SetData( aIndex : TvkUint32; aQueueFamilyRec : PVkQueueFamilyProperties);
    Procedure Clear;

  published

    Property QueueCount       : Integer Read GetQueueCount;
    Property QueueFamilyMode  : TvgQueueFamilyMode read GetQueFamilyMode write SetQueFamilyMode stored False;
    Property FamilyIndex      : TvkInt32 read  fQueueFamilyIndex stored False;
    Property Enabled          : Boolean read fEnabled stored False;
  end;

  TvgDeviceSelectMode = (vgdsAutomatic,   //highest score
                           vgdsName,  //specified by Name
                           vgdsIndex,     //specified by Index
                           vgdsDiscrete);  //First discrete GPU

  TvgFeatures = class(TvgBaseComponent)
    Private
    function GetLogicalDevice: TvgLogicalDevice;
    procedure SetLogicalDevice(const Value: TvgLogicalDevice);

    Protected
       fLogicalDevice       : TvgLogicalDevice ;

       fSetLocked           : Boolean; //if true don't set from Device

       fRequestedFeatures   : TVkPhysicalDeviceFeatures2KHR;
       fRequestedFeatures11 : TVkPhysicalDeviceVulkan11Features;
       fRequestedFeatures12 : TVkPhysicalDeviceVulkan12Features;
       fRequestedFeatures13 : TVkPhysicalDeviceVulkan13Features;

       frobustBufferAccess:Boolean;
       ffullDrawIndexUint32:Boolean;
       fimageCubeArray:Boolean;
       findependentBlend:Boolean;
       fgeometryShader:Boolean;
       ftessellationShader:Boolean;
       fsampleRateShading:Boolean;
       fdualSrcBlend:Boolean;
       flogicOp:Boolean;
       fmultiDrawIndirect:Boolean;
       fdrawIndirectFirstInstance:Boolean;
       fdepthClamp:Boolean;
       fdepthBiasClamp:Boolean;
       ffillModeNonSolid:Boolean;
       fdepthBounds:Boolean;
       fwideLines:Boolean;
       flargePoints:Boolean;
       falphaToOne:Boolean;
       fmultiViewport:Boolean;
       fsamplerAnisotropy:Boolean;
       ftextureCompressionETC2:Boolean;
       ftextureCompressionASTC_LDR:Boolean;
       ftextureCompressionBC:Boolean;
       focclusionQueryPrecise:Boolean;
       fpipelineStatisticsQuery:Boolean;
       fvertexPipelineStoresAndAtomics:Boolean;
       ffragmentStoresAndAtomics:Boolean;
       fshaderTessellationAndGeometryPointSize:Boolean;
       fshaderImageGatherExtended:Boolean;
       fshaderStorageImageExtendedFormats:Boolean;
       fshaderStorageImageMultisample:Boolean;
       fshaderStorageImageReadWithoutFormat:Boolean;
       fshaderStorageImageWriteWithoutFormat:Boolean;
       fshaderUniformBufferArrayDynamicIndexing:Boolean;
       fshaderSampledImageArrayDynamicIndexing:Boolean;
       fshaderStorageBufferArrayDynamicIndexing:Boolean;
       fshaderStorageImageArrayDynamicIndexing:Boolean;
       fshaderClipDistance:Boolean;
       fshaderCullDistance:Boolean;
       fshaderFloat64:Boolean;
       fshaderInt64:Boolean;
       fshaderInt16:Boolean;
       fshaderResourceResidency:Boolean;
       fshaderResourceMinLod:Boolean;
       fsparseBinding:Boolean;
       fsparseResidencyBuffer:Boolean;
       fsparseResidencyImage2D:Boolean;
       fsparseResidencyImage3D:Boolean;
       fsparseResidency2Samples:Boolean;
       fsparseResidency4Samples:Boolean;
       fsparseResidency8Samples:Boolean;
       fsparseResidency16Samples:Boolean;
       fsparseResidencyAliased:Boolean;
       fvariableMultisampleRate:Boolean;
       finheritedQueries:Boolean;

   //Ver 1_1
       fstorageBuffer16BitAccess:Boolean;
       funiformAndStorageBuffer16BitAccess:Boolean;
       fstoragePushConstant16:Boolean;
       fstorageInputOutput16:Boolean;
       fmultiview:Boolean;
       fmultiviewGeometryShader:Boolean;
       fmultiviewTessellationShader:Boolean;
       fvariablePointersStorageBuffer:Boolean;
       fvariablePointers:Boolean;
       fprotectedMemory:Boolean;
       fsamplerYcbcrConversion:Boolean;
       fshaderDrawParameters:Boolean;

   //Ver 1_2

       fSamplerMirrorClampToEdge:Boolean;
       fDrawIndirectCount:Boolean;
       fStorageBuffer8BitAccess:Boolean;
       fUniformAndStorageBuffer8BitAccess:Boolean;
       fStoragePushConstant8:Boolean;
       fShaderBufferInt64Atomics:Boolean;
       fShaderSharedInt64Atomics:Boolean;
       fShaderFloat16:Boolean;
       fShaderInt8:Boolean;
       fDescriptorIndexing:Boolean;
       fShaderInputAttachmentArrayDynamicIndexing:Boolean;
       fShaderUniformTexelBufferArrayDynamicIndexing:Boolean;
       fShaderStorageTexelBufferArrayDynamicIndexing:Boolean;
       fShaderUniformBufferArrayNonUniformIndexing:Boolean;
       fShaderSampledImageArrayNonUniformIndexing:Boolean;
       fShaderStorageBufferArrayNonUniformIndexing:Boolean;
       fShaderStorageImageArrayNonUniformIndexing:Boolean;
       fShaderInputAttachmentArrayNonUniformIndexing:Boolean;
       fShaderUniformTexelBufferArrayNonUniformIndexing:Boolean;
       fShaderStorageTexelBufferArrayNonUniformIndexing:Boolean;
       fDescriptorBindingUniformBufferUpdateAfterBind:Boolean;
       fDescriptorBindingSampledImageUpdateAfterBind:Boolean;
       fDescriptorBindingStorageImageUpdateAfterBind:Boolean;
       fDescriptorBindingStorageBufferUpdateAfterBind:Boolean;
       fDescriptorBindingUniformTexelBufferUpdateAfterBind:Boolean;
       fDescriptorBindingStorageTexelBufferUpdateAfterBind:Boolean;
       fDescriptorBindingUpdateUnusedWhilePending:Boolean;
       fDescriptorBindingPartiallyBound:Boolean;
       fDescriptorBindingVariableDescriptorCount:Boolean;
       fRuntimeDescriptorArray:Boolean;
       fSamplerFilterMinmax:Boolean;
       fScalarBlockLayout:Boolean;
       fImagelessFramebuffer:Boolean;
       fUniformBufferStandardLayout:Boolean;
       fShaderSubgroupExtendedTypes:Boolean;
       fSeparateDepthStencilLayouts:Boolean;
       fHostQueryReset:Boolean;
       fTimelineSemaphore:Boolean;
       fBufferDeviceAddress:Boolean;
       fBufferDeviceAddressCaptureReplay:Boolean;
       fBufferDeviceAddressMultiDevice:Boolean;
       fVulkanMemoryModel:Boolean;
       fVulkanMemoryModelDeviceScope:Boolean;
       fVulkanMemoryModelAvailabilityVisibilityChains:Boolean;
       fShaderOutputViewportIndex:Boolean;
       fShaderOutputLayer:Boolean;
       fSubgroupBroadcastDynamicId:Boolean;

   //Ver 1_3

       fRobustImageAccess:Boolean;
       fInlineUniformBlock:Boolean;
       fDescriptorBindingInlineUniformBlockUpdateAfterBind:Boolean;
       fPipelineCreationCacheControl:Boolean;
       fPrivateData:Boolean;
       fShaderDemoteToHelperInvocation:Boolean;
       fShaderTerminateInvocation:Boolean;
       fSubgroupSizeControl:Boolean;
       fComputeFullSubgroups:Boolean;
       fSynchronization2:Boolean;
       fTextureCompressionASTC_HDR:Boolean;
       fShaderZeroInitializeWorkgroupMemory:Boolean;
       fDynamicRendering:Boolean;
       fShaderIntegerDotProduct:Boolean;
       fMaintenance4:Boolean;

       Procedure SetDisabled ; Override;
       Procedure SetDesigning; Override;
       Procedure SetEnabled(aComp:TvgBaseComponent=nil);   Override;

       Function GetVK32Boolean(aval:Boolean):TVkBool32;
       Function GetBoolean(aval:TVkBool32):Boolean;

       Procedure CopyDataToRecords;
       Procedure CopyRecordsToData;
       Procedure UpdateRecordConnections;

    Public
       constructor Create(AOwner: TComponent); Override;

       Property SetLocked : Boolean read fSetLocked;
       Property LogicalDevice :  TvgLogicalDevice read GetLogicalDevice write SetLogicalDevice;

  //  Published   not sure about published in this way
       Property RobustBufferAccess : Boolean Read frobustBufferAccess  Write frobustBufferAccess  ;
       Property FullDrawIndex      : Boolean Read ffullDrawIndexUint32  Write ffullDrawIndexUint32  ;
       Property ImageCubeArray     : Boolean Read fImageCubeArray  Write fImageCubeArray  ;
       Property IndependentBlend   : Boolean Read findependentBlend  Write findependentBlend  ;
       Property GeometryShader     : Boolean Read fGeometryShader  Write fGeometryShader  ;
       Property TessellationShader : Boolean Read fTessellationShader  Write fTessellationShader  ;
       Property SampleRateShading  : Boolean Read fSampleRateShading Write fSampleRateShading ;
       Property DualSrcBlend        : Boolean Read fDualSrcBlend Write fDualSrcBlend ;
       Property LogicOp             : Boolean Read fLogicOp Write fLogicOp ;
       Property MultiDrawIndirect   : Boolean Read fMultiDrawIndirect Write fMultiDrawIndirect ;
       Property DrawIndirectFirstInstance : Boolean Read fDrawIndirectFirstInstance Write fDrawIndirectFirstInstance ;
       Property DepthClamp          : Boolean Read fDepthClamp Write fDepthClamp ;
       Property DepthBiasClamp      : Boolean Read fDepthBiasClamp Write fDepthBiasClamp ;
       Property FillModeNonSolid    : Boolean Read fFillModeNonSolid Write fFillModeNonSolid ;
       Property DepthBounds         : Boolean Read fDepthBounds Write fDepthBounds ;
       Property WideLines           : Boolean Read fWideLines Write fWideLines ;
       Property LargePoints         : Boolean Read fLargePoints Write fLargePoints ;
       Property AlphaToOne         : Boolean Read fAlphaToOne Write fAlphaToOne ;
       Property MultiViewport         : Boolean Read fMultiViewport Write fMultiViewport ;
       Property SamplerAnisotropy         : Boolean Read fSamplerAnisotropy Write fSamplerAnisotropy ;
       Property TextureComprssionETC2         : Boolean Read fTextureCompressionETC2 Write fTextureCompressionETC2 ;
       Property TextureComprssionASTC_LDR         : Boolean Read fTextureCompressionASTC_LDR Write fTextureCompressionASTC_LDR ;
       Property TextureComprssionBC         : Boolean Read fTextureCompressionBC Write fTextureCompressionBC ;
       Property OcclusionQueryPrecise         : Boolean Read fOcclusionQueryPrecise Write fOcclusionQueryPrecise ;
       Property PipelineStatisticsQuery   : Boolean Read fPipelineStatisticsQuery Write fPipelineStatisticsQuery ;
       Property VertexPipelineStoresAndAtomics   : Boolean Read fVertexPipelineStoresAndAtomics Write fVertexPipelineStoresAndAtomics ;
       Property FragmentStoresAndAtomics   : Boolean Read fFragmentStoresAndAtomics Write fFragmentStoresAndAtomics ;
       Property ShaderTessellationAndGeometryPointSize   : Boolean Read fShaderTessellationAndGeometryPointSize Write fShaderTessellationAndGeometryPointSize ;
       Property ShaderImageGatherExtended   : Boolean Read fShaderImageGatherExtended Write fShaderImageGatherExtended ;
       Property ShaderStorageImageExtendedFormats   : Boolean Read fShaderStorageImageExtendedFormats Write fShaderStorageImageExtendedFormats ;
       Property ShaderStorageImageMultisample   : Boolean Read fShaderStorageImageMultisample Write fShaderStorageImageMultisample ;
       Property ShaderStorageImageReadWithoutFormat   : Boolean Read fShaderStorageImageReadWithoutFormat Write fShaderStorageImageReadWithoutFormat ;
       Property ShaderStorageImageWriteWithoutFormat   : Boolean Read fShaderStorageImageWriteWithoutFormat Write fShaderStorageImageWriteWithoutFormat ;
       Property ShaderUniformBufferArrayDynamicIndexing   : Boolean Read fShaderUniformBufferArrayDynamicIndexing Write fShaderUniformBufferArrayDynamicIndexing ;
       Property ShaderSampledImageArrayDynamicIndexing   : Boolean Read fShaderSampledImageArrayDynamicIndexing Write fShaderSampledImageArrayDynamicIndexing ;
       Property ShaderStorageBufferArrayDynamicIndexing   : Boolean Read fShaderStorageBufferArrayDynamicIndexing Write fShaderStorageBufferArrayDynamicIndexing ;
       Property ShaderStorageImageArrayDynamicIndexing   : Boolean Read fShaderStorageImageArrayDynamicIndexing Write fShaderStorageImageArrayDynamicIndexing ;
       Property ShaderClipDistance   : Boolean Read fShaderClipDistance Write fShaderClipDistance ;
       Property ShaderCullDistance   : Boolean Read fShaderCullDistance Write fShaderCullDistance;
       Property ShaderFloat64   : Boolean Read fShaderFloat64 Write fShaderFloat64 ;
       Property ShaderInt64   : Boolean Read fShaderInt64 Write fShaderInt64 ;
       Property ShaderInt16   : Boolean Read fShaderInt16 Write fShaderInt16 ;
       Property ShaderResourceResidency   : Boolean Read fShaderResourceResidency Write fShaderResourceResidency ;
       Property ShaderResourceMinLod   : Boolean Read fShaderResourceMinLod Write fShaderResourceMinLod ;
       Property SparseBinding   : Boolean Read fSparseBinding Write fSparseBinding ;
       Property SparseResidencyBuffer   : Boolean Read fSparseResidencyBuffer Write fSparseResidencyBuffer ;
       Property SparseResidencyImage2D   : Boolean Read fSparseResidencyImage2D Write fSparseResidencyImage2D ;
       Property SparseResidencyImage3D   : Boolean Read fSparseResidencyImage3D Write fSparseResidencyImage3D ;
       Property SparseResidency2Samples   : Boolean Read fSparseResidency2Samples Write fSparseResidency2Samples ;
       Property SparseResidency4Samples   : Boolean Read fSparseResidency4Samples Write fSparseResidency4Samples ;
       Property SparseResidency8Samples   : Boolean Read fSparseResidency8Samples Write fSparseResidency8Samples ;
       Property SparseResidency16Samples   : Boolean Read fSparseResidency16Samples Write fSparseResidency16Samples ;
       Property SparseResidencyAliased   : Boolean Read fSparseResidencyAliased Write fSparseResidencyAliased ;
       Property VariableMultisampleRate   : Boolean Read fVariableMultisampleRate Write fVariableMultisampleRate ;
       Property InheritedQueries   : Boolean Read fInheritedQueries Write fInheritedQueries ;
  //1_1
       Property StorageBuffer16BitAccess   : Boolean Read fStorageBuffer16BitAccess Write fStorageBuffer16BitAccess ;
       Property UniformAndStorageBuffer16BitAccess   : Boolean Read fUniformAndStorageBuffer16BitAccess Write fUniformAndStorageBuffer16BitAccess ;
       Property StoragePushConstant16   : Boolean Read fStoragePushConstant16 Write fStoragePushConstant16 ;
       Property StorageInputOutput16   : Boolean Read fStorageInputOutput16 Write fStorageInputOutput16 ;
       Property Multiview   : Boolean Read fMultiview Write fMultiview ;
       Property MultiviewGeometryShader   : Boolean Read fMultiviewGeometryShader Write fMultiviewGeometryShader ;
       Property MultiviewTessellationShader   : Boolean Read fMultiviewTessellationShader Write fMultiviewTessellationShader ;
       Property VariablePointersStorageBuffer   : Boolean Read fVariablePointersStorageBuffer Write fVariablePointersStorageBuffer ;
       Property VariablePointers   : Boolean Read fVariablePointers Write fVariablePointers ;
       Property ProtectedMemory   : Boolean Read fProtectedMemory Write fProtectedMemory ;
       Property SamplerYcbcrConversion   : Boolean Read fSamplerYcbcrConversion Write fSamplerYcbcrConversion ;
       Property ShaderDrawParameters   : Boolean Read fShaderDrawParameters Write fShaderDrawParameters ;
   //1_2
       Property SamplerMirrorClampToEdge   : Boolean Read fSamplerMirrorClampToEdge Write fSamplerMirrorClampToEdge ;
       Property DrawIndirectCount   : Boolean Read fDrawIndirectCount Write fDrawIndirectCount ;
       Property StorageBuffer8BitAccess   : Boolean Read fStorageBuffer8BitAccess Write fStorageBuffer8BitAccess ;
       Property UniformAndStorageBuffer8BitAccess   : Boolean Read fUniformAndStorageBuffer8BitAccess Write fUniformAndStorageBuffer8BitAccess ;
       Property StoragePushConstant8   : Boolean Read fStoragePushConstant8 Write fStoragePushConstant8 ;
       Property ShaderBufferInt64Atomics   : Boolean Read fShaderBufferInt64Atomics Write fShaderBufferInt64Atomics ;
       Property ShaderSharedInt64Atomics   : Boolean Read fShaderSharedInt64Atomics Write fShaderSharedInt64Atomics ;
       Property ShaderFloat16   : Boolean Read fShaderFloat16 Write fShaderFloat16 ;
       Property ShaderInt8   : Boolean Read fShaderInt8 Write fShaderInt8 ;
       Property DescriptorIndexing   : Boolean Read fDescriptorIndexing Write fDescriptorIndexing ;
       Property ShaderInputAttachmentArrayDynamicIndexing   : Boolean Read fShaderInputAttachmentArrayDynamicIndexing Write fShaderInputAttachmentArrayDynamicIndexing ;
       Property ShaderUniformTexelBufferArrayDynamicIndexing   : Boolean Read fShaderUniformTexelBufferArrayDynamicIndexing Write fShaderUniformTexelBufferArrayDynamicIndexing ;
       Property ShaderStorageTexelBufferArrayDynamicIndexing   : Boolean Read fShaderStorageTexelBufferArrayDynamicIndexing Write fShaderStorageTexelBufferArrayDynamicIndexing ;
       Property ShaderUniformBufferArrayNonUniformIndexing   : Boolean Read fShaderUniformBufferArrayNonUniformIndexing Write fShaderUniformBufferArrayNonUniformIndexing ;
       Property ShaderSampledImageArrayNonUniformIndexing   : Boolean Read fShaderSampledImageArrayNonUniformIndexing Write fShaderSampledImageArrayNonUniformIndexing ;
       Property ShaderStorageBufferArrayNonUniformIndexing   : Boolean Read fShaderStorageBufferArrayNonUniformIndexing Write fShaderStorageBufferArrayNonUniformIndexing ;
       Property ShaderStorageImageArrayNonUniformIndexing   : Boolean Read fShaderStorageImageArrayNonUniformIndexing Write fShaderStorageImageArrayNonUniformIndexing ;
       Property ShaderInputAttachmentArrayNonUniformIndexing   : Boolean Read fShaderInputAttachmentArrayNonUniformIndexing Write fShaderInputAttachmentArrayNonUniformIndexing ;
       Property ShaderUniformTexelBufferArrayNonUniformIndexing   : Boolean Read fShaderUniformTexelBufferArrayNonUniformIndexing Write fShaderUniformTexelBufferArrayNonUniformIndexing ;
       Property ShaderStorageTexelBufferArrayNonUniformIndexing   : Boolean Read fShaderStorageTexelBufferArrayNonUniformIndexing Write fShaderStorageTexelBufferArrayNonUniformIndexing ;
       Property DescriptorBindingUniformBufferUpdateAfterBind   : Boolean Read fDescriptorBindingUniformBufferUpdateAfterBind Write fDescriptorBindingUniformBufferUpdateAfterBind ;
       Property DescriptorBindingSampledImageUpdateAfterBind   : Boolean Read fDescriptorBindingSampledImageUpdateAfterBind Write fDescriptorBindingSampledImageUpdateAfterBind ;
       Property DescriptorBindingStorageImageUpdateAfterBind   : Boolean Read fDescriptorBindingStorageImageUpdateAfterBind Write fDescriptorBindingStorageImageUpdateAfterBind ;
       Property DescriptorBindingStorageBufferUpdateAfterBind   : Boolean Read fDescriptorBindingStorageBufferUpdateAfterBind Write fDescriptorBindingStorageBufferUpdateAfterBind ;
       Property DescriptorBindingUniformTexelBufferUpdateAfterBind   : Boolean Read fDescriptorBindingUniformTexelBufferUpdateAfterBind Write fDescriptorBindingUniformTexelBufferUpdateAfterBind ;
       Property DescriptorBindingStorageTexelBufferUpdateAfterBind   : Boolean Read fDescriptorBindingStorageTexelBufferUpdateAfterBind Write fDescriptorBindingStorageTexelBufferUpdateAfterBind ;
       Property DescriptorBindingUpdateUnusedWhilePending   : Boolean Read fDescriptorBindingUpdateUnusedWhilePending Write fDescriptorBindingUpdateUnusedWhilePending ;
       Property DescriptorBindingPartiallyBound   : Boolean Read fDescriptorBindingPartiallyBound Write fDescriptorBindingPartiallyBound ;
       Property DescriptorBindingVariableDescriptorCount   : Boolean Read fDescriptorBindingVariableDescriptorCount Write fDescriptorBindingVariableDescriptorCount ;
       Property RuntimeDescriptorArray   : Boolean Read fRuntimeDescriptorArray Write fRuntimeDescriptorArray ;
       Property SamplerFilterMinmax   : Boolean Read fSamplerFilterMinmax Write fSamplerFilterMinmax ;
       Property ScalarBlockLayout   : Boolean Read fScalarBlockLayout Write fScalarBlockLayout ;
       Property ImagelessFramebuffer   : Boolean Read fImagelessFramebuffer Write fImagelessFramebuffer ;
       Property UniformBufferStandardLayout   : Boolean Read fUniformBufferStandardLayout Write fUniformBufferStandardLayout ;
       Property ShaderSubgroupExtendedTypes   : Boolean Read fShaderSubgroupExtendedTypes Write fShaderSubgroupExtendedTypes ;
       Property SeparateDepthStencilLayouts   : Boolean Read fSeparateDepthStencilLayouts Write fSeparateDepthStencilLayouts ;
       Property HostQueryReset   : Boolean Read fHostQueryReset Write fHostQueryReset ;
       Property TimelineSemaphore   : Boolean Read fTimelineSemaphore Write fTimelineSemaphore ;
       Property BufferDeviceAddress   : Boolean Read fBufferDeviceAddress Write fBufferDeviceAddress ;
       Property BufferDeviceAddressCaptureReplay   : Boolean Read fBufferDeviceAddressCaptureReplay Write fBufferDeviceAddressCaptureReplay ;
       Property BufferDeviceAddressMultiDevice   : Boolean Read fBufferDeviceAddressMultiDevice Write fBufferDeviceAddressMultiDevice ;
       Property VulkanMemoryModel   : Boolean Read fVulkanMemoryModel Write fVulkanMemoryModel ;
       Property VulkanMemoryModelDeviceScope   : Boolean Read fVulkanMemoryModelDeviceScope Write fVulkanMemoryModelDeviceScope ;
       Property VulkanMemoryModelAvailabilityVisibilityChains   : Boolean Read fVulkanMemoryModelAvailabilityVisibilityChains Write fVulkanMemoryModelAvailabilityVisibilityChains ;
       Property ShaderOutputViewportIndex   : Boolean Read fShaderOutputViewportIndex Write fShaderOutputViewportIndex ;
       Property ShaderOutputLayer   : Boolean Read fShaderOutputLayer Write fShaderOutputLayer ;
       Property SubgroupBroadcastDynamicId   : Boolean Read fSubgroupBroadcastDynamicId Write fSubgroupBroadcastDynamicId ;
  //1_3
       Property RobustImageAccess   : Boolean Read fRobustImageAccess Write fRobustImageAccess ;
       Property InlineUniformBlock   : Boolean Read fInlineUniformBlock Write fInlineUniformBlock ;
       Property DescriptorBindingInlineUniformBlockUpdateAfterBind   : Boolean Read fDescriptorBindingInlineUniformBlockUpdateAfterBind Write fDescriptorBindingInlineUniformBlockUpdateAfterBind ;
       Property PipelineCreationCacheControl   : Boolean Read fPipelineCreationCacheControl Write fPipelineCreationCacheControl ;
       Property PrivateData   : Boolean Read fPrivateData Write fPrivateData ;
       Property ShaderDemoteToHelperInvocation   : Boolean Read fShaderDemoteToHelperInvocation Write fShaderDemoteToHelperInvocation ;
       Property ShaderTerminateInvocation   : Boolean Read fShaderTerminateInvocation Write fShaderTerminateInvocation ;
       Property SubgroupSizeControl   : Boolean Read fSubgroupSizeControl Write fSubgroupSizeControl ;
       Property ComputeFullSubgroups   : Boolean Read fComputeFullSubgroups Write fComputeFullSubgroups ;
       Property Synchronization2   : Boolean Read fSynchronization2 Write fSynchronization2 ;
       Property TextureCompressionASTC_HDR   : Boolean Read fTextureCompressionASTC_HDR Write fTextureCompressionASTC_HDR ;
       Property ShaderZeroInitializeWorkgroupMemory   : Boolean Read fShaderZeroInitializeWorkgroupMemory Write fShaderZeroInitializeWorkgroupMemory ;
       Property DynamicRendering   : Boolean Read fDynamicRendering Write fDynamicRendering ;
       Property ShaderIntegerDotProduct   : Boolean Read fShaderIntegerDotProduct Write fShaderIntegerDotProduct ;
       Property Maintenance4   : Boolean Read fMaintenance4 Write fMaintenance4 ;

  end;

  TvgPhysicalDevice = class(TvgBaseComponent)
  private

    function GetInstance: TvgInstance;
    procedure SetInstance(const Value: TvgInstance);
    procedure SetActive(const Value: Boolean);
    function GetPhysicalDeviceName: String;
    procedure setPhysicalDeviceName(const Value: String);
    function GetDeviceSelect: TvgDeviceSelectMode;
    procedure SetDeviceSelect(const Value: TvgDeviceSelectMode);
    function GetDeviceIndex: Integer;
    procedure SetDeviceIndex(const Value: Integer);
    function GetActive: Boolean;

  protected
    fInstance       : TvgInstance;
    fLinkers        : TList<TvgLinker>;

    fDeviceSelect   : TvgDeviceSelectMode;

    fVulkanPhysicalDevice     : TpvVulkanPhysicalDevice ;  //provided by the ACTIVE Instance
    fPhysicalDeviceName : String;
    fDeviceIndex        : Integer;
    fPhysicalDeviceScore: TvkUInt64;
    fSupportSurface     : Boolean;


    procedure Notification(AComponent: TComponent; Operation: TOperation); override;

    procedure ReadActiveStatus(Reader: TReader);
    procedure ReadDeviceValues(Reader: TReader);
    procedure WriteActiveStatus(Writer: TWriter);
    procedure WriteDeviceValues(Writer: TWriter);

    Procedure SetDisabled;   Override;
    Procedure SetDesigning;  Override;
    Procedure SetEnabled(aComp:TvgBaseComponent=nil);    Override;
    Procedure DisableParent(ToRoot:Boolean=False); Override;

    Procedure SelectBestPhysicalDevice;

    Procedure AddLinker(aLink:TvgLinker);
    Procedure RemoveLinker(aLink:TvgLinker);

  public
    constructor Create(AOwner: TComponent); Override;
    destructor Destroy; override;

    Procedure ClearPhysicalDevice;
    Function RenderToScreen : Boolean;
    Function GetAPIVersion  : TvkUint32;

    Property VulkanPhysicalDevice : TpvVulkanPhysicalDevice  read fVulkanPhysicalDevice;

  published

    Property Active             : Boolean read GetActive write SetActive stored false;
    Property DeviceSelect       : TvgDeviceSelectMode  read  GetDeviceSelect  Write SetDeviceSelect ;
    Property DeviceIndex        : Integer read GetDeviceIndex write SetDeviceIndex;
    Property Instance           : TvgInstance read GetInstance write SetInstance;
    Property PhysicalDeviceName : String read GetPhysicalDeviceName write setPhysicalDeviceName;

  end;

  TvgLogicalDevice = class(TvgBaseComponent)
  private
    function GetInstance: TvgInstance;
    function GetPhysicalDevice: TvgPhysicalDevice;
    procedure SetInstance(const Value: TvgInstance);
    function GetQueueFamilyCount: Integer;
    function GetActive: Boolean;
    procedure SetActive(const Value: Boolean);
    function GetFeatures: TvgFeatures;

  Protected
    fInstance           : TvgInstance;
    fPhysicalDevice     : TvgPhysicalDevice;

    fVulkanDevice       : TpvVulkanDevice  ;

    fLayers             : TvgLayers;
    fExtensions         : TvgExtensions;
    fFeatures           : TvgFeatures;

    fUniversalQueue     : TvgQueueFamily;
    fPresentQueue       : TvgQueueFamily;
    fGraphicsQueue      : TvgQueueFamily;
    fComputeQueue       : TvgQueueFamily;
    fTransferQueue      : TvgQueueFamily;

    fOnLayerSetup       : TvgLayerSetupCallback;
    fOnExtensionSetup   : TvgExtensionSetupCallback;

    procedure Notification(AComponent: TComponent; Operation: TOperation); override;

    procedure SetPhysicalDevice(const Value: TvgPhysicalDevice); Virtual;

    Procedure SetDisabled;   Override;
    Procedure SetDesigning;  Override;
    Procedure SetEnabled(aComp:TvgBaseComponent=nil);    Override;

    Procedure SetUpLayers;     Virtual;
    Procedure SetUpExtensions; Virtual;
    Procedure SetUpFeatures;   Virtual;
    Procedure SetUpQueueFamilies;

    Procedure OnDeviceCreateEvent(const aDevice:TpvVulkanDevice;const aDeviceCreateInfo:PVkDeviceCreateInfo);

  Public
    constructor Create(AOwner: TComponent); Override;
    destructor Destroy; override;

    Procedure BuildALLLayers;
    Function BuildLayer(aLayer:ppvVulkanAvailableLayer):TvgLayer;
    Function DoesLayerExist(aLayer:ppvVulkanAvailableLayer):Boolean;
    Procedure RemoveALLLayers;

    Procedure BuildALLExtensions;
    Function BuildExtension(aExt:PpvVulkanAvailableExtension):TvgExtension;
    Function DoesExtensionExist(aExt:PpvVulkanAvailableExtension):Boolean;
    Procedure RemoveALLExtensions;

    Procedure BuildAllFeatures;

    Procedure WaitIdle;Virtual;

    Property Instance         : TvgInstance Read GetInstance Write SetInstance ;
    Property PhysicalDevice   : TvgPhysicalDevice Read GetPhysicalDevice Write SetPhysicalDevice ;

    Property VulkanDevice     : TpvVulkanDevice read fVulkanDevice;

    Property QueueFamilyCount : Integer read GetQueueFamilyCount;

  Published

    Property Active           : Boolean Read GetActive write SetActive  stored False;
    Property Features         : TvgFeatures Read GetFeatures;

    Property QueueUniversal   : TvgQueueFamily read fUniversalQueue;
    Property QueuePresentation: TvgQueueFamily read fPresentQueue;
    Property QueueGraphics    : TvgQueueFamily read fGraphicsQueue;
    Property QueueCompute     : TvgQueueFamily read fComputeQueue;
    Property QueueTransfer    : TvgQueueFamily read fTransferQueue;
  end;

  TvgScreenRenderDevice = class(TvgLogicalDevice)
  private
    function GetLinker: TvgLinker;
    procedure SetLinker(const Value: TvgLinker);

  Protected
    fLinker   : TvgLinker;    //property

    fMSAA     : TVkSampleCountFlagBits;

    procedure Notification(AComponent: TComponent; Operation: TOperation); override;

    procedure SetPhysicalDevice(const Value: TvgPhysicalDevice); override;

    Procedure SetDisabled;   Override;
    Procedure SetEnabled(aComp:TvgBaseComponent=nil);    Override;

    Procedure SetUpLayers;    Override;
    Procedure SetUpExtensions;   Override;
    Procedure SetUpScreenExtensions;
    Procedure SetUpDynamicStateExtensions;//handle any extensions required for DynamicStates
    Procedure SetUpMSAA;
    Function TurnOnExtension(aName:String):Boolean;

    Function IsExtensionEnabled(aName:String):Boolean;

  Public
    constructor Create(AOwner: TComponent); Override;
    destructor Destroy; override;

    Procedure WaitIdle;override;

    Property Linker            : TvgLinker Read GetLinker Write SetLinker ;

  end;


  TvgSurface = class(TvgBaseComponent)
  private
    procedure SetActive(const Value: Boolean);
    function GetSurface: TpvVulkanSurface;
    function GetActive: Boolean;
    function GetWindowIntf: IvgVulkanWindow;
    procedure SetWindowIntf(const Value: IvgVulkanWindow);
    function GetLinker: TvgLinker;
    procedure SetLinker(const Value: TvgLinker);
    function GetMaxImageCount: TvkUint32;
    function GetMinImageCount: TvkUint32;
    function GetTransform: TVkSurfaceTransformFlagBitsKHR;
    function GetPhysicalDevice: TvgPhysicalDevice;
    procedure SetPhysicalDevice(const Value: TvgPhysicalDevice);

  protected
      fPhysicalDevice  : TvgPhysicalDevice;
      fLinker          : TvgLinker;
     // connect to window
      fWindowIntf      : IvgVulkanWindow;

      fVulkanSurface   : TpvVulkanSurface;
      fSurfaceQueIndex : TvkUint32;                   //index that supports surface presentation

{$if defined(Android)}
      fWindow        : PVkAndroidANativeWindow  ;
{$ifend}
{$if defined(Wayland) and defined(Unix)}
      fWaylandDisplay: PVkWaylandDisplay;
      fWaylandSurface: PVkWaylandSurface ;
{$ifend}
{$if defined(Win32) or defined(Win64)}
      fWinInstance   : TVkHWND;
      fModInstance   : TVkHINSTANCE ;
{$ifend}
{$if defined(XCB) and defined(Unix)}
      fConnection    : PVkXCBConnection;
      fWindow        : TVkXCBWindow ;
{$ifend}
{$if defined(XLIB) and defined(Unix)}
      fDisplay       : PVkXLIBDisplay;
      fWindow        : TVkXLIBWindow ;
{$ifend}
{$if defined(MoltenVK_IOS) and defined(Darwin)}
      fView          : PVkVoid  ;
{$ifend}
{$if defined(MoltenVK_MacOS) and defined(Darwin)}
      fView          : PVkVoid  ;
{$ifend}

      fWinWidth                 : TvkUint32;
      fWinHeight                : TvkUint32;

      fVkSurfaceCapabilitiesKHR : TVkSurfaceCapabilitiesKHR ;
      fVkSurfaceFormatKHRs      : Array of TVkSurfaceFormatKHR;
      fvkPresentModeKHRs        : Array of TVkPresentModeKHR;


    procedure Notification(AComponent: TComponent; Operation: TOperation); override;

    Procedure SetDesigning;  Override;
    Procedure SetDisabled;   Override;
    Procedure SetEnabled(aComp:TvgBaseComponent=nil);    Override;

    Procedure GetSurfaceCapabilities;
    Function  GetSurfaceSupport(aQueueIndex:Integer):Boolean;

 //   Function GetInstance : TvgInstance;

  public

    constructor Create(AOwner: TComponent); Override;
    destructor Destroy; override;

    Function GetWindowSize(var aWidth, aHeight : TvkUint32):Boolean;

    Property VulkanSurface : TpvVulkanSurface Read GetSurface;
    Property WinWidth      : TvkUint32 read fWinWidth;
    Property WinHeight     : TvkUint32 read fWinHeight;

    Property MinImageCount : TvkUint32 Read GetMinImageCount;
    Property MaxImageCount : TvkUint32 Read GetMaxImageCount;
    Property Transform     : TVkSurfaceTransformFlagBitsKHR read GetTransform;

    Property PhysicalDevice : TvgPhysicalDevice read GetPhysicalDevice write SetPhysicalDevice;
    Property Linker         : TvgLinker Read GetLinker write SetLinker;
    Property WindowIntf     : IvgVulkanWindow read GetWindowIntf write SetWindowIntf;

  published

    Property Active         : Boolean read GetActive write SetActive stored false;
  end;

  TvgImageFormatColorSpace = class(TCollectionItem)
  private
    function GetColorSpace: TVgColorSpaceKHR;
    function GetFormat: TVgFormat;
    procedure SetColorSpace(const Value: TVgColorSpaceKHR);
    procedure SetFormat(const Value: TVgFormat);

  protected
    fDisplayName        : String;
    fImageFormat        : TVkFormat;
    fImageColorSpace    : TVkColorSpaceKHR;

    function GetDisplayName: string; override;
    procedure DefineProperties(Filer: TFiler); override;

    procedure ReadFormatAndColor(Reader: TReader);
    procedure WriteFormatAndColor(Writer: TWriter);

    Procedure SetUpDisplayName;

  Public
    constructor Create(Collection: TCollection); override;
    procedure Assign(Source: TPersistent);   override;

    Procedure SetData(aFormat:TVkFormat; aColorSpace:TVkColorSpaceKHR);

  Published
    Property ImageFormat    : TVgFormat read GetFormat write SetFormat ;
    Property ColorSpace     : TVgColorSpaceKHR read GetColorSpace write SetColorSpace ;
  end;

  TvgImageFormatColorSpaces = Class(TCollection)
    private
    FComp      : TvgSwapChain;
    FCollString: string;
    function GetItem(Index: Integer): TvgImageFormatColorSpace;
    procedure SetItem(Index: Integer; const Value: TvgImageFormatColorSpace);

  Protected
    function GetOwner: TPersistent; override;
    procedure Update(Item: TCollectionItem); override;

  public
    constructor Create (CollOwner: TvgSwapChain);
    function Add: TvgImageFormatColorSpace;
    function AddItem(Item: TvgImageFormatColorSpace; Index: Integer): TvgImageFormatColorSpace;
    function Insert(Index: Integer): TvgImageFormatColorSpace;
    property Items[Index: Integer]: TvgImageFormatColorSpace read GetItem write SetItem; default;

  End;

  TvgPresentMode = class(TCollectionItem)
  private
    function GetPresentMode: TvgPresentModeKHR;
    procedure SetPresentMode(const Value: TvgPresentModeKHR);
  protected
    fPresentMode        : TVKPresentModeKHR;
    fPresentName        : String;

    function GetDisplayName: string; override;
    Procedure SetUpDisplayName;

  Public
    constructor Create(Collection: TCollection); override;
    procedure Assign(Source: TPersistent);   override;

    Procedure SetData(aPresentMode:TVKPresentModeKHR);

  Published
    Property PresentMode : TvgPresentModeKHR read GetPresentMode write SetPresentMode  ;
  end;

  TvgPresentModes = Class(TCollection)
    private
    FComp      : TvgSwapChain;
    FCollString: string;

    function GetItem(Index: Integer): TvgPresentMode;
    procedure SetItem(Index: Integer; const Value: TvgPresentMode);

  Protected
    function GetOwner: TPersistent; override;
    procedure Update(Item: TCollectionItem); override;

  public
    constructor Create (CollOwner: TvgSwapChain);
    function Add: TvgPresentMode;
    function AddItem(Item: TvgPresentMode; Index: Integer): TvgPresentMode;
    function Insert(Index: Integer): TvgPresentMode;
    property Items[Index: Integer]: TvgPresentMode read GetItem write SetItem; default;

  End;

  //Image Buffer used for Depth/Select Multisampling Object selection etc

  TvgImageMode = (imNone,
                  imColour,
                  imFrame,
                  imDepth,
                  imDepthStencil,
                  imMSAA,
                  imSelect,
                  imTexture,
                  imCustom);


  TvgResourceImageBuffer = Class(TvgBaseComponent)
  private
    function GetActive: Boolean;
    procedure SetActive(const Value: Boolean);

    function GetImageType: TvgImageType;
    function GetInitialLayout: TvgImageLayout;
    function GetSamples: TvgSampleCountFlagBits;
    function GetSharingMode: TvgSharingMode;
    function GetUsage: TvgImageUsageFlagBits;
    procedure SetImageType(const Value: TvgImageType);
    procedure SetInitialLayout(const Value: TvgImageLayout);
    procedure SetSamples(const Value: TvgSampleCountFlagBits);
    procedure SetSharingMode(const Value: TvgSharingMode);
    procedure SetUsage(const Value: TvgImageUsageFlagBits);
    function GetArrayLayers: TvkUint32;
    function GetDepth: TvkUint32;
    function GetMipLevels: TvkUint32;
    procedure SetArrayLayers(const Value: TvkUint32);
    procedure SetDepth(const Value: TvkUint32);
    procedure SetMipLevels(const Value: TvkUint32);
    function GetImageTiling: TvgImageTiling;
    procedure SetImageTiling(const Value: TvgImageTiling);
    function GetMemoryProperty: TvgMemoryPropertyFlagBits;
    procedure SetMemoryProperty(const Value: TvgMemoryPropertyFlagBits);
    function GetMemoryType: TvgImageMemoryType;
    procedure SetMemoryType(const Value: TvgImageMemoryType);
    function GetImageAspect: TvgImageAspectFlagBits;
    procedure SetImageAspect(const Value: TvgImageAspectFlagBits);
    function GetLinker: TvgLinker;
    procedure SetLinker(const Value: TvgLinker);
    function GetImageMode: TvgImageMode;
    procedure SetImageMode(const Value: TvgImageMode);
    function GetFormat: TvgFormat;
    procedure SetFormat(const Value: TvgFormat);
    function GetImageHeight: TvkUint32;
    function GetImageWidth: TvkUint32;
    procedure SetImageHeight(const Value: TvkUint32);
    procedure SetImageWidth(const Value: TvkUint32);
    function GetMSAAON: Boolean;
    procedure SetMSAAOn(const Value: Boolean);

  protected
        fLinker            : TvgLinker;

        fImageMode         : TvgImageMode;

        fImageType         : TVkImageType;
        fFormat            : TVkFormat;
        fImageWidth,
        fImageHeight       : TvkUint32;
        fSamples           : TVkSampleCountFlagBits;
        fUsage             : TVkImageUsageFlags;
        fSharingMode       : TVkSharingMode;
        fInitialLayout     : TVkImageLayout ;
        fFinalLayout       : TVkImageLayout ;
        fDepth             : TvkUint32;
        fMipLevels         : TvkUint32;
        fArrayLayers       : TvkUint32;
        fImageTiling       : TVkImageTiling;

        fMemoryProperty    : TVkMemoryPropertyFlags ;
        fMemoryType        : TpvVulkanDeviceMemoryAllocationType;

        fImageViewType     : TVkImageViewType;
        fComponentRed      : TVkComponentSwizzle;
        fComponentGreen    : TVkComponentSwizzle;
        fComponentBlue     : TVkComponentSwizzle;
        fComponentAlpha    : TVkComponentSwizzle;
        fImageAspectFlags  : TVkImageAspectFlags;
        fBaseMipLevel      : TvkUint32;
        fCountMipMapLevels : TvkUint32;
        fBaseArrayLayer    : TvkUint32;
        fCountArrayLayers  : TvkUint32;

        fMSAAOn            : Boolean;

        fMemoryBlock           : TpvVulkanDeviceMemoryBlock;
        fFrameBufferAttachment : TpvVulkanFrameBufferAttachment;

        procedure DefineProperties(Filer: TFiler); override;
        procedure Notification(AComponent: TComponent; Operation: TOperation); override;

       Procedure SetDisabled ; override;
       Procedure SetEnabled(aComp:TvgBaseComponent=nil);   override;

       Procedure SetUpForImageMode;

       Procedure CheckFormat(aInstance : TpvVulkanInstance; aPhysicalDevice : TpvVulkanPhysicalDevice); Virtual;
       Procedure CheckImageType;

  Public

      constructor Create(AOwner: TComponent); Override;
      destructor Destroy; override;

      Property Linker                 : TvgLinker Read GetLinker write SetLinker;
      Property FrameBufferAttachment  : TpvVulkanFrameBufferAttachment read fFrameBufferAttachment;

  Published

      Property Active        : Boolean Read GetActive write SetActive stored False;

      Property ImageMode     : TvgImageMode Read GetImageMode write SetImageMode;

      Property Format                 : TvgFormat Read GetFormat write SetFormat;

      Property ImageWidth    : TvkUint32 Read GetImageWidth write SetImageWidth ;
      Property ImageHeight   : TvkUint32 Read GetImageHeight write SetImageHeight ;

      Property ArrayLayers   : TvkUint32 Read GetArrayLayers Write SetArrayLayers ;
      Property Depth         : TvkUint32 Read GetDepth Write SetDepth ;
      Property InitialLayout : TvgImageLayout Read GetInitialLayout Write SetInitialLayout  ;
      Property ImageAspect   : TvgImageAspectFlagBits Read GetImageAspect Write SetImageAspect;
      Property ImageTiling   : TvgImageTiling Read GetImageTiling Write SetImageTiling ;
      Property ImageType     : TvgImageType Read GetImageType Write SetImageType ;

      Property MipLevels     : TvkUint32 Read GetMipLevels Write SetMipLevels ;
      Property MemoryProperty: TvgMemoryPropertyFlagBits Read GetMemoryProperty Write SetMemoryProperty;
      Property MemoryType    : TvgImageMemoryType Read GetMemoryType write SetMemoryType;
      Property Samples       : TvgSampleCountFlagBits Read GetSamples Write SetSamples ;
      Property SharingMode   : TvgSharingMode Read GetSharingMode Write SetSharingMode ;
      Property Usage         : TvgImageUsageFlagBits Read GetUsage Write SetUsage ;

      Property MSAAOn        : Boolean Read GetMSAAON write SetMSAAOn;


  End;

  TvgDepthStencilImageBufferAsset = Class(TvgResourceImageBuffer)
  private

    function GetFormat: TvgDepthBufferFormat;
    procedure SetFormat(const Value: TvgDepthBufferFormat);
    function GetUseStencil: Boolean;
    procedure SetUseStencil(const Value: Boolean);

  Protected
    fStencilON  : Boolean;

    Procedure SetDisabled ; override;
    Procedure SetEnabled(aComp:TvgBaseComponent=nil);   override;

    Procedure CheckFormat(aInstance : TpvVulkanInstance; aPhysicalDevice : TpvVulkanPhysicalDevice); Override;

  Public
       constructor Create(AOwner: TComponent); Override;
       destructor Destroy; override;

  Published

      Property Format        : TvgDepthBufferFormat Read GetFormat Write SetFormat ;
      Property StencilON     : Boolean Read GetUseStencil Write SetUseStencil ;

  End;

  TvgDescriptorSet = Class(TvgBaseComponent)
  //Contains 1 Descriptor Set Pool and Descriptor Sets and associated Descriptors and linked Buffer, Image or Sampler resources
  //based at Renderer level, node level etc
  private
    function GetFRameCount: TvkUint32;
    procedure SetFrameCount(const Value: TvkUint32);
    function GetActive: Boolean;
    procedure SetActive(const Value: Boolean);
    function GetDevice: TvgLogicalDevice;
    Procedure SetDevice(aDevice: TvgLogicalDevice);
    procedure SetDescriptorCol(const Value: TvgDescriptorCol);
    function GetVulkanDescriptorSet(index: Integer): TpvVulkanDescriptorSet;
    procedure SetCurrentFrame(const Value: TvkUint32);

  Protected
  //Linked items
     fDevice               : TvgLogicalDevice;

     fDescriptorCol        : TvgDescriptorCol; //holds set of Descriptors

     fFrameCount           : TvkUint32;        //count of Descriptor Sets needed should match frames inFlight
     fCurrentFrame         : TvkUint32;

     fDSGraphicCommandPool   : TvgCommandBufferPool;


  //commands used to Upload and manage Resource data eg Image/texture
     fDSTransferCommandPool  : TvgCommandBufferPool;


  //PasVulkan Stuff
     fVulkanDescriptorSetLayout : TpvVulkanDescriptorSetLayout;
     fCountArray                : Array of TvkUint32; //holds data for Descriptor Pool Size
     fSetCount                  : TvkUint32;

     fVulkanDescriptorPool      : TpvVulkanDescriptorPool;
     fVulkanDescriptorSets      : array of TpvVulkanDescriptorSet;  //sized to count of Descriptor col

    Procedure SetDisabled ; override;
    Procedure SetEnabled(aComp:TvgBaseComponent=nil); override;

    Procedure BuildDescriptorSetLayout;
    Procedure ClearDescriptorSetLayout;

    Function GetLinkerFrameCount:TvkUint32;

  Public
    Constructor Create(AOwner: TComponent); Override;
    Destructor Destroy; override;

    procedure Assign(Source: TPersistent); Override;

    Procedure SetUpShaderData; //called after Node copy made

    Procedure UploadDescriptorSetData(aFrameIndex : TvkUint32);

    Function GetShaderDescriptorStringTemplate_Vertex(aSet:TvkUInt32):String;   Virtual;
    Function GetShaderDescriptorStringTemplate_Geometry(aSet:TvkUInt32):String; Virtual;
    Function GetShaderDescriptorStringTemplate_Fragment(aSet:TvkUInt32):String; Virtual;

    //upload ALL data in set

    Property FrameCount    : TvkUint32 Read GetFRameCount Write SetFrameCount;
    Property LogicalDevice : TvgLogicalDevice Read GetDevice write SetDevice;
    Property VulkanDescriptorSet[index:Integer] : TpvVulkanDescriptorSet Read GetVulkanDescriptorSet ;
    Property CurrentFrame  : TvkUint32 Read fCurrentFrame write SetCurrentFrame;

  Published
    Property Active        : Boolean Read GetActive Write SetActive  stored False;

    Property Descriptors   : TvgDescriptorCol  Read fDescriptorCol write SetDescriptorCol;

  End;

  TvgDescriptorCol = Class(TCollection)
  private
    FComp      : TvgDescriptorSet;
    FCollString: string;

    function GetItem(Index: Integer): TvgDescriptorItem;
    procedure SetItem(Index: Integer; const Value: TvgDescriptorItem);

  Protected
    function GetOwner: TPersistent; override;
    procedure Update(Item: TCollectionItem); override;

  public
    constructor Create (CollOwner: TvgDescriptorSet);
    procedure Assign(Source: TPersistent); override;

    function Add: TvgDescriptorItem;
    function AddItem(Item: TvgDescriptorItem; Index: Integer): TvgDescriptorItem;
    function Insert(Index: Integer): TvgDescriptorItem;
    property Items[Index: Integer]: TvgDescriptorItem read GetItem write SetItem; default;

    Property DescriptorSet : TvgDescriptorSet Read fComp;
  End;

  TvgDescriptorType = Class of TvgDescriptor;

  //Descriptor (Resource) used for Uniform Buffer Data, Images and Samplers
  TvgDescriptorItem = Class(TCollectionItem)
  //will contain instances of resouce data
  private
    function GetActive: Boolean;
    procedure SetActive(const Value: Boolean);
    Function GetDevice : TvgLogicalDevice;
    Procedure SetDevice(Value:TvgLogicalDevice);
    function GetName: String;
    procedure SetName(const Value: String);
 //   function GetDescriptorType: TvgDescriptorType;
    procedure SetDescriptorType(const Value: TvgDescriptorType);
    function GetDescriptor: TvgDescriptor;
    function GetDescriptorName: String;
    procedure SetDescriptorName(const Value: String);

  protected

    fActive           : Boolean;
    fName             : String;

    fDevice           : TvgLogicalDevice;  //link to Device

//shader Data structures

    fDescriptorType  : TvgDescriptorType ;  //define the instance of the shader data
    fDescriptor      : TvgDescriptor;       //created instance of data which should match the number of FramesInFlight

    function GetDisplayName: string; Override;

  Public

   constructor Create(Collection: TCollection); override;
   destructor Destroy; override;

   Property Device      : TvgLogicalDevice Read GetDevice write SetDevice;

  Published

   Property Active      : Boolean Read GetActive write SetActive stored False;
   Property Name        : String  Read GetName  Write SetName ;

   Property DescriptorName : String  Read GetDescriptorName write SetDescriptorName;
   Property Descriptor     : TvgDescriptor Read GetDescriptor;
   //actual the instance of the shader data  specified in ShaderType

  End;

  TvgDescriptor     = Class(TvgBaseComponent)
  private
    function GetActive: Boolean;
    procedure SetActive(const Value: Boolean);
    Function GetFrameCount : TvkUint32;
    Procedure SetDescriptor(Value :  TvgDescriptorItem);
    function GetUploadNeeded(Index: Integer): Boolean;
    procedure SetUploadNeeded(Index: Integer; const Value: Boolean);
    function GetDevice: TvgLogicalDevice;
    procedure SetResourceType(const Value: TvgResourceType);
    procedure SetCurrentFrame(const Value: TvkUint32);

  Protected
    fDevice           : TvgLogicalDevice;  //link to Device
    fDescriptorItem   : TvgDescriptorItem;   //owner Descriptor

    fFrameCount       : TvkUint32;           //count of data arrays default to MaxFramesInFlight
    fCurrentFrame     : TvkUint32;

    fSection          : array of TvgCriticalSection; //data protected Frame count

    fUseStaging       : Boolean;
    fUploadNeeded     : Array of Boolean;   //data uploaded by Frame

    fResourceType     : TvgResourceType;

 //Descriptor Set Layout
    fBindingFlags     : TVkDescriptorBindingFlags;
    fDescriptorType   : TVkDescriptorType;
    fExtendedBinding  : Boolean;
    fLayoutFlags      : TVkDescriptorSetLayoutCreateFlags;
    fStageFlags       : TVkShaderStageFlags;

  //  fImutableSamplers  finish
    Procedure SetDisabled ; override;
    Procedure SetEnabled(aComp:TvgBaseComponent=nil); override;

    procedure SetFrameCount(const Value: TvkUint32);   Virtual;

    procedure SetDevice(const Value: TvgLogicalDevice); Virtual;

  Public

    Constructor Create(AOwner: TComponent);  Override;
    Destructor Destroy;  Override;
    Procedure Assign(Source: TPersistent); override;

    Class Function GetPropertyName : String; Virtual;

 //override in descendants
    Function GetSize                         : TVkDeviceSize;  Virtual;   Abstract;
    Function GetDataOffset                   : TVkDeviceSize;  Virtual;   Abstract;
    Function GetDataPointer(Index:TvkUint32) : Pointer ;       Virtual;   Abstract;

    Procedure SetupData;    Virtual;

    Function LockData(aFrame:Integer; aWaitFor : Boolean=False):Boolean;
    Function UnLockData(aFrame:Integer) : Boolean;
    //used when updating data in Resource

    Procedure SetUploadFlags;
    //set all the upload flags

    Procedure UpLoadDescriptorData(aIndex:TvkUint32;
                                   aGraphicPool:TvgCommandBufferPool;
                                   aTransferPool:TvgCommandBufferPool);  Virtual;  Abstract;
    //upload resource data to GPU

    Procedure WriteToDescriptorSet(aSet:TpvVulkanDescriptorSet; aIndex, aBinding:TvkUint32);  Virtual;  Abstract;
    //writes data details to Descriptor Set

    Function GetShaderDescriptorStringTemplate_Vertex(aSet, aBinding : TvkUInt32):String;   Virtual;
    Function GetShaderDescriptorStringTemplate_Geometry(aSet, aBinding : TvkUInt32):String; Virtual;
    Function GetShaderDescriptorStringTemplate_Fragment(aSet, aBinding : TvkUInt32):String; Virtual;

    Property  Device      : TvgLogicalDevice Read GetDevice write SetDevice;  //link to Device

    Property Descriptor   : TvgDescriptorItem Read fDescriptorItem write SetDescriptor;
    Property UploadedNeeded[Index:Integer]:Boolean Read GetUploadNeeded write SetUploadNeeded;

    Property FrameCount     : TvkUint32 read GetFrameCount write SetFrameCount;
    Property CurrentFrame   : TvkUint32 read fCurrentFrame write SetCurrentFrame;

  Published

    Property Active         : Boolean Read GetActive Write SetActive  stored False;
    Property DescriptorType : TVkDescriptorType Read fDescriptorType;
    Property ResourceType   : TvgResourceType Read fResourceType Write SetResourceType;

  End;

  TvgDescriptorTypeList = Class(TpvGenericList<TvgDescriptorType>);
  //see registerShaderData

  TvgDescriptor_UBO = Class(TvgDescriptor)

  Protected

 //Buffer
    fBufferUsageFlags : TVkBufferUsageFlags;
    fBufferSharingMode: TVkSharingMode;

    fVulkanBuffer     : Array Of TpvVulkanBuffer ;

    Procedure SetDisabled;                            Override;
    Procedure SetEnabled(aComp:TvgBaseComponent=nil); Override;

  Public
    Constructor Create(AOwner: TComponent);  Override;

    Procedure UpLoadDescriptorData(aIndex:TvkUint32;
                                   aGraphicPool:TvgCommandBufferPool;
                                   aTransferPool:TvgCommandBufferPool);  Override;
    Procedure WriteToDescriptorSet(aSet:TpvVulkanDescriptorSet; aFrameIndex, aBinding:TvkUint32);  Override;

  End;

  TvgSampler = Class(TvgBaseComponent)
  private
    function GetDevice: TvgLogicalDevice;
    procedure SetDevice(const Value: TvgLogicalDevice);
    function GetAddressModeU: TvgSamplerAddressMode;
    function GetAddressModeV: TvgSamplerAddressMode;
    function GetAddressModeW: TvgSamplerAddressMode;
    function GetAnisotropyEnable: Boolean;
    function GetBorderColor: TvgBorderColor;
    function GetCompareEnable: Boolean;
    function GetCompareOp: TvgCompareOpBit;
    function GetMagFilter: TvgFilter;
    function GetMaxAnisotropy: TvkFloat;
    function GetMaxLod: TvkFloat;
    function GetMinFilter: TvgFilter;
    function GetMinLod: TvkFloat;
    function GetMipLodBias: TvkFloat;
    function GetMipmapMode: TvgSamplerMipmapMode;
    function GetReductionMode: TvgSamplerReductionMode;
    function GetUnnormalizedCoordinates: Boolean;
    procedure SetAddressModeU(const Value: TvgSamplerAddressMode);
    procedure SetAddressModeV(const Value: TvgSamplerAddressMode);
    procedure SetAddressModeW(const Value: TvgSamplerAddressMode);
    procedure SetAnisotropyEnable(const Value: Boolean);
    procedure SetBorderColor(const Value: TvgBorderColor);
    procedure SetCompareEnable(const Value: Boolean);
    procedure SetCompareOp(const Value: TvgCompareOpBit);
    procedure SetMagFilter(const Value: TvgFilter);
    procedure SetMaxAnisotropy(const Value: TvkFloat);
    procedure SetMaxLod(const Value: TvkFloat);
    procedure SetMinFilter(const Value: TvgFilter);
    procedure SetMinLod(const Value: TvkFloat);
    procedure SetMipLodBias(const Value: TvkFloat);
    procedure SetMipmapMode(const Value: TvgSamplerMipmapMode);
    procedure SetReductionMode(const Value: TvgSamplerReductionMode);
    procedure SetUnnormalizedCoordinates(const Value: Boolean);
    procedure SetFrameCount(const Value: TvkUint32);
  Protected
     fDevice                : TvgLogicalDevice;

     fVulkanSampler         : Array of TpvVulkanSampler;
     fFrameCount            : TvkUint32;        //count of Descriptor Sets needed should match frames inFlight

     fMagFilter             : TVkFilter;
     fMinFilter             : TVkFilter;
     fMipmapMode            : TVkSamplerMipmapMode;
     fAddressModeU          : TVkSamplerAddressMode;
     fAddressModeV          : TVkSamplerAddressMode;
     fAddressModeW          : TVkSamplerAddressMode;
     fMipLodBias            : TvkFloat;
     fAnisotropyEnable      : boolean;
     fMaxAnisotropy         : TvkFloat;
     fCompareEnable         : boolean;
     fCompareOp             : TVkCompareOp;
     fMinLod                : TvkFloat;
     fMaxLod                : TvkFloat;
     fBorderColor           : TVkBorderColor;
     fUnnormalizedCoordinates: boolean;
     fReductionMode         : TVkSamplerReductionMode;

    Procedure SetDisabled;                            Override;
    Procedure SetEnabled(aComp:TvgBaseComponent=nil); Override;

  Public
    Constructor Create(AOwner: TComponent);  Override;

    Property Device :  TvgLogicalDevice Read GetDevice Write SetDevice;

    Property FrameCount : TvkUint32 Read fFrameCount write SetFrameCount  ;

  Published

    Property MagFilter :TvgFilter   Read GetMagFilter   Write SetMagFilter  ;
    Property MinFilter :TvgFilter   Read GetMinFilter   Write SetMinFilter  ;
    Property MipmapMode : TvgSamplerMipmapMode  Read GetMipmapMode   Write SetMipmapMode  ;
    Property AddressModeU : TvgSamplerAddressMode  Read GetAddressModeU   Write SetAddressModeU  ;
    Property AddressModeV : TvgSamplerAddressMode Read GetAddressModeV   Write SetAddressModeV  ;
    Property AddressModeW : TvgSamplerAddressMode  Read GetAddressModeW   Write SetAddressModeW  ;
    Property MipLodBias   : TvkFloat Read GetMipLodBias   Write SetMipLodBias  ;
    Property AnisotropyEnable : Boolean   Read GetAnisotropyEnable   Write SetAnisotropyEnable  ;
    Property MaxAnisotropy : TvkFloat   Read GetMaxAnisotropy   Write SetMaxAnisotropy  ;
    Property CompareEnable : Boolean   Read GetCompareEnable   Write SetCompareEnable  ;
    Property CompareOp :  TvgCompareOpBit  Read GetCompareOp   Write SetCompareOp  ;
    Property MinLod    : TvkFloat   Read GetMinLod   Write SetMinLod  ;
    Property MaxLod    : TvkFloat  Read GetMaxLod   Write SetMaxLod  ;
    Property BorderColor : TvgBorderColor   Read GetBorderColor   Write SetBorderColor  ;
    Property UnnormalizedCoordinates : Boolean   Read GetUnnormalizedCoordinates   Write SetUnnormalizedCoordinates  ;
    Property ReductionMode :  TvgSamplerReductionMode  Read GetReductionMode   Write SetReductionMode  ;

  End;

  TvgDescriptor_Texture = Class(TvgDescriptor)
  private

    function GetBorderColor: TvgBorderColor;
    function GetWrapModeU: TpvVulkanTextureWrapMode;
    function GetWrapModeV: TpvVulkanTextureWrapMode;
    function GetWrapModeW: TpvVulkanTextureWrapMode;
    procedure SetBorderColor(const Value: TvgBorderColor);
    procedure SetWrapModeU(const Value: TpvVulkanTextureWrapMode);
    procedure SetWrapModeV(const Value: TpvVulkanTextureWrapMode);
    procedure SetWrapModeW(const Value: TpvVulkanTextureWrapMode);

    Procedure SetFileName(const Value : String);
    Function GetFilename: String;

  Protected

     fVulkanTexture : Array of TpvVulkanTexture;
     //can have a texture per Frame OR a single texture   DEFAULT to one
     fSampler    : TvgSampler;
     fStream     : TStream; // holds data for transfer

     //stored properties
     fFileName   : String;

     fWrapModeU       : TpvVulkanTextureWrapMode;
     fWrapModeV       : TpvVulkanTextureWrapMode;
     fWrapModeW       : TpvVulkanTextureWrapMode;
     fBorderColor     : TVkBorderColor;


    Procedure SetDisabled;                            Override;
    Procedure SetEnabled(aComp:TvgBaseComponent=nil); Override;

    procedure SetDevice(const Value: TvgLogicalDevice); Override;
    procedure SetFrameCount(const Value: TvkUint32);   Override;


  Public
    Constructor Create(AOwner: TComponent);  Override;
    Destructor Destroy; Override;
    Class Function GetPropertyName : String; Override;
    procedure Assign(Source: TPersistent);Override;


    Procedure UpLoadDescriptorData(aIndex:TvkUint32;
                                   aGraphicPool:TvgCommandBufferPool;
                                   aTransferPool:TvgCommandBufferPool);  Override;
    Procedure WriteToDescriptorSet(aSet:TpvVulkanDescriptorSet; aFrameIndex, aBinding:TvkUint32);  Override;

    Function GetShaderDescriptorStringTemplate_Fragment(aSet, aBinding : TvkUInt32):String; Override;


  Published

    Property FileName    : String Read GetFileName   Write SetFileName   ;

    Property Sampler     : TvgSampler Read fSampler;

    Property BorderColor : TvgBorderColor Read  GetBorderColor  Write SetBorderColor  ;

    Property WrapModeU   : TpvVulkanTextureWrapMode Read  GetWrapModeU  Write SetWrapModeU  ;
    Property WrapModeV   : TpvVulkanTextureWrapMode Read  GetWrapModeV  Write SetWrapModeV  ;
    Property WrapModeW   : TpvVulkanTextureWrapMode Read  GetWrapModeW  Write SetWrapModeW  ;

  End;

  TvgPushConstantCol = Class(TCollection)
  private
    fActive     : Boolean;
    FComp       : TvgGraphicPipeline;
    FCollString : string;
    fFrameCount : Integer;

    function GetItem(Index: Integer): TvgPushConstantItem;
    procedure SetItem(Index: Integer; const Value: TvgPushConstantItem);
    procedure SetFrameCount(const Value: Integer);
    procedure SetActive(const Value: Boolean);

  Protected
    function GetOwner: TPersistent; override;
    procedure Update(Item: TCollectionItem); override;

    Procedure SetEnabled;
    Procedure SetDisabled;

  public
    constructor Create (CollOwner: TvgGraphicPipeline);
    procedure Assign(Source: TPersistent); override;

    function Add: TvgPushConstantItem;
    function AddItem(Item: TvgPushConstantItem; Index: Integer): TvgPushConstantItem;
    function Insert(Index: Integer): TvgPushConstantItem;
    property Items[Index: Integer]: TvgPushConstantItem read GetItem write SetItem; default;

    Property GraphicPipeline : TvgGraphicPipeline Read fComp;
  Published
    Property Active     : Boolean Read fActive write SetActive;
    Property FrameCount : Integer read fFrameCount write SetFrameCount;
  end;

  TvgPushConstantType = Class of TvgPushConstant;

  TvgPushConstantTypeList = Class(TpvGenericList<TvgPushConstantType>);
  //see registerShaderData

  TvgPushConstantItem = Class(TCollectionItem )
  private
    function GetActive: Boolean;
    function GetName: String;
    function GetPushConstant: TvgPushConstant;
    function GetPushConstantName: String;
 //   function GetPushConstantType: TvgPushConstantType;
    procedure SetActive(const Value: Boolean);
    procedure SetName(const Value: String);
    procedure SetPushConstantName(const Value: String);
    procedure SetPushConstantType(const Value: TvgPushConstantType);

  Protected
    fActive           : Boolean;
    fName             : String;

    fPushConstantType  : TvgPushConstantType ;    //define the instance of the shader data
    fPushConstant      : TvgPushConstant;    //created instance of data which should match the number of FramesInFlight

    function GetDisplayName: string; Override;

  Public

   constructor Create(Collection: TCollection); override;
   destructor Destroy; override;

  Published

   Property Active      : Boolean Read GetActive write SetActive stored False;
   Property Name        : String  Read GetName  Write SetName ;

   Property PushConstantName : String  Read GetPushConstantName write SetPushConstantName;
   Property PushConstant     : TvgPushConstant Read GetPushConstant;

  End;

  TvgPushConstant  = Class(TvgBaseComponent)
  private
    function GetShaderFlags: TvgShaderStageFlagBits;
    procedure SetShaderFlags(const Value: TvgShaderStageFlagBits);
    procedure SetActive(const Value: Boolean);
    procedure SetFrameCount(const Value: TvkUint32);

  Protected
    fFrameCount  : TvkUint32;
    fShaderStage : TVkShaderStageFlags;

    Procedure SetDisabled ; Override;
    Procedure SetEnabled(aComp:TvgBaseComponent=nil);   Override;  //if aComp Set then SetEnabled

  Public
    Constructor Create(AOwner: TComponent);  Override;
    Destructor Destroy; Override;
    Procedure Assign(Source: TPersistent); override;

    Class Function GetPropertyName : String; Virtual;

    Procedure SetupData(FrameIndex:TvkUint32);     Virtual;
    function GetDataSize: TVkUInt32; Virtual;
    function GetDataPointer(FrameIndex:TvkUint32): Pointer; Virtual;

    Property FrameCount : TvkUint32 Read fFrameCount write SetFrameCount;
    Property Active     : Boolean Read fActive Write SetActive;

  Published

    Property ShaderFlags : TvgShaderStageFlagBits Read GetShaderFlags write SetShaderFlags ;
    Property DataSize    : TVkUInt32 Read GetDataSize;
  End;

  TvgSwapChain = class(TvgBaseComponent)
  Private

    function GetSurface: TvgSurface;
    procedure SetSurface(const Value: TvgSurface);

    function GetVulkanSWapChain: TpvVulkanSwapChain;
    function GetClipped: Boolean;
    function GetDesiredImageCount: TvkUint32;
    function GetDesiredTransform: TVgSurfaceTransformFlagBitsKHRSet;
    function GetForceCompositeAlpha: Boolean;
    function GetImageSharingMode: TvgSharingMode;
    function GetImageUsage: TvgImageUsageFlagsSet;
    function GetSRGB: Boolean;
    procedure SetClipped(const Value: Boolean);
    procedure SetDesiredImageCount(const Value: TvkUint32);
    procedure SetDesiredTransform(const Value: TVgSurfaceTransformFlagBitsKHRSet);
    procedure SetForceCompositeAlpha(const Value: Boolean);
    procedure SetImageSharingMode(const Value: TvgSharingMode);
    procedure SetImageUsage(const Value: TvgImageUsageFlagsSet);
    procedure SetSRGB(const Value: Boolean);
    procedure SetActive(const Value: Boolean);
    function GetActive: Boolean;
    procedure SetImagesColorSpaces(const Value: TvgImageFormatColorSpaces);

    function GetPresentModes: TvgPresentModes;
    procedure SetPresentModes(const Value: TvgPresentModes);
    function GetCompositeAlpha: TVgCompositeAlphaFlagBitsKHRSet;
    procedure SetCompositeAlpha(const Value: TVgCompositeAlphaFlagBitsKHRSet);
    function GetArrayLayers: TvkUint32;
    procedure SetArrayLayers(const Value: TvkUint32);
    function GetDevice: TvgScreenRenderDevice;
    procedure SetDevice(const Value: TvgScreenRenderDevice);
    function GetBaseArrayLayer: TvkUint32;
    function GetBaseMipLevel: TvkUint32;
    function GetComponentAlpha: TvgComponentSwizzle;
    function GetComponentBlue: TvgComponentSwizzle;
    function GetComponentGreen: TvgComponentSwizzle;
    function GetComponentRed: TvgComponentSwizzle;
    function GetCountArrayLayers: TvkUint32;
    function GetCountMipMapLevels: TvkUint32;
    procedure SetBaseArrayLayer(const Value: TvkUint32);
    procedure SetBaseMipLevel(const Value: TvkUint32);
    procedure SetComponentAlpha(const Value: TvgComponentSwizzle);
    procedure SetComponentBlue(const Value: TvgComponentSwizzle);
    procedure SetComponentGreen(const Value: TvgComponentSwizzle);
    procedure SetComponentRed(const Value: TvgComponentSwizzle);
    procedure SetCountArrayLayers(const Value: TvkUint32);
    procedure SetCountMipMapLevels(const Value: TvkUint32);

    function GetImageAspectFlags: TvgImageAspectFlagBits;
    procedure SetImageAspectFlags(const Value: TvgImageAspectFlagBits);
    function GetImageViewType: TvgImageViewType;
    procedure SetImageViewType(const Value: TvgImageViewType);
    function GetImageView(Index: Integer): TpvVulkanImageView;
    function GetImage(Index: Integer): TpvVulkanImage;
    function GetCurrentImageIndex: TvkUint32;
    function GetFrameBufferAttach(Index: Integer): TpvVulkanFrameBufferAttachment;
    function GetImageHeight: TvkUint32;
    function GetImageWidth: TvkUint32;
    function GetImageIndex: TvkUint32;

  Protected

    fSurface            : TvgSurface;
    fScreenDevice       : TvgScreenRenderDevice;
    fLinker             : TvgLinker;

    fVulkanSwapChain,
    fOldVulkanSwapChain : TpvVulkanSwapChain;

    fFrameBufferAtachments : Array of TpvVulkanFrameBufferAttachment;

    fImagesColorSpaces  : TvgImageFormatColorSpaces;
    fPresentModes       : TvgPresentModes;

    fImageFormat        : TVkFormat;         //not stored Valid if ACTIVE published READ only
    fColorSpace         : TVkColorSpaceKHR;  //not stored Valid if ACTIVE  published READ only
    fImageCount         : TvkUint32;         //not stored Valid if ACTIVE  published READ only
    fImageWidth         : TvkUint32;         //not stored Valid if ACTIVE  published READ only
    fImageHeight        : TvkUint32;         //not stored Valid if ACTIVE  published READ only

    fDesiredImageCount  : TvkUint32;
    fArrayLayers        : TvkUint32;
    fImageUsage         : TVkImageUsageFlags;
    fImageSharingMode   : TVkSharingMode;
    fCompositeAlpha     : TVgCompositeAlphaFlagBitsKHRSet;
    fForceCompositeAlpha: Boolean;
    fClipped            : Boolean;
    fDesiredTransform   : TVkSurfaceTransformFlagsKHR;
    fSRGB               : Boolean;

    fImageViewType      : TVkImageViewType;
    fComponentRed       : TVkComponentSwizzle;
    fComponentGreen     : TVkComponentSwizzle;
    fComponentBlue      : TVkComponentSwizzle;
    fComponentAlpha     : TVkComponentSwizzle;
    fImageAspectFlags   : TVkImageAspectFlags;
    fBaseMipLevel       : TvkUint32;
    fCountMipMapLevels  : TvkUint32;
    fBaseArrayLayer     : TvkUint32;
    fCountArrayLayers   : TvkUint32;

    procedure DefineProperties(Filer: TFiler); override;
    procedure ReadData(Reader: TReader);
    procedure WriteData(Writer: TWriter);

    procedure Notification(AComponent: TComponent; Operation: TOperation); override;

    Procedure SetDesigning;  Override;
    Procedure SetDisabled;   Override;
    Procedure SetEnabled(aComp:TvgBaseComponent=nil);    Override;

    Function RecreateSwapChain : Boolean;

    Procedure ImageViewsSetUp;
    Procedure ImageViewsClear;

    function AcquireNextImage(ImageAvailable:TpvVulkanSemaphore) : Boolean;
    function QueuePresent(const aQueue:TpvVulkanQueue; RenderingFinishedSemaphore:TpvVulkanSemaphore): Boolean;

//    Procedure WaitForFences(const aTimeOut:TvkUint64=TvkUint64(TvkInt64(-1)));
//    Procedure ResetFences;

    Procedure VulkanWaitIdle;

  Public
    constructor Create(AOwner: TComponent); Override;
    destructor Destroy; override;

    Procedure BuildALLImagesColorSpaces;
    Function BuildImagesColorSpaces(aFormat:TVkFormat; aColorSpace:TVkColorSpaceKHR):TvgImageFormatColorSpace;
    Function DoesImagesColorSpacesExist(aFormat:TVkFormat; aColorSpace:TVkColorSpaceKHR):Boolean;
    Procedure RemoveALLImagesColorSpaces;

    Procedure BuildALLPresentationModes;
    Function BuildPresentationMode(aMode:TVKPresentModeKHR):TvgPresentMode;
    Function DoesPresentModeExist(aMode:TVKPresentModeKHR):Boolean;
    Procedure ClearPresentationModes;

    Property VulkanSwapChain            : TpvVulkanSwapChain read GetVulkanSWapChain;
    Property CurrentImageIndex          : TvkUint32 read GetCurrentImageIndex;

    Property ImageView[Index : Integer]       : TpvVulkanImageView read GetImageView ;
    Property Image[Index : Integer]           : TpvVulkanImage read GetImage ;
    Property FrameBufferAttach[Index:Integer] : TpvVulkanFrameBufferAttachment Read GetFrameBufferAttach;

    Property Device            : TvgScreenRenderDevice read GetDevice   write SetDevice;
    Property Surface           : TvgSurface  Read GetSurface write SetSurface;

    Property ColorSpace        : TVkColorSpaceKHR Read fColorSpace; //valid if active
    Property ImageIndex        : TvkUint32 Read GetImageIndex;
    Property ImageCount        : TvkUint32 Read fImageCount;        //valid if active
    Property ImageFormat       : TVkFormat read fImageFormat;       //valid if active
    Property ImageHeight       : TvkUint32 read GetImageHeight;     //valid if active
    Property ImageWidth        : TvkUint32 read GetImageWidth;      //valid if active

  Published

    Property Active            : Boolean     Read GetActive   write SetActive stored false;

    Property ImagesColorSpaces : TvgImageFormatColorSpaces read fImagesColorSpaces write SetImagesColorSpaces;
    Property PresentModes      : TvgPresentModes read GetPresentModes write SetPresentModes;

    Property ArrayLayers        : TvkUint32 Read GetArrayLayers write SetArrayLayers stored false;

    Property ImageReqCount      : TvkUint32 Read GetDesiredImageCount Write SetDesiredImageCount stored false;
    Property ImageSharingMode   : TvgSharingMode Read GetImageSharingMode Write SetImageSharingMode;
    Property ImageUsage         : TvgImageUsageFlagsSet Read GetImageUsage Write SetImageUsage;
    Property CompositeAlpha     : TVgCompositeAlphaFlagBitsKHRSet Read GetCompositeAlpha write SetCompositeAlpha;
    Property ForceCompositeAlpha: Boolean Read GetForceCompositeAlpha Write SetForceCompositeAlpha;
    Property Clipped            : Boolean Read GetClipped Write SetClipped;
    Property Transform          : TVgSurfaceTransformFlagBitsKHRSet  Read GetDesiredTransform Write SetDesiredTransform stored false;
    Property SRGB               : Boolean Read GetSRGB Write SetSRGB;

    Property ImageViewType      : TvgImageViewType  Read GetImageViewType Write SetImageViewType ;
    Property ComponentRed       : TvgComponentSwizzle Read GetComponentRed Write SetComponentRed ;
    Property ComponentGreen     : TvgComponentSwizzle Read GetComponentGreen Write SetComponentGreen ;
    Property ComponentBlue      : TvgComponentSwizzle Read GetComponentBlue Write SetComponentBlue ;
    Property ComponentAlpha     : TvgComponentSwizzle Read GetComponentAlpha Write SetComponentAlpha ;
    Property ImageAspectFlags   : TvgImageAspectFlagBits  Read GetImageAspectFlags Write SetImageAspectFlags ;
    Property MipLevelBase       : TvkUint32 Read GetBaseMipLevel Write SetBaseMipLevel  stored false;
    Property MipMapLevelCount   : TvkUint32 Read GetCountMipMapLevels Write SetCountMipMapLevels  stored false;
    Property ArrayLayerBase     : TvkUint32 Read GetBaseArrayLayer Write SetBaseArrayLayer  stored false;
    Property ArrayLayerCount    : TvkUint32 Read GetCountArrayLayers Write SetCountArrayLayers  stored false;

  end;

  TvgCommandBufferEvent = Procedure(const aCommandBuffer:TvgCommandBuffer)  of Object;


  TvgCommandBuffer = Class(TObject)
  private
    function GetActive: Boolean;
    function GetCommandBufferLevel: TvgCommandBufferLevel;

    procedure SetActive(const Value: Boolean);
    procedure SetCommandBufferLevel(const Value: TvgCommandBufferLevel);
    function GetUseFlags: TvgCommandBufferUsageFlags;
    procedure SetUseFlags(const Value: TvgCommandBufferUsageFlags);

  protected
    fCommandPool         : TvgCommandBufferPool;
  //  fDevice              : TvgLogicalDevice;

    fVulkanCommandBuffer : TpvVulkanCommandBuffer ;
    fBufferFence         : TpvVulkanFence;
    fFenceSet            : Boolean;

    fCommandLevel        : TvgCommandBufferLevel;
    fActive              : Boolean;
    fName                : String;

    fBufferState         : TvgBufferState;
    fCommandCount        : Integer; //count of commands added if zero then don't allow submit

    fBufferUse           : TVkCommandBufferUsageFlags;

    fRecordCommand       : TvgCommandBufferEvent;
    fFreeCommand         : TvgCommandBufferEvent;    //will notify of impending free of this component

    Procedure SetDisabled;
    Procedure SetEnabled(aComp:TvgBaseComponent=nil);

    Function SetBufferState(aState:TvgBufferState; ForceState:Boolean=False):Boolean;
    Function WaitOnFence:Boolean;

  Public
    constructor Create;
    destructor Destroy; override;

     procedure BeginRecording({const aFlags:TVkCommandBufferUsageFlags=0;}const aInheritanceInfo:PVkCommandBufferInheritanceInfo=nil);
     procedure BeginRecordingPrimary;
     procedure BeginRecordingSecondary(const aRenderPass:TVkRenderPass;const aSubPass:TvkUint32;const aFrameBuffer:TVkFramebuffer;const aOcclusionQueryEnable:boolean;const aQueryFlags:TVkQueryControlFlags;const aPipelineStatistics:TVkQueryPipelineStatisticFlags{;const aFlags:TVkCommandBufferUsageFlags=TVkCommandBufferUsageFlags(VK_COMMAND_BUFFER_USAGE_RENDER_PASS_CONTINUE_BIT)});
     procedure EndRecording;
     procedure Reset(const aFlags:TVkCommandBufferResetFlags=TVkCommandBufferResetFlags(VK_COMMAND_BUFFER_RESET_RELEASE_RESOURCES_BIT));
     procedure Execute(const aQueue:TpvVulkanQueue;const aWaitDstStageFlags:TVkPipelineStageFlags;const aWaitSemaphore:TpvVulkanSemaphore=nil;const aSignalSemaphore:TpvVulkanSemaphore=nil;const aDoWaitAndResetFence:boolean=true);

     procedure CmdBindPipeline(pipelineBindPoint:TVkPipelineBindPoint;pipeline:TVkPipeline);
     procedure CmdSetViewport(firstViewport:TvkUint32;viewportCount:TvkUint32;const aViewports:PVkViewport);
     procedure CmdSetScissor(firstScissor:TvkUint32;scissorCount:TvkUint32;const aScissors:PVkRect2D);
     procedure CmdSetLineWidth(lineWidth:TvkFloat);
     procedure CmdSetDepthBias(depthBiasConstantFactor:TvkFloat;depthBiasClamp:TvkFloat;depthBiasSlopeFactor:TvkFloat);
     procedure CmdSetBlendConstants(const blendConstants:TvkFloat);
     procedure CmdSetCullMode(const cullMode:TVkCullModeFlags);
     procedure CmdSetDepthBounds(minDepthBounds:TvkFloat;maxDepthBounds:TvkFloat);
     procedure CmdSetStencilCompareMask(faceMask:TVkStencilFaceFlags;compareMask:TvkUint32);
     procedure CmdSetStencilWriteMask(faceMask:TVkStencilFaceFlags;writeMask:TvkUint32);
     procedure CmdSetStencilReference(faceMask:TVkStencilFaceFlags;reference:TvkUint32);
     procedure CmdBindDescriptorSets(pipelineBindPoint:TVkPipelineBindPoint;layout:TVkPipelineLayout;firstSet:TvkUint32;descriptorSetCount:TvkUint32;const aDescriptorSets:PVkDescriptorSet;dynamicOffsetCount:TvkUint32;const aDynamicOffsets:PvkUInt32);
     procedure CmdBindIndexBuffer(buffer:TVkBuffer;offset:TVkDeviceSize;indexType:TVkIndexType);
     procedure CmdBindVertexBuffers(firstBinding:TvkUint32;bindingCount:TvkUint32;const aBuffers:PVkBuffer;const aOffsets:PVkDeviceSize);
     procedure CmdDraw(vertexCount:TvkUint32;instanceCount:TvkUint32;firstVertex:TvkUint32;firstInstance:TvkUint32);
     procedure CmdDrawIndexed(indexCount:TvkUint32;instanceCount:TvkUint32;firstIndex:TvkUint32;vertexOffset:TvkInt32;firstInstance:TvkUint32);
     procedure CmdDrawIndirect(buffer:TVkBuffer;offset:TVkDeviceSize;drawCount:TvkUint32;stride:TvkUint32);
     procedure CmdDrawIndexedIndirect(buffer:TVkBuffer;offset:TVkDeviceSize;drawCount:TvkUint32;stride:TvkUint32);
     procedure CmdDispatch(x:TvkUint32;y:TvkUint32;z:TvkUint32);
     procedure CmdDispatchIndirect(buffer:TVkBuffer;offset:TVkDeviceSize);
     procedure CmdCopyBuffer(srcBuffer:TVkBuffer;dstBuffer:TVkBuffer;regionCount:TvkUint32;const aRegions:PVkBufferCopy);
     procedure CmdCopyImage(srcImage:TVkImage;srcImageLayout:TVkImageLayout;dstImage:TVkImage;dstImageLayout:TVkImageLayout;regionCount:TvkUint32;const aRegions:PVkImageCopy);
     procedure CmdBlitImage(srcImage:TVkImage;srcImageLayout:TVkImageLayout;dstImage:TVkImage;dstImageLayout:TVkImageLayout;regionCount:TvkUint32;const aRegions:PVkImageBlit;filter:TVkFilter);
     procedure CmdCopyBufferToImage(srcBuffer:TVkBuffer;dstImage:TVkImage;dstImageLayout:TVkImageLayout;regionCount:TvkUint32;const aRegions:PVkBufferImageCopy);
     procedure CmdCopyImageToBuffer(srcImage:TVkImage;srcImageLayout:TVkImageLayout;dstBuffer:TVkBuffer;regionCount:TvkUint32;const aRegions:PVkBufferImageCopy);
     procedure CmdUpdateBuffer(dstBuffer:TVkBuffer;dstOffset:TVkDeviceSize;dataSize:TVkDeviceSize;const aData:PVkVoid);
     procedure CmdFillBuffer(dstBuffer:TVkBuffer;dstOffset:TVkDeviceSize;size:TVkDeviceSize;data:TvkUint32);
     procedure CmdClearColorImage(image:TVkImage;imageLayout:TVkImageLayout;const aColor:PVkClearColorValue;rangeCount:TvkUint32;const aRanges:PVkImageSubresourceRange);
     procedure CmdClearDepthStencilImage(image:TVkImage;imageLayout:TVkImageLayout;const aDepthStencil:PVkClearDepthStencilValue;rangeCount:TvkUint32;const aRanges:PVkImageSubresourceRange);
     procedure CmdClearAttachments(attachmentCount:TvkUint32;const aAttachments:PVkClearAttachment;rectCount:TvkUint32;const aRects:PVkClearRect);
     procedure CmdResolveImage(srcImage:TVkImage;srcImageLayout:TVkImageLayout;dstImage:TVkImage;dstImageLayout:TVkImageLayout;regionCount:TvkUint32;const aRegions:PVkImageResolve);
     procedure CmdSetEvent(event:TVkEvent;stageMask:TVkPipelineStageFlags);
     procedure CmdResetEvent(event:TVkEvent;stageMask:TVkPipelineStageFlags);
     procedure CmdWaitEvents(eventCount:TvkUint32;const aEvents:PVkEvent;srcStageMask:TVkPipelineStageFlags;dstStageMask:TVkPipelineStageFlags;memoryBarrierCount:TvkUint32;const aMemoryBarriers:PVkMemoryBarrier;bufferMemoryBarrierCount:TvkUint32;const aBufferMemoryBarriers:PVkBufferMemoryBarrier;imageMemoryBarrierCount:TvkUint32;const aImageMemoryBarriers:PVkImageMemoryBarrier);
     procedure CmdPipelineBarrier(srcStageMask:TVkPipelineStageFlags;dstStageMask:TVkPipelineStageFlags;dependencyFlags:TVkDependencyFlags;memoryBarrierCount:TvkUint32;const aMemoryBarriers:PVkMemoryBarrier;bufferMemoryBarrierCount:TvkUint32;const aBufferMemoryBarriers:PVkBufferMemoryBarrier;imageMemoryBarrierCount:TvkUint32;const aImageMemoryBarriers:PVkImageMemoryBarrier);
     procedure CmdBeginQuery(queryPool:TVkQueryPool;query:TvkUint32;flags:TVkQueryControlFlags);
     procedure CmdEndQuery(queryPool:TVkQueryPool;query:TvkUint32);
     procedure CmdResetQueryPool(queryPool:TVkQueryPool;firstQuery:TvkUint32;queryCount:TvkUint32);
     procedure CmdWriteTimestamp(pipelineStage:TVkPipelineStageFlagBits;queryPool:TVkQueryPool;query:TvkUint32);
     procedure CmdCopyQueryPoolResults(queryPool:TVkQueryPool;firstQuery:TvkUint32;queryCount:TvkUint32;dstBuffer:TVkBuffer;dstOffset:TVkDeviceSize;stride:TVkDeviceSize;flags:TVkQueryResultFlags);
     procedure CmdPushConstants(layout:TVkPipelineLayout;stageFlags:TVkShaderStageFlags;offset:TvkUint32;size:TvkUint32;const aValues:PVkVoid);
     procedure CmdBeginRenderPass(const aRenderPassBegin:PVkRenderPassBeginInfo;contents:TVkSubpassContents);
     procedure CmdNextSubpass(contents:TVkSubpassContents);
     procedure CmdEndRenderPass;
     procedure CmdExecuteCommands(commandBufferCount:TvkUint32;const aCommandBuffers:PVkCommandBuffer);
     procedure CmdExecute(const aCommandBuffer:TpvVulkanCommandBuffer);
     procedure MetaCmdPresentToDrawImageBarrier(const aImage:TpvVulkanImage;const aDoTransitionToColorAttachmentOptimalLayout:boolean=true);
     procedure MetaCmdDrawToPresentImageBarrier(const aImage:TpvVulkanImage;const aDoTransitionToPresentSrcLayout:boolean=true);
     procedure MetaCmdMemoryBarrier(const aSrcStageMask,aDstStageMask:TVkPipelineStageFlags;const aSrcAccessMask,aDstAccessMask:TVkAccessFlags);


 // Published
    Property Active          : Boolean Read GetActive write SetActive stored false;
    Property CommandLevel    : TvgCommandBufferLevel read GetCommandBufferLevel write SetCommandBufferLevel;
    Property BufferState     : TvgBufferState Read fBufferState;
    Property VulkanCommandBuffer  : TpvVulkanCommandBuffer Read fVulkanCommandBuffer;
    Property BufferFence     : TpvVulkanFence read fBufferFence;
    Property UseFlags        : TvgCommandBufferUsageFlags Read GetUseFlags write SetUseFlags;

    Property OnRecordCommand : TvgCommandBufferEvent  read fRecordCommand write fRecordCommand;
  End;

  TvgCommandBufferList = Class(TList<TvgCommandBuffer>)
  End;

  TvgCommandPoolDestroyCallBack = Procedure(aPool:TvgCommandBufferPool) of Object ;
  //will call back when being destroyed

  TvgCommandBufferPool = Class(TvgBaseComponent)
  private

    procedure SetActive(const Value: Boolean);
    function GetActive: Boolean;
    function GetDevice: TvgLogicalDevice;
    procedure SetDevice(const Value: TvgLogicalDevice);
    function GetQueueFamilyType: TvgQueueFamilyType;
    procedure SetQueueFamilyType(const Value: TvgQueueFamilyType);
    function GetQueueCreateFlags: TVgCommandPoolCreateFlag;
    procedure SetQueueCreateFlags(const Value: TVgCommandPoolCreateFlag);
    function GetCommandQueue(Index:Integer): TpvVulkanQueue;
    function GetCommandBuffer(FIndex, SIndex: Integer): TvgCommandBuffer;
    function GetFrameIndex: TvkUint32;
    function GetSubpassIndex: TvkUint32;
    procedure SetFrameIndex(const Value: TvkUint32);
    procedure SetSubpassIndex(const Value: TvkUint32);
    function GetCurrentCommand: TvgCommandBuffer;

  protected
    fLogicalDevice     : TvgLogicalDevice;  //may be Screen or Compute Device
    fQueueFamilyType   : TvgQueueFamilyType;
    fQueueCreateFlags  : TVkCommandPoolCreateFlags;

    fVulkanCommandPool : TpvVulkanCommandPool;

    fCurrentFrame,
    fCurrentSubpass    : TvkUint32  ;

    fCommandLists      : Array of array of TvgCommandBuffer;
    //Frame array by subpass array
    //array of lists count matches fListCount
    //list to created to contain Created CommandBuffers

    fOwnerDestroyCallBack: TvgCommandPoolDestroyCallBack;

    procedure DefineProperties(Filer: TFiler); override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;

    procedure ReadPoolData(Reader: TReader);
    procedure WritePoolData(Writer: TWriter);

    Procedure SetDisabled;   Override;
    Procedure SetEnabled(aComp:TvgBaseComponent=nil);    Override;

    Function ResetEnabled:Boolean;

  Public
    constructor Create(AOwner: TComponent); Override;
    destructor Destroy; override;

    Procedure SetUpBufferArrays(aFrameCount,aSubpassCount:TvkUint32);
    //will free any existing Buffers then setup arrays with TvgCommandBuffer
    Procedure ReleaseAllCommands(DoAll:Boolean=False);
    Function RequestCommand(aFrameIndex,aSubpassIndex:TvkUint32;
                            aLevel:TvgCommandBufferLevel;
                            ResetNeeded:Boolean;
                            UseFlags:TvgCommandBufferUsageFlags):TvgCommandBuffer;
    Procedure ReleaseCommand(aCommand: TvgCommandBuffer);

    Property Queue[Index: Integer] : TpvVulkanQueue Read GetCommandQueue;
    Property CommandBuffer[FIndex, SIndex:Integer] : TvgCommandBuffer Read GetCommandBuffer;

    Property FrameIndex        : TvkUint32 Read GetFrameIndex write SetFrameIndex;
    Property SubpassIndex      : TvkUint32 Read GetSubpassIndex write SetSubpassIndex;

    Property CurrentCommand    : TvgCommandBuffer Read GetCurrentCommand;

  Published
    Property Active           : Boolean read GetActive write SetActive stored false;
    Property Device           : TvgLogicalDevice read GetDevice write SetDevice;
    Property QueueFamilyType  : TvgQueueFamilyType read GetQueueFamilyType write SetQueueFamilyType;
    Property QueueCreateFlags : TVgCommandPoolCreateFlag read GetQueueCreateFlags write SetQueueCreateFlags stored False;

  End;

  TvgVertexBindingDesc   = Class(TCollectionItem)
  private
    function GetBinding: TvkUint32;
    function GetName: String;
    function GetStride: TvkUint32;
    procedure SetBinding(const Value: TvkUint32);
    procedure SetInputRate(const Value: TvgVertexInputRate);
    procedure SetName(const Value: String);
    procedure SetStride(const Value: TvkUint32);
    function GetInputRate: TvgVertexInputRate;

    Protected
       fName     : String;
       fBinding  : TvkUint32;
       fStride   : TvkUint32;
       fInputRate: TVkVertexInputRate;

     function GetDisplayName: string; override;
     procedure DefineProperties(Filer: TFiler); override;

       procedure ReadData(Reader: TReader);
       procedure WriteData(Writer: TWriter);

       Procedure SetDisabled;

    Public
      constructor Create(Collection: TCollection); override;
      procedure Assign(Source: TPersistent);   override;

    Published

     Property  Name     : String    read GetName write SetName;
     Property  Binding  : TvkUint32 read GetBinding write SetBinding stored false;
     Property  Stride   : TvkUint32 read GetStride write SetStride stored false;
     Property  InputRate: TvgVertexInputRate read GetInputRate write SetInputRate;

  end;

  TvgVertexBindingDescs  = Class(TCollection)
  private
    FComp      : TvgVertexInputState;
  //  FCollString: string;

    function GetItem(Index: Integer): TvgVertexBindingDesc;
    procedure SetItem(Index: Integer; const Value: TvgVertexBindingDesc);

  Protected
    function GetOwner: TPersistent; override;
    procedure Update(Item: TCollectionItem); override;

  public
    constructor Create (CollOwner: TvgVertexInputState);

    function Add: TvgVertexBindingDesc;
    function AddItem(Item: TvgVertexBindingDesc; Index: Integer): TvgVertexBindingDesc;
    function Insert(Index: Integer): TvgVertexBindingDesc;
    property Items[Index: Integer]: TvgVertexBindingDesc read GetItem write SetItem; default;

  End;


  TvgVertexAttributeDesc   = Class(TCollectionItem)
  private
    function GetBinding: TvkUint32;
    function GetFormat: TvgFormat;
    function GetLocation: TvkUint32;
    function GetName: String;
    function GetOffset: TvkUint32;
    procedure SetBinding(const Value: TvkUint32);
    procedure SetFormat(const Value: TvgFormat);
    procedure SetLocation(const Value: TvkUint32);
    procedure SetName(const Value: String);
    procedure SetOffset(const Value: TvkUint32);
    function GetDataType: TvgDataType;
    procedure SetDataType(const Value: TvgDataType);
    function GetAttributeType: TvgAttributeType;
    procedure SetAttributeType(const Value: TvgAttributeType);

    Protected
       fName     : String;
       fLocation : TvkUint32;
       fBinding  : TvkUint32;
       fFormat   : TVkFormat;
       fOffset   : TvkUint32;
       fType     : TvgDataType  ;
       fAttributeType : TvgAttributeType;

       function GetDisplayName: string; override;

       procedure DefineProperties(Filer: TFiler); override;
       procedure ReadData(Reader: TReader);
       procedure WriteData(Writer: TWriter);

       Procedure SetDisabled;

    Public
      constructor Create(Collection: TCollection); override;
      procedure Assign(Source: TPersistent);   override;

       Function GetShaderHeadTemplate: String;

    Published
      Property Name     : String     Read GetName  Write SetName ;
      Property Location : TvkUint32  Read GetLocation  Write SetLocation stored false;
      Property Binding  : TvkUint32  Read GetBinding  Write SetBinding stored false;
      Property AttFormat: TvgFormat  Read GetFormat   Write SetFormat;
      Property Offset   : TvkUint32  Read GetOffset   Write SetOffset stored false;
      Property DataType : TvgDataType  Read GetDataType write SetDataType;
      Property AttType  : TvgAttributeType Read GetAttributeType write SetAttributeType;

  end;

  TvgVertexAttributeDescs  = Class(TCollection)
  private
    FComp      : TvgVertexInputState;
  //  FCollString: string;

    function GetItem(Index: Integer): TvgVertexAttributeDesc;
    procedure SetItem(Index: Integer; const Value: TvgVertexAttributeDesc);

  Protected
    function GetOwner: TPersistent; override;
    procedure Update(Item: TCollectionItem); override;

  public
    constructor Create (CollOwner: TvgVertexInputState);

    function Add: TvgVertexAttributeDesc;
    function AddItem(Item: TvgVertexAttributeDesc; Index: Integer): TvgVertexAttributeDesc;
    function Insert(Index: Integer): TvgVertexAttributeDesc;
    property Items[Index: Integer]: TvgVertexAttributeDesc read GetItem write SetItem; default;

  End;

  TvgViewport   = Class(TCollectionItem)
  private
    function GetHeight: TvkFloat;
    function GetLeft: TvkFloat;
    function GetMaxZ: TvkFloat;
    function GetMinZ: TvkFloat;
    function GetTop: TvkFloat;
    function GetWidth: TvkFloat;
    procedure SetHeight(const Value: TvkFloat);
    procedure SetLeft(const Value: TvkFloat);
    procedure SetMaxZ(const Value: TvkFloat);
    procedure SetMinZ(const Value: TvkFloat);
    procedure SetTop(const Value: TvkFloat);
    procedure SetWidth(const Value: TvkFloat);
    function GetName: String;
    procedure SetName(const Value: String);
    function GetSize: TvgWinSize;
    procedure SetSize(const Value: TvgWinSize);

    Protected
       fName     : String;
       fWinSize  : TvgWinSize;
       fLeft,
       fTop,
       fWidth,
       fHeight,
       fMinZ,
       fMaxZ     : TvkFloat;

       function GetDisplayName: string; override;

    Public
      constructor Create(Collection: TCollection); override;
      procedure Assign(Source: TPersistent);   override;

      Function IsValid:Boolean;

    Published
      Property Name     : String     Read GetName  Write SetName ;
      Property Size    : TvgWinSize read GetSize write SetSize;
      Property  Left   : TvkFloat Read GetLeft Write SetLeft ;
      Property  Top    : TvkFloat Read GetTop Write SetTop ;
      Property  Width  : TvkFloat Read GetWidth Write SetWidth ;
      Property  Height : TvkFloat Read GetHeight Write SetHeight ;
      Property  MinZ   : TvkFloat Read GetMinZ Write SetMinZ ;
      Property  MaxZ   : TvkFloat Read GetMaxZ Write SetMaxZ ;

  End;

  TvgViewports   = Class(TCollection)
  private
    FComp      : TvgGraphicPipeline;

    function GetItem(Index: Integer): TvgViewport;
    procedure SetItem(Index: Integer; const Value: TvgViewport);

  Protected
    function GetOwner: TPersistent; override;
    procedure Update(Item: TCollectionItem); override;

  public
    constructor Create (CollOwner: TvgGraphicPipeline);

    function Add: TvgViewport;
    function AddItem(Item: TvgViewport; Index: Integer): TvgViewport;
    function Insert(Index: Integer): TvgViewport;
    property Items[Index: Integer]: TvgViewport read GetItem write SetItem; default;

  End;

  TvgScissor   = Class(TCollectionItem)
  private
    function GetHeight: TvkFloat;
    function GetLeft: TvkFloat;
    function GetName: String;
    function GetTop: TvkFloat;
    function GetWidth: TvkFloat;
    procedure SetHeight(const Value: TvkFloat);
    procedure SetLeft(const Value: TvkFloat);
    procedure SetName(const Value: String);
    procedure SetTop(const Value: TvkFloat);
    procedure SetWidth(const Value: TvkFloat);
    function GetSize: TvgWinSize;
    procedure SetSize(const Value: TvgWinSize);

    Protected
       fName     : String;
       fWinSize  : TvgWinSize;
       fLeft,
       fTop,
       fWidth,
       fHeight   : TvkFloat;
       function GetDisplayName: string; override;

    Public
      constructor Create(Collection: TCollection); override;
      procedure Assign(Source: TPersistent);   override;

    Published

      Property Name    : String     Read GetName  Write SetName ;
      Property Size    : TvgWinSize read GetSize write SetSize;
      Property  Left   : TvkFloat Read GetLeft Write SetLeft ;
      Property  Top    : TvkFloat Read GetTop Write SetTop ;
      Property  Width  : TvkFloat Read GetWidth Write SetWidth ;
      Property  Height : TvkFloat Read GetHeight Write SetHeight ;

  End;

  TvgScissors   = Class(TCollection)
  private
    FComp      : TvgGraphicPipeline;
   // FCollString: string;

    function GetItem(Index: Integer): TvgScissor;
    procedure SetItem(Index: Integer; const Value: TvgScissor);

  Protected
    function GetOwner: TPersistent; override;
    procedure Update(Item: TCollectionItem); override;

  public
    constructor Create (CollOwner: TvgGraphicPipeline);

    function Add: TvgScissor;
    function AddItem(Item: TvgScissor; Index: Integer): TvgScissor;
    function Insert(Index: Integer): TvgScissor;
    property Items[Index: Integer]: TvgScissor read GetItem write SetItem; default;
  End;

//Dynamic State MUST be set at least once so need to have all Dynamic States which get to READY MUST be moved to SET
  TvgDynamicStateMode = ( DS_NOTSET,  //Not able to be SET (extension or version incompatible
                          DS_READY,   //if Ready then version OR extension are OK for this device
                          DS_SET);    //Has been set in PipeLine at least ONCE.

  TvgDynamicState   = Class(TCollectionItem)
  private
    function GetDynamicState: TvgDynamicStateBit;
    function GetName: String;
    procedure SetDynamicState(const Value: TvgDynamicStateBit);
    procedure SetName(const Value: String);
    Protected
       fName         : String;
       fDynamicState : TVkDynamicState;
       fMinVer       : TvkUint32;   //Minium Version supporting
       fExtName      : String;    //extension name
       fState        : TvgDynamicStateMode;

       function GetDisplayName: string; override;

       Procedure SetDisabled;

    Public
      constructor Create(Collection: TCollection); override;
      procedure Assign(Source: TPersistent);   override;

      Procedure SetUpDynamicStateExtension(aExtensions : TvgExtensions; aVer: TvkUint32);

    Published

      Property Name         : String     Read GetName  Write SetName ;
      Property DynamicState : TvgDynamicStateBit Read GetDynamicState write SetDynamicState;
      Property State        : TvgDynamicStateMode read fState;
  End;

  TvgDynamicStates   = Class(TCollection)
  private
    FComp      : TvgGraphicPipeline;

    function GetItem(Index: Integer): TvgDynamicState;
    procedure SetItem(Index: Integer; const Value: TvgDynamicState);

  Protected
    function GetOwner: TPersistent; override;
    procedure Update(Item: TCollectionItem); override;

  public
    constructor Create (CollOwner: TvgGraphicPipeline);

    function Add: TvgDynamicState;
    function AddItem(Item: TvgDynamicState; Index: Integer): TvgDynamicState;
    function Insert(Index: Integer): TvgDynamicState;
    property Items[Index: Integer]: TvgDynamicState read GetItem write SetItem; default;

  End;


  TvgStencilOp  =  class(TvgBaseComponent)
  Private
    function GetCompareMask: TvkUint32;
    function GetCompareOp: TvgCompareOpBit;
    function GetDepthFailOp: TvgStencilOpBit;
    function GetFailOp: TvgStencilOpBit;
    function GetPassOp: TvgStencilOpBit;
    function GetReference: TvkUint32;
    function GetWriteMask: TvkUint32;
    procedure SetCompareMask(const Value: TvkUint32);
    procedure SetCompareOp(const Value: TvgCompareOpBit);
    procedure SetDepthFailOp(const Value: TvgStencilOpBit);
    procedure SetFailOp(const Value: TvgStencilOpBit);
    procedure SetPassOp(const Value: TvgStencilOpBit);
    procedure SetReference(const Value: TvkUint32);
    procedure SetWriteMask(const Value: TvkUint32);
    function getActive: Boolean;
    procedure SetActive(const Value: Boolean);

  Protected
    fFailOp     : TVkStencilOp;
    fPassOp     : TVkStencilOp;
    fDepthFailOp: TVkStencilOp;
    fCompareOp  : TVkCompareOp;
    fCompareMask: TvkUint32;
    fWriteMask  : TvkUint32;
    fReference  : TvkUint32;

   procedure DefineProperties(Filer: TFiler); override;
   procedure ReadData(Reader:TReader);
   procedure WriteData(Writer: TWriter);

  Public
    constructor Create(AOwner: TComponent); Override;
    destructor Destroy; override;

   Procedure SetEnabled(aComp:TvgBaseComponent=nil);    Override;
   Procedure SetDisabled;  Override;//will free the VulkanPipe


  Published
    Property Active     : Boolean Read getActive write SetActive stored false;
    Property FailOp     : TvgStencilOpBit Read GetFailOp Write SetFailOp;
    Property PassOp     : TvgStencilOpBit Read GetPassOp Write SetPassOp;
    Property DepthFailOp: TvgStencilOpBit Read GetDepthFailOp Write SetDepthFailOp;
    Property CompareOp  : TvgCompareOpBit Read GetCompareOp Write SetCompareOp;
    Property CompareMask: TvkUint32 Read GetCompareMask Write SetCompareMask Stored false;
    Property WriteMask  : TvkUint32 Read GetWriteMask Write SetWriteMask Stored false;
    Property Reference  : TvkUint32 Read GetReference Write SetReference Stored false;

  end;

  TvgShaderModule = Class(TvgBaseComponent)
  Private
    function GetFileName: String;
    procedure SetFileName(const Value: String);
    function GetMainName: TvkCharString;
    procedure SetMainName(const Value: TvkCharString);
    function GetActive: Boolean;
    procedure SetActive(const Value: Boolean);

  Protected
     fDevice             : TvgScreenRenderDevice;

     fFileName           : String;
     fShaderModuleHandle : TVkShaderModule;

     fData               : PVkVoid;
     fDataAligned        : PVkVoid;
     fDataSize           : TVkSize;
     fMainName           : TvkCharString;

     Procedure SetDisabled ;   override;
     Procedure SetDesigning;   override;
     Procedure SetEnabled(aComp:TvgBaseComponent=nil);     override;

  Public

    constructor Create(AOwner: TComponent); Override;
    destructor Destroy; override;

    Procedure SetDevice(aDevice:TvgScreenRenderDevice);

    Property ShaderHandle : TVkShaderModule read  fShaderModuleHandle;

  Published
    Property Active       : Boolean read GetActive write SetActive stored false;
    Property FileName     : String read GetFileName write SetFileName;
    Property MainName     : TvkCharString Read GetMainName write SetMainName;
  End;

  TvgVertexInputState = Class(TvgBaseComponent)
  Private
    function GetVertexAttributeDescs: TvgVertexAttributeDescs;
    function GetVertexBindingDescs: TvgVertexBindingDescs;
    procedure SetVertexAttributeDesc(const Value: TvgVertexAttributeDescs);
    procedure SetVertexBindingDesc(const Value: TvgVertexBindingDescs);
    function GetActive: Boolean;
    procedure SetActive(const Value: Boolean);

  Protected
 //vertex input state

     fVertexBindingDescs   : TvgVertexBindingDescs;
     fVertexAttributeDescs : TvgVertexAttributeDescs;

     fBindingDesc     : Array of TVkVertexInputBindingDescription;
     fAttributeDesc   : Array of TVkVertexInputAttributeDescription;

     fvertexInputInfo : TVkPipelineVertexInputStateCreateInfo;

     Procedure SetDisabled ;   override;
     Procedure SetEnabled(aComp:TvgBaseComponent=nil);     override;

  Public

    constructor Create(AOwner: TComponent); Override;
    destructor Destroy; override;

  Published

    Property Active : Boolean Read GetActive write SetActive stored false;

    Property Bindings         : TvgVertexBindingDescs read GetVertexBindingDescs  write SetVertexBindingDesc ;
    Property Attributes       : TvgVertexAttributeDescs  read GetVertexAttributeDescs write SetVertexAttributeDesc;

  End;

  TvgInputAssemblyState = Class(TvgBaseComponent)
  Private
    function GetPrimitiveRestartEnable: Boolean;
    function GetTopology: TvgPrimitiveTopology;
    procedure SetPrimitiveRestartEnable(const Value: Boolean);
    procedure SetTopology(const Value: TvgPrimitiveTopology);
    function GetActive: Boolean;
    procedure SetActive(const Value: Boolean);

  Protected
     fFlags                  : TVkPipelineInputAssemblyStateCreateFlags;
     fTopology               : TVkPrimitiveTopology;
     fPrimitiveRestartEnable : Boolean;

     fpipelineIACreateInfo : TVkPipelineInputAssemblyStateCreateInfo  ;

     Procedure SetDisabled ;   override;
     Procedure SetEnabled(aComp:TvgBaseComponent=nil);     override;

  Public

    constructor Create(AOwner: TComponent); Override;
    destructor Destroy; override;

  Published
     Property Active : Boolean Read GetActive write SetActive stored false;

     Property Topology               : TvgPrimitiveTopology Read GetTopology Write SetTopology;
     Property PrimitiveRestartEnable : Boolean Read GetPrimitiveRestartEnable Write SetPrimitiveRestartEnable;
  End;

  TvgRasterizerState = Class(TvgBaseComponent)
  Private
    function GetCullMode: TvgCullMode;
    function GetDepthBiasClamp: TvkFloat;
    function GetDepthBiasConstantFactor: TvkFloat;
    function GetDepthBiasEnable: Boolean;
    function GetDepthBiasSlopeFactor: TvkFloat;
    function GetDepthClampEnable: Boolean;
    function GetFrontFace: TvgFrontFace;
    function GetLineWidth: TvkFloat;
    function GetPolygonMode: TvgPolygonMode;
    function GetRasterizerDiscardEnable: Boolean;
    procedure SetCullMode(const Value: TvgCullMode);
    procedure SetDepthBiasClamp(const Value: TvkFloat);
    procedure SetDepthBiasConstantFactor(const Value: TvkFloat);
    procedure SetDepthBiasEnable(const Value: Boolean);
    procedure SetDepthBiasSlopeFactor(const Value: TvkFloat);
    procedure SetDepthClampEnable(const Value: Boolean);
    procedure SetFrontFace(const Value: TvgFrontFace);
    procedure SetLineWidth(const Value: TvkFloat);
    procedure SetPolygonMode(const Value: TvgPolygonMode);
    procedure SetRasterizerDiscardEnable(const Value: Boolean);
    function GetActive: Boolean;
    procedure SetActive(const Value: Boolean);

  Protected
//Rasterizer
     fDepthClampEnable        : boolean;
     fRasterizerDiscardEnable : boolean;
     fPolygonMode             : TVkPolygonMode;     //needs GPU Feature if not FILL mode
     fCullMode                : TVkCullModeFlags;
     fFrontFace               : TVkFrontFace;
     fDepthBiasEnable         : boolean;
     fDepthBiasConstantFactor : TvkFloat;
     fDepthBiasClamp          : TvkFloat;
     fDepthBiasSlopeFactor    : TvkFloat;
     fLineWidth               : TvkFloat;           //needs GPU feature if >1

     fRastCreateInfo          : TVkPipelineRasterizationStateCreateInfo  ;

     Procedure SetDisabled ;   override;
     Procedure SetEnabled(aComp:TvgBaseComponent=nil);     override;

  Public

    constructor Create(AOwner: TComponent); Override;
    destructor Destroy; override;

  Published
     Property Active : Boolean Read GetActive write SetActive stored false;

    Property DepthClampEnable        : Boolean Read GetDepthClampEnable Write SetDepthClampEnable ;
    Property RasterizerDiscardEnable : Boolean Read GetRasterizerDiscardEnable Write SetRasterizerDiscardEnable ;
    Property PolygonMode             : TvgPolygonMode Read GetPolygonMode Write SetPolygonMode ;
    Property CullMode                : TvgCullMode Read GetCullMode Write SetCullMode ;
    Property FrontFace               : TvgFrontFace Read GetFrontFace Write SetFrontFace ;
    Property DepthBiasEnable         : Boolean Read GetDepthBiasEnable Write SetDepthBiasEnable ;
    Property DepthBiasConstantFactor : TvkFloat Read GetDepthBiasConstantFactor Write SetDepthBiasConstantFactor ;
    Property DepthBiasClamp          : TvkFloat Read GetDepthBiasClamp Write SetDepthBiasClamp ;
    Property DepthBiasSlopeFactor    : TvkFloat Read GetDepthBiasSlopeFactor Write SetDepthBiasSlopeFactor ;
    Property LineWidth               : TvkFloat Read GetLineWidth Write SetLineWidth ;
  End;

  TvgTessellationState = Class(TvgBaseComponent)
  Private
    function GetPatchControlPoints: TvkUint32;
    procedure SetPatchControlPoints(const Value: TvkUint32);
    function GetActive: Boolean;
    procedure SetActive(const Value: Boolean);

  Protected
//tessellation state
     fPatchControlPoints : TvkUint32 ;

     fTessCreateInfo     : TVkPipelineTessellationStateCreateInfo ;

     procedure DefineProperties(Filer: TFiler); override;
     procedure ReadData(Reader:TReader);
     procedure WriteData(Writer: TWriter);

     Procedure SetDisabled ;   override;
     Procedure SetEnabled(aComp:TvgBaseComponent=nil);     override;

  Public

    constructor Create(AOwner: TComponent); Override;
    destructor Destroy; override;

    Property PatchControlPoints : TvkUint32 read GetPatchControlPoints write SetPatchControlPoints Stored False;

  Published
     Property Active : Boolean Read GetActive write SetActive stored false;

  End;

  TvgMultisamplingState = Class(TvgBaseComponent)
  Private
    function GetAlphaToCoverageEnable: boolean;
    function GetAlphaToOneEnable: boolean;
    function GetMinSampleShading: TvkFloat;
    function GetRasterizationSample: TvgSampleCountFlagBits;
    function GetSampleShadingEnable: boolean;
    procedure SetAlphaToCoverageEnable(const Value: boolean);
    procedure SetAlphaToOneEnable(const Value: boolean);
    procedure SetMinSampleShading(const Value: TvkFloat);
    procedure SetRasterizationSample(const Value: TvgSampleCountFlagBits);
    procedure SetSampleShadingEnable(const Value: boolean);
    function GetActive: Boolean;
    procedure SetActive(const Value: Boolean);

  Protected
//Multisampling

     fSampleShadingEnable     : boolean;
     fRasterizationSamples    : TVkSampleCountFlagBits;    //TvgSampleCountFlagBits
     fMinSampleShading        : TvkFloat;
     fSampleMask              : array of TVkSampleMask;
     fAlphaToCoverageEnable   : boolean;
     fAlphaToOneEnable        : boolean;

     fpipelineMSCreateInfo    : TVkPipelineMultisampleStateCreateInfo;

     Procedure SetDisabled ;   override;
     Procedure SetEnabled(aComp:TvgBaseComponent=nil);     override;

  Public

    constructor Create(AOwner: TComponent); Override;
    destructor Destroy; override;

  Published
     Property Active : Boolean Read GetActive write SetActive stored false;

    Property SampleShadingEnable     : boolean Read GetSampleShadingEnable Write SetSampleShadingEnable ;
    Property RasterizationSamples    : TvgSampleCountFlagBits Read GetRasterizationSample Write SetRasterizationSample ;
    Property MinSampleShading        : TvkFloat Read GetMinSampleShading Write SetMinSampleShading ;
 //   Property SampleMask              : array of TVkSampleMask;   finish
    Property AlphaToCoverageEnable   : boolean Read GetAlphaToCoverageEnable Write SetAlphaToCoverageEnable ;
    Property AlphaToOneEnable        : boolean Read GetAlphaToOneEnable Write SetAlphaToOneEnable ;

  End;

  TvgColorBlendAttachment   = Class(TCollectionItem)
    private
    function GetAlphaBlendOp: TvgBlendOp;
    function GetBlendEnable: boolean;
    function GetColorBlendOp: TvgBlendOp;
    function GetColorWriteMask: TvgColorComponentFlagBits;
    function GetDstAlphaBlendFactor: TvgBlendFactor;
    function GetDstColorBlendFactor: TvgBlendFactor;
    function GetName: String;
    function GetSrcAlphaBlendFactor: TvgBlendFactor;
    function GetSrcColorBlendFactor: TvgBlendFactor;
    procedure SetAlphaBlendOp(const Value: TvgBlendOp);
    procedure SetBlendEnable(const Value: boolean);
    procedure SetColorBlendOp(const Value: TvgBlendOp);
    procedure SetColorWriteMask(const Value: TvgColorComponentFlagBits);
    procedure SetDstAlphaBlendFactor(const Value: TvgBlendFactor);
    procedure SetDstColorBlendFactor(const Value: TvgBlendFactor);
    procedure SetName(const Value: String);
    procedure SetSrcAlphaBlendFactor(const Value: TvgBlendFactor);
    procedure SetSrcColorBlendFactor(const Value: TvgBlendFactor);
    function GetActive: Boolean;
    procedure SetActive(const Value: Boolean);

    Protected
     fName                    : String;
     fActive                  : Boolean;

     fBlendEnable             : boolean;
     fSrcColorBlendFactor     : TVkBlendFactor;
     fDstColorBlendFactor     : TVkBlendFactor;
     fColorBlendOp            : TVkBlendOp;
     fSrcAlphaBlendFactor     : TVkBlendFactor;
     fDstAlphaBlendFactor     : TVkBlendFactor;
     fAlphaBlendOp            : TVkBlendOp;
     fColorWriteMask          : TVkColorComponentFlags;

       function GetDisplayName: string; override;

       Procedure SetEnabled;
       Procedure SetDisabled;

    Public
      constructor Create(Collection: TCollection); override;
      procedure Assign(Source: TPersistent);   override;

    Published

      Property Active : Boolean Read GetActive write SetActive stored false;
      Property Name         : String     Read GetName  Write SetName ;

      Property BlendEnable             : boolean Read GetBlendEnable Write SetBlendEnable ;
      Property SrcColorBlendFactor     : TvgBlendFactor Read GetSrcColorBlendFactor Write SetSrcColorBlendFactor ;
      Property DstColorBlendFactor     : TvgBlendFactor Read GetDstColorBlendFactor Write SetDstColorBlendFactor ;
      Property ColorBlendOp            : TvgBlendOp Read GetColorBlendOp Write SetColorBlendOp ;
      Property SrcAlphaBlendFactor     : TvgBlendFactor Read GetSrcAlphaBlendFactor Write SetSrcAlphaBlendFactor ;
      Property DstAlphaBlendFactor     : TvgBlendFactor Read GetDstAlphaBlendFactor Write SetDstAlphaBlendFactor ;
      Property AlphaBlendOp            : TvgBlendOp Read GetAlphaBlendOp Write SetAlphaBlendOp ;
      Property ColorWriteMask          : TvgColorComponentFlagBits Read GetColorWriteMask Write SetColorWriteMask ;

  End;

  TvgColorBlendAttachmentCol  = Class(TCollection)
  private
    FComp      : TvgColorBlendingState;

    function GetItem(Index: Integer): TvgColorBlendAttachment;
    procedure SetItem(Index: Integer; const Value: TvgColorBlendAttachment);

  Protected
    function GetOwner: TPersistent; override;
    procedure Update(Item: TCollectionItem); override;

  public
    constructor Create (CollOwner: TvgColorBlendingState);

    function Add: TvgColorBlendAttachment;
    function AddItem(Item: TvgColorBlendAttachment; Index: Integer): TvgColorBlendAttachment;
    function Insert(Index: Integer): TvgColorBlendAttachment;

    property Items[Index: Integer]: TvgColorBlendAttachment read GetItem write SetItem; default;

  End;

  TvgColorBlendingState = Class(TvgBaseComponent)
  Private
    function GetLogicOp: TvgLogicOp;
    function getLogicOpEnable: Boolean;
    procedure SetLogicOp(const Value: TvgLogicOp);
    procedure SetLogicOpEnable(const Value: Boolean);
    function GetActive: Boolean;
    procedure SetActive(const Value: Boolean);

  Protected
     fColorAttachments        : TvgColorBlendAttachmentCol;

     fLogicOpEnable           : Boolean;
     fLogicOp                 : TVkLogicOp;

     fBlendAttachState        : Array of TVkPipelineColorBlendAttachmentState ;
     fBlendCreateInfo         : TVkPipelineColorBlendStateCreateInfo;

     Procedure SetDisabled ;   override;
     Procedure SetEnabled(aComp:TvgBaseComponent=nil);     override;

  Public

    constructor Create(AOwner: TComponent); Override;
    destructor Destroy; override;

  Published
     Property Active : Boolean Read GetActive write SetActive stored false;

    Property LogicOpEnable   : Boolean Read getLogicOpEnable write SetLogicOpEnable;
    Property LogicOp         : TvgLogicOp Read GetLogicOp write SetLogicOp;

  End;

  TvgDepthStencilState = Class(TvgBaseComponent)
  Private
    function GetDepthBoundsTestEnable: boolean;
    function GetDepthCompareOp: TvgCompareOpBit;
    function GetDepthTestEnable: boolean;
    function GetDepthWriteEnable: boolean;
    function GetMaxDepthBounds: TvkFloat;
    function GetMinDepthBounds: TvkFloat;
    function GetStencilTestEnable: boolean;
    procedure SetDepthBoundsTestEnable(const Value: boolean);
    procedure SetDepthCompareOp(const Value: TvgCompareOpBit);
    procedure SetDepthTestEnable(const Value: boolean);
    procedure SetDepthWriteEnable(const Value: boolean);
    procedure SetMaxDepthBounds(const Value: TvkFloat);
    procedure SetMinDepthBounds(const Value: TvkFloat);
    procedure SetStencilTestEnable(const Value: boolean);
    function GetActive: Boolean;
    procedure SetActive(const Value: Boolean);

  Protected
//Depth and Stencil testing

   fDepthTestEnable         : boolean;
   fDepthWriteEnable        : boolean;
   fDepthCompareOp          : TVkCompareOp;
   fDepthBoundsTestEnable   : boolean;
   fStencilTestEnable       : boolean;
   fFrontOp                 : TvgStencilOp;
   fBackOp                  : TvgStencilOp;
   fMinDepthBounds          : TvkFloat;
   fMaxDepthBounds          : TvkFloat;

   fDepthStencilInfo        : TVkPipelineDepthStencilStateCreateInfo;

   Procedure SetDisabled ;   override;
   Procedure SetEnabled(aComp:TvgBaseComponent=nil);     override;

  Public

    constructor Create(AOwner: TComponent); Override;
    destructor Destroy; override;

    Procedure SetUpDepthStencilState(DepthON, StencilON : Boolean; CompareOP:TVkCompareOp); Virtual;

    Property DepthCompareOp          : TvgCompareOpBit  Read GetDepthCompareOp Write SetDepthCompareOp ;
    //set this value in the RenderPass

  Published
     Property Active : Boolean Read GetActive write SetActive stored false;

    Property DepthTestEnable         : boolean  Read GetDepthTestEnable Write SetDepthTestEnable ;
    Property DepthWriteEnable        : boolean  Read GetDepthWriteEnable Write SetDepthWriteEnable ;
    Property DepthBoundsTestEnable   : boolean Read GetDepthBoundsTestEnable Write SetDepthBoundsTestEnable ;
    Property StencilTestEnable       : boolean Read GetStencilTestEnable  write SetStencilTestEnable;
    Property MinDepthBounds          : TvkFloat Read GetMinDepthBounds Write SetMinDepthBounds ;
    Property MaxDepthBounds          : TvkFloat Read GetMaxDepthBounds Write SetMaxDepthBounds ;

    Property FrontOp                 : TvgStencilOp Read fFrontOp;
    Property BackOp                  : TvgStencilOp Read fBackOp;
  End;

  // a holder/creator of a SceneNode allowing interaction at Design time and run time

  TvgGraphicPipeItem      = Class(TCollectionItem)
  private
    function GetGraphicPipe: TvgGraphicPipeline;
    function GetGraphicPipeType: TvgGraphicsPipelineType;
    procedure SetGraphicPipeType(const Value: TvgGraphicsPipelineType);
    function GetGraphicPipeName: String;
    procedure SetGraphicPipeName(const Value: String);
    function GetRenderNodeType: TvgRenderNodeType;
    function GetRenderPassType: TvgRenderPassType;
    function GetSubPassRef: Integer;
    procedure SetRenderNodeType(const Value: TvgRenderNodeType);
    procedure SetRenderPassType(const Value: TvgRenderPassType);
    procedure SetSubPassRef(const Value: Integer);

    Protected

      fRenderPassType    : TvgRenderPassType;
      fSubPassRef        : Integer;
      fRenderNodeType    : TvgRenderNodeType;

      fGraphicPipeType   : TvgGraphicsPipelineType;

      fGraphicPipeline   : TvgGraphicPipeline;
    Public
      constructor Create(Collection: TCollection); override;
      procedure Assign(Source: TPersistent);       override;

      Property RenderPassType    : TvgRenderPassType read GetRenderPassType  write SetRenderPassType ;
      Property SubPassRef        : Integer           read GetSubPassRef      write SetSubPassRef;
      Property RenderNodeType    : TvgRenderNodeType read GetRenderNodeType  write SetRenderNodeType;

      Property GraphicPipeType   : TvgGraphicsPipelineType read GetGraphicPipeType write SetGraphicPipeType;

     //don't publish
    Published
      Property GraphicPipeName   : String Read GetGraphicPipeName write SetGraphicPipeName;
      //finish
      Property GraphicPipe       : TvgGraphicPipeline read GetGraphicPipe;
  End;

  TvgGraphicPipeLists = Class(TCollection)
   //holds a list of GraphicPipelins for the Nodes to be rendered
   //If correct pipe not available then request pipe from Node
    private
    FComp      : TvgRenderEngine;

    function GetItem(Index: Integer): TvgGraphicPipeItem;
    procedure SetItem(Index: Integer; const Value: TvgGraphicPipeItem);

  Protected
    function GetOwner: TPersistent; override;
    procedure Update(Item: TCollectionItem); override;

  public
    constructor Create (CollOwner: TvgRenderEngine);
    function Add: TvgGraphicPipeItem;
    function AddItem(Item: TvgGraphicPipeItem; Index: Integer): TvgGraphicPipeItem;
    function Insert(Index: Integer): TvgGraphicPipeItem;

    Function GetRenderer : TvgRenderEngine;

    property Items[Index: Integer]: TvgGraphicPipeItem read GetItem write SetItem; default;
  End;

  TvgRenderNodeList = Class(TList<TvgRenderNode>)

  Protected
     fRenderer : TvgRenderEngine;

  End;

  TvgGraphicPipeline     = Class(TvgBaseComponent)
  private
    function GetActive: Boolean;
    procedure SetActive(const Value: Boolean);
  //viewpoerts and Scissors
    function GetScissors: TvgScissors;
    function GetViewPorts: TvgViewports;
    procedure SetScissors(const Value: TvgScissors);
    procedure SetViewPorts(const Value: TvgViewports);
    function GetDynamicStates: TvgDynamicStates;
    procedure SetDynamicStates(const Value: TvgDynamicStates);
    function GetPipeCreateFlags: TvgPipelineCreateFlagBits;
    procedure SetPipeCreateFlags(const Value: TvgPipelineCreateFlagBits);
    function GetLinker: TvgLinker;
    Function GetScreenDevice : TvgScreenRenderDevice;
    function GetRenderEngine: TvgRenderEngine;
    procedure SetRenderEngine(const Value: TvgRenderEngine);
    function GetPipeHandle(aThread,aFrame : Integer): TVkPipeline;
    procedure SetFrameCount(const Value: TvkUint32);
 //   procedure SetName(const Value: String);
    procedure SetThreadCount(const Value: TvkUint32);
    procedure SetResourceUse(const Value: TvgResourceUse);
    procedure SetCurrentFrame(const Value: TvkUint32);
    function GetSubPassRef: Integer;
    procedure SetSubPassRef(const Value: Integer);
    function GetNodeCount: Integer;

  Protected
     fActive : Boolean;
     fName   : String;

   //links
     fRenderEngine       : TvgRenderEngine;
     fSubPassRef         : Integer; //Index of SubPass

  //state
     fPipeCreateFlags    : TVkPipelineCreateFlags; //  fix

 //states
     fVertexInputState   : TvgVertexInputState;
     fInputAssemblyState : TvgInputAssemblyState;
     fTessellationState  : TvgTessellationState ;
     fRasterizerState    : TvgRasterizerState;
     fMultisamplingState : TvgMultisamplingState;
     fDepthStencilState  : TvgDepthStencilState;
     fColorBlendingState : TvgColorBlendingState;

 //shaders
     fVertShader,
     fGeomShader,
     fFragShader         : TvgShaderModule;
     fShaderStages       : Array[0..2] of TvkPipelineShaderStageCreateInfo;

//Viewports and Scissors
     fvp                 : TvkViewPort;
     fSC                 : TVkRect2D;

     fViewports          : TvgViewports;
     fScissors           : TvgScissors;

     fvpCreateInfo       : TVkPipelineViewportStateCreateInfo ;

//Dynamic State
     fDynamicStates      : TvgDynamicStates;
     fDynamicState       : TVkPipelineDynamicStateCreateInfo;
     fDynamicStateArray  : Array of TVkDynamicState;

//Descriptor Sets and Push Constants

  // Instance of Shader Resource used by Nodes linked
  // Each use these as templates ans Node will copy these and fill with data
  // Node will upload data

     fResourceUse           : TvgResourceUse;   //holds list of used resources

     fGraphicPipeRes        : TvgDescriptorSet;

 //Material and Model need to be actual data for Node to copy from
     fGPMaterialRes,                              // NODE material data
     fGPModelRes            : TvgDescriptorSet;   // NODE model space data
  //   fSetNo                 : Integer;    //hold the set number for NODE resources

  //Push Constant Setup
     fPushConstantCol       : TvgPushConstantCol;

     fSetLayoutCount        : TvkUint32;
     fSetLayoutArray        : Array of TVkDescriptorSetLayout;

     fPushConstantRangeCount: TvkUint32;
     fPushConstantRanges    : Array of TVkPushConstantRange;

     fPipelineInfo          : TVkGraphicsPipelineCreateInfo;
     fPipelineLayout        : TVkPipelineLayoutCreateInfo ;
     fPipelineLayoutHandle  : TVkPipelineLayout;

     fFrameCount,
     fCurrentFrame,
     fThreadCount           : TvkUint32  ;

    //list of nodes which use this GraphicPipeline
    //Lists don't own the nodes
     fUnderlayNodes         : TvgRenderNodeList;
     fStaticNodes           : TvgRenderNodeList;
     fDynamicNodes          : TvgRenderNodeList;
     fOverlayNodes          : TvgRenderNodeList;

    //Worker(thread) array of Max Frames In Flight array of handle
     fPipelineHandles       : Array of Array of TVkPipeline;
     //holds Array of Frame In Flight worker array of   pipelines
     fValidStructure        : Boolean;  //set when GP is considered valid

     procedure DefineProperties(Filer: TFiler); override;

  //   procedure Notification(AComponent: TComponent; Operation: TOperation); override;

     Procedure SetDisabled ;   Override;
     Procedure SetDesigning;   Override;
     Procedure SetEnabled(aComp:TvgBaseComponent=nil);     Override;

     Procedure CheckDynamicStateCapabilities;
     Procedure SetUpDynamicStateExtensions(aExtensions : TvgExtensions; aVer: TvkUint32);

     Procedure SetUpViewPortAndScissors;
     Procedure UpdateConnections;

     Function GetLinkerFrameCount : TvkUint32;

  Public

    Class Function GetPropertyName : String ;   Virtual ;

    constructor Create(AOwner: TComponent); Override;
    destructor Destroy; override;

    Function IsDynamicStateEnabled(aState:TVkDynamicState; UpdateState:Boolean=False):Boolean;
    Procedure SetUpDepthStencilState(DepthON, StencilON : Boolean; CompareOP:TVkCompareOp);

    Procedure SetUpPipeline; Virtual;

    //called after constructor
    //descendants will setup up for specific type
     Procedure SetUpPipeLineLayout;

     Procedure SetUpPipeLinePushConstants;
     Procedure UpdatePushConstantData(aIndex:TvkUint32);
     //called during frame build

     Procedure BindPipelineResources(aCommandBuf : TvgCommandBuffer;
                                    // Commands    : TVulkan ;
                                     aWorkerIndex: TvkUint32;
                                     aSubPassIndex : TvkUint32);

     Procedure BindNodeResources(aCommandBuf : TvgCommandBuffer;
                                 //    Commands    : TVulkan ;
                                     aWorkerIndex: TvkUint32;
                                     aSubPassIndex : TvkUint32;
                                     aNode       : TvgRenderNode);

     Procedure BindPipeline(aCommandBuf : TvgCommandBuffer;
                          //   Commands   : TVulkan ;
                            aWorkerIndex,
                            aFrameIndex : TvkUint32);//called from the Node Draw

     Function BuildVertexShader:String;Virtual;
     Function BuildFragmentShader:String;Virtual;
     Function BuildGeometryShader:String;Virtual;
     //handle the asembly of text into Shader
     //see descendants

    Property GraphicPipeHandle[aThread, aFrame : Integer] : TVkPipeline Read GetPipeHandle;

    Property PipelineLayoutHandle  : TVkPipelineLayout Read fPipelineLayoutHandle;

    Property FrameCount    : TvkUint32 read fFrameCount write SetFrameCount;
    Property CurrentFrame  : TvkUint32 read fCurrentFrame write SetCurrentFrame;
    Property ThreadCount   : TvkUint32 read fThreadCount write SetThreadCount;

    Property UnderlayNodes : TvgRenderNodeList read fUnderlayNodes ;
    Property StaticNodes   : TvgRenderNodeList read fStaticNodes ;
    Property DynamicNodes  : TvgRenderNodeList read fDynamicNodes ;
    Property OverlayNodes  : TvgRenderNodeList read fOverlayNodes ;

    Property NodeCount     : Integer Read GetNodeCount;

  Published

    Property Active           : Boolean read GetActive write SetActive Stored false;

    Property PipeCreateFlags  : TvgPipelineCreateFlagBits Read GetPipeCreateFlags write SetPipeCreateFlags;

    Property VertexS          : TvgShaderModule Read fVertShader;
    Property GeometryS        : TvgShaderModule Read fGeomShader;
    Property FragmentS        : TvgShaderModule Read fFragShader;

    Property InputAssembly    : TvgInputAssemblyState read fInputAssemblyState;
    Property VertexInput      : TvgVertexInputState Read fVertexInputState;
    Property Tessellation     : TvgTessellationState Read fTessellationState;
    Property Multisampling    : TvgMultisamplingState Read fMultisamplingState;
    Property Rasterizer       : TvgRasterizerState Read fRasterizerState;
    Property DepthStencil     : TvgDepthStencilState Read fDepthStencilState;
    Property ColorBlending    : TvgColorBlendingState Read fColorBlendingState;

    Property ViewPorts        : TvgViewports read GetViewPorts write SetViewPorts ;
    Property Scissors         : TvgScissors  read GetScissors write SetScissors;

    Property DynamicStates    : TvgDynamicStates read GetDynamicStates write SetDynamicStates;

    Property Renderer         : TvgRenderEngine Read GetRenderEngine write SetRenderEngine;

    Property ResourceUse      : TvgResourceUse Read fResourceUse write SetResourceUse;

    Property GraphicPipeRes   : TvgDescriptorSet Read fGraphicPipeRes;
    Property MaterialRes      : TvgDescriptorSet  Read fGPMaterialRes ;
    Property ModelRes         : TvgDescriptorSet  Read fGPModelRes ;

    Property PushConstantCol  : TvgPushConstantCol read fPushConstantCol;
    Property SubPassRef       : Integer Read GetSubPassRef write SetSubPassRef; //Index of SubPass

  end;


  TvgGraphicPipeTypeList = Class( TList<TvgPipeTypeRec>);
  //Use registerGraphicPipe to make a list of pipes needed for a given renderpass type

  TvgAttachment = Class(TCollectionItem)
  private
    function GetFinalLayout: TvgImageLayout;
    function GetInitialLayout: TvgImageLayout;
    function GetLoadOp: TvgAttachmentLoadOp;
    function GetSamples: TvgSampleCountFlagBits;
    function GetStencilLoadOp: TvgAttachmentLoadOp;
    function GetStencilStoreOp: TvgAttachmentStoreOp;
    function GetStoreOp: TvgAttachmentStoreOp;
    procedure SetFinalLayout(const Value: TvgImageLayout);
    procedure SetInitialLayout(const Value: TvgImageLayout);
    procedure SetLoadOp(const Value: TvgAttachmentLoadOp);
    procedure SetSamples(const Value: TvgSampleCountFlagBits);
    procedure SetStencilLoadOp(const Value: TvgAttachmentLoadOp);
    procedure SetStencilStoreOp(const Value: TvgAttachmentStoreOp);
    procedure SetStoreOp(const Value: TvgAttachmentStoreOp);
    function getName: String;
    procedure SetName(const Value: String);
    function GetType: TvgAttachmentType;
    procedure SetType(const Value: TvgAttachmentType);
    function GetFormat: TvgFormat;
    procedure SetFormat(const Value: TvgFormat);
    function GetImageBuffer(Index: Integer): TvgResourceImageBuffer;
    procedure SetImageBufferSize(const Value: Integer);
  protected

       fName           : String;
       fActive         : Boolean;
       fType           : TvgAttachmentType;
       fIndex          : TvkUint32;     //index in VulkanRenderPass as set by AddAttachment

       fflags          : TVkAttachmentDescriptionFlags;
       fformat         : TVkFormat;
       fsamples        : TVkSampleCountFlagBits;
       floadOp         : TVkAttachmentLoadOp;
       fstoreOp        : TVkAttachmentStoreOp;
       fstencilLoadOp  : TVkAttachmentLoadOp;
       fstencilStoreOp : TVkAttachmentStoreOp;
       finitialLayout  : TVkImageLayout;
       ffinalLayout    : TVkImageLayout;

       fImageBufferSize  : Integer;//default 1 but set as Property
       fImageBufferArray : Array of TvgResourceImageBuffer;
       //length is Frame Count  or Screen Image count depending on RenderType
       //holds resources for attachment (NOT screen Image or Frame Image) eg depth/MSAA/Select

       procedure DefineProperties(Filer: TFiler); override;
       function GetDisplayName: string; override;

       Procedure SetEnabled;
       Procedure SetDisabled;

       Procedure SetUpForType;
       Procedure SetUpImageResources;

       Function GetRenderPass:TvgRenderPass;

  Public

      constructor Create(Collection: TCollection); override;
      procedure Assign(Source: TPersistent);   override;
      destructor Destroy; override;

      Property ImageBuffer[Index:Integer] : TvgResourceImageBuffer  Read GetImageBuffer;

  Published

      Property Name           : String read getName  write SetName;
      Property AttachType     : TvgAttachmentType Read GetType write SetType;

      Property Format         : TvgFormat               Read GetFormat write SetFormat;

      Property  Samples       : TvgSampleCountFlagBits  Read GetSamples  Write SetSamples  ;
      Property  LoadOp        : TvgAttachmentLoadOp     Read GetLoadOp  Write SetLoadOp  ;
      Property  StoreOp       : TvgAttachmentStoreOp    Read GetStoreOp  Write SetStoreOp  ;
      Property  StencilLoadOp : TvgAttachmentLoadOp     Read GetStencilLoadOp  Write SetStencilLoadOp  ;
      Property  StencilStoreOp: TvgAttachmentStoreOp    Read GetStencilStoreOp  Write SetStencilStoreOp  ;
      Property  InitialLayout : TvgImageLayout          Read GetInitialLayout  Write SetInitialLayout  ;
      Property  FinalLayout   : TvgImageLayout          Read GetFinalLayout  Write SetFinalLayout  ;

      Property ImageBufferSize : Integer read fImageBufferSize write SetImageBufferSize;
  End;

  TvgAttachmentCol = Class(TCollection)
  private
    FComp      : TvgRenderPass;

    function GetItem(Index: Integer): TvgAttachment;
    procedure SetItem(Index: Integer; const Value: TvgAttachment);
    function GetRenderPass: TvgRenderPass;

  Protected
    function GetOwner: TPersistent; override;
    procedure Update(Item: TCollectionItem); override;
    procedure Notify(Item: TCollectionItem; Action: TCollectionNotification); Override;

  public
    constructor Create (CollOwner: TvgRenderPass);
    function Add: TvgAttachment;
    function AddItem(Item: TvgAttachment; Index: Integer): TvgAttachment;
    function Insert(Index: Integer): TvgAttachment;
    property Items[Index: Integer]: TvgAttachment read GetItem write SetItem; default;

    Function GetAttachmentType(aType: TvgAttachmentType): TvgAttachment;//can return nil

    Property RenderPass : TvgRenderPass Read GetRenderPass;

  End;

  TvgSubPassAttachment = Class(TCollectionItem)
  private
      fName       : String;

      fAttachment : TvgAttachment;
      fLayout     : TVkImageLayout;

    function getName: String;
    procedure SetName(const Value: String);
    function GetLayout: TvgImageLayout;
    procedure SetLayout(const Value: TvgImageLayout);
    function GetAttachment: TvgAttachment;
    procedure SetAttachment(const Value: TvgAttachment);

  protected
       fAttachmentIndex : Integer; //temporary index holder for Read/Write

       procedure DefineProperties(Filer: TFiler); override;
       function GetDisplayName: string; override;

       Procedure SetDisabled;

       procedure ReadAttachment(Reader: TReader);
       procedure WriteAttachment(Writer: TWriter);

  Public

      constructor Create(Collection: TCollection); override;
      procedure Assign(Source: TPersistent);   override;

      Function GetRenderPass : TvgRenderPass;

      Property Name       : String read getName  write SetName;
  Published
      Property Attachment : TvgAttachment read GetAttachment write SetAttachment Stored False;
      Property Layout     : TvgImageLayout read GetLayout write SetLayout;

  End;

  TvgSubPassAttachmentCol = Class(TCollection)
  private
    FComp      : TvgSubPass;
    fLimit     : Integer;   //limits number of Items added if set >0

    fRefCount    : Integer;
    fRefArray    : Array of TvkAttachmentReference;

    function GetItem(Index: Integer): TvgSubPassAttachment;
    procedure SetItem(Index: Integer; const Value: TvgSubPassAttachment);
    function GetLimit: Integer;
    procedure SetLimit(const Value: Integer);

  Protected
    function GetOwner: TPersistent; override;
    procedure Update(Item: TCollectionItem); override;
    procedure DefineProperties(Filer: TFiler); override;
    procedure Notify(Item: TCollectionItem; Action: TCollectionNotification); Override;

  public
    constructor Create (CollOwner: TvgSubPass);
    Destructor Destroy;Override;

    Procedure BuildRefArray;
    Procedure ClearRefArray;

    function Add: TvgSubPassAttachment;
    function AddItem(Item: TvgSubPassAttachment; Index: Integer): TvgSubPassAttachment;
    function Insert(Index: Integer): TvgSubPassAttachment;

    property Items[Index: Integer]: TvgSubPassAttachment read GetItem write SetItem; default;
    Property Limit : Integer Read GetLimit write SetLimit;
  End;

  PvkAttachRefArray = ^TvkAttachRefArray;
  TvkAttachRefArray = Array of TvkAttachmentReference;

  TvgSubPass = Class(TCollectionItem)
  private
    function GetColorAttachments: TvgSubPassAttachmentCol;
    function GetDepthStencilAttachment: TvgSubPassAttachmentCol;
    function GetInputAttachments: TvgSubPassAttachmentCol;
    function GetPreserveAttachments: TvgSubPassAttachmentCol;
    function GetResolveAttachment: TvgSubPassAttachmentCol;
    procedure SetColorAttachments(const Value: TvgSubPassAttachmentCol);
    procedure SetDepthStencilAttachment( const Value: TvgSubPassAttachmentCol);
    procedure SetInputAttachments(const Value: TvgSubPassAttachmentCol);
    procedure SetPreserveAttachments(const Value: TvgSubPassAttachmentCol);
    procedure SetResolveAttachment(const Value: TvgSubPassAttachmentCol);
    function GetName: String;
    procedure SetName(const Value: String);
    function GetPipelineBindPoint: TvgPipelineBindPoint;
    procedure SetPipelineBindPoint(const Value: TvgPipelineBindPoint);
    procedure SetMode(const Value: TvgRenderPassMode);

  protected
     fName   : String;
     fIndex  : TvkUint32;
     fMode    : TvgRenderPassMode;

     fPipelineBindPoint         : TVkPipelineBindPoint;

     fInputAttachmentRefs       : TvgSubPassAttachmentCol ;
     fColorAttachmentRefs       : TvgSubPassAttachmentCol ;
     fResolveAttachmentRefs     : TvgSubPassAttachmentCol;
     fPreserveAttachmentRefs    : TvgSubPassAttachmentCol;
     fDepthStencilAttachmentRef : TvgSubPassAttachmentCol;

     procedure DefineProperties(Filer: TFiler); override;
     function GetDisplayName: string; override;

     Procedure SetDisabled;

  Public

      constructor Create(Collection: TCollection); override;
      procedure Assign(Source: TPersistent);   override;
      destructor Destroy; override;

      Function GetRenderPass : TvgRenderPass;

      Procedure SetUpAttachmentArrays;
      Procedure ClearAttachmentArrays;

      Property  Mode    : TvgRenderPassMode Read fMode write SetMode;


  Published
      Property Name                   : String read GetName write SetName;

      Property PipelineBindPoint      : TvgPipelineBindPoint Read GetPipelineBindPoint Write SetPipelineBindPoint ;

      Property InputAttachments       :  TvgSubPassAttachmentCol Read GetInputAttachments  Write  SetInputAttachments ;
      Property ColorAttachments       :  TvgSubPassAttachmentCol Read GetColorAttachments  Write  SetColorAttachments ;
      Property ResolveAttachment      :  TvgSubPassAttachmentCol Read GetResolveAttachment  Write  SetResolveAttachment ;
      Property DepthStencilAttachment :  TvgSubPassAttachmentCol Read GetDepthStencilAttachment  Write  SetDepthStencilAttachment ;
      Property PreserveAttachments    :  TvgSubPassAttachmentCol Read GetPreserveAttachments  Write  SetPreserveAttachments ;
  End;

  TvgSubPassCol = Class(TCollection)
  private
    FComp      : TvgRenderPass;
  //  FCollString: string;

    function GetItem(Index: Integer): TvgSubPass;
    procedure SetItem(Index: Integer; const Value: TvgSubPass);

  Protected
    function GetOwner: TPersistent; override;
    procedure Update(Item: TCollectionItem); override;
    procedure Notify(Item: TCollectionItem; Action: TCollectionNotification); Override;

  public
    constructor Create (CollOwner: TvgRenderPass);
    function Add: TvgSubPass;
    function AddItem(Item: TvgSubPass; Index: Integer): TvgSubPass;
    function Insert(Index: Integer): TvgSubPass;
    property Items[Index: Integer] : TvgSubPass read GetItem write SetItem; default;

    Function IndexOf(aItem:TvgSubPass):Integer;

  End;

  TvgSubPassDependency = Class(TCollectionItem)
  private
      fName           : String;
    //  fIndex          : TvkUint32;

      fSrcSubpass     : TvgSubPass;
      fDstSubpass     : TvgSubPass;

      fSrcSubpassIndex: Integer;   //temporary index holder for Read/Write
      fDstSubpassIndex: Integer;   //temporary index holder for Read/Write

      fSrcStageMask   : TVkPipelineStageFlags;
      fDstStageMask   : TVkPipelineStageFlags;

      fSrcAccessMask  : TVkAccessFlags;
      fDstAccessMask  : TVkAccessFlags;

      fDependencyFlags: TVkDependencyFlags;

    function GetName: String;
    procedure SetName(const Value: String);
    function GetDstSubPass: TvgSubPass;
    function GetSrcSubPass: TvgSubPass;
    procedure SetDstSubPass(const Value: TvgSubPass);
    procedure SetSrcSubPass(const Value: TvgSubPass);
    function GetDstStageMask: TvgPipelineStageFlagBits;
    function GetSrcStageMask: TvgPipelineStageFlagBits;
    procedure SetDstStageMask(const Value: TvgPipelineStageFlagBits);
    procedure SetSrcStageMask(const Value: TvgPipelineStageFlagBits);
    function GetDependencyFlags: TvgDependencyFlagBits;
    function GetDstAccessMask: TvgAccessFlagBits;
    function GetSrcAccessMask: TvgAccessFlagBits;
    procedure SetDependencyFlags(const Value: TvgDependencyFlagBits);
    procedure SetDstAccessMask(const Value: TvgAccessFlagBits);
    procedure SetSrcAccessMask(const Value: TvgAccessFlagBits);

  protected

       procedure DefineProperties(Filer: TFiler); override;
       function GetDisplayName: string; override;

       Procedure SetDisabled;

       procedure ReadSubPasses(Reader: TReader);
       procedure WriteSubPasses(Writer: TWriter);

  Public

      constructor Create(Collection: TCollection); override;
      procedure Assign(Source: TPersistent);   override;
      destructor Destroy; override;

      Function GetRenderPass : TvgRenderPass;


  Published
      Property Name       : String read GetName write SetName;

      Property SrcSubPass : TvgSubPass read GetSrcSubPass write SetSrcSubPass Stored False;
      Property DstSubPass : TvgSubPass read GetDstSubPass write SetDstSubPass Stored False;

      Property SrcStageMask   : TvgPipelineStageFlagBits read getSrcStageMask write SetSrcStageMask;
      Property DstStageMask   : TvgPipelineStageFlagBits read GetDstStageMask write SetDstStageMask;

      Property SrcAccessMask  : TvgAccessFlagBits Read GetSrcAccessMask Write SetSrcAccessMask;
      Property DstAccessMask  : TvgAccessFlagBits Read GetDstAccessMask Write SetDstAccessMask;

      Property DependencyFlags: TvgDependencyFlagBits Read GetDependencyFlags Write SetDependencyFlags;

  End;

  TvgSubPassDependencyCol = Class(TCollection)
  private
    FComp      : TvgRenderPass;

    function GetItem(Index: Integer): TvgSubPassDependency;
    procedure SetItem(Index: Integer; const Value: TvgSubPassDependency);

  Protected
    function GetOwner: TPersistent; override;
    procedure Update(Item: TCollectionItem); override;

  public
    constructor Create (CollOwner: TvgRenderPass);
    function Add: TvgSubPassDependency;
    function AddItem(Item: TvgSubPassDependency; Index: Integer): TvgSubPassDependency;
    function Insert(Index: Integer): TvgSubPassDependency;
    property Items[Index: Integer]: TvgSubPassDependency read GetItem write SetItem; default;

  End;

  TvgRenderPass     = Class(TvgBaseComponent)
  private
    function getAttachments: TvgAttachmentCol;
    procedure SetAttachments(const Value: TvgAttachmentCol);
    function GetSubPasses: TvgSubPassCol;
    procedure SetSubPasses(const Value: TvgSubPassCol);
    function GetActive: Boolean;
    procedure SetActive(const Value: Boolean);
    function GetSubPassDependencies: TvgSubPassDependencyCol;
    procedure SetSubPassDependencies(const Value: TvgSubPassDependencyCol);
    function GetColourFormat: TvgFormat;
    function GetDepthFormat: TvgDepthBufferFormat;
    procedure SetColourFormat(const Value: TvgFormat);
    procedure SetDepthFormat(const Value: TvgDepthBufferFormat);
    function GetSampleCount: TvgSampleCountFlagBits;
    procedure SetSampleCount(const Value: TvgSampleCountFlagBits);
    function GetLinker: TvgLinker;
    procedure SetLinker(const Value: TvgLinker);
    function GetDepthBufON: Boolean;
    function GetStencilBufON: Boolean;
    procedure SetDepthBufON(const Value: Boolean);
    procedure SetStencilBufON(const Value: Boolean);
    function GetBufDepthCompare: TvgCompareOpBit;
    procedure SetBufDepthCompare(const Value: TvgCompareOpBit);
    function GetClearCol(Index: Integer): TVkClearValue;
    function GetClearColCount: Integer;
    function GetClearColArray: PVkClearValue;
//    procedure SetRenderTarget(const Value: TvgRenderPassTarget);
    function GetFrameBufferHandle(Index: Integer): TVkFrameBuffer;
 //   function GetRenderPassHandle(Index: Integer): TVkRenderPass;

  Protected
    fLinker              : TvgLinker;
    fRenderEngine        : TvgRenderEngine;

    fRenderPassHandle    : TVkRenderPass;  //do not need more than one

    fAttachments         : TvgAttachmentCol;
    fSubPasses           : TvgSubPassCol;
    fSubPassDependencies : TvgSubPassDependencyCol;

    fClearColArray       : Array Of TVkClearValue;
    //hold clear colours for array of attachments

    fColourFormat        : TvkFormat;

 //multisampling
    fMSAASampleCount     : TVkSampleCountFlagBits;

 //depth buffering
    fDepthBufOn          : Boolean;
    fStencilBufOn        : Boolean;
    fDepthStencilFormat  : TvkFormat;
    fDepthCompare        : TVkCompareOp;
    fDepthClear          : TVkFloat;
    fStencilClear        : TvkUint32;

    fFrameBufferHandles  : Array of TVkFrameBuffer;
    //one frame buffer per Frame or per screen depending on fRenderTarget

    Procedure Loaded ; Override;

    procedure Notification(AComponent: TComponent; Operation: TOperation); override;

    Procedure SetDisabled ; Override;
    Procedure SetEnabled(aComp:TvgBaseComponent=nil);   Override;

    Function CheckValidity : Boolean;

    Procedure SetUpClearColorArray; Virtual;
    Procedure AddFrameToScreenSubPass; //used when rendering to a Frame then copying to Screen

    Procedure FrameBuffersSetUp;
    Procedure FrameBuffersClear;

  Public

    constructor Create(AOwner: TComponent); Override;
    destructor Destroy; override;

    Procedure BuildStructure;       Virtual;     //override for changes or build manually
    Procedure ClearStructure;                    //clear the renderpass for a new build of structure
    Function GetAttachmentOfType(aType: TvgAttachmentType): TvgAttachment;

    Procedure CheckDepthFormatSupport(Tiling:TVkImageTiling);
    Procedure SetRequiredSamplingExtension;
    Procedure UpdateWindowSize;
    Procedure UpdateAttachmentFormats;    //when screen data is available

    function IsMSAAOn: Boolean;

    Property RenderPassHandle: TVkRenderPass Read fRenderPassHandle;

    Property MSAAOn     : Boolean Read IsMSAAOn;
    Property DepthBufOn : Boolean Read fDepthBufOn;
    Property StencilBufOn : Boolean Read fStencilBufOn;
    Property DepthCompare : TVkCompareOp Read fDepthCompare;

    Property ClearColCount : Integer Read GetClearColCount;
    Property ClearCol[Index:Integer] : TVkClearValue Read GetClearCol;
    Property ClearColArray : PVkClearValue Read GetClearColArray;

    Property FrameBufferHandles[Index:Integer] : TVkFrameBuffer Read GetFrameBufferHandle;
    Property RenderEngine  : TvgRenderEngine Read fRenderEngine;


  Published

    Property Active              : Boolean Read GetActive write SetActive stored False;

    Property Linker              : TvgLinker Read GetLinker write SetLinker;

    Property Attachments         : TvgAttachmentCol read getAttachments write SetAttachments;
    Property SubPasses           : TvgSubPassCol read GetSubPasses write SetSubPasses;
    Property SubPassDependencies : TvgSubPassDependencyCol read GetSubPassDependencies write SetSubPassDependencies;

    Property ColourFormat        : TvgFormat Read GetColourFormat write SetColourFormat;
    Property DepthFormat         : TvgDepthBufferFormat Read GetDepthFormat write SetDepthFormat;

    Property BufDepthON          : Boolean Read GetDepthBufON write SetDepthBufON;
    Property BufStencilON        : Boolean Read GetStencilBufON write SetStencilBufON;
    Property BufDepthCompare     : TvgCompareOpBit   Read GetBufDepthCompare Write SetBufDepthCompare;

    Property MSAASample          : TvgSampleCountFlagBits Read GetSampleCount write SetSampleCount;

  End;

  TvgWindowLinkEnableEvent                = procedure(Sender: TvgLinker) of object;
  TvgWindowBuildRenderPassStructureEvent  = procedure(Sender: TvgRenderPass) of object;

  TvgLinker  = Class(TvgBaseComponent)
  //Manages link between Device, a Window and RenderEngine and includes all window linked structures eg surface depth buffer etc
  private
    function getActive: Boolean;
    function GetDevice: TvgPhysicalDevice;
    function GetSurface: TvgSurface;
    function GetSwapChain: TvgSwapChain;
    procedure SetActive(const Value: Boolean);
    procedure SetDevice(const Value: TvgPhysicalDevice);
    function GetScreenDevice: TvgScreenRenderDevice;
    function GetWindowIntf: IvgVulkanWindow;
    procedure SetWindowIntf(const Value: IvgVulkanWindow);
    function GetCurrentFrame: TvgFrame;
    function GetRenderer: TvgRenderEngine;
    procedure SetRenderer(const Value: TvgRenderEngine);
    function GetFramesInFlight: TvkUint32;
    procedure SetFramesInFlight(const Value: TvkUint32);
    function GetCurrentFrameIndex: Integer;
    function GetUseThread: Boolean;
    procedure SetUseThread(const Value: Boolean);
    function GetFrame(Index: Integer): TvgFrame;
    procedure SetRenderTarget(const Value: TvgRenderPassTarget);


  Protected
  //linked components
    fPhysicalDevice      : TvgPhysicalDevice;  //get instance through device
    fWindowIntf          : IvgVulkanWindow;
    fRenderer            : TvgRenderEngine;

  //sub components owned by Linker
    fSurface             : TvgSurface;
    fScreenDevice        : TvgScreenRenderDevice  ;   //logical device  sub component
    fSwapChain           : TvgSwapChain;             //subcomponent

    fFrameCount          : TvkUint32;
    fFrames              : Array of TvgFrame;  //length the MaxFramesInFlight

    fCurrentFrameIndex,                 //used for rendering
    fNextFrameIndex      : Integer;     //used for setup of next frame

    fImageFormat         : TVkFormat;         //not stored

    fRebuildNeeded,
    fUseThread,
    fRenderRequested     : Boolean;  //flagged by swap chain rebuild request

    fRenderTarget        : TvgRenderPassTarget;

    fOnEnabled                  : TvgWindowLinkEnableEvent;
 //   fOnRenderPassStructureBuild : TvgWindowBuildRenderPassStructureEvent;

    Procedure Loaded ; Override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;

    Procedure SetDisabled;  override;
    Procedure SetDesigning; override;
    Procedure SetEnabled(aComp:TvgBaseComponent=nil);   override  ;

    Procedure UpdateConnections;
    Procedure UpdateFormats;
    Procedure SetUpCapabilities;
    Procedure UpdateWindowSize;
    Procedure IncFrame(Var aCurrentFrame, aNextFrame:Integer);

//    Procedure FrameBuffersSetUp;
//    Procedure FrameBuffersClear;

    Procedure VulkanWaitIdle;
    Procedure SwapChainRebuild;
//    Function GetMainCommandPool:TvgCommandBufferPool;

  Public
    constructor Create(AOwner: TComponent); Override;
    destructor Destroy; override;

    Procedure DisableParent(ToRoot:Boolean=False); Override; //must be public

    Procedure BuildSwapChainColorSpaces;
    Procedure BuildSwapChainPresentationModes;
//    Procedure BuildRenderPassStructure;
    Procedure BuildFeaturesStructure;       //update features structure with current device capability


    Function VulkanPaint_Start  : Boolean;  Virtual;
    Function VulkanPaint_Finish : Boolean;  Virtual;
    Function VulkanPaint_Cancel : Boolean;  Virtual;

    Procedure FlagSwapChainRebuild;
    Procedure TriggerWindowRepaint;  Virtual;

    Property WindowIntf      : IvgVulkanWindow read GetWindowIntf write SetWindowIntf;

    Property ImageFormat     : TVkFormat Read fImageFormat;         //not stored

    Property CurrentFrame    : TvgFrame read GetCurrentFrame;

    Property FrameIndex      : Integer read GetCurrentFrameIndex;
    Property NextFrameIndex  : Integer Read fNextFrameIndex;

    Property Frame[Index:Integer] : TvgFrame Read GetFrame;

    Property UseThread       : Boolean Read GetUseThread write SetUseThread;

  Published

    Property Active         : Boolean Read getActive write SetActive stored False;

    Property Device         : TvgPhysicalDevice Read GetDevice write SetDevice;
    Property Renderer       : TvgRenderEngine read GetRenderer write SetRenderer;
    Property FrameCount     : TvkUint32 Read GetFramesInFlight write SetFramesInFlight;

//want to be able to edit these sub components
    Property Surface        : TvgSurface Read GetSurface ;
    Property ScreenDevice   : TvgScreenRenderDevice  Read GetScreenDevice;
    Property SwapChain      : TvgSwapChain read GetSwapChain;

    Property RenderTarget  : TvgRenderPassTarget Read fRenderTarget Write SetRenderTarget;

    Property OnEnabled         : TvgWindowLinkEnableEvent read fOnEnabled write fOnEnabled; //allow specific setup prior to enabling
//Property OnRenderPassBuild : TvgWindowBuildRenderPassStructureEvent read fOnRenderPassStructureBuild write fOnRenderPassStructureBuild;

  End;

  TvgFrame   = Class(TvgBaseComponent)
  Private
    function GetActive: Boolean;
    procedure SetActive(const Value: Boolean);
    function GetLinker: TvgLinker;
    procedure SetLinker(const Value: TvgLinker);
    procedure SetFrameIndex(const Value: TvkUint32);
    procedure SetWaitToExecute(const Value: Boolean);
    function GetFrameBufferHandle: TVkFramebuffer;

  Protected
   //connected components
    fLinker              : TvgLinker;

    fFrameIndex          : TvkUint32;
    //index in list of Frames
    fImageIndex          : TvkUint32;
    //index in list of swapchain images

    fGraphicQueue,
    fTransferQueue              : TpvVulkanQueue;

    fImageAvailableSemaphore    : TpvVulkanSemaphore;
    fRenderingFinishedSemaphore : TpvVulkanSemaphore;

    fFrameGraphicCommandPool    : TvgCommandBufferPool;
    //Graphic Command Pool
    //set with RESET capability so Buffers can be RESET

    fFramePrepareCommandBuffer  : TvgCommandBuffer;
    //primary command buffer for Frame
    //should be cleared at the start of rendering the the frame
    //all secondary buffers (from worker threads) should be compatible with this buffer

  //  fFramePresentCommandBuffer  : TvgCommandBuffer;
    //a Graphic command buffer used to move Frame Image to Screen
    //should be cleared at the start of rendering the the frame

    fFrameImageBuffer           : TvgResourceImageBuffer;
    //holds image buffer resource for copying to screen in last stage of Render
    //maybe nil
    //created in Enabled if required set to mirror screen properties

    fUIBufferON                 : Boolean;
    //UI Buffer ON
    fUIImageBuffer              : TvgResourceImageBuffer;
    //used to hold UI image eg cursor, screen text etc

    fWaitToExecute              : Boolean;
    //set to true when building/presenting a frame //default to false

  {$IFDEF TIMINGON}
     fPrepareFrameTime,
     fExecuteFrameTime,
     fPresentFrame       : Int64;
  {$ENDIF}


    Procedure SetDisabled;  override;
    Procedure SetEnabled(aComp:TvgBaseComponent=nil);   override  ;

 //   Procedure WaitIdle;
    Procedure ResetPrepareCommandBuffer;

  Public
    constructor Create(AOwner: TComponent); Override;
    destructor Destroy; override;

    Procedure PrepareFrame;  Virtual;
    //prepare the Frame for building the command buffer
    Procedure ExecuteFrame;  Virtual;
    //execute the fFramePrepareCommandBuffer
    //above build FrameImageBuffer to contain the Frames Image
    //The above calls MUST be run together in a single thread

    Procedure PresentFrame;  Virtual;
    //Will aquire the next swap chain image, copy FrameImageBuffer to swap chain image and Present
    //execute the fFramePresentCommandBuffer

    //The above calls can be run in Threads
    Function IsFrameLocked : Boolean;
    //will be TRUE if Frame is preparing or presenting frame
    //this includes that Vulkan is still executing the frame Command Buffer (including threads)


    Property Active              : Boolean Read GetActive Write SetActive stored false;
    Property FrameIndex          : TvkUint32 Read fFrameIndex write SetFrameIndex;
    Property ImageIndex          : TvkUint32 Read fImageIndex;
    Property FrameBufferHandle   :  TVkFramebuffer Read GetFrameBufferHandle;
    Property Linker              : TvgLinker read GetLinker Write SetLinker;
    Property FrameCommandBuffer  : TvgCommandBuffer Read fFramePrepareCommandBuffer;
    Property FrameImageBuffer    : TvgResourceImageBuffer Read fFrameImageBuffer;
    Property WaitToExecute       : Boolean read fWaitToExecute write SetWaitToExecute ;

  End;

  TvgNodeMode = (NM_NONE,
                 NM_UNDERLAY,
                 NM_STATIC,     //unable to interact with on the screen. No select/edit/move etc
                 NM_DYNAMIC,    //Able to select (for edit/move etc) and animate
                 NM_OVERLAY) ;

  TvgRenderTaskJob = (TM_NONE,
                      TM_UPLOADDATA,
                      TM_UPLOADRESOURCEDATA,
                      TM_BEGIN_RECORDING_FRAME,
                      TM_BIND_PIPELINE,
                      TM_RENDER_NODE,
                      TM_END_RECORDING_FRAME,
                      TM_EXECUTE_SECONDARY,
                      TM_RESET
                      );


  TvgRenderTaskStatus = (TS_NONE,
                         TS_PENDING,
                         TS_WORKING,
                         TS_COMPLETE,
                         TS_FAIL);

  PvgRenderTask = ^TvgRenderTask;
  TvgRenderTask = record
     Active           : Boolean;
     //task is in use
     //consider ALL data locked until fActive is FALSE
     TaskJob          : TvgRenderTaskJob;
     TaskStatus       : TvgRenderTaskStatus;

   //Vulkan Link Stuff
     RenderNode       : TvgRenderNode;
     GlobalRes,
     Resources        : TvgDescriptorSet;    //reference for uploading data and binding

     Frame            : TvgFrame;
     RenderPassHandle : TVkRenderPass;
     GraphicPipe      : TvgGraphicPipeline ;
     CriticalSection  : TvgCriticalSection;    //frame

     SubPassIndex,                  //current render sub pass being processed
     ImageIndex,                    //image Index
     FrameIndex,                    //current Frame Index for renderering
     WorkerIndex      : TvkUint32;  //current Worker(Thread) worker completing task data returned

     UploadData,
     UploadResourceData : Boolean;
  End;

  PvgRenderComplete = ^TvgRenderComplete;    //record returned on completion of a Task in a Worker Thread
  TvgRenderComplete = record
//     Active           : Boolean;
     //task is in use
     //consider ALL data locked until fActive is FALSE
     WorkerIndex      : TvkUint32;  //current Worker(Thread) worker completing task data returned

     TaskJob          : TvgRenderTaskJob;
     TaskStatus       : TvgRenderTaskStatus;


  end;


  TvgPipelineRec = record
     GraphicPipe     : TvgGraphicPipeline;
     MaterialRes,
     ModelRes        : TvgDescriptorSet;
     PushConstant    : TvgPushConstantCol;
     //holds a list of Push Constants relevant to the node
     //assigned from the GraphicPipeline
  end ;

  PvgRenderNode = ^TvgRenderNode;
  TvgRenderNode = Class(TObject)
  Private
    function GetActive: Boolean;
    procedure SetActive(const Value: Boolean);
    function GetNodeMode: TvgNodeMode;
    procedure SetNodeMode(const Value: TvgNodeMode);
    function GetRenderer: TvgRenderEngine;
    procedure SetRenderer(const Value: TvgRenderEngine);
    function GetGraphicPipeline(Index: Integer): TvgGraphicPipeline;
    procedure SetGraphicPipeline(Index: Integer;
      const Value: TvgGraphicPipeline);
    function GetPipelineCount: Integer;
    procedure SetPipelineCount(const Value: Integer);
    function GetMaterialRes(Index: Integer): TvgDescriptorSet;
    function GetModelRes(Index: Integer): TvgDescriptorSet;
    function GetPushConstant(Index: Integer): TvgPushConstantCol;
//    function GetGraphicPipeline: TvgGraphicPipeline;
//    procedure SetGraphicPipeline(const Value: TvgGraphicPipeline);

  Protected
  //Node management
     fOwner    : TvgRenderNodeList;  //use owner list to get back to scene
     fParent   : TvgRenderNode;     //parent Node
     fChildren : TvgRenderNodeList; //list of children nodes

     fActive,
     fVisible      : Boolean;

     fUploadNeeded : Boolean;

     fRenderMode   : TvgNodeMode;

  //vulkan stuff linked
     fRenderer            : TvgRenderEngine;

     fGraphicPipelineList : Array of TvgPipelineRec;
     //link to graphicpipelines responsible for rendering NODE
     //set during ADD NODE to renderer
     //length  is the number of Subpasses in the Renderpass

  //Data
     fSection     : TvgCriticalSection ;
     fUseStaging  : Boolean;
     fDataBuffer  : TpvVulkanBuffer;   //hold vertex and Index (if needed) data
     fVToIGap     : TvkUint32;        //gap in buffer between Vertex and Index data

 //    fPushConstantCol : TvgPushConstantCol;

    Procedure SetDisabled;  Virtual;
    Procedure SetEnabled;   Virtual;

    Procedure NodeSetUp;    Virtual;

 //these calls can be threaded and tasked

  // Manage Sync of data using SetUpVertexData and UploadVertexData.
  //SetUpVertexData will lock out UploadVertexData until complete
  //UploadVertexData will lock out SetUpVertexData until complete
  //Get... calls should ONLY be made from the UploadVertexData call
    Function LockData( aWaitFor : Boolean=False):Boolean;
    Function UnLockData:Boolean;

    Procedure SetUpDataTransfer;  Virtual;  Abstract;
    Procedure SetUpResourceData;  Virtual;

    Procedure VulkanDraw (aCommandBuffer: TvgCommandBuffer; aSubPass : TvkUint32); Virtual; Abstract;   //final draw calls MUST be called from inside RecordVulkanCommand

  Public
    constructor Create(aRenderObject:TvgRenderObject=nil); Virtual;
    destructor Destroy; override;

    Function GetVertexDataPointer : Pointer ;  Virtual;  //Must point to Variables or Dynamic allocated mem
    Function GetVertexCount       : TvkUint32; Virtual;
    Function GetVertexDataSize    : TvkUint32; Virtual;
    Class Function GetVertexStride      : TvkUint32; Virtual;

    Function GetIndexDataPointer : Pointer ;  Virtual;  //Must point to Variables or Dynamic allocated mem
    Function GetIndexCount       : TvkUint32; Virtual;
    Function GetIndexDataSize    : TvkUint32; Virtual;
    Function GetIndexType        : TVkIndexType; Virtual;    //VK_INDEX_TYPE_UINT16

    Function GetGraphicPipelineType : TvgGraphicsPipelineType;    Virtual;
    Function GetGraphicPipelineName : String;                     Virtual;

    Procedure SetUpAllData;                   Virtual;  Abstract;  //complete the data setup for data transfer
    Procedure UploadAllData(aPool:TvgCommandBufferPool);
    Procedure CreateDataBuffer;
    Procedure DeleteDataBuffer;
    Procedure SetCurrentFrame(Value:TvkUint32);

    Procedure ClearPipeLineList;

    //USE LOCKING FOR DATA SYNC

    Procedure RecordVulkanCommand(aCommandBuf  : TvgCommandBuffer;
                              //    Commands     : TVulkan ;
                              //    aWorkerIndex,
                                  aSubPassIndex : TvkUint32);  Virtual;

    Property Active      : Boolean Read GetActive write SetActive Stored False;

    Property NodeMode    : TvgNodeMode Read GetNodeMode write SetNodeMode;

    Property Renderer    : TvgRenderEngine Read GetRenderer write SetRenderer;
    Property PipelineCount : Integer Read GetPipelineCount write SetPipelineCount;
    Property GraphicPipeline[Index:Integer] : TvgGraphicPipeline Read GetGraphicPipeline write SetGraphicPipeline;
    Property MaterialRes    [Index:Integer] : TvgDescriptorSet   Read GetMaterialRes ;
    Property ModelRes       [Index:Integer] : TvgDescriptorSet   Read GetModelRes ;
    Property PushConstant   [Index:Integer] : TvgPushConstantCol Read GetPushConstant ;

  End;

  // provides low overhead object to hold node data and carry out Vulkan Draw for object
  // Should be created by a Scene Reader and added to the scene and NOT used as a design component.. see below for component holder

  TvgRenderObject = Class(TvgBaseComponent)
  private

    function GetActive: Boolean;
//    function GetNodeType: TvgNodeType;
    procedure SetActive(const Value: Boolean);
//    procedure SetNodeType(const Value: TvgNodeType);
    function GetNodeMode: TvgNodeMode;
    procedure SetNodeMode(const Value: TvgNodeMode);
    function GetRenderer: TvgRenderEngine;
    procedure SetRenderer(const Value: TvgRenderEngine);
    function GetRenderNode: TvgRenderNode;
 //   function GetMaterialRes(Index: Integer): TvgDescriptorSet;
 //   function GetModelRes(Index: Integer): TvgDescriptorSet;

  protected

    fRenderer   : TvgRenderEngine;
    fRenderNode : TvgRenderNode;

    procedure Notification(AComponent: TComponent; Operation: TOperation); override;

    Procedure SetDisabled; Override  ;
    Procedure SetEnabled(aComp:TvgBaseComponent=nil);   Override  ;

    Procedure CreateRenderNode;   Virtual;
    Function GetRenderNodeClass : TvgRenderNodeType;  Virtual;

  Public
    constructor Create(AOwner: TComponent);   Override;
    destructor Destroy; override;

    Property Node       : TvgRenderNode Read GetRenderNode;

  Published
    Property Active     : Boolean Read GetActive write SetActive Stored False;
    Property Renderer   : TvgRenderEngine Read GetRenderer write SetRenderer;
//    Property NodeType   : TvgNodeType Read GetNodeType write SetNodeType;
    Property NodeMode   : TvgNodeMode Read GetNodeMode write SetNodeMode;

 //   Property MaterialRes[Index:Integer]: TvgDescriptorSet Read GetMaterialRes;
 //   Property ModelRes   [Index:Integer]: TvgDescriptorSet Read GetModelRes;

  End;

  //Render workers run one per thread and carry out tasks using Parrellel-For Each pattern
//workers and tasks are managed in TvgRenderEngine descendants

  TvgRenderWorker = Class(TObject)
  private
    function GetActive: Boolean;
    procedure SetActive(const Value: Boolean);

    procedure SetRenderer(const Value: TvgRenderEngine);

  Protected
   //NOT Thread  SAFE Vulkan Link Stuff
     fActive           : Boolean;
     fTaskData         : TvgRenderTask;

     //used to log worker activity

  //internal created when active
     fGraphicCommandPool   : TvgCommandBufferPool;
     fCurrentCommandBuffer : TvgCommandBuffer;
     //current recording buffer for worker MUST be SECONDARY as called by Frame CommandBuffer
    //ONLY one pool/buffer per Frame and per Render SubPass

     fTransferCommandPool  : TvgCommandBufferPool;

     fEngineCriticalSection: TvgCriticalSection;
     fRecordingOn          : Boolean;

   //THREAD SAFE
     fRenderer             : TvgRenderEngine;
     fLinker               : TvgLinker;
     fFrame                : TvgFrame;

     fCurrentNode          : TvgRenderNode;
     fCurrentPipe          : TvgGraphicPipeline;  //currently bound pipeline

     fWorkerIndex          : TvkUint32;

     fRenderPassHandle     : TVkRenderPass;  //handle to current renderpass
     fSubPassCount,
     fSubPassIndex         : TvkUint32;

     fFrameBufferHandle    : TVkFramebuffer;
     fFrameCount,
     fFrameIndex           : TvkUint32;

     fRenderCount          : TvkUint32;

     //count of render node draw commands

    //Each worker will record a command with ALL nodes presented in it
    //Binding of Resources can happen once for each Graphic pipe and global resources
    //Each Node will still need to bind per instance

  //ALL MUST be thread safe

    Procedure BindPipeLine;
    Procedure BindDescriptors_Pipe;
    Procedure BindDescriptors_Node;

    Procedure UploadDataToVulkan;
    Procedure UploadResourceDataToVulkan;

    Function BuildCommandAndStartRecording   : Boolean;  //create a sub command for all worker related rendering and BeginRecording
    Procedure BuildCommand;
    Function EndCommandRecording             : Boolean;
    Procedure ExecuteSecondaryCommand;

    Procedure ActivateVulkanPipeline;

    //used to bind the supplied Resources to the existing pipelines/command
    //MUST have a valid fWorkingCommandBuffer

    Procedure CreateDataBuffer;

  Public
    constructor Create(aWorkerIndex : Integer);
    destructor Destroy; override;

    Procedure SetDisabled;  virtual;
    Procedure SetEnabled(aComp:TvgBaseComponent=nil);   virtual  ;

    Function CompleteTask(aTask: TvgRenderTask):TvgRenderTaskStatus;

    Property Active   : Boolean Read GetActive write SetActive Stored False;

    Property Renderer : TvgRenderEngine Read fRenderer write SetRenderer;

    Property WorkerIndex : TvkUint32 Read fWorkerIndex ;

  End;

  TvgRenderEngine  =  class(TvgBaseComponent)
  //handles graphics and rendering framework
  //DO NOT use as stand alone Use descendant
  Private
    function GetLinker: TvgLinker;
    function GetActive: Boolean;
    procedure SetActive(const Value: Boolean);
    function GetGlobalResources: TvgDescriptorSet;
    procedure SetWorkerCount(const Value: TvkUint32);
    procedure SetGraphicPipes(const Value: TvgGraphicPipeLists);
    procedure SetGlobalRes(const Value: TvgDescriptorSet);
    function GetFrameBufferHandle(Index: Integer): TVkFrameBuffer;

    Function GetRenderPass: TvgRenderPass;
//    procedure SetRenderTarget(const Value: TvgRenderPassTarget);
  //  Procedure SetRenderPass(const Value : TvgRenderPass);

  Protected
  //Connected Components Device connected in TvgEngine
    fLinker            : TvgLinker;

  //internal component
    fRenderPass        : TvgRenderPass;

  //scene stuff
    fRenderObjects     : TList<TvgRenderObject>;

  //Global resources
    fGlobalRes         : TvgDescriptorSet;
    //holds GLOBAL shader resources structure and data  SET = 0

    fGraphicPipeList   : TvgGraphicPipeLists;

    fRenderWorkerCount : TvkUint32;                 //should match thread/worker count used for rendering

    fCurrentFrame      : TvgFrame;
    //current rendering frame and image
    fImageIndex        : TvkUint32;

    fOnRenderPassStructureBuild : TvgWindowBuildRenderPassStructureEvent;

    procedure Notification(AComponent: TComponent; Operation: TOperation); override;

    Procedure SetDisabled;  override;
    Procedure SetEnabled(aComp:TvgBaseComponent=nil);   override  ;

    procedure SetLinker(const Value: TvgLinker); Virtual;

    Procedure BuildRenderPassStructure;    Virtual;

    Procedure BuildAndSetUpWorkers;        Virtual;
    //used to create set of workers to handle rendering
    Procedure CleanUpAndFreeWorkers;       Virtual;
    //tidy up

    procedure SetUpDepthAndMSAA(aPipe: TvgGraphicPipeline);

  Public

    constructor Create(AOwner: TComponent); Override;
    destructor Destroy; override;

//Render Nodes are internal and managed at Run Time or Design Time
    Procedure AddRenderNode(aRenderNode:TvgRenderNode);
    Procedure RemoveRenderNode(aRenderNode:TvgRenderNode; DoDestroy:Boolean=True);
    Procedure MoveRenderNode(aRenderNode:TvgRenderNode; OldMode,NewMode: TvgNodeMode);
    Function GetNodeCount:Integer;

//Render Objects are components which can be managed at Design time
//A render Object will add a suitable Render Node to the Render List when Active
    Procedure AddRenderObject(aRenderObject:TvgRenderObject)  ;
    Procedure RemoveRenderObject(aRenderObject:TvgRenderObject);

    Procedure RenderAFrame_Start( ImageIndex:TvkUint32; aFrame:TvgFrame);  Virtual;
    Procedure RenderAFrame_Finish;                                         Virtual;
    Procedure AddRenderNodeCommands(ImageIndex:TvkUint32; aFrame:TvgFrame ;aSubPass : TvkUint32);  Virtual;

    Function GetNextFrameIndex:TvkUint32;

    Procedure BuildGraphicPipelines;               Virtual;

    Procedure CreateRenderPass;                    Virtual;
    //allow the Render Engine descendants to build a specific set of Graphic Pipelines

    Property WorkerCount   : TvkUint32 read fRenderWorkerCount write SetWorkerCount;

    Property GraphicPipes  : TvgGraphicPipeLists Read fGraphicPipeList write SetGraphicPipes;
    //publish in descendants

    Property ScreenFrameBufferHandle[Index:Integer] : TVkFrameBuffer Read GetFrameBufferHandle;

  Published

    Property Active        : Boolean read getActive write SetActive stored false;
    Property Linker        : TvgLinker read GetLinker write SetLinker;
    Property RenderPass    : TvgRenderPass read GetRenderPass ;//write SetRenderPass;

    Property GlobalRes     : TvgDescriptorSet Read GetGlobalResources write SetGlobalRes;  //hold shader resource structure and data

    Property OnRenderPassBuild : TvgWindowBuildRenderPassStructureEvent read fOnRenderPassStructureBuild write fOnRenderPassStructureBuild;
  end;


  TvgComputeEngine  =  class(TvgBaseComponent)
  Private

  Protected

  Public

  Published


  end;


 function vgVulkanErrorToString(const ErrorCode:TVkResult):String;

//function CreateUniqueLayerName(Instance:TvgInstance_Component; const LayerName: string; LayerClass :TvgInstanceLayerClass;  Component: TComponent): string;
 Procedure RankPhysicalDevice(aPhysicalDevice: TpvVulkanPhysicalDevice;
                              aSurface       : TvgSurface;
                                var SupportSurface:Boolean;
                                Var Score:TvkUint64;
                                Var GraphicBit,ComputeBit,TransferBit,SparseBit:Boolean);


 Procedure HandleException(aComponentState: TComponentState;aStr:String);

 Procedure RegisterDescriptorType(aDescriptorType:TvgDescriptorType);
 Procedure FillDescriptorNameList(aList:TStringList);
 Function CreateDescriptorFromType(aType : TvgDescriptorType; aOwner : TComponent): TvgDescriptor;

 Procedure RegisterPushConstantType(aPushConstantType:TvgPushConstantType);
 Procedure FillPushConstantNameList(aList:TStringList);
 Function CreatePushConstantFromType(aType : TvgPushConstantType; aOwner : TComponent): TvgPushConstant;

 Procedure RegisterGraphicPipeType(aRenderPassType : TvgRenderPassType;
                                   aSubPassRef     : Integer;
                                   aNodeType       : TvgRenderNodeType;
                                   aPipeType       : TvgGraphicsPipelineType);
 Procedure FillGraphicTypeNameList(aList:TStringList);


Var
   GraphicPipeTypeList : TvgGraphicPipeTypeList = nil;
   ///used to hold the registered types og GraphicPipelines
   ///  created in Initialization
   ///  DONT MESS WITH THIS

implementation

Var
   DescriptorTypeList      : TvgDescriptorTypeList   = Nil;
   PushConstantTypeList    : TvgPushConstantTypeList = Nil;

Procedure RegisterGraphicPipeType(aRenderPassType : TvgRenderPassType;
                                  aSubPassRef     : Integer;
                                  aNodeType       : TvgRenderNodeType;
                                  aPipeType       : TvgGraphicsPipelineType);
   Var R : TvgPipeTypeRec;
       I : Integer;
Begin
  If not assigned(GraphicPipeTypeList)   then
     GraphicPipeTypeList := TvgGraphicPipeTypeList.Create;

  R.fRenderPassType      :=  aRenderPassType;
  R.fSubPassRef          :=  aSubPassRef;
  R.fRenderNodeType      :=  aNodeType;
  R.fGraphicPipelineType :=  aPipeType;
  R.fGraphicPipeline     :=  nil;

  If  GraphicPipeTypeList.IndexOf(R)=-1 then
  Begin
      I := GraphicPipeTypeList.Add(R);
      Assert((I>=0),'Graphicpipe registration failed');
    //  GraphicPipeTypeList.Items[I] := R;
  End;
End;

Procedure FillGraphicTypeNameList(aList:TStringList);
  Var I:Integer;
Begin
  If not assigned(aList) then exit;
  aList.Clear;

  If not assigned(GraphicPipeTypeList) or (GraphicPipeTypeList.Count=0) then
  Begin
    aList.Add('<NONE REGISTERED>');
    exit;
  End;
  For  I:=0 to GraphicPipeTypeList.Count-1 do
    aList.Add(GraphicPipeTypeList.Items[I].fGraphicPipelinetype.GetPropertyName);
End;

Procedure RegisterDescriptorType(aDescriptorType:TvgDescriptorType);
Begin
  If not assigned(aDescriptorType) then exit;

  If DescriptorTypeList.IndexOf(aDescriptorType)=-1 then
     DescriptorTypeList.Add(aDescriptorType);
end;


Procedure FillDescriptorNameList(aList:TStringList);
  Var I:Integer;
Begin
  If not assigned(aList) then exit;
  aList.Clear;

  If DescriptorTypeList.Count=0 then
  Begin
    aList.Add('<NONE>');
    exit;
  End;
  For  I:=0 to DescriptorTypeList.Count-1 do
    aList.Add(DescriptorTypeList.Items[I].GetPropertyName);
End;

Function CreateDescriptorFromType(aType : TvgDescriptorType; aOwner : TComponent): TvgDescriptor;
Begin
  Result := aType.Create(aOwner);
End;

Procedure RegisterPushConstantType(aPushConstantType:TvgPushConstantType);
Begin
  If not assigned(aPushConstantType) then exit;

  If PushConstantTypeList.IndexOf(aPushConstantType)=-1 then
     PushConstantTypeList.Add(aPushConstantType);
End;

 Procedure FillPushConstantNameList(aList:TStringList);
   Var I:Integer;
Begin
  If not assigned(aList) then exit;
  aList.Clear;

  If PushConstantTypeList.Count=0 then
  Begin
    aList.Add('<NONE>');
    exit;
  End;
  For  I:=0 to PushConstantTypeList.Count-1 do
    aList.Add(PushConstantTypeList.Items[I].GetPropertyName);
 End;

 Function CreatePushConstantFromType(aType : TvgPushConstantType; aOwner : TComponent): TvgPushConstant;
 Begin
  Result := aType.Create(aOwner);
 End;

Procedure HandleException(aComponentState: TComponentState;aStr:String);
Begin
    If (csDesigning in aComponentState) then
       raise EpvVulkanException.Create(aStr)
    else
      Exit;
End;

Procedure Matrix4x4_SetIdentity(Var aMat : TpvMatrix4x4);
Begin
   aMat.RawComponents[0,0]:=1.0;
   aMat.RawComponents[0,1]:=0.0;
   aMat.RawComponents[0,2]:=0.0;
   aMat.RawComponents[0,3]:=0.0;
   aMat.RawComponents[1,0]:=0.0;
   aMat.RawComponents[1,1]:=1.0;
   aMat.RawComponents[1,2]:=0.0;
   aMat.RawComponents[1,3]:=0.0;
   aMat.RawComponents[2,0]:=0.0;
   aMat.RawComponents[2,1]:=0.0;
   aMat.RawComponents[2,2]:=1.0;
   aMat.RawComponents[2,3]:=0.0;
   aMat.RawComponents[3,0]:=0.0;
   aMat.RawComponents[3,1]:=0.0;
   aMat.RawComponents[3,2]:=0.0;
   aMat.RawComponents[3,3]:=1.0;
End;


Procedure RankPhysicalDevice(aPhysicalDevice       : TpvVulkanPhysicalDevice;
                                 aSurface          : TvgSurface;
                                 var SupportSurface: Boolean;
                                 Var Score         : TvkUint64 ;
                                 Var GraphicBit,ComputeBit,TransferBit,SparseBit:Boolean);
  Var SubIndex:Integer;
      Temp,NewTemp   :TvkUint64;
      B1:Boolean;
    //adapted from PasVulkan.Framework

Begin
//  SupportSurface:=False;
  Score:=0;
  GraphicBit :=False;
  ComputeBit :=False;
  TransferBit:=False;
  SparseBit  :=False;

  If not assigned(aPhysicalDevice) then exit;

  If assigned(aSurface)then
  Begin
     SupportSurface:=False;
     If not aSurface.Active then
     Begin
         aSurface.Active:=True;
         B1:=aSurface.Active;
     End else
         B1:=False;

     If assigned(aSurface.VulkanSurface) then
     Begin
       for SubIndex:=0 to length(aPhysicalDevice.QueueFamilyProperties)-1 do
       begin
          if aPhysicalDevice.GetSurfaceSupport(SubIndex, aSurface.VulkanSurface) then
          begin
            SupportSurface := true;
            aSurface.fSurfaceQueIndex := SubIndex;
            break;
          end;
       end;
     end;

     If B1 then
        aSurface.Active:=False;
  end;

     // Include the device type into the scoring
     // CPU(/Unknown) < other < Virtual GPU (for example inside virtual machines) < Integrated GPU < Discrete GPU

     case aPhysicalDevice.Properties.deviceType of
      VK_PHYSICAL_DEVICE_TYPE_OTHER:            Score:=Score or (TvkUint64(1) shl 60);
      VK_PHYSICAL_DEVICE_TYPE_INTEGRATED_GPU:   Score:=Score or (TvkUint64(3) shl 60);
      VK_PHYSICAL_DEVICE_TYPE_DISCRETE_GPU:     Score:=Score or (TvkUint64(4) shl 60);
      VK_PHYSICAL_DEVICE_TYPE_VIRTUAL_GPU:      Score:=Score or (TvkUint64(2) shl 60);
      else {VK_PHYSICAL_DEVICE_TYPE_CPU:}       Score:=Score or (TvkUint64(0) shl 60);
     end;

 // Include the available queue families into the scoring
     for SubIndex:=0 to length(aPhysicalDevice.QueueFamilyProperties)-1 do
     begin
      Temp:=0;

      if (aPhysicalDevice.QueueFamilyProperties[SubIndex].queueFlags and TvkInt32(VK_QUEUE_GRAPHICS_BIT))<>0 then
      begin
       inc(Temp);
       GraphicBit:=True;
      end;

      if (aPhysicalDevice.QueueFamilyProperties[SubIndex].queueFlags and TvkInt32(VK_QUEUE_COMPUTE_BIT))<>0 then
      begin
       inc(Temp);
       ComputeBit:=True;
      end;

      if (aPhysicalDevice.QueueFamilyProperties[SubIndex].queueFlags and TvkInt32(VK_QUEUE_TRANSFER_BIT))<>0 then
      begin
       inc(Temp);
       TransferBit:=True;
      end;

      if (aPhysicalDevice.QueueFamilyProperties[SubIndex].queueFlags and TvkInt32(VK_QUEUE_SPARSE_BINDING_BIT))<>0 then
      begin
       inc(Temp);
       SparseBit:=True;
      end;

      Score := Score or (TvkUint64(Temp) shl 57);
     end;

     // Include the available total memory heap size into the scoring
     Temp:=0;
     for SubIndex:=0 to TvkInt32(aPhysicalDevice.MemoryProperties.memoryHeapCount)-1 do
     begin
      NewTemp:=Temp+aPhysicalDevice.MemoryProperties.memoryHeaps[SubIndex].size;
      if Temp<NewTemp then
      begin
        Temp:=NewTemp;
      end else
      begin
        Temp:=TvkUint64(TvkInt64(-1));
        break;
      end;
     end;

     Score := Score or (TvkUint64(Temp) shr 16);
     SupportSurface :=  GraphicBit;

End;

//need to handle LongWord filer storage issue on High(Longword);

Procedure WriteTvkUint32(Writer:TWriter;Value:TvkUint32);
  Var S:String;
      I:Int64;
Begin
  I:=Value ;
  S:=IntToStr(I);
  Writer.WriteString(S);
End;

Function ReadTvkUint32(Reader:TReader):TvkUint32;
  Var S:String;
      I:Int64;
Begin
  S:=Reader.ReadString;
  I:=StrToInt64(S);
  If (I>=0) and (I<=High(TvkUint32)) then
     Result:=I
  else
  If I<0 then
     Result:=0
  else
     Result:=High(TvkUint32);
End;

Procedure WriteTvkUint64(Writer:TWriter;Value:TvkUint64);
  Var S:String;
      I:UInt64;
Begin
  I := Value ;
  S := UIntToStr(I);
  Writer.WriteString(S);
End;

Function ReadTvkUint64(Reader:TReader):TvkUint64;
  Var S:String;
      I:UInt64;
Begin
  S:=Reader.ReadString;
  I:=StrToInt64(S);
  If (I>=0) and (I<=High(TvkUint64)) then
     Result:=I
  else
  If I<0 then
     Result:=0
  else
     Result:=High(TvkUint64);
End;

function vgVulkanErrorToString(const ErrorCode:TVkResult):String;
begin
 case ErrorCode of
  VK_SUCCESS:begin
   result:='VK_SUCCESS';
  end;
  VK_NOT_READY:begin
   result:='VK_NOT_READY';
  end;
  VK_TIMEOUT:begin
   result:='VK_TIMEOUT';
  end;
  VK_EVENT_SET:begin
   result:='VK_EVENT_SET';
  end;
  VK_EVENT_RESET:begin
   result:='VK_EVENT_RESET';
  end;
  VK_INCOMPLETE:begin
   result:='VK_INCOMPLETE';
  end;
  VK_ERROR_OUT_OF_HOST_MEMORY:begin
   result:='VK_ERROR_OUT_OF_HOST_MEMORY';
  end;
  VK_ERROR_OUT_OF_DEVICE_MEMORY:begin
   result:='VK_ERROR_OUT_OF_DEVICE_MEMORY';
  end;
  VK_ERROR_INITIALIZATION_FAILED:begin
   result:='VK_ERROR_INITIALIZATION_FAILED';
  end;
  VK_ERROR_DEVICE_LOST:begin
   result:='VK_ERROR_DEVICE_LOST';
  end;
  VK_ERROR_MEMORY_MAP_FAILED:begin
   result:='VK_ERROR_MEMORY_MAP_FAILED';
  end;
  VK_ERROR_LAYER_NOT_PRESENT:begin
   result:='VK_ERROR_LAYER_NOT_PRESENT';
  end;
  VK_ERROR_EXTENSION_NOT_PRESENT:begin
   result:='VK_ERROR_EXTENSION_NOT_PRESENT';
  end;
  VK_ERROR_FEATURE_NOT_PRESENT:begin
   result:='VK_ERROR_FEATURE_NOT_PRESENT';
  end;
  VK_ERROR_INCOMPATIBLE_DRIVER:begin
   result:='VK_ERROR_INCOMPATIBLE_DRIVER';
  end;
  VK_ERROR_TOO_MANY_OBJECTS:begin
   result:='VK_ERROR_TOO_MANY_OBJECTS';
  end;
  VK_ERROR_FORMAT_NOT_SUPPORTED:begin
   result:='VK_ERROR_FORMAT_NOT_SUPPORTED';
  end;
  VK_ERROR_SURFACE_LOST_KHR:begin
   result:='VK_ERROR_SURFACE_LOST_KHR';
  end;
  VK_ERROR_NATIVE_WINDOW_IN_USE_KHR:begin
   result:='VK_ERROR_NATIVE_WINDOW_IN_USE_KHR';
  end;
  VK_SUBOPTIMAL_KHR:begin
   result:='VK_SUBOPTIMAL_KHR';
  end;
  VK_ERROR_OUT_OF_DATE_KHR:begin
   result:='VK_ERROR_OUT_OF_DATE_KHR';
  end;
  VK_ERROR_INCOMPATIBLE_DISPLAY_KHR:begin
   result:='VK_ERROR_INCOMPATIBLE_DISPLAY_KHR';
  end;
  VK_ERROR_VALIDATION_FAILED_EXT:begin
   result:='VK_ERROR_VALIDATION_FAILED_EXT';
  end;
  VK_ERROR_INVALID_SHADER_NV:begin
   result:='VK_ERROR_INVALID_SHADER_NV';
  end;
  else begin
   result:='Unknown error code detected ('+IntToStr(TvkInt32(ErrorCode))+')';
  end;
 end;
end;

{ TvgCriticalSection }

{ TvgBaseComponent }

procedure TvgBaseComponent.DisableParent(ToRoot:Boolean=False);
begin
  //climb to the top(Instance) and disable from Top down
end;

procedure TvgBaseComponent.SetActiveState(aValue: Boolean);
begin
  if fActive = aValue then Exit;
  if fActiveChanging then Exit; // Prevent recursive activation

  fActiveChanging := True;
  try
    if aValue then
    begin
      // Activation sequence
      SetEnabled;
      fActive := True;
    end
    else
    begin
      // Deactivation sequence
      SetDisabled;
      fActive := False;
    end;

  finally
    fActiveChanging := False;
  end;

  end;

procedure TvgBaseComponent.SetDesigning;
begin
  //enable self and lower
end;

procedure TvgBaseComponent.SetDisabled;
begin

end;

procedure TvgBaseComponent.SetEnabled(aComp:TvgBaseComponent=nil);
begin

end;



{ TvgInstance }

procedure TvgInstance.AddDevice(aDevice: TvgPhysicalDevice);
begin
  If not assigned(aDevice) then exit;
  If assigned(aDevice.fInstance) then exit;

  If fPhysicalDevices.IndexOf(aDevice)=-1  then
  Begin
     FreeNotification(aDevice);
     fPhysicalDevices.Add(aDevice);
     aDevice.fInstance := self;
  End;
end;

Procedure TvgInstance.BuildALLExtensions;
  Var I:Integer;
      B:Boolean;
begin

  If not assigned(fVulkanInstance) then
  Begin
    SetDesigning;
    B:=True;
  End else
    B:=False;

  For I:=0 to fVulkanInstance.AvailableExtensionNames.Count-1 do
        BuildExtension(@fVulkanInstance.AvailableExtensions[I]);

  If B then SetActiveState(False);

end;

procedure TvgInstance.BuildAllExtensionsAndLayers;
  Var I:Integer;
      B:Boolean;
begin
  Assert(assigned(fExtensions),'Extensions list not available');
  Assert(assigned(fLayers),'Layers list not available');

  If not assigned(fVulkanInstance) then
  begin
     SetDesigning;
     B:=True;
  end else
    B:=False;

  For I:=0 to fVulkanInstance.AvailableLayerNames.Count-1 do
        BuildLayer(@fVulkanInstance.AvailableLayers[I]);

  For I:=0 to fVulkanInstance.AvailableExtensionNames.Count-1 do
        BuildExtension(@fVulkanInstance.AvailableExtensions[I]);

  If B then SetActiveState(False);
end;

procedure TvgInstance.BuildALLLayers;
  Var I:Integer;
      B:Boolean;
begin
  If not assigned(fVulkanInstance) then
  begin
     SetDesigning;
     B:=True;
  end else
    B:=False;

  For I:=0 to fVulkanInstance.AvailableLayerNames.Count-1 do
        BuildLayer(@fVulkanInstance.AvailableLayers[I]);

  If B then SetActiveState(False);

end;

function TvgInstance.BuildExtension(aExt: PpvVulkanAvailableExtension): TvgExtension;
begin
  Result:=nil;

  //check if layer exists then return instance
  If DoesExtensionExist(aExt) then exit;

  //build layer
  Result:= TvgExtension(fExtensions.Add);
  Result.SetData(aExt);
  Result.fvgOwner:=Self;
end;

Function TvgInstance.BuildLayer(aLayer: ppvVulkanAvailableLayer):TvgLayer;
begin
  Result:=nil;

  //check if layer exists then return instance
  If DoesLayerExist(aLayer) then exit;

  //build layer
  Result:= TvgLayer(fLayers.Add);
  If assigned(Result) then
  Begin
    Result.SetData(aLayer);
    Result.fvgOwner:=Self;
  end;
end;

Function TvgInstance.CheckVulkanHardwareStatus:Boolean;

begin
  Result:=False;
  fVulkanStatus:= VC_UNKNOWN_STATUS;

  Try

    If LoadVulkanLibrary and LoadVulkanGlobalCommands then
    Begin
      fVulkanStatus:= VC_VULKAN_OK;
      Result:=True;
    end else
      fVulkanStatus := VC_VULKAN_NOT_AVAILABLE;

  Except
     On E :Exception do
     Begin
       fVulkanStatus:= VC_VULKAN_NOT_AVAILABLE;
       raise;
     End;
  End;
end;

procedure TvgInstance.ClearAllExtensionsAndlayers;
begin
  Assert(assigned(fExtensions),'Extensions list not available');
  Assert(assigned(fLayers),'Layers list not available');

  fExtensions.Clear;
  fLayers.Clear;
end;

constructor TvgInstance.Create(AOwner: TComponent);
begin
  //must stay here
   fPhysicalDevices   := TList<TvgPhysicalDevice>.Create;

   fPhysicalDeviceList:= TvgPhysDevices.Create(self);

   fLayers            := TvgLayers.Create(self);
   fExtensions        := TvgExtensions.Create(self);

   Inherited;      //must stay here

   fValidation        := False;
//   fRenderDoc         := False;
   fActive            := False;

   fApplicationName   := 'Vulkan Graphics';
   fpplicationVersion := 1;
   fEngineName        := 'Vulkan Graphics Engine';
   fengineVersion     := 1;

   fapiVersion        := VG_API_VERSION_1_3;

   fAllocationStatus  := VG_SELF_MANAGE; //Is it best to let Vulkan do it???

   SetUpMemoryAllocation;

   CheckVulkanHardwareStatus;

end;

destructor TvgInstance.Destroy;
  Var I:Integer;
begin
 Try
  SetActiveState(False); //must stay here

  If assigned(fPhysicalDevices) then
  Begin
     If (fPhysicalDevices.Count>0) then
        For I:=0 to fPhysicalDevices.count-1 do
          If fPhysicalDevices.Items[I].Instance= self then
             fPhysicalDevices.Items[I].Instance:=nil;
     FreeAndNil(fPhysicalDevices);
  End;

  If assigned(fLayers) then
     FreeAndNil(fLayers);

  If assigned(fExtensions) then
     FreeAndNil(fExtensions);

  If assigned(fPhysicalDeviceList) then
     FreeAndNil(fPhysicalDeviceList);

  If assigned(fAllocationManager) then
     FreeAndNil(fAllocationManager);

  Inherited;

 Except
   On E:Exception do
   Begin
     If (csDesigning in ComponentState) then
        Raise;
   End;

 End;

end;

procedure TvgInstance.DisableDevices;
  Var I:Integer;
      D:TvgPhysicalDevice;
begin
  if not assigned(fPhysicalDevices) then exit;
  If fPhysicalDevices.Count=0 then exit;

  For I:=0 to fPhysicalDevices.count -1 do
  Begin
    D:=fPhysicalDevices.Items[I];
    If D.Active then
       D.Active := False;
  End;
end;

procedure TvgInstance.DisableParent(ToRoot:Boolean=False);
begin
  If fActive then
     SetActiveState(False);

end;

function TvgInstance.DoesExtensionExist( aExt: PpvVulkanAvailableExtension): Boolean;
  Var I:Integer;
      E:TvgExtension;
begin
  Result:=False;
  If fExtensions.Count=0 then exit;

  For I:=0 to fExtensions.count-1 do
  Begin
    E:=TvgExtension(fExtensions.Items[I]);
    If (AnsiCompareStr(String(E.fExtensionName),String(aExt.ExtensionName)) = 0) then
    Begin
      Result:=True;
      Break;
    End;
  End;
end;

function TvgInstance.DoesLayerExist( aLayer: ppvVulkanAvailableLayer): Boolean;
  Var I:Integer;
      L:TvgLayer;
begin
  Result:=False;
  If fLayers.Count=0 then exit;

  For I:=0 to fLayers.count-1 do
  Begin
    L:=TvgLayer(fLayers.Items[I]);
    If (AnsiCompareStr(String(L.fLayerName),String(aLayer.LayerName)) = 0) then
    Begin
      Result:=True;
      Break;
    End;
  End;
end;

function TvgInstance.GetAllocationMode: TvgAllocationMode;
begin
  Result:= self.fAllocationStatus;
end;

function TvgInstance.GetApplicationName: TpvVulkanCharString;
begin
 Result := fApplicationName ;
end;

function TvgInstance.GetApplicationVersion: TvkUint32;
begin
  Result :=  fpplicationVersion;
end;

function TvgInstance.GetDevice(Index: Integer): TvgPhysicalDevice;
begin
  Result:=fPhysicalDevices.Items[Index];
end;

function TvgInstance.GetDevicesCount: Integer;
begin
  Result:=fPhysicalDevices.Count;
end;

function TvgInstance.GetEngineName: TpvVulkanCharString;
begin
  Result := fEngineName;
end;

function TvgInstance.GetEngineVersion: TvkUint32;
begin
  Result := fengineVersion;
end;
function TvgInstance.GetRenderToScreen: Boolean;
begin
  result:=fRenderToScreen;
end;

function TvgInstance.GetActive: Boolean;
begin
 Result:= fActive;
end;

function TvgInstance.GetValidation: Boolean;
begin
  Result := fValidation;
end;

function TvgInstance.GetAPIVersion: TvkUint32;
begin
      Case fAPIVersion  of
         VG_API_VERSION_1_0 : Result := VK_API_VERSION_1_0;
         VG_API_VERSION_1_1 : Result := VK_API_VERSION_1_1;
         VG_API_VERSION_1_2 : Result := VK_API_VERSION_1_2;
         VG_API_VERSION_1_3 : Result := VK_API_VERSION_1_3;
      else
          Result := VK_API_VERSION_1_0;
      End;
end;

function TvgInstance.GetVulkanAPIVersion: TvgAPI_Version;
begin
  Result:=fAPIVersion;
end;

procedure TvgInstance.Loaded;
begin
  inherited;
  CheckVulkanHardwareStatus;
end;

procedure TvgInstance.Notification(AComponent: TComponent;  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);

  If (csDestroying in ComponentState) and fActive then
     SetActiveState(False);

  Case Operation of
     opInsert : Begin
                  If aComponent=self then exit;
                  If NotificationTestON and Not (csDesigning in ComponentState) then exit;     //don't mess with links at runtime

                  If (aComponent is TvgPhysicalDevice) and not assigned(TvgPhysicalDevice(aComponent).Instance) then
                  Begin
                    // SetDisabled;
                     TvgPhysicalDevice(aComponent).Instance := Self;
                  End;
                End;
     opRemove : Begin
                  If (aComponent is TvgPhysicalDevice) and (TvgPhysicalDevice(aComponent).Instance=Self) then
                  Begin
                  //  SetDisabled;
                    TvgPhysicalDevice(aComponent).Instance := nil ;
                  End;
                end;
  End;

end;
(*
procedure TvgInstance.EnableParent;
begin
  If not assigned(fVulkanInstance) then
     SetEnabled;
end;
 *)
procedure TvgInstance.RemoveALLExtensions;
begin
  If fExtensions.count=0 then exit;
  fExtensions.Clear;
end;

procedure TvgInstance.RemoveALLLayers;
begin
  If fLayers.count=0 then exit;
  fLayers.Clear;
end;

procedure TvgInstance.RemoveDevice(aDevice: TvgPhysicalDevice);
begin
  If not assigned(aDevice) then exit;

  RemoveFreeNotification(aDevice);
  aDevice.SetActiveState(False);
  aDevice.fInstance:=nil;
  fPhysicalDevices.Remove(aDevice);
end;

procedure TvgInstance.SetAllocationMode(const Value: TvgAllocationMode);
begin
  If fAllocationStatus=Value then exit;

  SetActiveState(false);

  fAllocationStatus := Value;

  SetUpMemoryAllocation;

end;
procedure TvgInstance.SetAPIVersion(Value: TvkUint32);
  Var V:TvgAPI_Version;
begin
   V:= VG_API_VERSION_1_0;

   If Value = VK_API_VERSION then V:= VG_API_VERSION
   else
   If Value = VK_API_VERSION_1_0 then V:= VG_API_VERSION_1_0
   else
   If Value = VK_API_VERSION_1_1 then V:= VG_API_VERSION_1_1
   else
   If Value = VK_API_VERSION_1_2 then V:= VG_API_VERSION_1_2
   else
   If Value = VK_API_VERSION_1_3 then V:= VG_API_VERSION_1_3;

   If V = fAPIVersion then exit;
   fAPIVersion := V;

end;

(*
procedure TvgInstance.SetAPIVersion(const Value: TvkUint32);
begin
  If fapiVersion=Value then exit;
  SetDisabled;
  ClearAllExtensionsAndlayers;

  fapiVersion := Value;
end;
 *)
procedure TvgInstance.SetApplicationName(const Value: TpvVulkanCharString);
begin
  If fApplicationName=Value then exit;
  SetActiveState(False);
  ClearAllExtensionsAndlayers;
  fApplicationName := Value;
end;

procedure TvgInstance.SetApplicationVersion(const Value: TvkUint32);
begin
  If fpplicationVersion=Value then exit;
  SetActiveState(False);
  ClearAllExtensionsAndlayers;
  fpplicationVersion := Value;
end;

procedure TvgInstance.SetEngineName(const Value: TpvVulkanCharString);
begin
  If fEngineName=Value then exit;
  SetActiveState(False);
 // ClearAllExtensionsAndlayers;
  fEngineName := Value;
end;

procedure TvgInstance.SetEngineVersion(const Value: TvkUint32);
begin
  If fengineVersion=Value then exit;
  SetActiveState(False);
 // ClearAllExtensionsAndlayers;
  fengineVersion := Value;
end;

procedure TvgInstance.SetExtensions(const Value: TvgExtensions);
begin
  If not assigned(Value) then exit;
  fExtensions.Clear;
  fExtensions.Assign(Value);
end;

procedure TvgInstance.SetLayers( const Value: TvgLayers);
begin
  If not assigned(Value) then exit;
  SetActiveState(False);
  fLayers.Clear;
  fLayers.Assign(Value);
end;

procedure TvgInstance.SetPhysicalDevices(const Value: TvgPhysDevices);
begin
  If not assigned(Value) then exit;
  SetActiveState(False);
  fPhysicalDeviceList.Clear;
  fPhysicalDeviceList.Assign(Value);
end;

procedure TvgInstance.SetRenderToScreen(const Value: Boolean);
  Var B:Boolean;
      I:Integer;
      Procedure SetValue;
      Begin
        If assigned(fVulkanInstance) then
           SetActiveState(False);

        fRenderToScreen := Value;

        If fRenderToScreen then
           SetUpScreenExtensions;
      End;
begin
  If fRenderToScreen=Value then exit;

  If (Value=False) then
  Begin
      B:=False;
      If fPhysicalDevices.Count>0 then
      Begin
        For I:=0 to fPhysicalDevices.Count-1 do
           If  fPhysicalDevices.Items[I].RenderToScreen then
              B:=True;
      End;
      If B then exit;
      SetValue;
  end else
      SetValue;

end;

procedure TvgInstance.SetActive(const Value: Boolean);
begin
  If Value=fActive then exit;
  SetActiveState(Value) ;

end;

procedure TvgInstance.EnableDevices;
  Var I:Integer;
begin
  If not assigned(fVulkanInstance) then exit;
  If not assigned(fPhysicalDevices) then exit;
  If (fPhysicalDevices.Count=0) then exit;

  For I:=0 to fPhysicalDevices.Count-1 do
  Begin
     If not fPhysicalDevices.Items[I].Active then
     Begin
        fPhysicalDevices.Items[I].Active:=True;
     End;
  End;

end;

Procedure TvgInstance.SetUpScreenExtensions;
     Var SE,SEOS, SE1, SE2, SE3, SE4:String;
         E:TvgExtension;
         I:Integer;
   Begin
    // If assigned(fVulkanInstance) then exit;
    if not assigned(fExtensions) then exit;
    If  fExtensions.count=0 then exit;

     SE  := VK_KHR_SURFACE_EXTENSION_NAME;
     SE1 := VK_EXT_FULL_SCREEN_EXCLUSIVE_EXTENSION_NAME;
     SE2 := VK_KHR_GET_PHYSICAL_DEVICE_PROPERTIES_2_EXTENSION_NAME; //2
     SE3 := VK_KHR_GET_SURFACE_CAPABILITIES_2_EXTENSION_NAME;//1
     SE4 := VK_EXT_HOST_QUERY_RESET_EXTENSION_NAME;//1

    {$if defined(Android)}
         SEOS := VK_KHR_ANDROID_SURFACE_EXTENSION_NAME;
    {$ifend}
    {$if defined(Wayland) and defined(Unix)}
         SEOS := VK_KHR_WAYLAND_SURFACE_EXTENSION_NAME;
    {$ifend}
    {$if defined(Win32) or defined(Win64)}
         SEOS := VK_KHR_WIN32_SURFACE_EXTENSION_NAME;
    {$ifend}
    {$if defined(XCB) and defined(Unix)}
         SEOS := VK_KHR_XCB_SURFACE_EXTENSION_NAME;
    {$ifend}
    {$if defined(XLIB) and defined(Unix)}
         SEOS := VK_KHR_XLIB_SURFACE_EXTENSION_NAME;
    {$ifend}
    {$if defined(MoltenVK_IOS) and defined(Darwin)}
         SEOS := VK_KHR_MIR_SURFACE_EXTENSION_NAME;
    {$ifend}
    {$if defined(MoltenVK_MacOS) and defined(Darwin)}
         SEOS := VK_KHR_MIR_SURFACE_EXTENSION_NAME;
    {$ifend}

   //  B1:=False;
   //  B2:=False;

     For I:=0 to fExtensions.Count-1 do
     Begin
       E:=TvgExtension(fExtensions.Items[I]);

{$if not defined(Windows)}  //remove the Windows specific layer     as it may have been set during Designing
       If CompareText(String(E.fExtensionName),VK_KHR_WIN32_SURFACE_EXTENSION_NAME)=0 then
          E.fExtMode:=VGE_NOT_REQUIRED;
{$ifend}

       If fRenderToScreen then
       Begin
           If (CompareText(String(E.fExtensionName),SE) =0) or
              (CompareText(String(E.fExtensionName),SE1)=0) or
              (CompareText(String(E.fExtensionName),SE2)=0) or
              (CompareText(String(E.fExtensionName),SE3)=0) or
              (CompareText(String(E.fExtensionName),SE4)=0) or
              (CompareText(String(E.fExtensionName),SEOS)=0) then
           Begin
              E.fExtMode:=VGE_MUST_HAVE;
             // B:=True;
           End;
      //     If not B1 and B2 then
       //       raise EvgVulkanResultException.Create(VK_ERROR_EXTENSION_NOT_PRESENT, 'Required Screen Display Extension NOT found');
       End else   //not rendering to screen
       Begin
           If (CompareText(String(E.fExtensionName),SE) =0) or
              (CompareText(String(E.fExtensionName),SE1)=0) or
              (CompareText(String(E.fExtensionName),SE2)=0) or
              (CompareText(String(E.fExtensionName),SE3)=0) or
              (CompareText(String(E.fExtensionName),SE4)=0) or
              (CompareText(String(E.fExtensionName),SEOS)=0) then
           Begin
              E.fExtMode:=VGE_NOT_REQUIRED;
             // B:=True;
           End;
       End;
     End;

End;

procedure TvgInstance.SetUpValidationExtensions;
  Var S1,S2 : String;
         E  : TvgExtension;
         I  : Integer;

begin
     If not fValidation then exit;
     If not assigned(fExtensions) or (fExtensions.count=0) then exit;

     S1:= VK_EXT_DEBUG_REPORT_EXTENSION_NAME;
     S2:= VK_EXT_DEBUG_UTILS_EXTENSION_NAME;

     For I:=0 to fExtensions.Count-1 do
     Begin
       E:=TvgExtension(fExtensions.Items[I]);
       If (CompareText(String(E.fExtensionName),S1)=0) or
          (CompareText(String(E.fExtensionName),S2)=0) then
         E.fExtMode:= VGE_MUST_HAVE;
     End;

end;

procedure TvgInstance.SetUpValidationLayers;
  const S1 : String ='VK_LAYER_KHRONOS_validation';
  Var  // S2 : String;
         L : TvgLayer;
         I : Integer;
begin
     If not assigned(fLayers) or (fLayers.count=0) then exit;
    (*
     If fRenderDoc then
     Begin
       S2 := VK_LAYER_RENDERDOC_Capture_Name ;

       For I:=0 to fLayers.Count-1 do
       Begin
         L:=TvgLayer(fLayers.Items[I]);
         If CompareText(String(L.fLayerName),S2)=0 then
         Begin
           L.fLayerMode    := VGL_MUST_HAVE;
           If (Ord(APIVersion) < Ord(VG_API_VERSION_1_2)) then
              fAPIVersion      := VG_API_VERSION_1_2 ;
           RenderDocUsed := True;
         End;
       End;
     End;
     *)
     If fValidation then
     Begin

       For I:=0 to fLayers.Count-1 do
       Begin
         L:=TvgLayer(fLayers.Items[I]);
         If CompareText(String(L.fLayerName),S1)=0 then
         Begin
           L.fLayerMode    := VGL_MUST_HAVE;
         End;
       End;
     End;
end;

procedure TvgInstance.SetUpExtensions;
  Var I:Integer;
      E:TvgExtension;
      B:Boolean;
      ES:String;

   Function IsExtensionAvailable(aExt : TvgExtension):Boolean;
     Var J : Integer;
         S1: String;
         AE: TpvVulkanAvailableExtension;
   Begin
     Result:=False;
     If not assigned(fVulkanInstance) then exit;
     S1:=Trim(String(aExt.fExtensionName));
     J := fVulkanInstance.AvailableExtensionNames.IndexOf(S1);
     If J=-1 then exit;
     AE:=fVulkanInstance.AvailableExtensions[J];
     Result:= (aExt.fSpecVersion <= AE.SpecVersion);
   End;

   Procedure DeleteNotRequired;
     Var J:Integer;
         EI:TvgExtension;
   Begin
     If (csDesigning in ComponentState) then exit;

     For J:=fExtensions.Count-1 downto 0 do
     Begin
       EI:= TvgExtension(fExtensions.Items[J]);
       If EI.fExtMode=VGE_NOT_REQUIRED then
          fExtensions.Delete(J);
     End;
   End;

begin
   If not assigned(fExtensions) then  exit;
   Assert(assigned(fVulkanInstance), 'Vulkan Instance not created.');

   DeleteNotRequired;       //delete not required design time layers
   BuildALLExtensions;      //build any new extensions in current hardware/platform

   If assigned(fOnExtensionSetup) then
      fOnExtensionSetup(fExtensions);    //run time can update required extensions available on current hardware

  //MUST stay here
   If fRenderToScreen then
      BuildALLExtensions;   //build again in case render to screen layers not included

   SetUpScreenExtensions;  //Must stay here will handle RenderToScreen and NOT RenderToScreen
   SetUpValidationExtensions;
 //  SetUpPortabilityExtensions;

   DeleteNotRequired;    //tidy up before creating the instance

   For I:=0 to fExtensions.count-1 do
   Begin
     E:= TvgExtension(fExtensions.Items[I]);
     e.fEnabled := False;
     If (E.fExtMode=VGE_NOT_REQUIRED) then  continue;

     B:= IsExtensionAvailable(E)  ;

     Case E.fExtMode of
       //  vglNotRequired:;  //do not need to initialize default
          VGE_MUST_HAVE  :Begin
                          if Not B then
                          Begin
                             ES:= Format('%s (%s) %s',['Must have instance extension (', String(E.ExtensionName), ') NOT available on this hardware.']);
                             raise EvgVulkanResultException.Create(VK_ERROR_EXTENSION_NOT_PRESENT, ES);
                          end else
                          Begin
                             fVulkanInstance.EnabledExtensionNames.Add(String(E.ExtensionName));
                             E.fEnabled:=True;
                          end;
                        end;     //Instance initialization MUST have this layer
          VGE_OPTIONAL  :If B then
                        Begin
                          fVulkanInstance.EnabledExtensionNames.Add(String(E.ExtensionName));     //Instance may have the layer
                          E.fEnabled:=True;
                        end;
        VGE_ON_VALIDATION:If B and fValidation then
                        Begin
                          fVulkanInstance.EnabledExtensionNames.Add(String(E.ExtensionName));
                          E.fEnabled:=True;
                        end;

     end;
   End;

end;

procedure TvgInstance.SetUpLayers;
  Var I:Integer;
      L:TvgLayer;
      B:Boolean;
      ES:String;

   Procedure DeleteNotRequired;
     Var J:Integer;
         LI:TvgLayer;
   Begin
     If (csDesigning in ComponentState) then exit;

     For J:=fLayers.Count-1 downto 0 do
     Begin
       LI:= TvgLayer(fLayers.Items[J]);
       If (LI.fLayerMode= VGL_NOT_REQUIRED) then
          fLayers.Delete(J);
     End;
   End;

   Function IsLayerAvailable(aLayer:TvgLayer):Boolean;
     Var J:Integer;
         S1:String;
         AL: TpvVulkanAvailableLayer;
   Begin
     Result:=False;
     If not assigned(fVulkanInstance) then exit;
     S1:=Trim(String(aLayer.fLayerName));
     J := fVulkanInstance.AvailableLayerNames.IndexOf(S1);
     If J=-1 then exit;
   //  Result:=True;
     AL:=fVulkanInstance.AvailableLayers[J];
     Result:= (aLayer.fSpecVersion <= AL.SpecVersion ) ;
   End;

begin
   If not assigned(fLayers) {or (fLayers.Count=0)} then exit;
   Assert(assigned(fVulkanInstance), 'Vulkan Instance not created');

   DeleteNotRequired;

   BuildALLLayers;   //build layers for run time hardware

   SetUpValidationLayers;

   If assigned(fOnLayerSetup) then
      fOnLayerSetup(fLayers);

//   DeleteNotRequired;

   For I:=0 to fLayers.count-1 do
   Begin
     L:= TvgLayer(fLayers.Items[I]);
     L.fEnabled:=False;

     If (L.fLayerMode=VGL_NOT_REQUIRED) then  continue;

     B := IsLayerAvailable(L) ;

     Case L.fLayerMode of
       //  vglNotRequired:;  //do not need to initialize default
          VGL_MUST_HAVE  :Begin
                              if Not B then
                              Begin
                                 ES:= Format('%s (%s) %s',['Must have instance layer (', String(L.fLayerName), ') is NOT available on this hardware platform.']);
                                 raise EvgVulkanResultException.Create(VK_ERROR_EXTENSION_NOT_PRESENT, ES);
                              end else
                              Begin
                                 fVulkanInstance.EnabledLayerNames.Add(String(L.LayerName));
                                 L.fEnabled:=True;
                              end;
                          end;     //Instance initialization MUST have this layer
          VGL_OPTIONAL   : If B then Begin
                                     fVulkanInstance.EnabledLayerNames.Add(String(L.LayerName));
                                     L.fEnabled:=True;    //Instance may have the layer
                                   end;
        VGL_ON_VALIDATION:If B and fValidation then
                                  Begin
                                    fVulkanInstance.EnabledLayerNames.Add(String(L.LayerName));
                                    L.fEnabled:=True;
                                  end;

     end;
   End;

end;

procedure TvgInstance.SetUpMemoryAllocation;
begin
  If assigned(fVulkanInstance) then exit;

  Case  fAllocationStatus   of
    VG_SELF_MANAGE   :Begin
                       If not assigned(fAllocationManager) then
                          fAllocationManager:= TpvVulkanAllocationManager.create;
                    end;
    VG_VULKAN_MANAGE :Begin
                       If assigned(fAllocationManager) then
                       Begin
                          fAllocationManager.Free;
                          fAllocationManager:=nil;
                       End;
                    end;
  End;
end;

procedure TvgInstance.SetUpPhysicalDevices;
  Var I:Integer;
      P:TpvVulkanPhysicalDevice;
      PC:TvgPhysDevice;
begin
  fPhysicalDeviceList.Clear;

  Assert(assigned(fVulkanInstance),'Vulkan Instance not created');
  Assert( (fVulkanInstance.Handle <> VK_NULL_HANDLE),'Vulkan Handle not valid.');
  Assert( (fVulkanInstance.PhysicalDevices.Count>0), 'No Physical Devices available.');

  For I:=0 to  fVulkanInstance.PhysicalDevices.Count-1 do
  Begin
    P := fVulkanInstance.PhysicalDevices[I];
    PC:= TvgPhysDevice.Create(fPhysicalDeviceList);
    PC.SetData(P);
  End;

end;

procedure TvgInstance.SetUpPortabilityExtensions;
  Var S1    : String;
         E  : TvgExtension;
         I  : Integer;

begin
     if not PortabilityOn then exit;

     If not assigned(fExtensions) or (fExtensions.count=0) then exit;

     S1:= VK_KHR_PORTABILITY_ENUMERATION_EXTENSION_NAME;

     For I:=0 to fExtensions.Count-1 do
     Begin
       E:=TvgExtension(fExtensions.Items[I]);
       If (CompareText(String(E.fExtensionName),S1)=0) then
         E.fExtMode:= VGE_MUST_HAVE;
     End;

end;

procedure TvgInstance.SetValidation(const Value: Boolean);
begin
  If fValidation=Value then exit;

  SetActiveState(False);

  fValidation:=Value;

end;

procedure TvgInstance.SetVulkanAPIVersion(const Value: TvgAPI_Version);
begin
  If Value=fAPIVersion then exit;
  SetActiveState(False);
  ClearAllExtensionsAndlayers;

  fAPIVersion := Value;

end;

procedure TvgInstance.SetDisabled;
  Var I:Integer;
begin
  fActive:=False;

  //keep this order
  DisableDevices;

  For I:=0 to fLayers.count-1 do
     TvgLayer(fLayers.Items[I]).fEnabled:=False;

  For I:=0 to fExtensions.count-1 do
     TvgExtension(fExtensions.Items[I]).fEnabled:=False;

  fPhysicalDeviceList.Clear;

  If assigned(fVulkanInstance) then
     FreeAndNil(fVulkanInstance) ;

  If assigned(fAllocationManager ) then
     FreeAndNil(fAllocationManager) ;

  fActive := fVulkanInstance<>nil;
end;

procedure TvgInstance.SetDesigning;

begin
  If fActive then
     fActive:=False;

  fPhysicalDeviceList.Clear;

  If fVulkanInstance<>nil then
     FreeAndNil(fVulkanInstance);
 Try
  SetUpMemoryAllocation;

  fVulkanInstance:= TpvVulkanInstance.create(fApplicationName,
                                             fpplicationVersion,
                                             fEngineName,
                                             fengineVersion,
                                             GetAPIVersion,
                                             False,
                                             fAllocationManager);

    If assigned(fVulkanInstance) then
    Begin

      fVulkanInstance.Initialize;

      SetUpPhysicalDevices; //needed by Logical Devices
      fActive := True ;

    End;

    Assert( assigned(fVulkanInstance) , 'Vulkan Instance creation failed.' );

  Except

     On E: EpvVulkanException do
     Begin
        If assigned(fVulkanInstance) then
           FreeAndNil(fVulkanInstance);
        fActive:=False;
        Raise;
     End;
  End;


end;

procedure TvgInstance.SetEnabled(aComp:TvgBaseComponent=nil);
begin
    fActive:=False;

  Try

    If fVulkanInstance<>nil then
       FreeAndNil(fVulkanInstance);

    fPhysicalDeviceList.Clear;

  //need to start from scratch
    SetUpMemoryAllocation;

    fVulkanInstance:= TpvVulkanInstance.create(fApplicationName,
                                                   fpplicationVersion,
                                                   fEngineName,
                                                   fengineVersion,
                                                   GetAPIVersion,
                                                   false,  //must be false
                                                   fAllocationManager);

    If assigned(fVulkanInstance) and (fVulkanInstance.Handle=VK_NULL_HANDLE) then
    Begin
      //must be called here
      SetUpLayers;
      SetUpExtensions;
      SetAPIVersion(fVulkanInstance.APIVersion);

    Try
      fVulkanInstance.Initialize(*(TVkInstanceCreateFlags(VK_INSTANCE_CREATE_ENUMERATE_PORTABILITY_BIT_KHR))*);  //may fail if using local allocation manager NOT SURE WHY.  The recall fixes the issue NOT GOOD

    Except
       On E:Exception do
       begin
          fVulkanInstance.Initialize(*(TVkInstanceCreateFlags(VK_INSTANCE_CREATE_ENUMERATE_PORTABILITY_BIT_KHR))*);
       end;
    End;

      SetUpPhysicalDevices;

      fActive := True ;

      If assigned(aComp) and (aComp is TvgPhysicalDevice) then
         TvgPhysicalDevice(aComp).SetEnabled
      else
        EnableDevices;

    End;

    Assert( assigned(fVulkanInstance) , 'Vulkan Instance creation failed.');

  Except

     On E: EpvVulkanException do
     Begin
        If fVulkanInstance<>nil then
           FreeAndNil(fVulkanInstance);
        fActive:=False;
        Raise;
     End;
  End;
end;

{ TvgInstanceLayer }

procedure TvgLayer.Assign(Source: TPersistent);
  var L:TvgLayer;
begin
  if Source is TvgLayer then
  begin
    L:=TvgLayer(Source);
    self.fLayerMode             := L.LayerMode;
    self.fLayerName             := L.LayerName;
    self.fSpecVersion           := L.SpecVersion;
    self.fImplementationVersion := L.ImplementationVersion;
    self.fDescription           := L.Description;
  end
  else inherited Assign(Source);
end;

constructor TvgLayer.Create(Collection: TCollection);
begin
  inherited Create(Collection);
end;

procedure TvgLayer.DefineProperties(Filer: TFiler);
begin
  inherited DefineProperties(Filer);

  Filer.DefineProperty('LayerNameProp', ReadLayer, WriteLayer, (fLayerName<>''));
  Filer.DefineProperty('LaySpecVersionProp', ReadSpecVersion, WriteSpecVersion, True);
  Filer.DefineProperty('LayImplementationProp', ReadImplementationVer, WriteImplementationVer, True);

end;

function TvgLayer.GetDescription: String;
begin
  Result := fDescription;
end;

function TvgLayer.GetDisplayName: string;
begin
  Result:=GetFullName;
  If Result='' then Inherited GetDisplayName;
end;

function TvgLayer.GetFullName: String;
begin
  Result := Trim(String(GetDescription));
end;

function TvgLayer.GetImplementationVersion: TvkUint32;
begin
  Result:=self.fImplementationVersion;
end;

function TvgLayer.GetLayerMode: TvgLayerRequireMode;
begin
  Result:=self.fLayerMode;
end;

function TvgLayer.GetLayerName: TpvVulkanCharString;
begin
  Result:=self.fLayerName;
end;

function TvgLayer.GetSpecVersion: TvkUint32;
begin
  Result:=self.fSpecVersion;
end;
function TvgLayer.GetvgOwner: TComponent;
begin
  Result:=fvgOwner;
end;

procedure TvgLayer.ReadImplementationVer(Reader: TReader);
begin
  fImplementationVersion:=ReadTvkUint32(Reader);
end;

procedure TvgLayer.ReadLayer(Reader: TReader);
begin
  fLayerName:=ansiString(Reader.ReadString);
end;

procedure TvgLayer.ReadSpecVersion(Reader: TReader);
begin
  fSpecVersion:=ReadTvkUint32(Reader);
end;

procedure TvgLayer.SetData(aLayerRec: ppvVulkanAvailableLayer);
begin
  fLayerName             := aLayerRec^.LayerName;
  fSpecVersion           := aLayerRec^.SpecVersion;
  fImplementationVersion := aLayerRec^.ImplementationVersion;
  fDescription           := String(aLayerRec^.Description);
end;

procedure TvgLayer.SetDescription(const Value: String);
begin
  fDescription := Value;
end;

procedure TvgLayer.SetLayerMode(const Value: TvgLayerRequireMode);
begin
   If fLayerMode= Value then exit;

   fLayerMode := Value;

  If assigned(fvgOwner) then
  Begin
    If (vgOwner is TvgInstance) and (TvgInstance(fvgOwner).Active) then  TvgInstance(fvgOwner).Active:=False;
    If (vgOwner is TvgPhysicalDevice) and (TvgPhysicalDevice(fvgOwner).Active) then      TvgPhysicalDevice(fvgOwner).Active:=False;
  End;

end;

procedure TvgLayer.SetvgOwner(const Value: TComponent);
begin
   vgOwner:=Value;
end;

procedure TvgLayer.WriteImplementationVer(Writer: TWriter);

begin
  WriteTvkUint32(Writer,fImplementationVersion);
end;

procedure TvgLayer.WriteLayer(Writer: TWriter);
begin
 Writer.WriteString(String(fLayerName));
end;

procedure TvgLayer.WriteSpecVersion(Writer: TWriter);
begin
  WriteTvkUint32(Writer,fSpecVersion);
end;

{ TvgInstanceLayerCollection }

function TvgLayers.Add: TvgLayer;
begin
  Result := TvgLayer(inherited Add);
end;

function TvgLayers.AddItem(Item: TvgLayer; Index: Integer): TvgLayer;
Begin
  if Item = nil then
    Result := TvgLayer.Create(self)
  else
    Result := Item;

  if Assigned(Result) then
  begin
    Result.Collection := Self;
    if Index < 0 then
      Index := Count - 1;
    Result.Index := Index;
  end;

end;

constructor TvgLayers.Create(aOwner: TvgBaseComponent);
begin
  Inherited Create(TvgLayer);
  fOwner := aOwner;
end;

function TvgLayers.GetItem(Index: Integer): TvgLayer;
begin
  Result := TvgLayer(inherited GetItem(Index));
end;

function TvgLayers.GetOwner: TPersistent;
begin
  Result := fOwner;
end;

function TvgLayers.Insert(Index: Integer): TvgLayer;
begin
  Result := AddItem(nil, Index);
end;

procedure TvgLayers.SetItem(Index: Integer;  const Value: TvgLayer);
begin
  inherited SetItem(Index, Value);
end;

procedure TvgLayers.Update(Item: TCollectionItem);
var
  str: string;
  i: Integer;
begin
  inherited;
  // update everything in any case...
  str := '';
  for i := 0 to Count - 1 do
  begin
    str := str + (Items [i] as TvgLayer).Description;
    if i < Count - 1 then
      str := str + '-';
  end;
  FCollString := str;
end;

{ TvgInstanceExtensions }

function TvgExtensions.Add: TvgExtension;
begin
  Result := TvgExtension(inherited Add);

end;

function TvgExtensions.AddItem(Item: TvgExtension; Index: Integer): TvgExtension;
begin
  if Item = nil then
    Result := TvgExtension.Create(self)
  else
    Result := Item;

  if Assigned(Result) then
  begin
    Result.Collection := Self;
    if Index < 0 then
      Index := Count - 1;
    Result.Index := Index;
  end;
end;

constructor TvgExtensions.Create(aOwner: TvgBaseComponent);
begin
  Inherited Create(TvgExtension);
  fOwner := aOwner;
end;

function TvgExtensions.GetItem(Index: Integer): TvgExtension;
begin
  Result := TvgExtension(inherited GetItem(Index));

end;

function TvgExtensions.GetOwner: TPersistent;
begin
  Result := fOwner;
end;

function TvgExtensions.Insert(Index: Integer): TvgExtension;
begin
  Result := AddItem(nil, Index);
end;

procedure TvgExtensions.SetItem(Index: Integer; const Value: TvgExtension);
begin
  inherited SetItem(Index, Value);
end;

procedure TvgExtensions.Update(Item: TCollectionItem);
var
  str: string;
  i: Integer;
begin
  inherited;
  // update everything in any case...
  str := '';
  for i := 0 to Count - 1 do
  begin
    str := str + String((Items [i] as TvgExtension).fExtensionName);
    if i < Count - 1 then
      str := str + '-';
  end;
  FCollString := str;
end;

{ TvgInstanceExtension }

procedure TvgExtension.Assign(Source: TPersistent);
  Var E: TvgExtension;
begin
  inherited;
  If not (source is  TvgExtension) then exit;
  E:= TvgExtension(Source);

  self.fExtMode       := E.fExtMode;
  self.fLayerIndex    := E.fLayerIndex;
  self.fExtensionName := E.fExtensionName;
  self.fSpecVersion   := E.fSpecVersion;
end;

constructor TvgExtension.Create(Collection: TCollection);
begin
  inherited Create(Collection);
end;

procedure TvgExtension.DefineProperties(Filer: TFiler);
begin
  inherited DefineProperties(Filer);

  Filer.DefineProperty('ExtLayerIndexProp', ReadLayerIndex, WriteLayerIndex, True);
  Filer.DefineProperty('ExtSpecVersionProp', ReadSpecVersion, WriteSpecVersion, True);
  Filer.DefineProperty('ExtImplementationProp', ReadExtName, WriteExtName, True);
end;

function TvgExtension.GetDisplayName: string;
begin
  Result:=GetFullName;
end;

function TvgExtension.GetExtensionName: TpvVulkanCharString;
begin
  Result:=  fExtensionName;
end;

function TvgExtension.GetExtMode: TvgExtensionRequireMode;
begin
  Result:=  fExtMode;
end;

function TvgExtension.GetFullName: String;
begin
  Result:=Trim(String(fExtensionName));
end;

function TvgExtension.GetLayerIndex: TvkUint32;
begin
  Result:=  fLayerIndex;
end;

function TvgExtension.GetSpecVersion: TvkUint32;
begin
  Result:=  fSpecVersion;
end;

function TvgExtension.GetvgOwner: TComponent;
begin
  Result:=fvgOwner;
end;

procedure TvgExtension.ReadExtName(Reader: TReader);
begin
  fExtensionName := ansiString(Reader.ReadString);
end;

procedure TvgExtension.ReadLayerIndex(Reader: TReader);
begin
  fLayerIndex := ReadTvkUint32(Reader);
end;

procedure TvgExtension.ReadSpecVersion(Reader: TReader);
begin
  fSpecVersion:= ReadTvkUint32(Reader);
end;

procedure TvgExtension.SetData(aExtRec: PpvVulkanAvailableExtension);
begin
  If aExtRec=nil then exit;

  fLayerIndex   := aExtRec^.LayerIndex;
  fExtensionName:= aExtRec^.ExtensionName;
  fSpecVersion  := aExtRec^.SpecVersion;
end;

procedure TvgExtension.SetExtMode(const Value: TvgExtensionRequireMode);
begin
  If fExtMode=Value then exit;
  fExtMode := Value;

  If assigned(fvgOwner) then
  Begin
    If (vgOwner is TvgInstance) and (TvgInstance(fvgOwner).Active) then  TvgInstance(fvgOwner).Active:=False;
    If (vgOwner is TvgPhysicalDevice) and (TvgPhysicalDevice(fvgOwner).Active) then      TvgPhysicalDevice(fvgOwner).Active:=False;
  End;
end;

procedure TvgExtension.SetvgOwner(const Value: TComponent);
begin
  fvgOwner := Value;
end;

procedure TvgExtension.WriteExtName(Writer: TWriter);
begin
  Writer.WriteString(String(fExtensionName));
end;

procedure TvgExtension.WriteLayerIndex(Writer: TWriter);
begin
  WriteTvkUint32(Writer,fLayerIndex) ;
end;

procedure TvgExtension.WriteSpecVersion(Writer: TWriter);
begin
  WriteTvkUint32(Writer,fSpecVersion) ;
end;

{ EvgVulkanResultException }

constructor EvgVulkanResultException.Create(const aResultCode: TVkResult; const aMsg: String);
  Var s:String;
begin
  S:=Format('%s (%s)',[aMsg, vgVulkanErrorToString(aResultCode)]);
  inherited Create(S);
end;

destructor EvgVulkanResultException.Destroy;
begin

  inherited;
end;

{ TvgFeatures }

procedure TvgFeatures.CopyDataToRecords;
  Var Device : TpvVulkanPhysicalDevice;
begin
  If not assigned(fLogicalDevice) then exit;
  If not assigned(fLogicalDevice.PhysicalDevice) then exit;
  If not assigned(fLogicalDevice.PhysicalDevice.VulkanPhysicalDevice) then exit;

  Device := fLogicalDevice.PhysicalDevice.VulkanPhysicalDevice;

//1_0
  fRequestedFeatures.features.robustBufferAccess  := GetVK32Boolean(frobustBufferAccess ) and Device.Features.robustBufferAccess;
  fRequestedFeatures.features.fullDrawIndexUint32 := GetVK32Boolean(ffullDrawIndexUint32 ) and Device.Features.fullDrawIndexUint32 ;
  fRequestedFeatures.features.imageCubeArray      := GetVK32Boolean(fimageCubeArray ) and Device.Features.imageCubeArray;
  fRequestedFeatures.features.independentBlend    := GetVK32Boolean(findependentBlend ) and Device.Features.independentBlend;
  fRequestedFeatures.features.geometryShader      := GetVK32Boolean(fgeometryShader ) and Device.Features.geometryShader;
  fRequestedFeatures.features.tessellationShader  := GetVK32Boolean(ftessellationShader ) and Device.Features.tessellationShader;
  fRequestedFeatures.features.sampleRateShading   := GetVK32Boolean(fsampleRateShading ) and Device.Features.sampleRateShading;
  fRequestedFeatures.features.dualSrcBlend        := GetVK32Boolean(fdualSrcBlend ) and Device.Features.dualSrcBlend;
  fRequestedFeatures.features.logicOp             := GetVK32Boolean(flogicOp ) and Device.Features.logicOp;
  fRequestedFeatures.features.multiDrawIndirect   := GetVK32Boolean(fmultiDrawIndirect ) and Device.Features.multiDrawIndirect;
  fRequestedFeatures.features.drawIndirectFirstInstance := GetVK32Boolean(fdrawIndirectFirstInstance ) and Device.Features.drawIndirectFirstInstance;
  fRequestedFeatures.features.depthClamp          := GetVK32Boolean(fdepthClamp ) and Device.Features.depthClamp;
  fRequestedFeatures.features.depthBiasClamp      := GetVK32Boolean(fdepthBiasClamp ) and Device.Features.depthBiasClamp;
  fRequestedFeatures.features.fillModeNonSolid    := GetVK32Boolean(ffillModeNonSolid ) and Device.Features.fillModeNonSolid;
  fRequestedFeatures.features.depthBounds         := GetVK32Boolean(fdepthBounds ) and Device.Features.depthBounds;
  fRequestedFeatures.features.wideLines           := GetVK32Boolean(fwideLines ) and Device.Features.wideLines;
  fRequestedFeatures.features.largePoints         := GetVK32Boolean(flargePoints ) and Device.Features.largePoints;
  fRequestedFeatures.features.alphaToOne          := GetVK32Boolean(falphaToOne ) and Device.Features.alphaToOne;
  fRequestedFeatures.features.multiViewport       := GetVK32Boolean(fmultiViewport ) and Device.Features.multiViewport;
  fRequestedFeatures.features.samplerAnisotropy   := GetVK32Boolean(fsamplerAnisotropy ) and Device.Features.samplerAnisotropy;
  fRequestedFeatures.features.textureCompressionETC2      := GetVK32Boolean(ftextureCompressionETC2 ) and Device.Features.textureCompressionETC2;
  fRequestedFeatures.features.textureCompressionASTC_LDR  := GetVK32Boolean(ftextureCompressionASTC_LDR ) and Device.Features.textureCompressionASTC_LDR;
  fRequestedFeatures.features.textureCompressionBC        := GetVK32Boolean(ftextureCompressionBC ) and Device.Features.textureCompressionBC;
  fRequestedFeatures.features.occlusionQueryPrecise       := GetVK32Boolean(focclusionQueryPrecise ) and Device.Features.occlusionQueryPrecise;
  fRequestedFeatures.features.pipelineStatisticsQuery     := GetVK32Boolean(fpipelineStatisticsQuery ) and Device.Features.pipelineStatisticsQuery;
  fRequestedFeatures.features.vertexPipelineStoresAndAtomics := GetVK32Boolean(fvertexPipelineStoresAndAtomics ) and Device.Features.vertexPipelineStoresAndAtomics;
  fRequestedFeatures.features.fragmentStoresAndAtomics    := GetVK32Boolean(ffragmentStoresAndAtomics ) and Device.Features.fragmentStoresAndAtomics;
  fRequestedFeatures.features.shaderTessellationAndGeometryPointSize := GetVK32Boolean(fshaderTessellationAndGeometryPointSize ) and Device.Features.shaderTessellationAndGeometryPointSize;
  fRequestedFeatures.features.shaderImageGatherExtended   := GetVK32Boolean(fshaderImageGatherExtended ) and Device.Features.shaderImageGatherExtended;
  fRequestedFeatures.features.shaderStorageImageExtendedFormats       := GetVK32Boolean(fshaderStorageImageExtendedFormats ) and Device.Features.shaderStorageImageExtendedFormats;
  fRequestedFeatures.features.shaderStorageImageMultisample           := GetVK32Boolean(fshaderStorageImageMultisample ) and Device.Features.shaderStorageImageMultisample;
  fRequestedFeatures.features.shaderStorageImageReadWithoutFormat     := GetVK32Boolean(fshaderStorageImageReadWithoutFormat ) and Device.Features.shaderStorageImageReadWithoutFormat;
  fRequestedFeatures.features.shaderStorageImageWriteWithoutFormat    := GetVK32Boolean(fshaderStorageImageWriteWithoutFormat ) and Device.Features.shaderStorageImageWriteWithoutFormat;
  fRequestedFeatures.features.shaderUniformBufferArrayDynamicIndexing := GetVK32Boolean(fshaderUniformBufferArrayDynamicIndexing ) and Device.Features.shaderUniformBufferArrayDynamicIndexing;
  fRequestedFeatures.features.shaderSampledImageArrayDynamicIndexing  := GetVK32Boolean(fshaderSampledImageArrayDynamicIndexing ) and Device.Features.shaderSampledImageArrayDynamicIndexing;
  fRequestedFeatures.features.shaderStorageBufferArrayDynamicIndexing := GetVK32Boolean(fshaderStorageBufferArrayDynamicIndexing ) and Device.Features.shaderStorageBufferArrayDynamicIndexing;
  fRequestedFeatures.features.shaderStorageImageArrayDynamicIndexing  := GetVK32Boolean(fshaderStorageImageArrayDynamicIndexing ) and Device.Features.shaderStorageImageArrayDynamicIndexing;
  fRequestedFeatures.features.shaderClipDistance      := GetVK32Boolean(fshaderClipDistance ) and Device.Features.shaderClipDistance;
  fRequestedFeatures.features.shaderCullDistance      := GetVK32Boolean(fshaderCullDistance ) and Device.Features.shaderCullDistance;
  fRequestedFeatures.features.shaderFloat64           := GetVK32Boolean(fshaderFloat64 ) and Device.Features.shaderFloat64;
  fRequestedFeatures.features.shaderInt64             := GetVK32Boolean(fshaderInt64 ) and Device.Features.shaderInt64;
  fRequestedFeatures.features.shaderInt16             := GetVK32Boolean(fshaderInt16 ) and Device.Features.shaderInt16;
  fRequestedFeatures.features.shaderResourceResidency := GetVK32Boolean(fshaderResourceResidency ) and Device.Features.shaderResourceResidency;
  fRequestedFeatures.features.shaderResourceMinLod    := GetVK32Boolean(fshaderResourceMinLod ) and Device.Features.shaderResourceMinLod;
  fRequestedFeatures.features.sparseBinding           := GetVK32Boolean(fsparseBinding ) and Device.Features.sparseBinding;
  fRequestedFeatures.features.sparseResidencyBuffer   := GetVK32Boolean(fsparseResidencyBuffer ) and Device.Features.sparseResidencyBuffer;
  fRequestedFeatures.features.sparseResidencyImage2D  := GetVK32Boolean(fsparseResidencyImage2D ) and Device.Features.sparseResidencyImage2D;
  fRequestedFeatures.features.sparseResidencyImage3D  := GetVK32Boolean(fsparseResidencyImage3D ) and Device.Features.sparseResidencyImage3D;
  fRequestedFeatures.features.sparseResidency2Samples := GetVK32Boolean(fsparseResidency2Samples ) and Device.Features.sparseResidency2Samples;
  fRequestedFeatures.features.sparseResidency4Samples := GetVK32Boolean(fsparseResidency4Samples ) and Device.Features.sparseResidency4Samples;
  fRequestedFeatures.features.sparseResidency8Samples := GetVK32Boolean(fsparseResidency8Samples ) and Device.Features.sparseResidency8Samples;
  fRequestedFeatures.features.sparseResidency16Samples:= GetVK32Boolean(fsparseResidency16Samples ) and Device.Features.sparseResidency16Samples;
  fRequestedFeatures.features.sparseResidencyAliased  := GetVK32Boolean(fsparseResidencyAliased ) and Device.Features.sparseResidencyAliased;
  fRequestedFeatures.features.variableMultisampleRate := GetVK32Boolean(fvariableMultisampleRate ) and Device.Features.variableMultisampleRate;
  fRequestedFeatures.features.inheritedQueries        := GetVK32Boolean(finheritedQueries ) and Device.Features.inheritedQueries;

//1_1
  fRequestedFeatures11.storageBuffer16BitAccess := GetVK32Boolean(fstorageBuffer16BitAccess ) and Device.Vulkan11Features.storageBuffer16BitAccess ;
  fRequestedFeatures11.uniformAndStorageBuffer16BitAccess := GetVK32Boolean(funiformAndStorageBuffer16BitAccess )  and Device.Vulkan11Features.uniformAndStorageBuffer16BitAccess;
  fRequestedFeatures11.storagePushConstant16 := GetVK32Boolean(fstoragePushConstant16 )  and Device.Vulkan11Features.storagePushConstant16;
  fRequestedFeatures11.storageInputOutput16 := GetVK32Boolean(fstorageInputOutput16 )  and Device.Vulkan11Features.storageInputOutput16;
  fRequestedFeatures11.multiview := GetVK32Boolean(fmultiview )  and Device.Vulkan11Features.multiview;
  fRequestedFeatures11.multiviewGeometryShader := GetVK32Boolean(fmultiviewGeometryShader )  and Device.Vulkan11Features.multiviewGeometryShader;
  fRequestedFeatures11.multiviewTessellationShader := GetVK32Boolean(fmultiviewTessellationShader )  and Device.Vulkan11Features.multiviewTessellationShader;
  fRequestedFeatures11.variablePointersStorageBuffer := GetVK32Boolean(fvariablePointersStorageBuffer )  and Device.Vulkan11Features.variablePointersStorageBuffer;
  fRequestedFeatures11.variablePointers := GetVK32Boolean(fvariablePointers ) and Device.Vulkan11Features.variablePointers;
  fRequestedFeatures11.protectedMemory := GetVK32Boolean(fprotectedMemory )  and Device.Vulkan11Features.protectedMemory;
  fRequestedFeatures11.samplerYcbcrConversion := GetVK32Boolean(fsamplerYcbcrConversion )  and Device.Vulkan11Features.samplerYcbcrConversion;
  fRequestedFeatures11.shaderDrawParameters := GetVK32Boolean(fshaderDrawParameters )  and Device.Vulkan11Features.shaderDrawParameters;


 //1_2
  fRequestedFeatures12.samplerMirrorClampToEdge := GetVK32Boolean(fsamplerMirrorClampToEdge )  and Device.Vulkan12Features.samplerMirrorClampToEdge;
  fRequestedFeatures12.drawIndirectCount := GetVK32Boolean(fdrawIndirectCount ) and Device.Vulkan12Features.drawIndirectCount ;
  fRequestedFeatures12.storageBuffer8BitAccess := GetVK32Boolean(fstorageBuffer8BitAccess )  and Device.Vulkan12Features.storageBuffer8BitAccess;
  fRequestedFeatures12.uniformAndStorageBuffer8BitAccess := GetVK32Boolean(funiformAndStorageBuffer8BitAccess )  and Device.Vulkan12Features.uniformAndStorageBuffer8BitAccess;
  fRequestedFeatures12.storagePushConstant8 := GetVK32Boolean(fstoragePushConstant8 )  and Device.Vulkan12Features.storagePushConstant8;
  fRequestedFeatures12.shaderBufferInt64Atomics := GetVK32Boolean(fshaderBufferInt64Atomics ) and Device.Vulkan12Features.shaderBufferInt64Atomics ;
  fRequestedFeatures12.shaderSharedInt64Atomics := GetVK32Boolean(fshaderSharedInt64Atomics )  and Device.Vulkan12Features.shaderSharedInt64Atomics;
  fRequestedFeatures12.shaderFloat16 := GetVK32Boolean(fshaderFloat16 )  and Device.Vulkan12Features.shaderFloat16;
  fRequestedFeatures12.shaderInt8 := GetVK32Boolean(fshaderInt8 )  and Device.Vulkan12Features.shaderInt8;
  fRequestedFeatures12.descriptorIndexing := GetVK32Boolean(fdescriptorIndexing )  and Device.Vulkan12Features.descriptorIndexing;
  fRequestedFeatures12.shaderInputAttachmentArrayDynamicIndexing := GetVK32Boolean(fshaderInputAttachmentArrayDynamicIndexing )  and Device.Vulkan12Features.shaderInputAttachmentArrayDynamicIndexing;
  fRequestedFeatures12.shaderUniformTexelBufferArrayDynamicIndexing := GetVK32Boolean(fshaderUniformTexelBufferArrayDynamicIndexing )  and Device.Vulkan12Features.shaderUniformTexelBufferArrayDynamicIndexing;
  fRequestedFeatures12.shaderStorageTexelBufferArrayDynamicIndexing := GetVK32Boolean(fshaderStorageTexelBufferArrayDynamicIndexing )  and Device.Vulkan12Features.shaderStorageTexelBufferArrayDynamicIndexing;
  fRequestedFeatures12.shaderUniformBufferArrayNonUniformIndexing := GetVK32Boolean(fshaderUniformBufferArrayNonUniformIndexing )  and Device.Vulkan12Features.shaderUniformBufferArrayNonUniformIndexing;
  fRequestedFeatures12.shaderSampledImageArrayNonUniformIndexing := GetVK32Boolean(fshaderSampledImageArrayNonUniformIndexing )  and Device.Vulkan12Features.shaderSampledImageArrayNonUniformIndexing;
  fRequestedFeatures12.shaderStorageBufferArrayNonUniformIndexing := GetVK32Boolean(fshaderStorageBufferArrayNonUniformIndexing )  and Device.Vulkan12Features.shaderStorageBufferArrayNonUniformIndexing;
  fRequestedFeatures12.shaderStorageImageArrayNonUniformIndexing := GetVK32Boolean(fshaderStorageImageArrayNonUniformIndexing )  and Device.Vulkan12Features.shaderStorageImageArrayNonUniformIndexing;
  fRequestedFeatures12.shaderInputAttachmentArrayNonUniformIndexing := GetVK32Boolean(fshaderInputAttachmentArrayNonUniformIndexing )  and Device.Vulkan12Features.shaderInputAttachmentArrayNonUniformIndexing;
  fRequestedFeatures12.shaderUniformTexelBufferArrayNonUniformIndexing := GetVK32Boolean(fshaderUniformTexelBufferArrayNonUniformIndexing )  and Device.Vulkan12Features.shaderUniformTexelBufferArrayNonUniformIndexing;
  fRequestedFeatures12.shaderStorageTexelBufferArrayNonUniformIndexing := GetVK32Boolean(fshaderStorageTexelBufferArrayNonUniformIndexing )  and Device.Vulkan12Features.shaderStorageTexelBufferArrayNonUniformIndexing;
  fRequestedFeatures12.descriptorBindingUniformBufferUpdateAfterBind := GetVK32Boolean(fdescriptorBindingUniformBufferUpdateAfterBind )  and Device.Vulkan12Features.descriptorBindingUniformBufferUpdateAfterBind;
  fRequestedFeatures12.descriptorBindingSampledImageUpdateAfterBind := GetVK32Boolean(fdescriptorBindingSampledImageUpdateAfterBind )  and Device.Vulkan12Features.descriptorBindingSampledImageUpdateAfterBind;
  fRequestedFeatures12.descriptorBindingStorageImageUpdateAfterBind := GetVK32Boolean(fdescriptorBindingStorageImageUpdateAfterBind )  and Device.Vulkan12Features.descriptorBindingStorageImageUpdateAfterBind;
  fRequestedFeatures12.descriptorBindingStorageBufferUpdateAfterBind := GetVK32Boolean(fdescriptorBindingStorageBufferUpdateAfterBind )  and Device.Vulkan12Features.descriptorBindingStorageBufferUpdateAfterBind;
  fRequestedFeatures12.descriptorBindingUniformTexelBufferUpdateAfterBind := GetVK32Boolean(fdescriptorBindingUniformTexelBufferUpdateAfterBind )  and Device.Vulkan12Features.descriptorBindingUniformTexelBufferUpdateAfterBind;
  fRequestedFeatures12.descriptorBindingStorageTexelBufferUpdateAfterBind := GetVK32Boolean(fdescriptorBindingStorageTexelBufferUpdateAfterBind )  and Device.Vulkan12Features.descriptorBindingStorageTexelBufferUpdateAfterBind;
  fRequestedFeatures12.descriptorBindingUpdateUnusedWhilePending := GetVK32Boolean(fdescriptorBindingUpdateUnusedWhilePending )  and Device.Vulkan12Features.descriptorBindingUpdateUnusedWhilePending;
  fRequestedFeatures12.descriptorBindingPartiallyBound := GetVK32Boolean(fdescriptorBindingPartiallyBound )  and Device.Vulkan12Features.descriptorBindingPartiallyBound;
  fRequestedFeatures12.descriptorBindingVariableDescriptorCount := GetVK32Boolean(fdescriptorBindingVariableDescriptorCount )  and Device.Vulkan12Features.descriptorBindingVariableDescriptorCount;
  fRequestedFeatures12.runtimeDescriptorArray := GetVK32Boolean(fruntimeDescriptorArray )  and Device.Vulkan12Features.runtimeDescriptorArray;
  fRequestedFeatures12.samplerFilterMinmax := GetVK32Boolean(fsamplerFilterMinmax )  and Device.Vulkan12Features.samplerFilterMinmax;
  fRequestedFeatures12.scalarBlockLayout := GetVK32Boolean(fscalarBlockLayout )  and Device.Vulkan12Features.scalarBlockLayout;
  fRequestedFeatures12.imagelessFramebuffer := GetVK32Boolean(fimagelessFramebuffer )  and Device.Vulkan12Features.imagelessFramebuffer;
  fRequestedFeatures12.uniformBufferStandardLayout := GetVK32Boolean(funiformBufferStandardLayout )  and Device.Vulkan12Features.uniformBufferStandardLayout;
  fRequestedFeatures12.shaderSubgroupExtendedTypes := GetVK32Boolean(fshaderSubgroupExtendedTypes )  and Device.Vulkan12Features.shaderSubgroupExtendedTypes;
  fRequestedFeatures12.separateDepthStencilLayouts := GetVK32Boolean(fseparateDepthStencilLayouts )  and Device.Vulkan12Features.separateDepthStencilLayouts;
  fRequestedFeatures12.hostQueryReset := GetVK32Boolean(fhostQueryReset )  and Device.Vulkan12Features.hostQueryReset;
  fRequestedFeatures12.timelineSemaphore := GetVK32Boolean(ftimelineSemaphore )  and Device.Vulkan12Features.timelineSemaphore;
  fRequestedFeatures12.bufferDeviceAddress := GetVK32Boolean(fbufferDeviceAddress )  and Device.Vulkan12Features.bufferDeviceAddress;
  fRequestedFeatures12.bufferDeviceAddressCaptureReplay := GetVK32Boolean(fbufferDeviceAddressCaptureReplay ) and Device.Vulkan12Features.bufferDeviceAddressCaptureReplay ;
  fRequestedFeatures12.bufferDeviceAddressMultiDevice := GetVK32Boolean(fbufferDeviceAddressMultiDevice )  and Device.Vulkan12Features.bufferDeviceAddressMultiDevice;
  fRequestedFeatures12.vulkanMemoryModel := GetVK32Boolean(fvulkanMemoryModel )  and Device.Vulkan12Features.vulkanMemoryModel;
  fRequestedFeatures12.vulkanMemoryModelDeviceScope := GetVK32Boolean(fvulkanMemoryModelDeviceScope )  and Device.Vulkan12Features.vulkanMemoryModelDeviceScope;
  fRequestedFeatures12.vulkanMemoryModelAvailabilityVisibilityChains := GetVK32Boolean(fvulkanMemoryModelAvailabilityVisibilityChains ) ;
  fRequestedFeatures12.shaderOutputViewportIndex := GetVK32Boolean(fshaderOutputViewportIndex )  and Device.Vulkan12Features.shaderOutputViewportIndex;
  fRequestedFeatures12.shaderOutputLayer := GetVK32Boolean(fshaderOutputLayer )  and Device.Vulkan12Features.shaderOutputLayer;
  fRequestedFeatures12.subgroupBroadcastDynamicId := GetVK32Boolean(fsubgroupBroadcastDynamicId )  and Device.Vulkan12Features.subgroupBroadcastDynamicId;

 //1_3
  fRequestedFeatures13.robustImageAccess := GetVK32Boolean(frobustImageAccess )  and Device.Vulkan13Features.robustImageAccess;
  fRequestedFeatures13.inlineUniformBlock := GetVK32Boolean(finlineUniformBlock )  and Device.Vulkan13Features.inlineUniformBlock;
  fRequestedFeatures13.descriptorBindingInlineUniformBlockUpdateAfterBind := GetVK32Boolean(fdescriptorBindingInlineUniformBlockUpdateAfterBind )  and Device.Vulkan13Features.descriptorBindingInlineUniformBlockUpdateAfterBind;
  fRequestedFeatures13.pipelineCreationCacheControl := GetVK32Boolean(fpipelineCreationCacheControl )  and Device.Vulkan13Features.pipelineCreationCacheControl;
  fRequestedFeatures13.privateData := GetVK32Boolean(fprivateData )  and Device.Vulkan13Features.privateData;
  fRequestedFeatures13.shaderDemoteToHelperInvocation := GetVK32Boolean(fshaderDemoteToHelperInvocation )  and Device.Vulkan13Features.shaderDemoteToHelperInvocation;
  fRequestedFeatures13.shaderTerminateInvocation := GetVK32Boolean(fshaderTerminateInvocation )  and Device.Vulkan13Features.shaderTerminateInvocation;
  fRequestedFeatures13.subgroupSizeControl := GetVK32Boolean(fsubgroupSizeControl )  and Device.Vulkan13Features.subgroupSizeControl;
  fRequestedFeatures13.computeFullSubgroups := GetVK32Boolean(fcomputeFullSubgroups )  and Device.Vulkan13Features.computeFullSubgroups;
  fRequestedFeatures13.synchronization2 := GetVK32Boolean(fsynchronization2 )  and Device.Vulkan13Features.synchronization2;
  fRequestedFeatures13.textureCompressionASTC_HDR := GetVK32Boolean(ftextureCompressionASTC_HDR )  and Device.Vulkan13Features.textureCompressionASTC_HDR;
  fRequestedFeatures13.shaderZeroInitializeWorkgroupMemory := GetVK32Boolean(fshaderZeroInitializeWorkgroupMemory ) ;
  fRequestedFeatures13.dynamicRendering := GetVK32Boolean(fdynamicRendering )  and Device.Vulkan13Features.dynamicRendering;
  fRequestedFeatures13.shaderIntegerDotProduct := GetVK32Boolean(fshaderIntegerDotProduct )  and Device.Vulkan13Features.shaderIntegerDotProduct;
  fRequestedFeatures13.maintenance4 := GetVK32Boolean(fmaintenance4 )  and Device.Vulkan13Features.maintenance4;

end;

procedure TvgFeatures.CopyRecordsToData;
begin
  If fSetLocked then exit;

//1_0
  frobustBufferAccess   := GetBoolean( fRequestedFeatures.features.robustBufferAccess) ;
  ffullDrawIndexUint32   := GetBoolean( fRequestedFeatures.features.fullDrawIndexUint32) ;
  fimageCubeArray   := GetBoolean( fRequestedFeatures.features.imageCubeArray) ;
  findependentBlend   := GetBoolean( fRequestedFeatures.features.independentBlend) ;
  fgeometryShader   := GetBoolean( fRequestedFeatures.features.geometryShader) ;
  ftessellationShader   := GetBoolean( fRequestedFeatures.features.tessellationShader) ;
  fsampleRateShading   := GetBoolean( fRequestedFeatures.features.sampleRateShading) ;
  fdualSrcBlend   := GetBoolean( fRequestedFeatures.features.dualSrcBlend) ;
  flogicOp   := GetBoolean( fRequestedFeatures.features.logicOp) ;
  fmultiDrawIndirect   := GetBoolean( fRequestedFeatures.features.multiDrawIndirect) ;
  fdrawIndirectFirstInstance   := GetBoolean( fRequestedFeatures.features.drawIndirectFirstInstance) ;
  fdepthClamp   := GetBoolean( fRequestedFeatures.features.depthClamp) ;
  fdepthBiasClamp   := GetBoolean( fRequestedFeatures.features.depthBiasClamp) ;
  ffillModeNonSolid   := GetBoolean( fRequestedFeatures.features.fillModeNonSolid) ;
  fdepthBounds   := GetBoolean( fRequestedFeatures.features.depthBounds) ;
  fwideLines   := GetBoolean( fRequestedFeatures.features.wideLines) ;
  flargePoints   := GetBoolean( fRequestedFeatures.features.largePoints) ;
  falphaToOne   := GetBoolean( fRequestedFeatures.features.alphaToOne) ;
  fmultiViewport   := GetBoolean( fRequestedFeatures.features.multiViewport) ;
  fsamplerAnisotropy   := GetBoolean( fRequestedFeatures.features.samplerAnisotropy) ;
  ftextureCompressionETC2   := GetBoolean( fRequestedFeatures.features.textureCompressionETC2) ;
  ftextureCompressionASTC_LDR   := GetBoolean( fRequestedFeatures.features.textureCompressionASTC_LDR) ;
  ftextureCompressionBC   := GetBoolean( fRequestedFeatures.features.textureCompressionBC) ;
  focclusionQueryPrecise   := GetBoolean( fRequestedFeatures.features.occlusionQueryPrecise) ;
  fpipelineStatisticsQuery   := GetBoolean( fRequestedFeatures.features.pipelineStatisticsQuery) ;
  fvertexPipelineStoresAndAtomics   := GetBoolean( fRequestedFeatures.features.vertexPipelineStoresAndAtomics) ;
  ffragmentStoresAndAtomics   := GetBoolean( fRequestedFeatures.features.fragmentStoresAndAtomics) ;
  fshaderTessellationAndGeometryPointSize   := GetBoolean( fRequestedFeatures.features.shaderTessellationAndGeometryPointSize) ;
  fshaderImageGatherExtended   := GetBoolean( fRequestedFeatures.features.shaderImageGatherExtended) ;
  fshaderStorageImageExtendedFormats   := GetBoolean( fRequestedFeatures.features.shaderStorageImageExtendedFormats) ;
  fshaderStorageImageMultisample   := GetBoolean( fRequestedFeatures.features.shaderStorageImageMultisample) ;
  fshaderStorageImageReadWithoutFormat   := GetBoolean( fRequestedFeatures.features.shaderStorageImageReadWithoutFormat) ;
  fshaderStorageImageWriteWithoutFormat   := GetBoolean( fRequestedFeatures.features.shaderStorageImageWriteWithoutFormat) ;
  fshaderUniformBufferArrayDynamicIndexing   := GetBoolean( fRequestedFeatures.features.shaderUniformBufferArrayDynamicIndexing) ;
  fshaderSampledImageArrayDynamicIndexing   := GetBoolean( fRequestedFeatures.features.shaderSampledImageArrayDynamicIndexing) ;
  fshaderStorageBufferArrayDynamicIndexing   := GetBoolean( fRequestedFeatures.features.shaderStorageBufferArrayDynamicIndexing) ;
  fshaderStorageImageArrayDynamicIndexing   := GetBoolean( fRequestedFeatures.features.shaderStorageImageArrayDynamicIndexing) ;
  fshaderClipDistance   := GetBoolean( fRequestedFeatures.features.shaderClipDistance) ;
  fshaderCullDistance   := GetBoolean( fRequestedFeatures.features.shaderCullDistance) ;
  fshaderFloat64   := GetBoolean( fRequestedFeatures.features.shaderFloat64) ;
  fshaderInt64   := GetBoolean( fRequestedFeatures.features.shaderInt64) ;
  fshaderInt16   := GetBoolean( fRequestedFeatures.features.shaderInt16) ;
  fshaderResourceResidency   := GetBoolean( fRequestedFeatures.features.shaderResourceResidency) ;
  fshaderResourceMinLod   := GetBoolean( fRequestedFeatures.features.shaderResourceMinLod) ;
  fsparseBinding   := GetBoolean( fRequestedFeatures.features.sparseBinding) ;
  fsparseResidencyBuffer   := GetBoolean( fRequestedFeatures.features.sparseResidencyBuffer) ;
  fsparseResidencyImage2D   := GetBoolean( fRequestedFeatures.features.sparseResidencyImage2D) ;
  fsparseResidencyImage3D   := GetBoolean( fRequestedFeatures.features.sparseResidencyImage3D) ;
  fsparseResidency2Samples   := GetBoolean( fRequestedFeatures.features.sparseResidency2Samples) ;
  fsparseResidency4Samples   := GetBoolean( fRequestedFeatures.features.sparseResidency4Samples) ;
  fsparseResidency8Samples   := GetBoolean( fRequestedFeatures.features.sparseResidency8Samples) ;
  fsparseResidency16Samples   := GetBoolean( fRequestedFeatures.features.sparseResidency16Samples) ;
  fsparseResidencyAliased   := GetBoolean( fRequestedFeatures.features.sparseResidencyAliased) ;
  fvariableMultisampleRate   := GetBoolean( fRequestedFeatures.features.variableMultisampleRate) ;
  finheritedQueries   := GetBoolean( fRequestedFeatures.features.inheritedQueries) ;

//1_1
  fstorageBuffer16BitAccess   := GetBoolean( fRequestedFeatures11.storageBuffer16BitAccess) ;
  funiformAndStorageBuffer16BitAccess   := GetBoolean( fRequestedFeatures11.uniformAndStorageBuffer16BitAccess) ;
  fstoragePushConstant16   := GetBoolean( fRequestedFeatures11.storagePushConstant16) ;
  fstorageInputOutput16   := GetBoolean( fRequestedFeatures11.storageInputOutput16) ;
  fmultiview   := GetBoolean( fRequestedFeatures11.multiview) ;
  fmultiviewGeometryShader   := GetBoolean( fRequestedFeatures11.multiviewGeometryShader) ;
  fmultiviewTessellationShader   := GetBoolean( fRequestedFeatures11.multiviewTessellationShader) ;
  fvariablePointersStorageBuffer   := GetBoolean( fRequestedFeatures11.variablePointersStorageBuffer) ;
  fvariablePointers   := GetBoolean( fRequestedFeatures11.variablePointers) ;
  fprotectedMemory   := GetBoolean( fRequestedFeatures11.protectedMemory) ;
  fsamplerYcbcrConversion   := GetBoolean( fRequestedFeatures11.samplerYcbcrConversion) ;
  fshaderDrawParameters   := GetBoolean( fRequestedFeatures11.shaderDrawParameters) ;

 //1_2
  fsamplerMirrorClampToEdge   := GetBoolean( fRequestedFeatures12.samplerMirrorClampToEdge) ;
  fdrawIndirectCount   := GetBoolean( fRequestedFeatures12.drawIndirectCount) ;
  fstorageBuffer8BitAccess   := GetBoolean( fRequestedFeatures12.storageBuffer8BitAccess) ;
  funiformAndStorageBuffer8BitAccess   := GetBoolean( fRequestedFeatures12.uniformAndStorageBuffer8BitAccess) ;
  fstoragePushConstant8   := GetBoolean( fRequestedFeatures12.storagePushConstant8) ;
  fshaderBufferInt64Atomics   := GetBoolean( fRequestedFeatures12.shaderBufferInt64Atomics) ;
  fshaderSharedInt64Atomics   := GetBoolean( fRequestedFeatures12.shaderSharedInt64Atomics) ;
  fshaderFloat16   := GetBoolean( fRequestedFeatures12.shaderFloat16) ;
  fshaderInt8   := GetBoolean( fRequestedFeatures12.shaderInt8) ;
  fdescriptorIndexing   := GetBoolean( fRequestedFeatures12.descriptorIndexing) ;
  fshaderInputAttachmentArrayDynamicIndexing   := GetBoolean( fRequestedFeatures12.shaderInputAttachmentArrayDynamicIndexing) ;
  fshaderUniformTexelBufferArrayDynamicIndexing   := GetBoolean( fRequestedFeatures12.shaderUniformTexelBufferArrayDynamicIndexing) ;
  fshaderStorageTexelBufferArrayDynamicIndexing   := GetBoolean( fRequestedFeatures12.shaderStorageTexelBufferArrayDynamicIndexing) ;
  fshaderUniformBufferArrayNonUniformIndexing   := GetBoolean( fRequestedFeatures12.shaderUniformBufferArrayNonUniformIndexing) ;
  fshaderSampledImageArrayNonUniformIndexing   := GetBoolean( fRequestedFeatures12.shaderSampledImageArrayNonUniformIndexing) ;
  fshaderStorageBufferArrayNonUniformIndexing   := GetBoolean( fRequestedFeatures12.shaderStorageBufferArrayNonUniformIndexing) ;
  fshaderStorageImageArrayNonUniformIndexing   := GetBoolean( fRequestedFeatures12.shaderStorageImageArrayNonUniformIndexing) ;
  fshaderInputAttachmentArrayNonUniformIndexing   := GetBoolean( fRequestedFeatures12.shaderInputAttachmentArrayNonUniformIndexing) ;
  fshaderUniformTexelBufferArrayNonUniformIndexing   := GetBoolean( fRequestedFeatures12.shaderUniformTexelBufferArrayNonUniformIndexing) ;
  fshaderStorageTexelBufferArrayNonUniformIndexing   := GetBoolean( fRequestedFeatures12.shaderStorageTexelBufferArrayNonUniformIndexing) ;
  fdescriptorBindingUniformBufferUpdateAfterBind   := GetBoolean( fRequestedFeatures12.descriptorBindingUniformBufferUpdateAfterBind) ;
  fdescriptorBindingSampledImageUpdateAfterBind   := GetBoolean( fRequestedFeatures12.descriptorBindingSampledImageUpdateAfterBind) ;
  fdescriptorBindingStorageImageUpdateAfterBind   := GetBoolean( fRequestedFeatures12.descriptorBindingStorageImageUpdateAfterBind) ;
  fdescriptorBindingStorageBufferUpdateAfterBind   := GetBoolean( fRequestedFeatures12.descriptorBindingStorageBufferUpdateAfterBind) ;
  fdescriptorBindingUniformTexelBufferUpdateAfterBind   := GetBoolean( fRequestedFeatures12.descriptorBindingUniformTexelBufferUpdateAfterBind) ;
  fdescriptorBindingStorageTexelBufferUpdateAfterBind   := GetBoolean( fRequestedFeatures12.descriptorBindingStorageTexelBufferUpdateAfterBind) ;
  fdescriptorBindingUpdateUnusedWhilePending   := GetBoolean( fRequestedFeatures12.descriptorBindingUpdateUnusedWhilePending) ;
  fdescriptorBindingPartiallyBound   := GetBoolean( fRequestedFeatures12.descriptorBindingPartiallyBound) ;
  fdescriptorBindingVariableDescriptorCount   := GetBoolean( fRequestedFeatures12.descriptorBindingVariableDescriptorCount) ;
  fruntimeDescriptorArray   := GetBoolean( fRequestedFeatures12.runtimeDescriptorArray) ;
  fsamplerFilterMinmax   := GetBoolean( fRequestedFeatures12.samplerFilterMinmax) ;
  fscalarBlockLayout   := GetBoolean( fRequestedFeatures12.scalarBlockLayout) ;
  fimagelessFramebuffer   := GetBoolean( fRequestedFeatures12.imagelessFramebuffer) ;
  funiformBufferStandardLayout   := GetBoolean( fRequestedFeatures12.uniformBufferStandardLayout) ;
  fshaderSubgroupExtendedTypes   := GetBoolean( fRequestedFeatures12.shaderSubgroupExtendedTypes) ;
  fseparateDepthStencilLayouts   := GetBoolean( fRequestedFeatures12.separateDepthStencilLayouts) ;
  fhostQueryReset   := GetBoolean( fRequestedFeatures12.hostQueryReset) ;
  ftimelineSemaphore   := GetBoolean( fRequestedFeatures12.timelineSemaphore) ;
  fbufferDeviceAddress   := GetBoolean( fRequestedFeatures12.bufferDeviceAddress) ;
  fbufferDeviceAddressCaptureReplay   := GetBoolean( fRequestedFeatures12.bufferDeviceAddressCaptureReplay) ;
  fbufferDeviceAddressMultiDevice   := GetBoolean( fRequestedFeatures12.bufferDeviceAddressMultiDevice) ;
  fvulkanMemoryModel   := GetBoolean( fRequestedFeatures12.vulkanMemoryModel) ;
  fvulkanMemoryModelDeviceScope   := GetBoolean( fRequestedFeatures12.vulkanMemoryModelDeviceScope) ;
  fvulkanMemoryModelAvailabilityVisibilityChains   := GetBoolean( fRequestedFeatures12.vulkanMemoryModelAvailabilityVisibilityChains) ;
  fshaderOutputViewportIndex   := GetBoolean( fRequestedFeatures12.shaderOutputViewportIndex) ;
  fshaderOutputLayer   := GetBoolean( fRequestedFeatures12.shaderOutputLayer) ;
  fsubgroupBroadcastDynamicId   := GetBoolean( fRequestedFeatures12.subgroupBroadcastDynamicId) ;

 //1_3
  frobustImageAccess   := GetBoolean( fRequestedFeatures13.robustImageAccess) ;
  finlineUniformBlock   := GetBoolean( fRequestedFeatures13.inlineUniformBlock) ;
  fdescriptorBindingInlineUniformBlockUpdateAfterBind   := GetBoolean( fRequestedFeatures13.descriptorBindingInlineUniformBlockUpdateAfterBind) ;
  fpipelineCreationCacheControl   := GetBoolean( fRequestedFeatures13.pipelineCreationCacheControl) ;
  fprivateData   := GetBoolean( fRequestedFeatures13.privateData) ;
  fshaderDemoteToHelperInvocation   := GetBoolean( fRequestedFeatures13.shaderDemoteToHelperInvocation) ;
  fsubgroupSizeControl   := GetBoolean( fRequestedFeatures13.subgroupSizeControl) ;
  fcomputeFullSubgroups   := GetBoolean( fRequestedFeatures13.computeFullSubgroups) ;
  fsynchronization2   := GetBoolean( fRequestedFeatures13.synchronization2) ;
  ftextureCompressionASTC_HDR   := GetBoolean( fRequestedFeatures13.textureCompressionASTC_HDR) ;
  fshaderZeroInitializeWorkgroupMemory   := GetBoolean( fRequestedFeatures13.shaderZeroInitializeWorkgroupMemory) ;
  fdynamicRendering   := GetBoolean( fRequestedFeatures13.dynamicRendering) ;
  fshaderIntegerDotProduct  := GetBoolean( fRequestedFeatures13.shaderIntegerDotProduct) ;
  fmaintenance4   := GetBoolean( fRequestedFeatures13.maintenance4) ;


end;

constructor TvgFeatures.Create(AOwner: TComponent);
begin
  inherited;

end;

function TvgFeatures.GetBoolean(aval: TVkBool32): Boolean;
begin
   If aVal=VK_TRUE then
      Result := TRUE
   else
      Result := FALSE;
end;

function TvgFeatures.GetLogicalDevice: TvgLogicalDevice;
begin
  Result := fLogicalDevice;
end;

function TvgFeatures.GetVK32Boolean(aval: Boolean): TVkBool32;
begin
   If aVal then
      Result := VK_TRUE
   else
      Result := VK_FALSE;
end;


procedure TvgFeatures.SetDesigning;
  Var B1,B2,B3  : Boolean;
      Ver : TvkUint32;
begin
  If fActive then exit;

  Assert(assigned(fLogicalDevice),'Logical Device not assigned');
  Assert(assigned(fLogicalDevice.Instance),'Instance not assigned to Logical Device');

  Assert(assigned(fLogicalDevice.PhysicalDevice),'Physical Device not assigned');

  If not fLogicalDevice.Instance.Active then
  Begin
    fLogicalDevice.Instance.SetDesigning;
    B1:=True;
  End else
    B1:=False;
  Assert(assigned(fLogicalDevice.Instance.fVulkanInstance),'Instance not active');

  Assert(assigned(fLogicalDevice.PhysicalDevice),'Physical Device not assigned');
  If not fLogicalDevice.PhysicalDevice.Active then
  Begin
    fLogicalDevice.PhysicalDevice.SetDesigning;
    B2:=True;
  End else
    B2:=False;
  Assert(assigned(fLogicalDevice.PhysicalDevice.fVulkanPhysicalDevice),'Physical Device not active');

  If not fLogicalDevice.Active then
  Begin
    fLogicalDevice.SetDesigning;
    B3:=True;
  End else
    B3:=False;
  Assert(assigned(fLogicalDevice.fVulkanDevice),'Logical Device not active');

  Assert(assigned(fLogicalDevice.Instance.fVulkanInstance.Commands),'Instance commands not available');

  fActive := True;

  FillChar(fRequestedFeatures,SizeOf(fRequestedFeatures),#0);
  FillChar(fRequestedFeatures11,SizeOf(fRequestedFeatures11),#0);
  FillChar(fRequestedFeatures12,SizeOf(fRequestedFeatures12),#0);
  FillChar(fRequestedFeatures13,SizeOf(fRequestedFeatures13),#0);

   UpdateRecordConnections;

 // Ver := fLogicalDevice.Instance.VulkanInstance.APIVersion;    check
   Ver := fLogicalDevice.fPhysicalDevice.VulkanPhysicalDevice.Properties.apiVersion and VK_API_VERSION_WITHOUT_PATCH_MASK;

   if ((Ver {and VK_API_VERSION_WITHOUT_PATCH_MASK})=VK_API_VERSION_1_0) and
      assigned(fLogicalDevice.Instance.fVulkanInstance.Commands.Commands.GetPhysicalDeviceFeatures2KHR) then

       fLogicalDevice.Instance.fVulkanInstance.Commands.GetPhysicalDeviceFeatures2KHR(fLogicalDevice.PhysicalDevice.fVulkanPhysicalDevice.Handle,
                                                                                      @fRequestedFeatures)
   else

       fLogicalDevice.Instance.fVulkanInstance.Commands.GetPhysicalDeviceFeatures2(fLogicalDevice.PhysicalDevice.fVulkanPhysicalDevice.Handle,
                                                                                   @fRequestedFeatures);

  CopyRecordsToData  ;

  If B3 then
    fLogicalDevice.SetActiveState(False);

  If B2 then
    fLogicalDevice.PhysicalDevice.SetActiveState(False);

  If B1 then
    fLogicalDevice.Instance.SetActiveState(False);

end;

procedure TvgFeatures.SetDisabled;
begin
  fActive := False;
end;

procedure TvgFeatures.SetEnabled(aComp: TvgBaseComponent);
Begin
  fActive := True;

  CopyDataToRecords;
  UpdateRecordConnections;
end;

procedure TvgFeatures.SetLogicalDevice(const Value: TvgLogicalDevice);
begin
  If fLogicalDevice = Value then exit;
  SetActiveState(False);
  fLogicalDevice := Value;
end;

procedure TvgFeatures.UpdateRecordConnections;
  var   Ver : TvkUint32;
begin
  fRequestedFeatures.sType :=  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_FEATURES_2;
  fRequestedFeatures.pNext := Nil;

  fRequestedFeatures11.sType :=  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_VULKAN_1_1_FEATURES;
  fRequestedFeatures11.pNext := Nil;

  fRequestedFeatures12.sType :=  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_VULKAN_1_2_FEATURES;
  fRequestedFeatures12.pNext := Nil;

  fRequestedFeatures13.sType :=  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_VULKAN_1_3_FEATURES;
  fRequestedFeatures13.pNext := Nil;

 // Ver := fLogicalDevice.Instance.VulkanInstance.APIVersion;    check
  Ver := fLogicalDevice.fPhysicalDevice.VulkanPhysicalDevice.Properties.apiVersion and VK_API_VERSION_WITHOUT_PATCH_MASK;  //OK

  If (Ver{ and VK_API_VERSION_WITHOUT_PATCH_MASK})>=VK_API_VERSION_1_1 then
    fRequestedFeatures.pNext := @fRequestedFeatures11;

  If (Ver {and VK_API_VERSION_WITHOUT_PATCH_MASK})>=VK_API_VERSION_1_2 then
    fRequestedFeatures11.pNext := @fRequestedFeatures12;

  If (Ver {and VK_API_VERSION_WITHOUT_PATCH_MASK})>=VK_API_VERSION_1_3 then
    fRequestedFeatures12.pNext := @fRequestedFeatures13;

end;

{ TvgDevice }

procedure TvgPhysicalDevice.AddLinker(aLink: TvgLinker);
begin
  If not assigned(aLink) then exit;
  If assigned(aLink.fPhysicalDevice) then exit;

  If fLinkers.IndexOf(aLink)=-1  then
  Begin
   //  SetDisabled;
     fLinkers.Add(aLink);
     FreeNotification(aLink);
     aLink.fPhysicalDevice := Self;   //leave it alone
     If assigned(fInstance) then
        fInstance.RenderToScreen := (fLinkers.Count>0);
  End;

end;

procedure TvgPhysicalDevice.ClearPhysicalDevice;
begin

 //need to claer the Device setting if changing surface details
  fPhysicalDeviceName  := '';
  fPhysicalDeviceScore := 0;
  fSupportSurface      := False;
  fVulkanPhysicalDevice      := Nil;

end;

constructor TvgPhysicalDevice.Create(AOwner: TComponent);

begin
  fLinkers  := TList<TvgLinker>.Create;

  inherited;   //leave here

end;

destructor TvgPhysicalDevice.Destroy;
begin

  if assigned(fLinkers) then
  Begin
    If fLinkers.Count>0 then
       fLinkers.Clear;
    FreeAndNil(fLinkers);
  End;

  SetActiveState(False);

  inherited;
end;

procedure TvgPhysicalDevice.DisableParent(ToRoot:Boolean=False);
begin
  If ToRoot then
  Begin
     If assigned(fInstance) and fInstance.Active then
        fInstance.DisableParent(ToRoot);
  End else
     SetActiveState(False);
end;

function TvgPhysicalDevice.GetActive: Boolean;
begin
 Result:=fActive;
end;

function TvgPhysicalDevice.GetAPIVersion: TvkUint32;
begin
   Result:=0;
   If not assigned(fVulkanPhysicalDevice) then exit;
   Result:= fVulkanPhysicalDevice.Properties.apiVersion;
end;

function TvgPhysicalDevice.GetDeviceIndex: Integer;
begin
  Result:= fDeviceIndex;
end;

function TvgPhysicalDevice.GetDeviceSelect: TvgDeviceSelectMode;
begin
  Result:= self.fDeviceSelect;
end;

function TvgPhysicalDevice.GetInstance: TvgInstance;
begin
  Result:=fInstance  ;
end;

function TvgPhysicalDevice.GetPhysicalDeviceName: String;
begin
  Result:=fPhysicalDeviceName;
end;

procedure TvgPhysicalDevice.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);

  Case Operation of
     opInsert : Begin
                  If aComponent=self then exit;
                  If NotificationTestON and Not (csDesigning in ComponentState) then exit ;      //don't mess with links at runtime

                  If (aComponent is TvgInstance) and not assigned(fInstance)  then
                  Begin
                     SetActiveState(False);
                     TvgInstance(aComponent).AddDevice(self);
                  End;

                  If (aComponent is TvgLinker) and not assigned(TvgLinker(aComponent).fPhysicalDevice) then
                  Begin
                   // SetDisabled;
                    TvgLinker(aComponent).Device := Self;
                  End;

                End;

     opRemove : Begin
                  If (aComponent is TvgInstance) and (TvgInstance(aComponent)=fInstance)  then
                  Begin
                    SetActiveState(False);
                    ClearPhysicalDevice;
                    fInstance:=Nil;
                  End;

                  If (aComponent is TvgLinker) and (TvgLinker(aComponent).fPhysicalDevice=self) then
                  Begin
                    RemoveLinker(TvgLinker(aComponent));
                  End;

               end;
  End;
end;

procedure TvgPhysicalDevice.ReadActiveStatus(Reader: TReader);
begin
  fActive:=Reader.ReadBoolean;
end;

procedure TvgPhysicalDevice.ReadDeviceValues(Reader: TReader);
begin

end;

procedure TvgPhysicalDevice.RemoveLinker(aLink: TvgLinker);
begin
  If not assigned(aLink) then exit;

  If aLink.fPhysicalDevice=Self then
  Begin
    RemoveFreeNotification(aLink);
    If assigned(fLinkers) then fLinkers.Remove(aLink);
    aLink.fPhysicalDevice := nil;
  End;
end;

function TvgPhysicalDevice.RenderToScreen: Boolean;
begin
  Result:=False;
  If not assigned(fLinkers) then exit;
  If fLinkers.Count>0 then
     Result := True;
end;

procedure TvgPhysicalDevice.SelectBestPhysicalDevice;
  var
    P,BestP:TpvVulkanPhysicalDevice;
    aSupportSurface:Boolean;
    aScore,BestScore:TvkUint64;
    aGraphicBit,aComputeBit,aTransferBit,aSparseBit:Boolean;
 //   I:Integer;
   // aSurface : TpvVulkanSurface;

         Function IsPhysicalDeviceOK:Boolean;
         Begin
           If RenderToScreen then
             Result := aSupportSurface
           else
             Result := True;
         End;

         Procedure AutomaticSelect;
           Var I,BestI:Integer;
         Begin
              aSupportSurface := RenderToScreen;
              BestP    := Nil;
              aScore   := 0;
              BestScore:= 0;
              BestI    := 0;

              If fInstance.PhysicalDevices.Count>1 then
              Begin
                  For I:=0 to fInstance.PhysicalDevices.Count-1 do
                  Begin
                    P:=  TvgPhysDevice(fInstance.PhysicalDevices.Items[I]).VulkanPhysicalDevice;
                    If assigned(P) then
                    Begin
                      RankPhysicalDevice(P,Nil, aSupportSurface, aScore, aGraphicBit, aComputeBit, aTransferBit, aSparseBit);

                      If IsPhysicalDeviceOK and (aScore> BestScore) then
                       Begin
                         BestScore := aScore;
                         BestI     := I;
                         BestP     := P;
                       end;
                    End;
                  End;
              End else
              Begin
                P:=  TvgPhysDevice(fInstance.PhysicalDevices.Items[0]).VulkanPhysicalDevice;

                RankPhysicalDevice(P,Nil, aSupportSurface, aScore, aGraphicBit, aComputeBit, aTransferBit, aSparseBit);
                If IsPhysicalDeviceOK then
                  BestP:=P;
              End;

              Assert(Assigned(BestP), 'Suitable Physical Device not found.');

              fVulkanPhysicalDevice     := BestP;
              fPhysicalDeviceName := String(fVulkanPhysicalDevice.DeviceName);
              fDeviceIndex        := BestI;
         End;

         Procedure NameSelect;
           Var I:Integer;
         Begin
            BestP    := Nil;

            If fPhysicalDeviceName=''  then
            Begin
              AutomaticSelect;
              Exit;
            End;

            For I:=0 to fInstance.PhysicalDevices.Count-1 do
            Begin
              P:=  TvgPhysDevice(fInstance.PhysicalDevices.Items[I]).VulkanPhysicalDevice;

              If assigned(P) and (CompareText(String(P.DeviceName),String(fPhysicalDeviceName))=0) then
              Begin
                BestP     := P;
                Break;
              End;
            End;

            If assigned(BestP) then
            Begin
              fVulkanPhysicalDevice     := BestP;
              fDeviceIndex        := I;
            end else
              AutomaticSelect;
         End;

         Procedure IndexSelect;
         Begin
            BestP    := Nil;
            Assert(((fDeviceIndex>=0) and
                    (fDeviceIndex<fInstance.PhysicalDevices.Count)), 'Required Physical Device Index not valid.' );

            BestP    := TvgPhysDevice(fInstance.PhysicalDevices.Items[fDeviceIndex]).VulkanPhysicalDevice;

            If assigned(BestP) then
            Begin
              fVulkanPhysicalDevice     := BestP;
              fPhysicalDeviceName := String(BestP.DeviceName);
            end else
              AutomaticSelect;
         end;

         Procedure DiscreteSelect;
           Var I:Integer;
         Begin
              BestP    := Nil;
              I        := 0;

              If fInstance.PhysicalDevices.Count>1 then
              Begin
                  For I:=0 to fInstance.PhysicalDevices.Count-1 do
                  Begin
                    P := TvgPhysDevice(fInstance.PhysicalDevices.Items[I]).VulkanPhysicalDevice;
                    If assigned(P) and
                     (TvgPhysDevice(fInstance.PhysicalDevices.Items[I]).fDeviceType=VK_PHYSICAL_DEVICE_TYPE_DISCRETE_GPU) then
                    Begin
                      BestP := P;
                      Break;
                    End;
                  End;
              End;

            If assigned(BestP) then
            Begin
                fVulkanPhysicalDevice     := BestP  ;
                fPhysicalDeviceName := String(fVulkanPhysicalDevice.DeviceName);
                fDeviceIndex        := I;
            end else
              AutomaticSelect;
         End;

  // Var B:Boolean;
begin

  fVulkanPhysicalDevice:=nil;
  ClearPhysicalDevice;

  Assert(assigned(fInstance) , 'Instance not selected.');
  Assert(assigned(fInstance.VulkanInstance) , 'Vulkan Instance not available.');
  Assert(fInstance.PhysicalDevices.Count>0 , 'There are no Vulkan Physivcal Devices.');


  Case fDeviceSelect of
    vgdsAutomatic : AutomaticSelect;   //highest score
         vgdsName : NameSelect;        //specified by Name
        vgdsIndex : IndexSelect;       //specified by Index
     vgdsDiscrete : DiscreteSelect;    //First discrete GPU
  end;

end;

procedure TvgPhysicalDevice.SetDesigning;
  Var B:Boolean;
begin
  fActive:=False;

  Assert(assigned(fInstance) , 'Vulkan Instance not connected.');

  If not Assigned(fInstance.VulkanInstance) then
  Begin
     fInstance.SetDesigning;
     B:=True;
  End else
     B:=False;

  Assert(Assigned(fInstance.VulkanInstance) , 'Unable to create Instance');

  SelectBestPhysicalDevice;

  If B then
    fInstance.SetActiveState(False);

  Assert(assigned(fVulkanPhysicalDevice) , 'Physical Vulkan Device not found.');

 Try

  If Assigned(fVulkanPhysicalDevice) then
    fActive := True;    //must stay here

 Except
    On E:Exception do
    Begin
    //  If B then
     //   fTempSurface.SetDisabled;
      Raise;
    End;
 End
end;

procedure TvgPhysicalDevice.SetDeviceIndex(const Value: Integer);
begin
  If fDeviceIndex=Value then exit;
  SetActiveState(False);

  fDeviceIndex:=Value;

end;

procedure TvgPhysicalDevice.SetDeviceSelect(const Value: TvgDeviceSelectMode);
begin
  If fDeviceSelect=Value then exit;

  fDeviceSelect := Value;

  SetActiveState(False);
end;

procedure TvgPhysicalDevice.SetActive(const Value: Boolean);
begin
   If fActive=Value then exit;
   SetActiveState(Value);
end;

procedure TvgPhysicalDevice.SetDisabled;
  Var I:Integer;

begin
  fActive:=False;

  If assigned(fLinkers) and (fLinkers.Count>0) then
    For I:=0 to fLinkers.count-1 do
    Begin
      If fLinkers.Items[I].Active then
         fLinkers.Items[I].Active:=False;
    End;

  ClearPhysicalDevice ;

  fActive :=  fVulkanPhysicalDevice<>Nil;

end;

procedure TvgPhysicalDevice.SetEnabled(aComp:TvgBaseComponent=nil);
  Var I:Integer;
     // B:Boolean;
begin

  fActive:=False;

  Assert(assigned(fInstance) , 'Vulkan Graphics Instance not connected.');

  If not fInstance.Active then
  Begin
    fInstance.SetEnabled(self);
    Exit;
  end;
  Assert(Assigned(fInstance.VulkanInstance) , 'Unable to create Vulkan Graphics Instance.');

  SelectBestPhysicalDevice;

  Assert(assigned(fVulkanPhysicalDevice)  ,   'Physical Vulkan Device not found.'  );

  fActive :=  fVulkanPhysicalDevice<>Nil;

  If (csDesigning in ComponentState) and not fActive then
     raise EpvVulkanException.Create('Vulkan Device creation failed.');

  if assigned(aComp) and (aComp is TvgLinker) then
     TvgLinker(aComp).SetEnabled
  else
    If assigned(fLinkers) and (fLinkers.Count>0) then
      For I:=0 to fLinkers.count-1 do
      Begin
        If Not fLinkers.Items[I].Active then
           fLinkers.Items[I].Active := True;
      End;
end;

procedure TvgPhysicalDevice.SetInstance(const Value: TvgInstance);
begin
  if fInstance=Value then exit;

  SetActiveState(False);
  If assigned(fInstance) then
  Begin
     fInstance.RemoveDevice(self);
     fInstance := Nil; //important
  end;

  if assigned(Value) then
    Value.AddDevice(self);

  If assigned(fInstance) then
      fInstance.RenderToScreen := (fLinkers.Count>0);
end;

procedure TvgPhysicalDevice.setPhysicalDeviceName(const Value: String);
begin

  If CompareStr(Value, fPhysicalDeviceName)=0 then exit;
  SetActiveState(False);
  fPhysicalDeviceName := Value;
end;

procedure TvgPhysicalDevice.WriteActiveStatus(Writer: TWriter);
begin
  Writer.WriteBoolean(fActive);
end;

procedure TvgPhysicalDevice.WriteDeviceValues(Writer: TWriter);
begin
end;

{ TvgDevice }

procedure TvgLogicalDevice.BuildALLExtensions;
  Var I:Integer;
      B1,B2:Boolean;
begin

  B1:=False;
  B2:=False;
 Try
   Assert(assigned(fInstance) ,'Instance not assigned to Device.');

  If not assigned(fInstance.VulkanInstance) then
  Begin
     fInstance.SetDesigning;
     B1:= (fInstance.VulkanInstance<>Nil);
  End;

  Assert(assigned(fInstance.VulkanInstance) , 'Vulkan Instance creation failed.');

  Assert(assigned(fPhysicalDevice) , 'Physical Device not assigned.');
  If not  fPhysicalDevice.Active then
  Begin
    fPhysicalDevice.SetDesigning;
    B2:= fPhysicalDevice.VulkanPhysicalDevice<>nil;
  End;

  If fPhysicalDevice.VulkanPhysicalDevice.AvailableExtensionNames.Count>0 then
  Begin
    For I:=0 to fPhysicalDevice.VulkanPhysicalDevice.AvailableExtensionNames.Count-1 do
        BuildExtension(@fPhysicalDevice.VulkanPhysicalDevice.AvailableExtensions[I]);
  End;

  If B2 then
     fPhysicalDevice.SetActiveState(False);

  If B1 then
     fInstance.SetActiveState(False);

 Except
   On E:Exception do
   Begin
      If B2 then
         SetActiveState(False);

      If B1 then
         fInstance.SetActiveState(False);

      Raise;
   End;

 End;
end;

procedure TvgLogicalDevice.BuildAllFeatures;
  Var //I:Integer;
      B1,B2:Boolean;
begin

  Assert(assigned(fFeatures) ,'Features not created.');

  B1:=False;
  B2:=False;
 Try
   Assert(assigned(fInstance) ,'Instance not assigned to Device.');

  If not assigned(fInstance.VulkanInstance) then
  Begin
     fInstance.SetDesigning;
     B1:= (fInstance.VulkanInstance<>Nil);
  End;

  Assert(assigned(fInstance.VulkanInstance) , 'Vulkan Instance creation failed.');

  Assert(assigned(fPhysicalDevice) , 'Physical Device not assigned.');
  If not  fPhysicalDevice.Active then
  Begin
    fPhysicalDevice.SetDesigning;
    B2:= fPhysicalDevice.VulkanPhysicalDevice<>nil;
  End;

  fFeatures.fRequestedFeatures.features := fPhysicalDevice.VulkanPhysicalDevice.Features;
  fFeatures.fRequestedFeatures11        := fPhysicalDevice.VulkanPhysicalDevice.Vulkan11Features;
  fFeatures.fRequestedFeatures12        := fPhysicalDevice.VulkanPhysicalDevice.Vulkan12Features;
  fFeatures.fRequestedFeatures13        := fPhysicalDevice.VulkanPhysicalDevice.Vulkan13Features;

  If B2 then
     fPhysicalDevice.SetActiveState(False);

  If B1 then
     fInstance.SetActiveState(False);

 Except
   On E:Exception do
   Begin
      If B2 then
         SetActiveState(False);

      If B1 then
         fInstance.SetActiveState(False);

      Raise;
   End;

 End;
end;

procedure TvgLogicalDevice.BuildALLLayers;
  Var I:Integer;
      B1,B2:Boolean;
begin

  B1:=False;
  B2:=False;
 Try
   Assert(assigned(fInstance) ,'Instance not assigned to Device.');

  If not assigned(fInstance.VulkanInstance) then
  Begin
     fInstance.SetDesigning;
     B1:= (fInstance.VulkanInstance<>Nil);
  End;

  Assert(assigned(fInstance.VulkanInstance) , 'Vulkan Instance creation failed.');

  Assert(assigned(fPhysicalDevice) , 'Physical Device not assigned.');
  If not  fPhysicalDevice.Active then
  Begin
    fPhysicalDevice.SetDesigning;
    B2:= fPhysicalDevice.VulkanPhysicalDevice<>nil;
  End;

  If fPhysicalDevice.VulkanPhysicalDevice.AvailableLayerNames.Count>0 then
  Begin
    For I:=0 to fPhysicalDevice.VulkanPhysicalDevice.AvailableLayerNames.Count-1 do
        BuildLayer(@fPhysicalDevice.VulkanPhysicalDevice.AvailableLayers[I]);
  End;

  If B2 then
     fPhysicalDevice.SetActiveState(False);

  If B1 then
     fInstance.SetActiveState(False);

 Except
   On E:Exception do
   Begin
      If B2 then
         SetActiveState(False);

      If B1 then
         fInstance.SetActiveState(False);

      Raise;
   End;

 End;
end;

function TvgLogicalDevice.BuildExtension( aExt: PpvVulkanAvailableExtension): TvgExtension;
  Var S1:String;
begin
  Result:=nil;

  //check if layer exists then return instance
  If DoesExtensionExist(aExt) then exit;

  //build extension
  Result:= TvgExtension(fExtensions.Add);
  Result.SetData(aExt);
  Result.fvgOwner:=Self;

  If assigned(fInstance) and fInstance.Validation then
  Begin
    S1 := VK_EXT_DEBUG_MARKER_EXTENSION_NAME;
    If CompareText(S1, String(aExt.ExtensionName)) = 0 then
       Result.fExtMode:= VGE_MUST_HAVE;
  End;
end;

function TvgLogicalDevice.BuildLayer(aLayer: ppvVulkanAvailableLayer): TvgLayer;
begin
  Result:=Nil;

  //check if layer exists then return instance
  If DoesLayerExist(aLayer) then exit;

  //build layer
  Result:= TvgLayer(fLayers.Add);
  Result.SetData(aLayer);
  Result.fvgOwner:=Self;
end;

constructor TvgLogicalDevice.Create(AOwner: TComponent);
begin
  fUniversalQueue:=  TvgQueueFamily.Create;
  fPresentQueue  :=  TvgQueueFamily.Create;
  fGraphicsQueue :=  TvgQueueFamily.Create;
  fComputeQueue  :=  TvgQueueFamily.Create;
  fTransferQueue :=  TvgQueueFamily.Create;

  fLayers        := TvgLayers.Create(self);
  fExtensions    := TvgExtensions.Create(self);

  fFeatures      := TvgFeatures.Create(self);
  fFeatures.SetSubComponent(True);
  fFeatures.Name:= 'FR';
  FreeNotification(fFeatures);
  fFeatures.LogicalDevice := Self;

  inherited;

end;

destructor TvgLogicalDevice.Destroy;
begin
  SetActiveState(False);

  If assigned(fLayers) then FreeAndNil(fLayers);
  If assigned(fExtensions) then FreeAndNil(fExtensions);
  If assigned(fFeatures) then
  Begin
    fFeatures.LogicalDevice := nil;
    FreeAndNil(fFeatures);
  End;

  If assigned(fUniversalQueue) then FreeAndNil(fUniversalQueue);
  If assigned(fPresentQueue)   then FreeAndNil(fPresentQueue);
  If assigned(fGraphicsQueue)  then FreeAndNil(fGraphicsQueue);
  If assigned(fComputeQueue)   then FreeAndNil(fComputeQueue);
  If assigned(fTransferQueue)  then FreeAndNil(fTransferQueue);
  inherited;
end;

function TvgLogicalDevice.DoesExtensionExist( aExt: PpvVulkanAvailableExtension): Boolean;
  Var I:Integer;
      E:TvgExtension;
begin
  Result:=False;
  If fExtensions.Count=0 then exit;

  For I:=0 to fExtensions.count-1 do
  Begin
    E:=TvgExtension(fExtensions.Items[I]);
    If (AnsiCompareStr(String(E.fExtensionName),String(aExt.ExtensionName)) = 0) then
    Begin
      Result:=True;
      Break;
    End;
  End;
end;

function TvgLogicalDevice.DoesLayerExist(aLayer: ppvVulkanAvailableLayer): Boolean;
  Var I:Integer;
      L:TvgLayer;
begin
  Result:=False;
  If fLayers.Count=0 then exit;

  For I:=0 to fLayers.count-1 do
  Begin
    L:=TvgLayer(fLayers.Items[I]);
    If (AnsiCompareStr(String(L.fLayerName),String(aLayer.LayerName)) = 0) then
    Begin
      Result:=True;
      Break;
    End;
  End;
end;

function TvgLogicalDevice.GetActive: Boolean;
begin
 Result:=fActive;
end;

function TvgLogicalDevice.GetFeatures: TvgFeatures;
begin
  Result := fFeatures;
end;

function TvgLogicalDevice.GetInstance: TvgInstance;
begin
  Result:=fInstance;
end;

function TvgLogicalDevice.GetPhysicalDevice: TvgPhysicalDevice;
begin
  Result:= fPhysicalDevice;
end;

function TvgLogicalDevice.GetQueueFamilyCount: Integer;
begin
  Result:=0;

  If Assigned(fPhysicalDevice) and assigned(fPhysicalDevice.VulkanPhysicalDevice) then
     Result:= Length(fPhysicalDevice.VulkanPhysicalDevice.QueueFamilyProperties);
end;

procedure TvgLogicalDevice.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited;

end;

procedure TvgLogicalDevice.OnDeviceCreateEvent(const aDevice: TpvVulkanDevice;  const aDeviceCreateInfo: PVkDeviceCreateInfo);
begin

    If assigned(fFeatures) then
    Begin
      fFeatures.SetEnabled;  //update data to records

      aDeviceCreateInfo^.pNext            := @fFeatures.fRequestedFeatures;
      aDeviceCreateInfo^.pEnabledFeatures := Nil;
    end;

end;

procedure TvgLogicalDevice.RemoveALLExtensions;
begin
  If fExtensions.count=0 then exit;
  fExtensions.Clear;
end;

procedure TvgLogicalDevice.RemoveALLLayers;
begin
  If fLayers.count=0 then exit;
  fLayers.Clear;
end;

procedure TvgLogicalDevice.SetActive(const Value: Boolean);
begin
  If fActive=Value then exit;
  SetActiveState(Value);

end;

procedure TvgLogicalDevice.SetDesigning;
begin
  Assert(assigned(fPhysicalDevice),'Physical Device not connected');
  Assert(assigned(fPhysicalDevice.VulkanPhysicalDevice),'Physical Device not Active');
  Assert(assigned(fInstance),'Instance not connected');
  Assert(assigned(fInstance.VulkanInstance),'Instance not Active');

  fVulkanDevice       := TpvVulkanDevice.create(fPhysicalDevice.Instance.VulkanInstance,
                                                fPhysicalDevice.VulkanPhysicalDevice,
                                                nil,
                                                fPhysicalDevice.Instance.AllocationManager,
                                                True)  ;
end;

procedure TvgLogicalDevice.SetDisabled;
begin
  If assigned(fFeatures) then
    fFeatures.SetActiveState(False);

  If assigned(fVulkanDevice) then
     FreeAndNil(fVulkanDevice);


end;

procedure TvgLogicalDevice.SetEnabled(aComp:TvgBaseComponent=nil);
begin
  fActive:=False;
  Assert(assigned(fPhysicalDevice),'Physical Device not connected');
  If not assigned(fPhysicalDevice.VulkanPhysicalDevice) then
  Begin
    fPhysicalDevice.SetEnabled(Self);
    Exit;
  End;

  Assert(assigned(fInstance),'Instance not connected');
  Assert(assigned(fInstance.VulkanInstance),'Instance not Active');


  fVulkanDevice       := TpvVulkanDevice.create(fPhysicalDevice.Instance.VulkanInstance,
                                                fPhysicalDevice.VulkanPhysicalDevice,
                                                Nil,
                                                fPhysicalDevice.Instance.AllocationManager,
                                                True)  ;

  If Assigned(fVulkanDevice) then
  Begin
    fVulkanDevice.OnBeforeDeviceCreate := OnDeviceCreateEvent; //setup features during initialization

    SetUpExtensions;
    SetUpLayers;

    fVulkanDevice.AddQueues(Nil);     //need to check  seems OK

    fVulkanDevice.Initialize;

    SetUpQueueFamilies;

    fActive := True;    //must stay here
  end;


end;

procedure TvgLogicalDevice.SetInstance(const Value: TvgInstance);
begin
  If fInstance = Value then exit;
  SetActiveState(False);
  fInstance:=Value;
end;

procedure TvgLogicalDevice.SetPhysicalDevice(const Value: TvgPhysicalDevice);
begin
  If fPhysicalDevice = Value then exit;
  SetActiveState(False);
  fPhysicalDevice:=Value;

  If assigned(fPhysicalDevice) then
     SetUpFeatures;
end;

procedure TvgLogicalDevice.SetUpExtensions;
  Var I:Integer;
      E:TvgExtension;
      B:Boolean;
      ES:String;

   Function IsExtensionAvailable(aExt : TvgExtension):Boolean;
     Var J:Integer;
         S1:String;
         AE: TpvVulkanAvailableExtension;
   Begin
     Result:=False;

     If not assigned(fPhysicalDevice) then exit;
     S1:=Trim(String(aExt.fExtensionName));
     J := fPhysicalDevice.VulkanPhysicalDevice.AvailableExtensionNames.IndexOf(S1);
     If J=-1 then exit;
     AE:=fPhysicalDevice.VulkanPhysicalDevice.AvailableExtensions[J];
     Result:= (aExt.fSpecVersion <= AE.SpecVersion);
   End;

   Procedure DeleteNotRequired;
     Var J:Integer;
         EI:TvgExtension;
   Begin
     If (csDesigning in ComponentState) then exit;

     For J:=fExtensions.Count-1 downto 0 do
     Begin
       EI:= TvgExtension(fExtensions.Items[J]);
       If EI.fExtMode=VGE_NOT_REQUIRED then
          fExtensions.Delete(J);
     End;
   End;

   Var BI:Boolean;
begin
   if not assigned(fInstance) or not assigned(fInstance.VulkanInstance) then exit;

   If not assigned(fExtensions) then  exit;

   If not assigned(fPhysicalDevice) then
   Begin
     SetDesigning;
     BI:=True;
   end else
     BI:=False;

   If not assigned( fPhysicalDevice) then
   Begin
     raise EvgVulkanException.Create('Vulkan Physical Device not available');
   end;

   If not assigned(fVulkanDevice) then
     raise EvgVulkanException.Create('Vulkan Device not available');

   DeleteNotRequired;       //delete not required design time layers
   BuildALLExtensions;      //build any new extensions in current hardware/platform


   If assigned(fOnExtensionSetup) then
      fOnExtensionSetup(fExtensions);    //run time can update required extensions available on current hardware

  //MUST stay here
//   If RenderToScreen then
//      BuildALLExtensions;   //build again in case render to screen layers not included

//   SetUpScreenExtensions;  //Must stay here will handle RenderToScreen and NOT RenderToScreen

   DeleteNotRequired;    //tidy up before creating the instance

   For I:=0 to fExtensions.count-1 do
   Begin
     E:= TvgExtension(fExtensions.Items[I]);
     e.fEnabled := False;
     If (E.fExtMode=VGE_NOT_REQUIRED) then  continue;

     B:= IsExtensionAvailable(E)  ;

     Case E.fExtMode of
       //  vglNotRequired:;  //do not need to initialize default
          VGE_MUST_HAVE  :Begin
                          if Not B then
                          Begin
                             ES:= Format('%s (%s) %s',['Must have instance extension (', String(E.ExtensionName), ') NOT available on this hardware.']);
                             raise EvgVulkanResultException.Create(VK_ERROR_EXTENSION_NOT_PRESENT, ES);
                          end else
                          Begin
                             fVulkanDevice.EnabledExtensionNames.Add(String(E.ExtensionName));
                             E.fEnabled:=True;
                          end;
                        end;     //Instance initialization MUST have this layer
          VGE_OPTIONAL  :If B then
                        Begin
                          fVulkanDevice.EnabledExtensionNames.Add(String(E.ExtensionName));     //Instance may have the layer
                          E.fEnabled:=True;
                        end;
        VGE_ON_VALIDATION:If B and fInstance.Validation then
                        Begin
                          fVulkanDevice.EnabledLayerNames.Add(String(E.ExtensionName));
                          E.fEnabled:=True;
                        end;

     end;
   End;

   If BI then SetActiveState(False);

end;

procedure TvgLogicalDevice.SetUpFeatures;
 // Var B1:Boolean;
begin
  // If not assigned(self.)
 (*
   if not assigned(fVulkanDevice) then
   Begin
      SetDesigning;
      B1:=True
   end else
      B1:=False;

  If assigned(fFeatures) and NOT (fFeatures.setLocked) and
     assigned(fPhysicalDevice) and assigned(fPhysicalDevice.fPhysicalDevice) and (fPhysicalDevice.fPhysicalDevice.Handle <> VK_NULL_HANDLE) then
     fFeatures.fRequestedFeatures := fPhysicalDevice.fPhysicalDevice.Features;      //set TRUE for and available features

  if B1 then
     SetActiveState(False);
  *)
end;

procedure TvgLogicalDevice.SetUpLayers;
  Var I:Integer;
      L:TvgLayer;
      B,B1:Boolean;
      ES:String;

   Procedure DeleteNotRequired;
     Var J:Integer;
         LI:TvgLayer;
   Begin
     If (csDesigning in ComponentState) then exit;

     For J:=fLayers.Count-1 downto 0 do
     Begin
       LI:= TvgLayer(fLayers.Items[J]);
       If LI.fLayerMode=VGL_NOT_REQUIRED then
          fLayers.Delete(J);
     End;
   End;

   Function IsLayerAvailable(aLayer:TvgLayer):Boolean;
     Var J:Integer;
         S1:String;
         AL: TpvVulkanAvailableLayer;
   Begin
     Result:=False;
     If not assigned(fPhysicalDevice) then exit;
     S1:=Trim(String(aLayer.fLayerName));
     J := fPhysicalDevice.VulkanPhysicalDevice.AvailableLayerNames.IndexOf(S1);
     If J=-1 then exit;
   //  Result:=True;
     AL:=fPhysicalDevice.VulkanPhysicalDevice.AvailableLayers[J];
     Result:= (aLayer.fSpecVersion <= AL.SpecVersion ) ;
   End;

begin
   If not assigned(fLayers) or (fLayers.Count=0) then exit;

   if not assigned(fVulkanDevice) then
   Begin
      SetDesigning;
      B1:=True
   end else
      B1:=False;

   If NOT (csDesigning in ComponentState) then
   Begin
     DeleteNotRequired;
     BuildALLLayers;   //build layers for run time hardware
   end;

   If assigned(fOnLayerSetup) then
      fOnLayerSetup(fLayers);

   DeleteNotRequired;

   For I:=0 to fLayers.count-1 do
   Begin
     L:= TvgLayer(fLayers.Items[I]);
     L.fEnabled:=False;

     If (L.fLayerMode=VGL_NOT_REQUIRED) then  continue;

     B:= IsLayerAvailable(L)  ;

     Case L.fLayerMode of
       //  VGL_NOT_REQUIRED:;  //do not need to initialize default
          VGL_MUST_HAVE  :Begin
                          if Not B then
                          Begin
                             ES:= Format('%s (%s) %s',['Must have instance layer (', String(L.fLayerName), ') NOT available on this hardware.']);
                             raise EvgVulkanResultException.Create(VK_ERROR_EXTENSION_NOT_PRESENT, ES);
                          end else
                          Begin
                             fVulkanDevice.EnabledLayerNames.Add(String(L.LayerName));
                             L.fEnabled:=True;
                          end;
                        end;     //Instance initialization MUST have this layer
          VGL_OPTIONAL  :If B then Begin
                                    fVulkanDevice.EnabledLayerNames.Add(String(L.LayerName));
                                    L.fEnabled:=True;    //Instance may have the layer
                                  end;
        VGL_ON_VALIDATION:If B and fInstance.Validation then
                                  Begin
                                    fVulkanDevice.EnabledLayerNames.Add(String(L.LayerName));
                                    L.fEnabled:=True;
                                  end;

     end;
   End;

   If B1 then
     SetActiveState(False);

end;

procedure TvgLogicalDevice.SetUpQueueFamilies;
  Procedure SetUpFamily(aIndex:TvkInt32; aQueueFamily:TvgQueueFamily);
  Begin
    If aIndex< High(TvkInt32)  then
    Begin
      aQueueFamily.SetData(aIndex , @fPhysicalDevice.VulkanPhysicalDevice.QueueFamilyProperties[aIndex]) ;
    //  fSupportSurface := fPhysicalDevice.VulkanPhysicalDevice.GetSurfaceSupport(aIndex, self.f
    end else
      aQueueFamily.clear;
  End;
begin
  If not assigned(self.fVulkanDevice) then exit;

  SetUpFamily(fVulkanDevice.UniversalQueueFamilyIndex  ,fUniversalQueue);
  SetUpFamily(fVulkanDevice.PresentQueueFamilyIndex    ,fPresentQueue);
  SetUpFamily(fVulkanDevice.GraphicsQueueFamilyIndex   ,fGraphicsQueue);
  SetUpFamily(fVulkanDevice.ComputeQueueFamilyIndex    ,fComputeQueue);
  SetUpFamily(fVulkanDevice.TransferQueueFamilyIndex   ,fTransferQueue);

end;

procedure TvgLogicalDevice.WaitIdle;
begin

end;

{ TvgSurface }

constructor TvgSurface.Create(AOwner: TComponent);
begin
  inherited;

  fVulkanSurface:=Nil;

  FillChar(fVkSurfaceCapabilitiesKHR,SizeOf(fVkSurfaceCapabilitiesKHR),#0);

end;

destructor TvgSurface.Destroy;
begin

  SetActiveState(False);

  If assigned(fWindowIntf)  then
     fWindowIntf:=nil;

  inherited;
end;

function TvgSurface.GetSurface: TpvVulkanSurface;
begin
   Result := fVulkanSurface  ;
end;

procedure TvgSurface.GetSurfaceCapabilities;
 Var  B:Boolean;
      E:TVKResult;
      VKCommands : TVulkan;
      I:TvkUint32 ;
begin
  Assert(assigned(fPhysicalDevice)  , 'Device not connected');
  Assert(assigned(fPhysicalDevice.VulkanPhysicalDevice)  , 'Vulkan Physical Device not assigned');

//  Assert(assigned(fPhysicalDevice.fInstance)  , 'Instance not assigned to Device');
//  Assert(assigned(fPhysicalDevice.fInstance.VulkanInstance), 'Vulkan Instance not created');

  If not fActive then
  Begin
    SetDesigning;
    B:=True  ;
  End else
    B:=False;

  Assert(assigned(VulkanSurface) , ' Vulkan Surface not created');

  VKCommands := fPhysicalDevice.fInstance.VulkanInstance.Commands;

  Try
   FillChar(fVkSurfaceCapabilitiesKHR,SizeOf(fVkSurfaceCapabilitiesKHR),#0);

   E:=VKCommands.GetPhysicalDeviceSurfaceCapabilitiesKHR(fPhysicalDevice.VulkanPhysicalDevice.Handle,
                                                         VulkanSurface.Handle,
                                                         @fVkSurfaceCapabilitiesKHR);
   If E<>VK_SUCCESS then raise EvgVulkanResultException.Create(E, 'Unable to retrieve Vulkan Surface capabilities.');

   E:=VKCommands.GetPhysicalDeviceSurfaceFormatsKHR(fPhysicalDevice.VulkanPhysicalDevice.Handle,VulkanSurface.Handle,@I,nil);
   If E<>VK_SUCCESS then raise EvgVulkanResultException.Create(E, 'Unable to retrieve Vulkan Surface Format Count #1.');
   SetLength(fVkSurfaceFormatKHRs,I);
   E:=VKCommands.GetPhysicalDeviceSurfaceFormatsKHR(fPhysicalDevice.VulkanPhysicalDevice.Handle,VulkanSurface.Handle,@I,@fVkSurfaceFormatKHRs[0]);
   If E<>VK_SUCCESS then raise EvgVulkanResultException.Create(E, 'Unable to retrieve Vulkan Surface Format capabilities #2.');


   E:=VKCommands.GetPhysicalDeviceSurfacePresentModesKHR(fPhysicalDevice.VulkanPhysicalDevice.Handle,VulkanSurface.Handle,@I,nil);
   If E<>VK_SUCCESS then raise EvgVulkanResultException.Create(E, 'Unable to retrieve Vulkan Surface Presentation Modes Count #1.');
   SetLength(fvkPresentModeKHRs,I);
   E:=VKCommands.GetPhysicalDeviceSurfacePresentModesKHR(fPhysicalDevice.VulkanPhysicalDevice.Handle,VulkanSurface.Handle,@I,@fvkPresentModeKHRs[0]);
   If E<>VK_SUCCESS then raise EvgVulkanResultException.Create(E, 'Unable to retrieve Vulkan Surface Presentation capabilities #2.');

   If B then SetActiveState(False);

  Except
      On E:Exception do
      Begin
        If B then SetActiveState(False);
        Raise;
      End;
  End;

end;

function TvgSurface.GetSurfaceSupport(aQueueIndex:Integer): Boolean;
  Var QueIndex:TvkUint32;
begin
  Result:=False;
  If not assigned(fPhysicalDevice) then exit;
  If not assigned(fPhysicalDevice.VulkanPhysicalDevice) then exit;
  If not assigned(fVulkanSurface) then exit;

  QueIndex := aQueueIndex;

  Result := fPhysicalDevice.VulkanPhysicalDevice.GetSurfaceSupport(QueIndex, fVulkanSurface) ;
end;

function TvgSurface.GetTransform: TVkSurfaceTransformFlagBitsKHR;
begin
    Result:=   fVkSurfaceCapabilitiesKHR.currentTransform;
end;

function TvgSurface.GetWindowIntf: IvgVulkanWindow;
begin
  Result:= fWindowIntf;
end;

function TvgSurface.GetWindowSize(var aWidth, aHeight: TvkUint32): Boolean;
begin
  Result:=False;
  aWidth  :=0;
  aHeight :=0;
  If not assigned(fWindowIntf) then exit;
  fWindowIntf.vgWindowSizeCallback(aWidth, aHeight );

  fWinWidth  := aWidth;
  fWinHeight := aHeight;

  Result:=True;
end;

function TvgSurface.GetLinker: TvgLinker;
begin
  Result:=fLinker;
end;

function TvgSurface.GetActive: Boolean;
begin
  Result:= fActive;
end;

function TvgSurface.GetMaxImageCount: TvkUint32;
begin
  Result:=   fVkSurfaceCapabilitiesKHR.maxImageCount;
end;

function TvgSurface.GetMinImageCount: TvkUint32;
begin
  Result:=   fVkSurfaceCapabilitiesKHR.minImageCount;
end;

function TvgSurface.GetPhysicalDevice: TvgPhysicalDevice;
begin
  Result:=self.fPhysicalDevice;
end;

procedure TvgSurface.Notification(AComponent: TComponent; Operation: TOperation);
 // Var Intf : IvgVulkanWindow;
begin
  inherited Notification(AComponent, Operation);

  Case Operation of
     opInsert : Begin
                  If aComponent=self then exit;
                  If NotificationTestON and Not (csDesigning in ComponentState) then exit;        //don't mess with links at runtime

                  If (aComponent is TvgPhysicalDevice) and not assigned(fPhysicalDevice)  then
                  Begin
                    SetPhysicalDevice(TvgPhysicalDevice(aComponent));
                  end;
                End;

     opRemove : Begin

                  If (aComponent is TvgPhysicalDevice) and (TvgPhysicalDevice(aComponent)=fPhysicalDevice)  then
                  Begin
                    SetActiveState(False);
                    TvgPhysicalDevice(aComponent).Instance := nil ;
                  End;
                end;
  end;
end;

procedure TvgSurface.SetDesigning;
begin
  fActive:=False;

  Assert(assigned(fWindowIntf) , 'Surface Window not connected.');

  Assert(assigned(fPhysicalDevice) , 'Vulkan Physical Device not connected.');
  Assert(assigned(fPhysicalDevice.fInstance) , 'Vulkan Instance not connected to Device.');

  If not fPhysicalDevice.fInstance.active then
  Begin
    fPhysicalDevice.fInstance.SetDesigning;
  End;

  Assert(assigned(fPhysicalDevice.fInstance.VulkanInstance) , 'Vulkan Instance creation failed.');

  Try
    {$if defined(Android)}
      Assert(fWindow<>0 , 'Window not connected');
      fVulkanSurface :=  TpvVulkanSurface.CreateAndroid(fInstance.VulkanInstance, fWindow);
    {$ifend}
    {$if defined(Wayland) and defined(Unix)}
      Assert(assigned(fVulkanWindow) , 'Window not connected');
      fVulkanWindow.SurfaceWinPlatformCallback( fDisplay,fSurface);
      Assert(fDisplay<>0 , 'Display not defined');
      Assert(fSurface<>0 , 'Surface not defined');
      fVulkanSurface:=  TpvVulkanSurface.CreateWayland(fInstance.VulkanInstance,fDisplay,fSurface);
    {$ifend}
    {$if defined(Win32) or defined(Win64)}
     // Assert(assigned(fWindowIntf) , 'Compatible display Window not connected.');
      fWindowIntf.SurfaceWinPlatformCallback(fWinInstance, fModInstance ) ;
      Assert(fWinInstance<>0 , 'Window Handle is not defined.');
      Assert(fModInstance<>0 , 'Module Handle is not defined.');
      fVulkanSurface  := TpvVulkanSurface.CreateWin32(fPhysicalDevice.fInstance.VulkanInstance, fModInstance, fWinInstance );
    {$ifend}
    {$if defined(XCB) and defined(Unix)}
      Assert(assigned(fVulkanWindow) , '');
      fVulkanWindow.SurfaceWinPlatformCallback(fConnection,fWindow );
      Assert(fConnection<>0 , 'Connection not defined');
      Assert(fWindow<>0 , 'Window not defined');
      fVulkanSurface := TpvVulkanSurface.CreateXCB(fPhysicalDevice.fInstance.VulkanInstance, fConnection, fWindow);
    {$ifend}
    {$if defined(XLIB) and defined(Unix)}
      Assert(assigned(fVulkanWindow) , 'Window not connected);
      fVulkanWindow.SurfaceWinPlatformCallback(fDisplay, fWindow);
      Assert(fDisplay<>0 , 'Display not defined');
      Assert(fWindow<>0 , 'Window not defined');
      fVulkanSurface := TpvVulkanSurface.CreateXLIB(fPhysicalDevice.fInstance.VulkanInstance,fDisplay,fWindow);
    {$ifend}
    {$if defined(MoltenVK_IOS) and defined(Darwin)}
      Assert(assigned(fVulkanWindow) , 'Window not connected');
      If  then  fVulkanWindow.SurfaceWinPlatformCallback(fView );
      Assert(fView<>0 , 'View not defined');
      fVulkanSurface := TpvVulkanSurface.CreateMoltenVK_IOS(fInstance,fView);
    {$ifend}
    {$if defined(MoltenVK_MacOS) and defined(Darwin)}
      Assert(assigned(fVulkanWindow) , 'Window not connected');
      If  then  fVulkanWindow.SurfaceWinPlatformCallback(fView );
      Assert(fView<>0 , 'View not defined');
      fVulkanSurface := TpvVulkanSurface.CreateMoltenVK_MacOS(fPhysicalDevice.fInstance.VulkanInstance,fView);
    {$ifend}

    fActive:=  fVulkanSurface<>Nil;

    Assert(fActive , 'Vulkan Surface creation failed.');

  Except
    On E:Exception do
     Begin
        fActive:=False;
       Raise;
     End;
  End;

end;

procedure TvgSurface.SetDisabled;
begin
  fActive:=False;

  If assigned(fLinker) and (fLinker.Active) then
     fLinker.Active:=False;

  If assigned(fVulkanSurface) then
     FreeAndNil( fVulkanSurface);

  If assigned(fWindowIntf) then
  Begin
     fWindowIntf.SetDisabled;
     fWindowIntf.vgWindowInvalidate(True);
  End;

end;

procedure TvgSurface.SetEnabled(aComp:TvgBaseComponent=nil);
  Var SF : TVkSurfaceKHR;
begin
  fActive:=False;

  Assert( assigned(fWindowIntf),'Surface Window not connected.');

  Assert( assigned(fPhysicalDevice), 'Vulkan Device not connected.' );
  Assert( assigned(fPhysicalDevice.fInstance), 'Vulkan Instance not connected to Device.' );

  If not assigned(fPhysicalDevice.fInstance.VulkanInstance) then
  Begin
    fPhysicalDevice.fInstance.SetEnabled(self);   //check
    Exit;
  end;

  Assert( assigned(fPhysicalDevice.fInstance.VulkanInstance) , 'Vulkan Instance creation failed.' );

  Try
     If (fWindowIntf.vgWindowGetSurface(SF)) then
     Begin
       fVulkanSurface := TpvVulkanSurface.CreateHandle(fPhysicalDevice.fInstance.VulkanInstance, SF);
     End else
     Begin

          {$if defined(Android)}
            Assert(fWindow<>0 , 'Window not connected');
            fVulkanSurface :=  TpvVulkanSurface.CreateAndroid(fPhysicalDevice.fInstance.VulkanInstance, fWindow);
          {$ifend}
          {$if defined(Wayland) and defined(Unix)}
            Assert(assigned(fVulkanWindow) , 'Window not connected');
            fVulkanWindow.SurfaceWinPlatformCallback( fDisplay,fSurface);
            Assert(fDisplay<>0 , 'Display not defined');
            Assert(fSurface<>0 , 'Surface not defined');
            fVulkanSurface:=  TpvVulkanSurface.CreateWayland(fPhysicalDevice.fInstance.VulkanInstance,fDisplay,fSurface);
          {$ifend}
          {$if defined(Win32) or defined(Win64)}
         //   Assert(assigned(fWindowIntf) , 'Compatible display Window not connected.');
            fWindowIntf.SurfaceWinPlatformCallback(fWinInstance, fModInstance ) ;
            Assert((fWinInstance<>0) , 'Window Handle is not defined.');
            Assert((fModInstance<>0) , 'Module Handle is not defined.');
            fVulkanSurface  := TpvVulkanSurface.CreateWin32(fPhysicalDevice.fInstance.VulkanInstance, fModInstance, fWinInstance );
          {$ifend}
          {$if defined(XCB) and defined(Unix)}
            Assert(assigned(fVulkanWindow) , '');
            fVulkanWindow.SurfaceWinPlatformCallback(fConnection,fWindow );
            Assert(fConnection<>0 , 'Connection not defined');
            Assert(fWindow<>0 , 'Window not defined');
            fVulkanSurface := TpvVulkanSurface.CreateXCB(fPhysicalDevice.fInstance.VulkanInstance, fConnection, fWindow);
          {$ifend}
          {$if defined(XLIB) and defined(Unix)}
            Assert(assigned(fVulkanWindow) , 'Window not connected);
            fVulkanWindow.SurfaceWinPlatformCallback(fDisplay, fWindow);
            Assert(fDisplay<>0 , 'Display not defined');
            Assert(fWindow<>0 , 'Window not defined');
            fVulkanSurface := TpvVulkanSurface.CreateXLIB(fPhysicalDevice.fInstance.VulkanInstance,fDisplay,fWindow);
          {$ifend}
          {$if defined(MoltenVK_IOS) and defined(Darwin)}
            Assert(assigned(fVulkanWindow) , 'Window not connected');
            If  then  fVulkanWindow.SurfaceWinPlatformCallback(fView );
            Assert(fView<>0 , 'View not defined');
            fVulkanSurface := TpvVulkanSurface.CreateMoltenVK_IOS(fPhysicalDevice.fInstance,VulkanInstance,fView);
          {$ifend}
          {$if defined(MoltenVK_MacOS) and defined(Darwin)}
            Assert(assigned(fVulkanWindow) , 'Window not connected');
            If  then  fVulkanWindow.SurfaceWinPlatformCallback(fView );
            Assert(fView<>0 , 'View not defined');
            fVulkanSurface := TpvVulkanSurface.CreateMoltenVK_MacOS(fPhysicalDevice.fInstance.VulkanInstance,fView);
          {$ifend}
       (*
          If assigned(self.fDevice) and assigned(fDevice.fPhysicalDevice) and not fDevice.SurfaceSupport(self,fDevice.VulkanDevice.GraphicsQueueFamilyIndex) then
          Begin
            FreeAndNil(fVulkanSurface);
          End;
       *)
    end;

    fActive:=  fVulkanSurface<>Nil;

    Assert(fActive , 'Vulkan Surface creation failed.');

  Except
    On E:Exception do
     Begin
        If assigned(fWindowIntf) then
           fWindowIntf.vgWindowInvalidate(True);
        fActive:=False;
       Raise;
     End;
  End;

  If assigned(fWindowIntf) then
     fWindowIntf.vgWindowInvalidate(True);

end;

procedure TvgSurface.SetPhysicalDevice(const Value: TvgPhysicalDevice);
begin
  If fPhysicalDevice = Value then exit;
  SetActiveState(False);

  fPhysicalDevice := Value;

end;

procedure TvgSurface.SetWindowIntf(const Value: IvgVulkanWindow);
begin

  If fWindowIntf = Value then exit;
  SetActiveState(False);

  fWindowIntf := Value;

end;

procedure TvgSurface.SetLinker(const Value: TvgLinker);
begin
  If fLinker=Value then exit;
  SetActiveState(False);
  fLinker := Value;
  If assigned(fLinker) then
     fLinker.fSurface:=Self;
end;

procedure TvgSurface.SetActive(const Value: Boolean);

begin
  If fActive=Value then exit;
  SetActiveState(Value);
end;

{ TvgPhysicalDevice }

constructor TvgPhysDevice.Create(Collection: TCollection);
begin
  inherited Create(Collection);
end;

function TvgPhysDevice.GetDescription: String;
begin
  Result:=GetDisplayName;
end;

function TvgPhysDevice.GetDisplayName: string;
begin
  if not assigned(fVulkanPhysicalDevice) then
    Result:='NO Physical Device attached'
  else
    Result:= Trim(String(fVulkanPhysicalDevice.DeviceName));
end;

procedure TvgPhysDevice.SetData(aPhyDev: TpvVulkanPhysicalDevice);
begin
  fVulkanPhysicalDevice:= aPhyDev;

  If assigned(fVulkanPhysicalDevice) then
     fDeviceType :=  fVulkanPhysicalDevice.Properties.deviceType;
end;

{ TvgPhysicalDevices }

constructor TvgPhysDevices.Create(CollOwner: TvgInstance);
begin
  Inherited Create(TvgPhysDevice);
  FComp:= CollOwner;
end;

function TvgPhysDevices.GetItem(Index: Integer): TvgPhysDevice;
begin
  Result := TvgPhysDevice(inherited GetItem(Index));
end;

function TvgPhysDevices.GetOwner: TPersistent;
begin
  Result:=fComp;
end;

procedure TvgPhysDevices.SetItem(Index: Integer; const Value: TvgPhysDevice);
begin
  inherited SetItem(Index, Value);
end;

procedure TvgPhysDevices.Update(Item: TCollectionItem);
var
  str: string;
  i: Integer;
begin
  inherited;
  // update everything in any case...
  str := '';
  for i := 0 to Count - 1 do
  begin
    str := str + String((Items [i] as TvgPhysDevice).GetDisplayName);
    if i < Count - 1 then
      str := str + '-';
  end;

  FCollString := str;
end;

{ TvgQueueFamily }

procedure TvgQueueFamily.Clear;
begin
  fQueueFamilyIndex:=-1;
  fEnabled         :=False;

end;

constructor TvgQueueFamily.Create;

begin
  inherited;

  Clear;
end;

procedure TvgQueueFamily.DefineProperties(Filer: TFiler);
begin
  inherited;
  Filer.DefineProperty('QueueFamilyValues', ReadQueueFamilyValues, WriteQueueFamilyValues, True);

end;

function TvgQueueFamily.GetQueFamilyMode: TvgQueueFamilyMode;
begin
  Result:= fQueueFamilyMode;
end;

function TvgQueueFamily.GetQueueCount: Integer;
begin
  Result:=Integer(fqueueCount);
end;

procedure TvgQueueFamily.ReadQueueFamilyValues(Reader: TReader);
begin
  Reader.ReadListBegin;

  fQueueFamilyMode := TvgQueueFamilyMode(Reader.ReadInteger);

  Reader.ReadListEnd;
end;

procedure TvgQueueFamily.SetData(aIndex: TvkUint32; aQueueFamilyRec: PVkQueueFamilyProperties);
begin
  fQueueFamilyIndex   := aIndex;
  fEnabled            := fQueueFamilyIndex>=0;
  fQueueFamilyMode    := VGQ_MUST_HAVE;
  fqueueFlags         := aQueueFamilyRec.queueFlags;
  fqueueCount         := aQueueFamilyRec.queueCount;
  ftimestampValidBits := aQueueFamilyRec.timestampValidBits;
  fminImageTransferGranularity := aQueueFamilyRec.minImageTransferGranularity;

end;

procedure TvgQueueFamily.SetQueFamilyMode(const Value: TvgQueueFamilyMode);
begin
  fQueueFamilyMode:= Value;
end;

procedure TvgQueueFamily.WriteQueueFamilyValues(Writer: TWriter);
begin
  Writer.WriteListBegin;

  Writer.WriteInteger(ord(fQueueFamilyMode));

  Writer.WriteListEnd;
end;

{ TvgSwapChain }

function TvgSwapChain.AcquireNextImage(ImageAvailable:TpvVulkanSemaphore)   : Boolean;
  Var VR:TVkResult;
begin
  Result:=False;
  If not assigned(fVulkanSwapChain) then exit;

  Try

    VR := fVulkanSwapChain.AcquireNextImage(ImageAvailable, nil, 100000000);

    If VR=VK_SUCCESS then
    Begin
      Result:=True;
    end else
    Begin
      //need to rebuild soon but next image has beeen aquired.
      If assigned(fLinker) then
         fLinker.FlagSwapChainRebuild   ;
    End;

  Except

    On E:EpvVulkanResultException do
    Begin
      VR:=E.ResultCode;
      If VR<VK_SUCCESS then
      Begin
        //need to rebuild now
        If assigned(fLinker) then
           fLinker.FlagSwapChainRebuild   ;
        Result := AcquireNextImage(nil);
      End;
    End;
  End;
end;

procedure TvgSwapChain.BuildALLImagesColorSpaces;
  Var I,L: Integer;
      B2 : Boolean;
begin
  Assert(assigned(fScreenDevice)  , 'Vulkan Device not assigned to Swap Chain.' );
  Assert(assigned(fSurface) , 'Vulkan Surface not assigned Swap Chain.' );

  If not fSurface.Active then
  Begin
     fSurface.SetDesigning;
     B2:=True;
  end else
     B2:=False;

  Assert( assigned(fSurface.fVulkanSurface) , 'Vulkan Surface not created.' );

  L:=  Length(fSurface.fVkSurfaceFormatKHRs) ;

  if L>0 then
  For I:=0 to L-1 do
    BuildImagesColorSpaces(fSurface.fVkSurfaceFormatKHRs[I].format, fSurface.fVkSurfaceFormatKHRs[I].colorSpace);

  If B2 then
     fSurface.Active:=False;

end;

procedure TvgSwapChain.BuildALLPresentationModes;
  Var
      B2 : Boolean;

begin
  Assert(assigned(fScreenDevice)  , 'Vulkan Device not assigned to Swap Chain.' );
  Assert(assigned(fSurface) , 'Vulkan Surface not assigned Swap Chain.' );

  If not fSurface.Active then
  Begin
     fSurface.SetDesigning;
     B2:=True;
  end else
     B2:=False;

  Assert( assigned(fSurface.fVulkanSurface) , 'Vulkan Surface not created.' );

  BuildPresentationMode(VK_PRESENT_MODE_MAILBOX_KHR);
  BuildPresentationMode(VK_PRESENT_MODE_FIFO_KHR);
  BuildPresentationMode(VK_PRESENT_MODE_FIFO_RELAXED_KHR);
  BuildPresentationMode(VK_PRESENT_MODE_IMMEDIATE_KHR);    //always present
  BuildPresentationMode(VK_PRESENT_MODE_SHARED_DEMAND_REFRESH_KHR);
  BuildPresentationMode(VK_PRESENT_MODE_SHARED_CONTINUOUS_REFRESH_KHR);


  If B2 then
     fSurface.Active:=False;
end;

function TvgSwapChain.BuildImagesColorSpaces(aFormat:TVkFormat; aColorSpace:TVkColorSpaceKHR): TvgImageFormatColorSpace;
begin
    Result:=nil;
    If DoesImagesColorSpacesExist(aFormat, aColorSpace) then  exit;
    Result:= TvgImageFormatColorSpace.Create(fImagesColorSpaces);
    Result.SetData(aFormat, aColorSpace);
end;

Function TvgSwapChain.BuildPresentationMode(aMode: TVKPresentModeKHR):TvgPresentMode;
begin
  Result:=nil;
  If DoesPresentModeExist(aMode) then exit;
  Result := TvgPresentMode.Create(fPresentModes);
  Result.SetData(aMode);
end;

procedure TvgSwapChain.ClearPresentationModes;
begin
  If assigned(fPresentModes) then
     fPresentModes.Clear;
end;

constructor TvgSwapChain.Create(AOwner: TComponent);
begin
  fImagesColorSpaces  := TvgImageFormatColorSpaces.Create(self);
  fPresentModes       := TvgPresentModes.Create(Self);

  inherited Create(aOwner);

  fImageSharingMode:= VK_SHARING_MODE_EXCLUSIVE;
  fSRGB            := True;
  fClipped         := True;

  fImageUsage    :=  TVkImageUsageFlags(VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT) +
                     TVkImageUsageFlags(VK_IMAGE_USAGE_TRANSFER_DST_BIT  )  +
                     TVkImageUsageFlags(VK_IMAGE_USAGE_INPUT_ATTACHMENT_BIT  ) ;

  Include(fCompositeAlpha, CA_OPAQUE);

  fArrayLayers := 1;

  fDesiredTransform  :=  TVkSurfaceTransformFlagsKHR(VK_SURFACE_TRANSFORM_IDENTITY_BIT_KHR);

  fImageViewType     := VK_IMAGE_VIEW_TYPE_2D;
  fImageAspectFlags  := TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT);
  fCountMipMapLevels := 1;
  fCountArrayLayers  := 1;

  fDesiredImageCount := 3;

end;

procedure TvgSwapChain.DefineProperties(Filer: TFiler);
begin
  inherited;

//  Filer.DefineProperty('SwapChainData', ReadData, WriteData, True);

end;

destructor TvgSwapChain.Destroy;
begin

  If assigned(fImagesColorSpaces) then
     FreeandNil(fImagesColorSpaces);

  If assigned(fPresentModes)   then
    FreeandNil(fPresentModes);

  SetActiveState(False);

  inherited;
end;

function TvgSwapChain.DoesImagesColorSpacesExist(aFormat: TVkFormat; aColorSpace: TVkColorSpaceKHR): Boolean;
  Var I:Integer;
      V:TvgImageFormatColorSpace;
begin
  Result:=False;
  If not assigned(fImagesColorSpaces) then exit;
  If fImagesColorSpaces.Count=0 then exit;

  For I:= 0 to fImagesColorSpaces.Count-1 do
  begin
    V:=  TvgImageFormatColorSpace(fImagesColorSpaces.Items[I]);
    If (V.fImageFormat=aFormat) and
       (V.fImageColorSpace=aColorSpace)  then
    Begin
      Result:=True;
      Break;
    End;
  end;
end;

function TvgSwapChain.DoesPresentModeExist(aMode: TVKPresentModeKHR): Boolean;
   Var I:Integer;
       PM:TvgPresentMode;
begin
  Result:=False;
  If fPresentModes.Count=0 then exit;
  For I:=0 to fPresentModes.Count-1 do
  Begin
    PM:= fPresentModes.Items[I];
    If (PM.fPresentMode=aMode) then
    Begin
      Result:=True;
      Exit;
    End;
  End;
end;

function TvgSwapChain.GetActive: Boolean;
begin
  Result:= fActive ;
end;

function TvgSwapChain.GetArrayLayers: TvkUint32;
begin
  Result:= fArrayLayers;
end;

function TvgSwapChain.GetBaseArrayLayer: TvkUint32;
begin
  Result:=Self.fBaseArrayLayer;
end;

function TvgSwapChain.GetBaseMipLevel: TvkUint32;
begin
    Result:=Self.fBaseMipLevel;
end;

function TvgSwapChain.GetClipped: Boolean;
begin
  Result:= fClipped;
end;

function TvgSwapChain.GetComponentAlpha: TvgComponentSwizzle;
begin
  Result:= GetVGComponentSwizzle( Self.fComponentAlpha);
end;

function TvgSwapChain.GetComponentBlue: TvgComponentSwizzle;
begin
  Result:=GetVGComponentSwizzle( Self.fComponentBlue);
end;

function TvgSwapChain.GetComponentGreen: TvgComponentSwizzle;
begin
  Result:=GetVGComponentSwizzle( Self.fComponentGreen);
end;

function TvgSwapChain.GetComponentRed: TvgComponentSwizzle;
begin
  Result:=GetVGComponentSwizzle( Self.fComponentRed);
end;

function TvgSwapChain.GetCompositeAlpha: TVgCompositeAlphaFlagBitsKHRSet;
begin
  Result:= fCompositeAlpha;
end;

function TvgSwapChain.GetCountArrayLayers: TvkUint32;
begin
  Result:=Self.fCountArrayLayers;
end;

function TvgSwapChain.GetCountMipMapLevels: TvkUint32;
begin
  Result:=Self.fCountMipMapLevels;
end;

function TvgSwapChain.GetCurrentImageIndex: TvkUint32;
begin
  Result := High(TvkUint32);
  if not assigned(fVulkanSwapChain) then exit;
  Result:=  fVulkanSwapChain.CurrentImageIndex;
end;

function TvgSwapChain.GetDesiredImageCount: TvkUint32;
begin
  Result:= fDesiredImageCount;
end;

function TvgSwapChain.GetDesiredTransform: TVgSurfaceTransformFlagBitsKHRSet;
begin
  Result:= GetVGTransform(fDesiredTransform);
end;

function TvgSwapChain.GetDevice: TvgScreenRenderDevice;
begin
  Result:=fScreenDevice;
end;

function TvgSwapChain.GetForceCompositeAlpha: Boolean;
begin
  Result:= fForceCompositeAlpha;
end;

function TvgSwapChain.GetFrameBufferAttach( Index: Integer): TpvVulkanFrameBufferAttachment;
begin
  If (Index<0) or (Index>=Length(self.fFrameBufferAtachments)) then
     Result:=Nil
  else
     Result:= fFrameBufferAtachments[Index];
end;

function TvgSwapChain.GetImage(Index: Integer): TpvVulkanImage;
begin
  Result:=nil;
  If not fActive then exit;
  If not assigned(fVulkanSwapChain) then exit;
  If (Index<0)   or (Index>=Length(fFrameBufferAtachments))  then exit;

  Result := fFrameBufferAtachments[Index].Image;
//  Result:= fImages[Index];
end;

function TvgSwapChain.GetImageAspectFlags: TvgImageAspectFlagBits;
begin
   Result:= GetVGImageAspectFlags(self.fImageAspectFlags);
end;

function TvgSwapChain.GetImageHeight: TvkUint32;
begin
   Result:= fImageHeight;
end;

function TvgSwapChain.GetImageIndex: TvkUint32;
begin
  If assigned(fVulkanSwapChain) then
     Result:=fVulkanSwapChain.CurrentImageIndex
  else
     Result:= High(TvkUint32);
end;

function TvgSwapChain.GetImageSharingMode: TvgSharingMode;
begin
  Result:=  GetVGSharingMode( fImageSharingMode);
end;

function TvgSwapChain.GetImageUsage: TvgImageUsageFlagsSet;
begin
  Result := GetVGImageUseFlags(fImageUsage);
end;

function TvgSwapChain.GetImageView(Index: Integer): TpvVulkanImageView;
begin
  Result:=nil;
  If not fActive then exit;
  If (Index<0) or (Index>= Length(fFrameBufferAtachments)) then exit;

  Result:=  fFrameBufferAtachments[Index].ImageView;
end;

function TvgSwapChain.GetImageViewType: TvgImageViewType;
begin
  Result:= GetVGImageViewType(self.fImageViewType);
end;

function TvgSwapChain.GetImageWidth: TvkUint32;
begin
  Result:=fImageWidth;
end;

function TvgSwapChain.GetPresentModes: TvgPresentModes;
begin
  Result:= fPresentModes;
end;

function TvgSwapChain.GetSRGB: Boolean;
begin
  Result:= fSRGB;
end;

function TvgSwapChain.GetSurface: TvgSurface;

begin
  Result:=fSurface;
end;

function TvgSwapChain.GetVulkanSWapChain: TpvVulkanSwapChain;
begin
  Result:=fVulkanSwapChain;
end;

procedure TvgSwapChain.ImageViewsClear;
  Var I:Integer;
begin
  If not assigned(fVulkanSwapChain) then exit;
  If fVulkanSwapChain.CountImages=0 then exit;

  For I:=0 to Length(fFrameBufferAtachments)-1 do
    If assigned(fFrameBufferAtachments[I]) then
    Begin
      FreeAndNil(fFrameBufferAtachments[I]);
    End;

  SetLength(fFrameBufferAtachments,0);


end;

procedure TvgSwapChain.ImageViewsSetUp;
  Var I, CI:Integer;
    ColorAttachmentImage    :TpvVulkanImage;
    ColorAttachmentImageView:TpvVulkanImageView;

begin
  if not assigned(fScreenDevice) then exit;
  If not assigned(fScreenDevice.VulkanDevice) then exit;

  If not assigned(fVulkanSwapChain) then exit;
  If fVulkanSwapChain.CountImages=0 then exit;

  If not assigned(fLinker) then exit;

  CI:= fVulkanSwapChain.CountImages ;

  SetLength(fFrameBufferAtachments,CI);

  For I:= 0 to CI-1 do
  Begin


    ColorAttachmentImage := TpvVulkanImage.Create(fScreenDevice.fVulkanDevice,
                                        fVulkanSwapChain.Images[I].Handle,
                                        nil,
                                        false);


    ColorAttachmentImageView:=TpvVulkanImageView.Create(fScreenDevice.VulkanDevice,
                                  ColorAttachmentImage,//   fImages[I],
                                  fImageViewType,
                                  fImageFormat,  //fVulkanSwapChain.ImageFormat,
                                  fComponentRed,
                                  fComponentGreen,
                                  fComponentBlue,
                                  fComponentAlpha,
                                  fImageAspectFlags,
                                  fBaseMipLevel,
                                  fCountMipMapLevels,
                                  fBaseArrayLayer,
                                  fCountArrayLayers
                                  );

     ColorAttachmentImage.ImageView := ColorAttachmentImageView;

     fFrameBufferAtachments[I] := TpvVulkanFrameBufferAttachment.Create(fScreenDevice.VulkanDevice,
                                                  ColorAttachmentImage,
                                                  ColorAttachmentImageView,
                                                  ImageWidth,
                                                  ImageHeight,
                                                  ImageFormat,
                                                  True);


  End;

end;

procedure TvgSwapChain.Notification(AComponent: TComponent;  Operation: TOperation);
begin
    inherited Notification(AComponent, Operation);


    Case Operation of
       opInsert : Begin
                    If aComponent=self then exit;
                    If NotificationTestON and Not (csDesigning in ComponentState) then exit;     //don't mess with links at runtime

                    If (aComponent is TvgScreenRenderDevice) and not assigned(fScreenDevice) then
                    Begin
                       SetDevice(TvgScreenRenderDevice(aComponent));
                    End;

                    If (aComponent is TvgSurface) and not assigned(fSurface) then
                    Begin
                       SetSurface(TvgSurface(aComponent));
                    End;
                  End;

       opRemove : Begin

                    If (aComponent is TvgScreenRenderDevice) and (TvgScreenRenderDevice(aComponent)=fScreenDevice) then
                    Begin
                      fScreenDevice:=nil;
                    End;

                    If (aComponent is TvgSurface) and (TvgSurface(aComponent)=fSurface) then
                    Begin
                      fSurface:=nil;
                    End;
                  end;
    End;
end;

function TvgSwapChain.QueuePresent(const aQueue: TpvVulkanQueue; RenderingFinishedSemaphore:TpvVulkanSemaphore): Boolean;
  Var VR:TVkResult;
begin
  Result:=False;
  If not assigned(fVulkanSwapChain) then exit;
  If not assigned(aQueue) then exit;

  Try
    VR := fVulkanSwapChain.QueuePresent(aQueue, RenderingFinishedSemaphore);

    If VR=VK_SUCCESS then
    Begin
      Result:=True;
    end else
    Begin
      If assigned(fLinker) then
         fLinker.FlagSwapChainRebuild   ;
     // else
      //need to rebuild soon but next image has beeen aquired.
      // fRebuildNeeded := True;
    End;

  Except
    On E:EpvVulkanResultException do
    Begin
      VR:=E.ResultCode;
      If VR<VK_SUCCESS then
      Begin
        //need to rebuild now
        If assigned(fLinker) then
           fLinker.FlagSwapChainRebuild   ;

        If RecreateSwapChain then
           VR := fVulkanSwapChain.QueuePresent(aQueue,Nil);
        Result:=(VR=VK_SUCCESS);
      End;
    End;
  End;
end;

procedure TvgSwapChain.ReadData(Reader: TReader);
begin
  Reader.ReadListBegin;
  fDesiredImageCount  := ReadTvkUint32(Reader);
  fArrayLayers        := ReadTvkUint32(Reader);
  fBaseMipLevel       := ReadTvkUint32(Reader);
  fCountMipMapLevels  := ReadTvkUint32(Reader);
  fBaseArrayLayer     := ReadTvkUint32(Reader);
  fCountArrayLayers   := ReadTvkUint32(Reader);
  Reader.ReadListEnd;
end;

Function TvgSwapChain.RecreateSwapChain:Boolean;
begin
  Result:=False;
  Assert(Assigned(fScreenDevice));
  If not assigned(fScreenDevice.VulkanDevice) then exit;

  ImageViewsClear;  //need to call this here

  fOldVulkanSwapChain := fVulkanSwapChain;
  fVulkanSwapChain    := nil;

  Try
    SetActiveState(False);
    SetEnabled;

    Result := True;
  Finally
     If assigned(fOldVulkanSwapChain) then
       FreeAndNil(fOldVulkanSwapChain);
  End;

end;

procedure TvgSwapChain.RemoveALLImagesColorSpaces;
begin
  If assigned(fImagesColorSpaces) then
    fImagesColorSpaces.Clear;
end;

procedure TvgSwapChain.SetActive(const Value: Boolean);
begin
  if Value=fActive then exit;
  SetActiveState(Value);
end;

procedure TvgSwapChain.SetArrayLayers(const Value: TvkUint32);
begin
  If fArrayLayers=Value then exit;
  SetActiveState(False);
  If Value<1 then
     fArrayLayers:=1
  else
     fArrayLayers:=Value;
end;

procedure TvgSwapChain.SetBaseArrayLayer(const Value: TvkUint32);
begin
  If self.fBaseArrayLayer=Value then exit;
  SetActiveState(False);
  self.fBaseArrayLayer:=Value;
end;

procedure TvgSwapChain.SetBaseMipLevel(const Value: TvkUint32);
begin
  If self.fBaseMipLevel=Value then exit;
  SetActiveState(False);
  self.fBaseMipLevel:=Value;
end;

procedure TvgSwapChain.SetClipped(const Value: Boolean);
begin
  If fClipped=Value then exit;
  SetActiveState(False);
  fClipped := Value;
end;

procedure TvgSwapChain.SetComponentAlpha(const Value: TvgComponentSwizzle);
  Var CS:TvkComponentSwizzle ;
begin
  CS:=GetVKComponentSwizzle(Value);
  If self.fComponentAlpha=CS then exit;
  SetActiveState(False);
  self.fComponentAlpha:=CS;
end;

procedure TvgSwapChain.SetComponentBlue(const Value: TvgComponentSwizzle);
  Var CS:TvkComponentSwizzle ;
begin
  CS:=GetVKComponentSwizzle(Value);
  If self.fComponentBlue=CS then exit;
  SetActiveState(False);
  self.fComponentBlue:=CS;
end;

procedure TvgSwapChain.SetComponentGreen(const Value: TvgComponentSwizzle);
  Var CS:TvkComponentSwizzle ;
begin
  CS:=GetVKComponentSwizzle(Value);
  If self.fComponentGreen=CS then exit;
  SetActiveState(False);
  self.fComponentGreen:=CS;
end;

procedure TvgSwapChain.SetComponentRed(const Value: TvgComponentSwizzle);
  Var CS:TvkComponentSwizzle ;
begin
  CS:=GetVKComponentSwizzle(Value);
  If self.fComponentRed=CS then exit;
  SetActiveState(False);
  self.fComponentRed:=CS;
end;

procedure TvgSwapChain.SetCompositeAlpha(const Value: TVgCompositeAlphaFlagBitsKHRSet);
begin
  If fCompositeAlpha=Value then exit;
  SetActiveState(False);
  fCompositeAlpha := Value;
end;

procedure TvgSwapChain.SetCountArrayLayers(const Value: TvkUint32);
begin
  If self.fCountArrayLayers=Value then exit;
  SetActiveState(False);
  self.fCountArrayLayers:=Value;
end;

procedure TvgSwapChain.SetCountMipMapLevels(const Value: TvkUint32);
begin
  If self.fCountMipMapLevels=Value then exit;
  SetActiveState(False);
  self.fCountMipMapLevels:=Value;
end;

procedure TvgSwapChain.SetDesigning;
begin

end;

procedure TvgSwapChain.SetDesiredImageCount(const Value: TvkUint32);
begin
  If fDesiredImageCount=Value then exit;
  SetActiveState(False);
  fDesiredImageCount := Value;
end;

procedure TvgSwapChain.SetDesiredTransform(const Value: TVgSurfaceTransformFlagBitsKHRSet);
  Var V:TVkSurfaceTransformFlagsKHR;
begin
  V:= GetVKTransform( Value);
  If V=fDesiredTransform then exit;
  SetActiveState(False);

  fDesiredTransform :=  V;
end;

procedure TvgSwapChain.SetDevice(const Value: TvgScreenRenderDevice);
begin
  If fScreenDevice=Value then  exit;
  SetActiveState(False);

  fScreenDevice:=Value;

end;

procedure TvgSwapChain.SetDisabled;

begin

  fActive:=False;

  If assigned(fLinker)  then
     fLinker.VulkanWaitIdle;

  ImageViewsClear;

  If assigned(fVulkanSwapChain)            then
    FreeAndNil(fVulkanSwapChain);

end;

procedure TvgSwapChain.SetEnabled(aComp:TvgBaseComponent=nil);
  Var
       aPresentMode : TVkPresentModeKHR;
       aTransform   : TVkSurfaceTransformFlagsKHR;
       aCompositeAlpha     : array of TVkCompositeAlphaFlagBitsKHR;
       aQueueFamilyIndices : array of TvkUint32;
       aSharingMode : TVkSharingMode;
       aImageUsage  : TVkImageUsageFlags;

          Procedure SetUpImageColorSpace;
            Var I,J,L:Integer;
                 CS  :TvgImageFormatColorSpace;
          Begin
            fImageFormat := VK_FORMAT_B8G8R8A8_SRGB;          //good choice for default 96% cards support  Vulkan Caps database
            fColorSpace  := VK_COLOR_SPACE_SRGB_NONLINEAR_KHR;

            //No surfaace formats defined
           // If not assigned(fDevice) then exit;
          //  If not assigned(Surface) then exit;
            L:= Length(fSurface.fVkSurfaceFormatKHRs);
            If L=0 then exit;

            //check for VK_UNDEFINED
            For I:=0 to L-1 do
            Begin
              If (fSurface.fVkSurfaceFormatKHRs[I].format=VK_FORMAT_UNDEFINED) then
              Begin
                If fImagesColorSpaces.Count>0 then
                Begin
                    CS:=  fImagesColorSpaces.Items[0];
                    fImageFormat := CS.fImageFormat ;
                    fColorSpace  := CS.fImageColorSpace;
                End else
                  Exit;  //take the default
              End;
            end;

            //will select the from the list of user options
            If fImagesColorSpaces.Count>0 then
              For I:=0 to fImagesColorSpaces.Count-1 do
              Begin
                For J:=0 to L-1 do
                Begin
                  CS:=  fImagesColorSpaces.Items[I];
                  If (CS.fImageFormat     = fSurface.fVkSurfaceFormatKHRs[J].format) and
                     (CS.fImageColorSpace = fSurface.fVkSurfaceFormatKHRs[J].colorSpace) then
                  Begin
                    fImageFormat:= CS.fImageFormat ;
                    fColorSpace := CS.fImageColorSpace;
                    exit;
                  End;
                End;
              End;

            //last fall back to the first provided by the device
            fImageFormat:= fSurface.fVkSurfaceFormatKHRs[0].format ;
            fColorSpace := fSurface.fVkSurfaceFormatKHRs[0].colorSpace;

          End;

          Procedure SetUpSizes;
          //  Var W,H,IC : Integer;
          Begin
           // If not assigned(Surface) then exit;

            If (fImageWidth=0) or
               (fImageWidth< fSurface.fVkSurfaceCapabilitiesKHR.minImageExtent.width) or
               (fImageWidth> fSurface.fVkSurfaceCapabilitiesKHR.maxImageExtent.width) then
                fImageWidth := fSurface.fVkSurfaceCapabilitiesKHR.currentExtent.width ;

            If (fImageHeight=0) or
               (fImageHeight< fSurface.fVkSurfaceCapabilitiesKHR.minImageExtent.height) or
               (fImageHeight> fSurface.fVkSurfaceCapabilitiesKHR.maxImageExtent.height) then
                fImageHeight := fSurface.fVkSurfaceCapabilitiesKHR.currentExtent.height ;

          End;

          Procedure SetUpPresentationMode;
            Var I,L,J :Integer;
                PM    :TvgPresentMode;

          Begin
            aPresentMode := VK_PRESENT_MODE_FIFO_KHR;  //always available

            L:=Length(fSurface.fvkPresentModeKHRs);
            If (L=0) then exit; //this is OK
            If fPresentModes.Count=0 then exit;

            For J:=0 to fPresentModes.Count-1 do    //take user list and see if presentation mode is available
            Begin
              PM:=  fPresentModes.Items[J];
              For I:=0 to L-1 do
              Begin
                  If (PM.fPresentMode = fSurface.fvkPresentModeKHRs[I]) then
                  Begin
                    aPresentMode := fSurface.fvkPresentModeKHRs[I];
                    Exit;
                  End;
              End;
            End;
          End;

          Procedure SetUpImageCount;
          Begin
            If (aPresentMode = VK_PRESENT_MODE_FIFO_KHR) and (fDesiredImageCount<2) then
              fDesiredImageCount := 2;

            If (fDesiredImageCount < fSurface.MinImageCount) then
                fDesiredImageCount := fSurface.MinImageCount + 1;

            If  (fDesiredImageCount > fSurface.MaxImageCount) then
                fDesiredImageCount := fSurface.MaxImageCount;

            fImageCount := fDesiredImageCount;

          End;

          Procedure SetUpTransform;
            Var TR1,TR2,TR3:TVgSurfaceTransformFlagBitsKHRSet;

          Begin
             TR1:= GetVGTransform(fDesiredTransform);
             TR2:= GetVGTransform(fSurface.fVkSurfaceCapabilitiesKHR.supportedTransforms);
             TR3:=[];

             If (ST_IDENTITY in TR1)                     and (ST_IDENTITY in TR2) then Include(TR3, ST_IDENTITY );
             If (ST_ROTATE_90 in TR1)                    and (ST_ROTATE_90 in TR2) then Include(TR3, ST_ROTATE_90 );
             If (ST_ROTATE_180 in TR1)                   and (ST_ROTATE_180 in TR2) then Include(TR3, ST_ROTATE_180 );
             If (ST_ROTATE_270 in TR1)                   and (ST_ROTATE_270 in TR2) then Include(TR3, ST_ROTATE_270 );
             If (ST_HORIZONTAL_MIRROR in TR1)            and (ST_HORIZONTAL_MIRROR in TR2) then Include(TR3, ST_HORIZONTAL_MIRROR );
             If (ST_HORIZONTAL_MIRROR_ROTATE_90 in TR1)  and (ST_HORIZONTAL_MIRROR_ROTATE_90 in TR2) then Include(TR3, ST_HORIZONTAL_MIRROR_ROTATE_90 );
             If (ST_HORIZONTAL_MIRROR_ROTATE_180 in TR1) and (ST_HORIZONTAL_MIRROR_ROTATE_180 in TR2) then Include(TR3, ST_HORIZONTAL_MIRROR_ROTATE_180 );
             If (ST_HORIZONTAL_MIRROR_ROTATE_270 in TR1) and (ST_HORIZONTAL_MIRROR_ROTATE_270 in TR2) then Include(TR3, ST_HORIZONTAL_MIRROR_ROTATE_270 );
             If (ST_TRANSFORM_INHERIT in TR1)            and (ST_TRANSFORM_INHERIT in TR2) then Include(TR3, ST_TRANSFORM_INHERIT );

             If (TR3<>[])  then
               aTransform:= GetVKTransform(TR3)
             else
               aTransform :=  TVkCompositeAlphaFlagsKHR(fSurface.fVkSurfaceCapabilitiesKHR.currentTransform);  //safe start most likely
          End;

          Procedure SetUpCompositeAlpha;
            Var I,L:Integer;
          Begin
            L:=0;
            If (CA_OPAQUE in fCompositeAlpha) then  Inc(L);
            If (CA_PRE_MULTIPLIED in fCompositeAlpha) then  Inc(L);
            If (CA_POST_MULTIPLIED in fCompositeAlpha) then  Inc(L);
            If (CA_ALPHA_INHERIT in fCompositeAlpha) then  Inc(L);

            If L=0 then
            Begin
              SetLength(aCompositeAlpha,1);
              aCompositeAlpha[0]:= VK_COMPOSITE_ALPHA_OPAQUE_BIT_KHR;
            End else
            Begin
              SetLength(aCompositeAlpha,L);
              I:=0;
              If (CA_OPAQUE in fCompositeAlpha) then           Begin aCompositeAlpha[I]:= VK_COMPOSITE_ALPHA_OPAQUE_BIT_KHR;         Inc(I); end;
              If (CA_PRE_MULTIPLIED in fCompositeAlpha) then   Begin aCompositeAlpha[I]:= VK_COMPOSITE_ALPHA_PRE_MULTIPLIED_BIT_KHR; Inc(I); end;
              If (CA_POST_MULTIPLIED in fCompositeAlpha) then  Begin aCompositeAlpha[I]:= VK_COMPOSITE_ALPHA_POST_MULTIPLIED_BIT_KHR;Inc(I); end;
              If (CA_ALPHA_INHERIT in fCompositeAlpha) then    Begin aCompositeAlpha[I]:= VK_COMPOSITE_ALPHA_INHERIT_BIT_KHR;       { Inc(I); }end;
            End;
          End;

          Procedure SetUpSharingMode;
            Var QueueFamilyCount,I:Integer;
          Begin
            Case fImageSharingMode of
              VK_SHARING_MODE_EXCLUSIVE :
              Begin
                 aSharingMode:=VK_SHARING_MODE_EXCLUSIVE;
                 SetLength(aQueueFamilyIndices,0) ;
              end;
              VK_SHARING_MODE_CONCURRENT:
              Begin
                If assigned(fScreenDevice) then
                   QueueFamilyCount:=  fScreenDevice.GetQueueFamilyCount
                else
                   QueueFamilyCount:=0;
                If QueueFamilyCount<2 then
                Begin
                  aSharingMode:=VK_SHARING_MODE_EXCLUSIVE;
                  SetLength(aQueueFamilyIndices,0) ;
                end else
                Begin    //set to share all queue families
                  aSharingMode:= VK_SHARING_MODE_CONCURRENT;
                  SetLength(aQueueFamilyIndices,QueueFamilyCount) ;
                  For I:=0 to QueueFamilyCount-1 do
                    aQueueFamilyIndices[I]:=I;
                End;
              End;
            end;
          End;

          Procedure SetUpImageUsage;
            Var IU1,IU2,IU3 :  TvgImageUsageFlagsSet;
          Begin
            IU1:= GetVGImageUseFlags(fImageUsage);
            If not (IU_TRANSFER_DST in IU1) then Include(IU1, IU_TRANSFER_DST);     //check temporary

            IU2:= GetVGImageUseFlags(fSurface.fVkSurfaceCapabilitiesKHR.supportedUsageFlags);
            IU3:=[];

            If (IU_TRANSFER_SRC in IU1) and (IU_TRANSFER_SRC in IU2) then Include(IU3,IU_TRANSFER_SRC);
            If (IU_TRANSFER_DST in IU1) and (IU_TRANSFER_DST in IU2) then Include(IU3,IU_TRANSFER_DST);
            If (IU_SAMPLED in IU1) and (IU_SAMPLED in IU2) then Include(IU3,IU_SAMPLED);
            If (IU_STORAGE in IU1) and (IU_STORAGE in IU2) then Include(IU3,IU_STORAGE);
            If (IU_COLOR_ATTACHMENT in IU1) and (IU_COLOR_ATTACHMENT in IU2) then Include(IU3,IU_COLOR_ATTACHMENT);
            If (IU_DEPTH_STENCIL_ATTACHMENT in IU1) and (IU_DEPTH_STENCIL_ATTACHMENT in IU2) then Include(IU3,IU_DEPTH_STENCIL_ATTACHMENT);
            If (IU_TRANSIENT_ATTACHMENT in IU1) and (IU_TRANSIENT_ATTACHMENT in IU2) then Include(IU3,IU_TRANSIENT_ATTACHMENT);
            If (IU_INPUT_ATTACHMENT in IU1) and (IU_INPUT_ATTACHMENT in IU2) then Include(IU3,IU_INPUT_ATTACHMENT);
            If (IU_SHADING_RATE_IMAGE_NV in IU1) and (IU_SHADING_RATE_IMAGE_NV in IU2) then Include(IU3,IU_SHADING_RATE_IMAGE_NV);
            If (IU_FRAGMENT_DENSITY_MAP_EXT in IU1) and (IU_FRAGMENT_DENSITY_MAP_EXT in IU2) then Include(IU3,IU_FRAGMENT_DENSITY_MAP_EXT);

            If IU3=[] then
              aImageUsage := (TVkImageUsageFlags(VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT)  +  TVkImageUsageFlags(VK_IMAGE_USAGE_TRANSFER_DST_BIT))
            else
              aImageUsage := GetVKImageUseFlags(IU3);
          End;


begin

    fActive := False;

    Assert(Assigned(fScreenDevice),'ScreenDevice not assigned');
    Assert(Assigned(fScreenDevice.fVulkanDevice),'Screen Device not active');

    Assert(Assigned(fSurface),'Surface not assigned');
    Assert(Assigned(fSurface.fVulkanSurface),'Surface not active');

    Assert(Assigned(fSurface.WindowIntf),'Surface not connected to Window');

    fSurface.WindowIntf.vgWindowSizeCallback(fImageWidth , fImageHeight);

    SetUpImageColorSpace;
    SetUpSizes;
    SetUpPresentationMode;
    SetUpImageCount;//stay here  may need to adjust for Present Mode
    SetUpTransform;
    SetUpCompositeAlpha;

    SetUpSharingMode;
    SetUpImageUsage;  //must follow SetUpPresentationMode


    fVulkanSwapChain := TpvVulkanSwapChain.Create(fScreenDevice.VulkanDevice,
                                                  fSurface.VulkanSurface,
                                                  fOldVulkanSwapChain,         //ok in case the swap chain is being rebuilt
                                                  fImageWidth,      //ok
                                                  FImageHeight,     //ok
                                                  fImageCount,      //ok
                                                  fArrayLayers,     //ok
                                                  fImageFormat,           //ok
                                                  fColorSpace,            //ok
                                                  aImageUsage,    //ok
                                                  aSharingMode,
                                                  aQueueFamilyIndices,
                                                  aCompositeAlpha,
                                                  fForceCompositeAlpha,
                                                  aPresentMode,
                                                  fClipped,
                                                  aTransform,
                                                  fSRGB,
                                                  false,
                                                  TpvVulkanExclusiveFullScreenMode.Default,
                                                  @fSurface.fWinInstance);

   fActive:= (fVulkanSwapChain <> Nil);

   SetLength(aCompositeAlpha,0);

   If fActive then
   Begin
     fImageCount := fVulkanSwapChain.CountImages;

     If (fImageFormat<> fVulkanSwapChain.ImageFormat) then
         fImageFormat := fVulkanSwapChain.ImageFormat;
     If (fColorSpace<> fVulkanSwapChain.ImageColorSpace) then
         fColorSpace  := fVulkanSwapChain.ImageColorSpace;

     ImageViewsSetUp;

   end;
end;

procedure TvgSwapChain.SetForceCompositeAlpha(const Value: Boolean);
begin
  If Value= fForceCompositeAlpha then exit;
  SetActiveState(False);

  fForceCompositeAlpha := Value;
end;

procedure TvgSwapChain.SetImageAspectFlags(const Value: TvgImageAspectFlagBits);
  Var V: TVkImageAspectFlags;
begin
  V := GetVKImageAspectFlags(Value);
  If self.fImageAspectFlags=V then exit;
  SetActiveState(False);

  fImageAspectFlags:=V;

end;

procedure TvgSwapChain.SetImagesColorSpaces( const Value: TvgImageFormatColorSpaces);
begin
  If not assigned(Value) then exit;
  if not assigned(fImagesColorSpaces) then exit;

  fImagesColorSpaces.Clear;
  fImagesColorSpaces.Assign(Value);
end;

procedure TvgSwapChain.SetImageSharingMode(const Value: TvgSharingMode);
  Var V:TVKSharingMode;
begin
  V:= GetVKSharingMode(Value);
  If V=fImageSharingMode then exit;
  SetActiveState(False);

  fImageSharingMode := V;
end;

procedure TvgSwapChain.SetImageUsage(const Value: TvgImageUsageFlagsSet);
  Var V:  TVkImageUsageFlags;
begin
  V:= GetVKImageUseFlags(Value);
  If V= fImageUsage then exit;
  SetActiveState(False);

  fImageUsage := V;
end;

procedure TvgSwapChain.SetImageViewType(const Value: TvgImageViewType);
  Var V:TVkImageViewType;
begin
  V:= GetVKImageViewType(Value);
  If self.fImageViewType=V then exit;
  SetActiveState(False);
  fImageViewType := V;
end;

procedure TvgSwapChain.SetPresentModes(const Value: TvgPresentModes);
begin
  If not assigned(Value) then exit;
  if not assigned(fPresentModes) then exit;

  fPresentModes.Clear;
  fPresentModes.Assign(Value);
end;

Procedure TvgSwapChain.SetSRGB(const Value: Boolean);
begin
  If Value= fSRGB then exit;
  SetActiveState(False);

  fSRGB := Value;
end;

procedure TvgSwapChain.SetSurface(const Value: TvgSurface);
begin
  If fSurface=Value then exit;

  SetActiveState(False);
  fSurface := Value;

end;

procedure TvgSwapChain.VulkanWaitIdle;
  Var Index,SubIndex:Integer ;
begin
   Assert(assigned(fScreenDevice));
   Assert(assigned(fScreenDevice.VulkanDevice));

   for Index:=0 to length(fScreenDevice.VulkanDevice.QueueFamilyQueues)-1 do
    begin
       for SubIndex:=0 to length(fScreenDevice.VulkanDevice.QueueFamilyQueues[Index])-1 do
       begin
        if assigned(fScreenDevice.VulkanDevice.QueueFamilyQueues[Index,SubIndex]) then
           fScreenDevice.VulkanDevice.QueueFamilyQueues[Index,SubIndex].WaitIdle;
       end;
    end;

end;

procedure TvgSwapChain.WriteData(Writer: TWriter);
begin
  Writer.WriteListBegin;
  WriteTvkUint32(Writer, fDesiredImageCount);
  WriteTvkUint32(Writer, fArrayLayers);
  WriteTvkUint32(Writer, fBaseMipLevel);
  WriteTvkUint32(Writer, fCountMipMapLevels);
  WriteTvkUint32(Writer, fBaseArrayLayer);
  WriteTvkUint32(Writer, fCountArrayLayers);
  Writer.WriteListEnd;
end;

{ TvgImageFormatColorSpace }

procedure TvgImageFormatColorSpace.Assign(Source: TPersistent);
  Var E: TvgImageFormatColorSpace;
begin
  inherited;
  If not (source is  TvgImageFormatColorSpace) then exit;
  E:= TvgImageFormatColorSpace(Source);

  fDisplayName        := E.fDisplayName;
  fImageFormat        := E.fImageFormat;
  fImageColorSpace    := E.fImageColorSpace;

  SetUpDisplayName;
end;

constructor TvgImageFormatColorSpace.Create(Collection: TCollection);
begin
  inherited;

 // SetUpDisplayName;
end;

procedure TvgImageFormatColorSpace.DefineProperties(Filer: TFiler);
begin
  inherited;
 // Filer.DefineProperty('FormatVal', ReadFormatAndColor, WriteFormatAndColor, True);

end;

function TvgImageFormatColorSpace.GetColorSpace: TVgColorSpaceKHR;
begin
  Result:= GetVGColorSpace(fImageColorSpace);
end;

function TvgImageFormatColorSpace.GetDisplayName: string;
begin
   If fDisplayName='' then
      SetUpDisplayName;

   Result := fDisplayName;
end;

function TvgImageFormatColorSpace.GetFormat: TVgFormat;
begin
  Result:= GetVGFormat(fImageFormat);
end;

procedure TvgImageFormatColorSpace.ReadFormatAndColor(Reader: TReader);
begin
  SetUpDisplayName;
end;

procedure TvgImageFormatColorSpace.SetColorSpace(const Value: TVgColorSpaceKHR);
begin
  fImageColorSpace := GetVKColorSpace(Value);
  SetUpDisplayName;

end;

procedure TvgImageFormatColorSpace.SetData(aFormat: TVkFormat; aColorSpace: TVkColorSpaceKHR);
begin
  fImageFormat     := aFormat;
  fImageColorSpace := aColorSpace;

  SetUpDisplayName;
end;

procedure TvgImageFormatColorSpace.SetFormat(const Value: TVgFormat);
begin
  fImageFormat := GetVKFormat(Value);
  SetUpDisplayName;
end;

procedure TvgImageFormatColorSpace.SetUpDisplayName;
  Var FMT: TvgFormat;
      CS : TvgColorSpaceKHR ;
begin
   FMT := GetVGFormat(fImageFormat);
   CS  := GetVGColorSpace(fImageColorSpace);

   fDisplayName := GetEnumName(typeInfo(TvgFormat ), Ord(FMT)) + ' with ' + GetEnumName(typeInfo(TvgColorSpaceKHR ), Ord(CS));
end;

procedure TvgImageFormatColorSpace.WriteFormatAndColor(Writer: TWriter);
begin
end;

{ TvgImageFormatColorSpaces }

function TvgImageFormatColorSpaces.Add: TvgImageFormatColorSpace;
begin
  Result := TvgImageFormatColorSpace(inherited Add);
end;

function TvgImageFormatColorSpaces.AddItem(Item: TvgImageFormatColorSpace;Index: Integer): TvgImageFormatColorSpace;
begin
  if Item = nil then
    Result := TvgImageFormatColorSpace.Create(self)
  else
    Result := Item;

  if Assigned(Result) then
  begin
    Result.Collection := Self;
    if Index < 0 then
      Index := Count - 1;
    Result.Index := Index;
  end;
end;

constructor TvgImageFormatColorSpaces.Create(CollOwner: TvgSwapChain);
begin
  Inherited Create(TvgImageFormatColorSpace);
  FComp := CollOwner;
end;

function TvgImageFormatColorSpaces.GetItem( Index: Integer): TvgImageFormatColorSpace;
begin
  Result := TvgImageFormatColorSpace(inherited GetItem(Index));
end;

function TvgImageFormatColorSpaces.GetOwner: TPersistent;
begin
  Result := fComp;
end;

function TvgImageFormatColorSpaces.Insert( Index: Integer): TvgImageFormatColorSpace;
begin
  Result := AddItem(nil, Index);
end;

procedure TvgImageFormatColorSpaces.SetItem(Index: Integer; const Value: TvgImageFormatColorSpace);
begin
  inherited SetItem(Index, Value);
end;

procedure TvgImageFormatColorSpaces.Update(Item: TCollectionItem);
var
  str: string;
  i: Integer;
begin
  inherited;
  // update everything in any case...
  str := '';

  for i := 0 to Count - 1 do
  begin
    str := str + (Items [i] as TvgImageFormatColorSpace).GetDisplayName;
    if i < Count - 1 then
      str := str + '-';
  end;

  FCollString := str;
end;

{ TvgPresentModes }

function TvgPresentModes.Add: TvgPresentMode;
begin
  Result := TvgPresentMode(inherited Add);
end;

function TvgPresentModes.AddItem(Item: TvgPresentMode; Index: Integer): TvgPresentMode;
begin
  if Item = nil then
    Result := TvgPresentMode.Create(self)
  else
    Result := Item;

  if Assigned(Result) then
  begin
    Result.Collection := Self;
    if Index < 0 then
      Index := Count - 1;
    Result.Index := Index;
  end;
end;

constructor TvgPresentModes.Create(CollOwner: TvgSwapChain);
begin
  Inherited Create(TvgPresentMode);
  FComp := CollOwner;
end;

function TvgPresentModes.GetItem(Index: Integer): TvgPresentMode;
begin
  Result := TvgPresentMode(inherited GetItem(Index));
end;

function TvgPresentModes.GetOwner: TPersistent;
begin
  Result := fComp;
end;

function TvgPresentModes.Insert(Index: Integer): TvgPresentMode;
begin
  Result := AddItem(nil, Index);
end;

procedure TvgPresentModes.SetItem(Index: Integer; const Value: TvgPresentMode);
begin
  inherited SetItem(Index, Value);
end;

procedure TvgPresentModes.Update(Item: TCollectionItem);
var
  str: string;
  i: Integer;
begin
  inherited;
  // update everything in any case...
  str := '';

  for i := 0 to Count - 1 do
  begin
    str := str + (Items [i] as TvgPresentMode).GetDisplayName;
    if i < Count - 1 then
      str := str + '-';
  end;

  FCollString := str;
end;

{ TvgPresentMode }

procedure TvgPresentMode.Assign(Source: TPersistent);
begin
  inherited;
  fPresentMode := VK_PRESENT_MODE_FIFO_KHR;
  SetUpDisplayName;
end;

constructor TvgPresentMode.Create(Collection: TCollection);
begin
  Inherited Create(Collection);
end;

function TvgPresentMode.GetDisplayName: string;
begin
  Result:=fPresentName;
end;

function TvgPresentMode.GetPresentMode: TvgPresentModeKHR;
begin
  Result:= GetVGPresentMode(Self.fPresentMode);
end;

procedure TvgPresentMode.SetData(aPresentMode: TVKPresentModeKHR);
begin
  fPresentMode:= aPresentMode;
  SetUpDisplayName;
end;

procedure TvgPresentMode.SetPresentMode(const Value: TvgPresentModeKHR);
begin
  fPresentMode := GetVKPresentMode(Value);
  SetUpDisplayName;
end;

procedure TvgPresentMode.SetUpDisplayName;
  Var  PM:TvgPresentModeKHR;
begin
  PM :=GetVGPresentMode(fPresentMode);
  fPresentName := GetEnumName(typeInfo(TvgPresentModeKHR ), Ord(PM))   ;
end;

{ TvgRenderEngine }

procedure TvgRenderEngine.AddRenderNode(aRenderNode: TvgRenderNode);
     var I  :Integer;
         GI : TvgGraphicPipeItem;
         GP : TvgGraphicPipeline;

   Procedure AddNode( aList:TvgRenderNodeList);
   Begin
        If aList.IndexOf(aRenderNode)=-1 then
        Begin
          aList.Add(aRenderNode);    //Able to select (for edit/move etc) and animate
          aRenderNode.Renderer         := self;
          aRenderNode.PipelineCount    := fRenderPass.SubPasses.count;  //sets number of pipelines
        End;
   End;

begin
  If not assigned(aRenderNode) then exit;

  For I:=0 to  fGraphicPipeList.Count-1 do
  Begin
    GI := fGraphicPipeList.Items[I];

    If assigned(GI) and
       (GI.RenderPassType = fRenderPass.ClassType) and
       (GI.RenderNodeType = aRenderNode.ClassType) and
       (assigned(GI.GraphicPipe)) and
       (GI.SubPassRef>=0) and (GI.SubPassRef<fRenderPass.SubPasses.count) then
    Begin
      GP := GI.GraphicPipe;

      Case aRenderNode.fRenderMode of
          NM_UNDERLAY : AddNode( GP.UnderlayNodes );
          NM_STATIC   : AddNode( GP.StaticNodes );
          NM_DYNAMIC  : AddNode( GP.DynamicNodes );
          NM_OVERLAY  : AddNode( GP.OverlayNodes );
      End;

      aRenderNode.GraphicPipeline[ GI.SubPassRef] := GP;
    End;
  End;


end;

procedure TvgRenderEngine.AddRenderNodeCommands(ImageIndex:TvkUint32; aFrame:TvgFrame ;aSubPass : TvkUint32);
begin
  //see descendants
end;

procedure TvgRenderEngine.AddRenderObject(aRenderObject: TvgRenderObject);
begin
  If not assigned(aRenderObject) then exit;

  If fRenderObjects.IndexOf(aRenderObject)=-1 then
  Begin
    fRenderObjects.Add(aRenderObject);
    aRenderObject.fRenderer := Self;
  //  If assigned(aRenderObject.fRenderNode) then
  //    AddRenderNode(aRenderObject.fRenderNode);
  End;
end;

procedure TvgRenderEngine.BuildAndSetUpWorkers;
begin
  //do nothing
end;

procedure TvgRenderEngine.BuildGraphicPipelines;
  Var I :Integer;
      GI:TvgGraphicPipeItem;
begin

  If fGraphicPipeList.Count>0 then exit;

  If  assigned(GraphicPipeTypeList) and (GraphicPipeTypeList.Count>0) and (fGraphicPipeList.Count=0) then
  Begin

    For I:=0 to GraphicPipeTypeList.Count-1 do
    Begin

      If GraphicPipeTypeList.Items[I].fRenderPassType = fRenderPass.ClassType then
      Begin
        GI:= fGraphicPipeList.Add;
        If assigned(GI) then
        Begin
          GI.RenderPassType  := GraphicPipeTypeList.Items[I].fRenderPassType;
          GI.SubPassRef      := GraphicPipeTypeList.Items[I].fSubPassRef;
          GI.RenderNodeType  := GraphicPipeTypeList.Items[I].fRenderNodeType;

          GI.GraphicPipeType := GraphicPipeTypeList.Items[I].fGraphicPipelineType;
          If assigned(GI.GraphicPipe) then
          Begin
            GI.GraphicPipe.Renderer     := self ;
            GI.GraphicPipe.Name         := GI.GraphicPipe.GetPropertyName;
            GI.DisplayName              := GI.GraphicPipe.GetPropertyName + 'Item';
            GI.GraphicPipe.SetSubComponent(True);
            GI.GraphicPipe.SubPassRef   := GraphicPipeTypeList.Items[I].fSubPassRef;
            GI.GraphicPipe.SetUpPipeline;
          End;
        End;
      End;
    End;
  End;

end;

procedure TvgRenderEngine.BuildRenderPassStructure;
begin
  Assert(Assigned(fRenderPass),'RenderPass not created.');

  If assigned(fLinker) then
     fRenderPass.fColourFormat := fLinker.ImageFormat;

  If assigned(fOnRenderPassStructureBuild) then
  Begin
     fRenderPass.ClearStructure;
     fOnRenderPassStructureBuild(fRenderPass) ;
  end else
     fRenderPass.BuildStructure;

end;

procedure TvgRenderEngine.CleanUpAndFreeWorkers;
begin
  //do nothing
end;

constructor TvgRenderEngine.Create(AOwner: TComponent);
begin

   fRenderObjects   := TList<TvgRenderObject>.Create;

   fGlobalRes       := TvgDescriptorSet.Create(self);  //haold shader resource structure and data
   fGlobalRes.SetSubComponent(True);
   fGlobalRes.Name  := 'Global';
   If assigned(fLinker) and assigned(fLinker.ScreenDevice) then
      fGlobalRes.LogicalDevice:= fLinker.ScreenDevice;

  fGraphicPipeList   := TvgGraphicPipeLists.Create(self);

  CreateRenderPass;  //descendants can set type of renderpass//sub component
  Assert(assigned(fRenderPass),'RenderPass not created in CreateRenderPass');
  If assigned(fRenderPass) then
  Begin
    fRenderPass.Name:='RP';//'Render_Pass';
    fRenderPass.SetSubComponent(True);
    FreeNotification(fRenderPass);
    fRenderPass.fRenderEngine := Self;
  End;

  inherited;

  fRenderWorkerCount := 1;

  BuildGraphicPipelines;

end;

procedure TvgRenderEngine.CreateRenderPass;
begin
  //do nothing  see descendants
end;

destructor TvgRenderEngine.Destroy;
begin
  SetActiveState(False);

  If assigned(fRenderPass) then
     FreeAndNil(fRenderPass);

  If assigned(fGraphicPipeList) then
     FreeAndNil(fGraphicPipeList);

  If assigned(fGlobalRes) then
    FreeAndNil(fGlobalRes);

  If assigned(fRenderObjects) then
  Begin
    fRenderObjects.Clear;
    FreeAndNil(fRenderObjects);
  End;
 (*
  If assigned(fUnderlayNodes) then
  Begin
    fUnderlayNodes.Clear;
    FreeAndNil(fUnderlayNodes);
  End;

  If assigned(fStaticNodes) then
  Begin
    fStaticNodes.Clear;
    FreeAndNil(fStaticNodes);
  End;

  If assigned(fDynamicNodes) then
  Begin
    fDynamicNodes.Clear;
    FreeAndNil(fDynamicNodes);
  End;

  If assigned(fOverlayNodes) then
  Begin
    fOverlayNodes.Clear;
    FreeAndNil(fOverlayNodes);
  End;
 *)
  inherited;
end;

function TvgRenderEngine.GetActive: Boolean;
begin
  Result:=fActive;
end;

function TvgRenderEngine.GetFrameBufferHandle(  Index: Integer): TVkFrameBuffer;
begin
  Assert(assigned(fRenderPass),'RenderPass NOT created');

  If (index<0) or (index>Length(fRenderPass.fFrameBufferHandles)-1) then
     Result := VK_NULL_HANDLE
  else
     Result := fRenderPass.FrameBufferHandles[Index];
end;

function TvgRenderEngine.GetLinker: TvgLinker;
begin
  Result := fLinker;
end;

function TvgRenderEngine.GetNextFrameIndex: TvkUint32;
begin
 // Result := 0;
  Assert(assigned(fLinker),'Linker NOT assigned');

  Result := fLinker.NextFrameIndex;
end;

function TvgRenderEngine.GetNodeCount: Integer;
  Var I:Integer;
      GP:TvgGraphicPipeline;
begin
  Result := 0;
  For I:=0 to fGraphicPipeList.Count-1 do
  Begin
    GP:= fGraphicPipeList.Items[I].GraphicPipe;
    If assigned(GP) then
    Begin
      If assigned(GP.UnderlayNodes) then Result := Result + GP.UnderlayNodes.Count  ;
      If assigned(GP.StaticNodes) then   Result := Result + GP.StaticNodes.Count  ;
      If assigned(GP.DynamicNodes) then  Result := Result + GP.DynamicNodes.Count  ;
      If assigned(GP.OverlayNodes) then  Result := Result + GP.OverlayNodes.Count  ;
    End;
  End;
end;
(*
function TvgRenderEngine.GetNodeGraphicPipeline( aRenderNode: TvgRenderNode): TvgGraphicPipeline;
  Var I :Integer;
      GP:TvgGraphicPipeItem;
begin
  Result := nil;
  If not assigned(aRenderNode) then exit;
  if fGraphicPipeList.Count=0 then exit;

  For I:=0 to  fGraphicPipeList.Count-1 do
  Begin
    GP := fGraphicPipeList.Items[I] ;
    If assigned(GP) then
      If  (GP.GraphicPipeType = aRenderNode.GetGraphicPipelineType) then
      Begin
        Result := GP.GraphicPipe;
        Break;
      End;
  End;
end;
*)

function TvgRenderEngine.GetRenderPass: TvgRenderPass;
begin
  result := fRenderPass;
end;

function TvgRenderEngine.GetGlobalResources: TvgDescriptorSet;
begin
  Result := fGlobalRes;
end;

procedure TvgRenderEngine.MoveRenderNode(aRenderNode: TvgRenderNode; OldMode,  NewMode: TvgNodeMode);
  Var I:Integer;
      GI : TvgGraphicPipeItem;
      GP : TvgGraphicPipeline;

  Procedure RemoveNode(aMode: TvgNodeMode; aList:TvgRenderNodeList);
  Begin
     RemoveRenderNode( aRenderNode, False);
  End;

  Procedure AddNode(aMode: TvgNodeMode; aList:TvgRenderNodeList);
  Begin
     AddRenderNode(aRenderNode);
  End;

begin
  If not assigned(aRenderNode) then exit;

  For I:=0 to  fGraphicPipeList.Count-1 do
  Begin
    GI := fGraphicPipeList.Items[I];

    If assigned(GI) and
       (GI.RenderPassType = fRenderPass.ClassType) and
       (GI.RenderNodeType = aRenderNode.ClassType) and
       (assigned(GI.GraphicPipe)) and
       (GI.SubPassRef>=0) and (GI.SubPassRef<fRenderPass.SubPasses.count) then
    Begin
      GP := GI.GraphicPipe;

      Case OldMode of
          NM_UNDERLAY : RemoveNode(OldMode, GP.UnderlayNodes );
          NM_STATIC   : RemoveNode(OldMode, GP.StaticNodes );
          NM_DYNAMIC  : RemoveNode(OldMode, GP.DynamicNodes );
          NM_OVERLAY  : RemoveNode(OldMode, GP.OverlayNodes );
      End;

      Case OldMode of
          NM_UNDERLAY : AddNode(NewMode, GP.UnderlayNodes );
          NM_STATIC   : AddNode(NewMode, GP.StaticNodes );
          NM_DYNAMIC  : AddNode(NewMode, GP.DynamicNodes );
          NM_OVERLAY  : AddNode(NewMode, GP.OverlayNodes );
      End;
    End;
  End;

end;

procedure TvgRenderEngine.Notification(AComponent: TComponent; Operation: TOperation);
begin
    inherited Notification(AComponent, Operation);

    Case Operation of
       opInsert : Begin
                    If aComponent=self then exit;
                    If NotificationTestON and Not (csDesigning in ComponentState) then exit;     //don't mess with links at runtime

                    If (aComponent is TvgLinker) and Not assigned(fLinker) then
                    Begin
                      SetActiveState(False);
                      fLinker:=TvgLinker(aComponent);
                    End;

                    If (aComponent is TvgRenderObject) and Not assigned(TvgRenderObject(aComponent).Renderer) then
                    Begin
                      TvgRenderObject(aComponent).Renderer := Self;
                    End;

                    If (aComponent is TvgRenderPass) and Not assigned(fRenderPass) then
                    Begin
                      SetActiveState(False);
                      fRenderPass:=TvgRenderPass(aComponent);
                    End;

                  End;

       opRemove : Begin
                    If (aComponent is TvgLinker) and (fLinker=TvgLinker(aComponent)) then
                    Begin
                      SetActiveState(False);
                      fLinker:=Nil;
                    End;

                    If (aComponent is TvgRenderObject) and (TvgRenderObject(aComponent).Renderer=self) then
                    Begin
                      TvgRenderObject(aComponent).Renderer := nil;
                    End;

                    If (aComponent is TvgRenderPass) and (fRenderPass = TvgRenderPass(aComponent)) then
                    Begin
                      SetActiveState(False);
                      fRenderPass := nil;
                    End;
                  end;

    End;

end;

Procedure TvgRenderEngine.RemoveRenderNode(aRenderNode: TvgRenderNode; DoDestroy: Boolean);
   Var I: integer;
       GI : TvgGraphicPipeItem;
       GP : TvgGraphicPipeline;

   Procedure RemoveANode(aList:TvgRenderNodeList);
     Var  J :Integer;
   Begin
     J := aList.IndexOf(aRenderNode);

     If ( J > -1) then
     Begin
        aList.Remove(aRenderNode)  ;
        aRenderNode.fRenderer        := Nil;
        aRenderNode.ClearPipeLineList;
        If DoDestroy then
           aRenderNode.Destroy;
     End;
   End;

begin
  If not assigned(aRenderNode) then exit;

  For I:=0 to  fGraphicPipeList.Count-1 do
  Begin
    GI := fGraphicPipeList.Items[I];

    If assigned(GI) and
       (GI.RenderPassType = fRenderPass.ClassType) and
       (GI.RenderNodeType = aRenderNode.ClassType) and
       (assigned(GI.GraphicPipe)) and
       (GI.SubPassRef>=0) and (GI.SubPassRef<fRenderPass.SubPasses.count) then
    Begin
      GP := GI.GraphicPipe;

      Case aRenderNode.fRenderMode of
          NM_UNDERLAY : RemoveANode( GP.UnderlayNodes );
          NM_STATIC   : RemoveANode( GP.StaticNodes );
          NM_DYNAMIC  : RemoveANode( GP.DynamicNodes );
          NM_OVERLAY  : RemoveANode( GP.OverlayNodes );
      End;
    End;
  End;
end;

procedure TvgRenderEngine.RemoveRenderObject(aRenderObject: TvgRenderObject);
begin
  If not assigned(aRenderObject) then exit;

  If fRenderObjects.IndexOf(aRenderObject)<>-1 then
  Begin
    If assigned(aRenderObject.fRenderNode) then
       RemoveRenderNode(aRenderObject.fRenderNode,False);
    fRenderObjects.Remove(aRenderObject);
    aRenderObject.fRenderer:=nil;
  End;
end;

procedure TvgRenderEngine.RenderAFrame_Start(ImageIndex:TvkUint32; aFrame:TvgFrame);
  Var
      VK_presentToClear  : TVkImageMemoryBarrier  ;
      VK_ClearToPresent  : TVkImageMemoryBarrier  ;
      VK_ImageSub        : TVkImageSubresourceRange;
      RP                 : TVkRenderPassBeginInfo;
      aRenderArea        : TVkRect2D;
      CurrentSubPass     : TvkUint32;
      SP                 : TvgSubPass;
      I                  : Integer;
      //aRenderTarget      : TvgRend
begin

  If not fActive then exit;

  Assert(assigned(fLinker),'Vulkan Link not attached');

  Assert(assigned(aFrame),'A Frame not provided.');

  Assert(assigned(fLinker.ScreenDevice),'Internal Screen Device not available.');
  Assert(assigned(fLinker.ScreenDevice.fVulkanDevice),'Internal Screen Vulkan Device not available.');

  Assert(assigned(fLinker.SwapChain),'Internal Swap Chain not available.');
  If not assigned(fLinker.SwapChain.VulkanSwapChain) then exit;
  Assert(fLinker.SwapChain.VulkanSwapChain.CountImages<>0,'No Images available in Swap Chain.');

  fCurrentFrame := aFrame;

  fImageIndex := ImageIndex;

  If (fLinker.ScreenDevice.fPresentQueue.fQueueFamilyIndex<>fLinker.ScreenDevice.fGraphicsQueue.fQueueFamilyIndex) then
  Begin

      FillChar(VK_ImageSub,SizeOf(TVkImageSubresourceRange),#0);
      VK_ImageSub.aspectMask     := TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT);
      VK_ImageSub.baseMipLevel   := 0;
      VK_ImageSub.levelCount     := 1;
      VK_ImageSub.baseArrayLayer := 0;
      VK_ImageSub.layerCount     := 1;

      FillChar(VK_presentToClear,SizeOf(TVkImageMemoryBarrier),#0);
      VK_presentToClear.sType         := VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER;
      VK_presentToClear.pNext         := nil;
      VK_presentToClear.srcAccessMask := TVkAccessFlags(VK_ACCESS_MEMORY_READ_BIT);
      VK_presentToClear.dstAccessMask := TVkAccessFlags(VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT);
      VK_presentToClear.oldLayout     := VK_IMAGE_LAYOUT_PRESENT_SRC_KHR;
      VK_presentToClear.newLayout     := VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL;
      VK_presentToClear.srcQueueFamilyIndex := fLinker.ScreenDevice.fPresentQueue.fQueueFamilyIndex;   //check
      VK_presentToClear.dstQueueFamilyIndex := fLinker.ScreenDevice.fGraphicsQueue.fQueueFamilyIndex;   //check
      VK_presentToClear.subresourceRange    := VK_ImageSub;

      FillChar(VK_ClearToPresent,SizeOf(TVkImageMemoryBarrier),#0);
      VK_ClearToPresent.sType         := VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER;
      VK_ClearToPresent.pNext         := nil;
      VK_ClearToPresent.srcAccessMask := TVkAccessFlags(VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT);
      VK_ClearToPresent.dstAccessMask := TVkAccessFlags(VK_ACCESS_MEMORY_READ_BIT);
      VK_ClearToPresent.oldLayout     := VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL;
      VK_ClearToPresent.newLayout     := VK_IMAGE_LAYOUT_PRESENT_SRC_KHR;
      VK_ClearToPresent.srcQueueFamilyIndex := fLinker.ScreenDevice.fGraphicsQueue.fQueueFamilyIndex;   //check
      VK_ClearToPresent.dstQueueFamilyIndex := fLinker.ScreenDevice.fPresentQueue.fQueueFamilyIndex;   //check
      VK_ClearToPresent.subresourceRange    := VK_ImageSub;

  end;

  aRenderArea.offset.x:=0;
  aRenderArea.offset.y:=0;
  aRenderArea.extent.width :=fLinker.SwapChain.ImageWidth;
  aRenderArea.extent.height:=fLinker.SwapChain.ImageHeight;

 // ImageIndex               := fLinker.SwapChain.CurrentImageIndex;

  FillChar(RP, SizeOf(TVkRenderPassBeginInfo),#0);
  RP.sType            := VK_STRUCTURE_TYPE_RENDER_PASS_BEGIN_INFO;
  RP.pNext            := nil;
  RP.renderPass       := fRenderPass.RenderPassHandle;
  RP.framebuffer      := fRenderPass.FrameBufferHandles[ImageIndex]; // aFrame.FrameBufferHandle;  ;
  RP.renderArea       := aRenderArea;
  RP.clearValueCount  := Length(fRenderPass.fClearColArray);
  RP.pClearValues     := @fRenderPass.fClearColArray[0];

 // VulkanCommands      := fLinker.ScreenDevice.fVulkanDevice.Commands;
  //use DEVICE commands as faster and take device version into account

  If not fCurrentFrame.Active then
     fCurrentFrame.Active:=True;

  Try
    If Assigned(fCurrentFrame.FrameCommandBuffer) then
    Begin
        if fCurrentFrame.FrameCommandBuffer.fBufferState=BS_PENDING then
           fCurrentFrame.FrameCommandBuffer.SetBufferState(BS_INITIAL);

        fCurrentFrame.FrameCommandBuffer.BeginRecording( nil);

        If (fLinker.ScreenDevice.fPresentQueue.fQueueFamilyIndex<>fLinker.ScreenDevice.fGraphicsQueue.fQueueFamilyIndex) then
        Begin
          VK_presentToClear.image   := fLinker.SwapChain.VulkanSwapChain.Images[ImageIndex].Handle;//aFrame.FrameImageBuffer.fFrameBufferAttachment.Image.Handle;
                                           //was

          fCurrentFrame.FrameCommandBuffer.CmdPipelineBarrier(
                                TVkPipelineStageFlags(VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT),   //srcStageMask:TVkPipelineStageFlags;
                                TVkPipelineStageFlags(VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT),   //dstStageMask:TVkPipelineStageFlags;
                                0,   //dependencyFlags:TVkDependencyFlags;
                                0,   //memoryBarrierCount:TvkUint32;
                                nil, //aMemoryBarriers:PVkMemoryBarrier;
                                0,   //bufferMemoryBarrierCount:TvkUint32
                                nil, //aBufferMemoryBarriers:PVkBufferMemoryBarrier
                                1,     //imageMemoryBarrierCount:TvkUint32
                                @VK_PresentToClear);  // aImageMemoryBarriers:PVkImageMemoryBarrier

        end;

        CurrentSubPass := 0;

        fCurrentFrame.FrameCommandBuffer.CmdBeginRenderPass( @RP,
                                                      VK_SUBPASS_CONTENTS_SECONDARY_COMMAND_BUFFERS);

        for I := 0 to fRenderPass.SubPasses.count-1 do
        Begin
           SP := fRenderPass.SubPasses.Items[I];
           case SP.Mode of
             RP_CUSTOM: ;
             RP_SCENE : AddRenderNodeCommands(ImageIndex, aFrame, CurrentSubPass);
             RP_UI    : ;
             RP_OFFSCREENTOSCREEN: ;
           end;


           if (fRenderPass.SubPasses.count>1) and (I<fRenderPass.SubPasses.count-1) then
           Begin
              inc(CurrentSubPass);
              fCurrentFrame.FrameCommandBuffer.CmdNextSubpass( VK_SUBPASS_CONTENTS_SECONDARY_COMMAND_BUFFERS);
           End;
        End;


        //uses task/s to pass jobs to WorkerThread
        //Uses a secondary command per Worker/thread to record data

      (*
        If fRenderPass.SubPasses.Count>1 then
        Begin
          while  (CurrentSubPass < TvkUint32(fRenderPass.SubPasses.Count) - 1)  do
          Begin
            Inc(CurrentSubPass);


            if (SP.Mode in [RP_SCENE, RP_CUSTOM]) then
                AddRenderNodeCommands(ImageIndex, aFrame, CurrentSubPass);
          End;
        End;
        *)

        fCurrentFrame.FrameCommandBuffer.CmdEndRenderPass;

        If (fLinker.ScreenDevice.fPresentQueue.fQueueFamilyIndex<>fLinker.ScreenDevice.fGraphicsQueue.fQueueFamilyIndex) then
        Begin

            VK_ClearToPresent.image  := fLinker.SwapChain.VulkanSwapChain.Images[ImageIndex].Handle;//aFrame.FrameImageBuffer.fFrameBufferAttachment.Image.Handle;
                                       // was

            fCurrentFrame.FrameCommandBuffer.CmdPipelineBarrier(
                                  TVkPipelineStageFlags(VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT),//srcStageMask:TVkPipelineStageFlags;
                                  TVkPipelineStageFlags(VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT),         //dstStageMask:TVkPipelineStageFlags;
                                  0,   //dependencyFlags:TVkDependencyFlags;
                                  0,   //memoryBarrierCount:TvkUint32;
                                  nil, //aMemoryBarriers:PVkMemoryBarrier;
                                  0,   //bufferMemoryBarrierCount:TvkUint32
                                  nil, //aBufferMemoryBarriers:PVkBufferMemoryBarrier
                                  1,     //imageMemoryBarrierCount:TvkUint32
                                 @VK_ClearToPresent);  // aImageMemoryBarriers:PVkImageMemoryBarrier

        end;


       fCurrentFrame.FrameCommandBuffer.EndRecording;

    End;


  Except
     On E:EpvVulkanResultException do
     Begin


     End;

  End;

end;

procedure TvgRenderEngine.RenderAFrame_Finish;
begin

end;

procedure TvgRenderEngine.SetActive(const Value: Boolean);
begin
  If fActive = Value then exit;
  SetActiveState(Value);
end;

procedure TvgRenderEngine.SetDisabled;
  Var I:Integer;

begin
  fActive := False;

  If assigned(fGraphicPipeList) and (fGraphicPipeList.Count>0) then
    For I:= 0 to fGraphicPipeList.Count-1 do
    Begin
      If assigned(fGraphicPipeList.Items[I]) and assigned(fGraphicPipeList.Items[I].GraphicPipe) then
         fGraphicPipeList.Items[I].GraphicPipe.Active:=False;
    End;

  If assigned(fGlobalRes) then
     fGlobalRes.Active := False;

  CleanUpAndFreeWorkers;

  If assigned(fRenderObjects) and (fRenderObjects.Count>0) then
  Begin
    For I:=0 to fRenderObjects.Count-1 do
      If assigned(fRenderObjects.Items[I]) and (fRenderObjects.Items[I].Active) then
        fRenderObjects.Items[I].Active := False;
  end;


  If assigned(fRenderPass) then
     fRenderPass.Active := False;       //may be nil in destroy
end;

procedure TvgRenderEngine.SetEnabled(aComp:TvgBaseComponent=nil);
  Var I:Integer;
      GP : TvgGraphicPipeline;
begin
  Assert(assigned(fLinker),'Window Link not assigned');
  Assert(assigned(fRenderPass),'RenderPass NOT created');

  fRenderPass.Active := True;

  If fRenderWorkerCount=0 then
      fRenderWorkerCount := 1;

  If assigned(fGlobalRes) then
      fGlobalRes.active := True;

  BuildAndSetUpWorkers;
  //override to create set of workers

   If fGraphicPipeList.Count>0 then
   Begin
     For I:=0 to fGraphicPipeList.Count-1 do
     Begin
       GP:= fGraphicPipeList.Items[I].GraphicPipe ;
       If assigned(GP) then
       Begin
         GP.ThreadCount  := fRenderWorkerCount;
         GP.FrameCount   := fLinker.FrameCount;
       //  GP.SetUpPipeline;
         SetUpDepthAndMSAA(GP);
         GP.Active       := True;
       End;
     End;
   End;


  If fRenderObjects.Count>0 then
    For I:=0 to fRenderObjects.Count-1 do
      fRenderObjects.Items[I].Active:=True;

  fActive := True;

end;

procedure TvgRenderEngine.SetGlobalRes( const Value: TvgDescriptorSet);
begin
  If not assigned(Value) then exit;
end;

procedure TvgRenderEngine.SetGraphicPipes( const Value: TvgGraphicPipeLists);
begin
  If not assigned(Value) then exit;
  SetActiveState(False);
  fGraphicPipeList.Clear;
  fGraphicPipeList.Assign(Value);
end;

procedure TvgRenderEngine.SetLinker(const Value: TvgLinker);
  Var I:Integer;
      GP:TvgGraphicPipeline;
begin
  If fLinker =Value then exit;
  SetActiveState(False);

  If assigned(fRenderPass) then
    fRenderPass.Linker := Nil;

  If assigned(fLinker) then
    fLinker.fRenderer := Nil;

  If assigned(fGlobalRes) then
    fGlobalRes.LogicalDevice := Nil;

  fLinker := Value;

  If assigned(fLinker) then
  Begin
    fLinker.fRenderer := self;
    fLinker.UseThread := False;

    If assigned(fRenderPass) then
      fRenderPass.Linker := fLinker;
  End;

  If assigned(fLinker)and assigned(fLinker.ScreenDevice)  then
  Begin

      If assigned(fGlobalRes) then
        fGlobalRes.LogicalDevice := fLinker.ScreenDevice;

      If fGraphicPipeList.Count>0 then
      Begin
        For I:=0 to fGraphicPipeList.Count-1 do
        Begin
          GP          :=  fGraphicPipeList.Items[I].GraphicPipe;

          If assigned(GP) then
          Begin
            GP.Renderer := Self;

            If (RU_MATERIAL in GP.ResourceUse) and (assigned(GP.MaterialRes)) then
               GP.MaterialRes.LogicalDevice := fLinker.ScreenDevice;

            If (RU_MODEL in GP.ResourceUse) and (assigned(GP.ModelRes)) then
               GP.ModelRes.LogicalDevice := fLinker.ScreenDevice;
          End;
        End;
      End;
  end;
end;

procedure TvgRenderEngine.SetUpDepthAndMSAA(  aPipe: TvgGraphicPipeline);
begin
  Assert(assigned(aPipe),'Pipe not assigned');
  Assert( assigned(fRenderPass),'Render Pass not created');

  If fRenderPass.MSAAOn then
  Begin
    aPipe.Multisampling.SampleShadingEnable := True;
    aPipe.Multisampling.RasterizationSamples:= fRenderPass.MSAASample;
  End;

  If fRenderPass.DepthBufOn then
    aPipe.SetUpDepthStencilState(fRenderPass.DepthBufOn,
                                 fRenderPass.StencilBufOn,
                                 fRenderPass.DepthCompare);

end;

procedure TvgRenderEngine.SetWorkerCount(const Value: TvkUint32);
  Var TC : TvkUint32;
begin
  If fRenderWorkerCount=Value then exit;
  SetActiveState(False);

  TC := TThread.ProcessorCount;
  If Value>TC then
     fRenderWorkerCount := TC-1
  else
     fRenderWorkerCount := Value;

end;

{ TvgCommandPool }

constructor TvgCommandBufferPool.Create(AOwner: TComponent);
begin
  inherited Create(aOwner);

  fQueueFamilyType  :=  VGT_GRAPHIC;
  fQueueCreateFlags :=  TVkCommandPoolCreateFlags(VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT ) OR
                        TVkCommandPoolCreateFlags(VK_COMMAND_POOL_CREATE_TRANSIENT_BIT );
//  fFrameCount   := 1;
//  fSubPassCount := 1; //defaults
end;

procedure TvgCommandBufferPool.DefineProperties(Filer: TFiler);
begin
  inherited DefineProperties(Filer);
  Filer.DefineProperty('CommandPoolData', ReadPoolData, WritePoolData, True);
end;

destructor TvgCommandBufferPool.Destroy;
  var I,J:Integer;
begin
  SetActiveState(False);

  For I:=0 to Length(fCommandLists)-1 do
  Begin
    For J:=0 to Length(fCommandLists[I])-1 do
    Begin
      FreeAndNil(fCommandLists[I,J]);
    End;
    SetLength( fCommandLists[I],0);
  End;
  SetLength( fCommandLists,0);

  inherited;
end;

function TvgCommandBufferPool.GetActive: Boolean;
begin
  Result:=fActive;
end;

function TvgCommandBufferPool.GetCommandBuffer(FIndex, SIndex: Integer): TvgCommandBuffer;
begin
  Result := nil;

  If (FIndex>=0) and (FIndex<Length(fCommandLists)) then
     If (SIndex>=0) and (SIndex<Length(fCommandLists[FIndex])) then
       Result := fCommandLists[FIndex,SIndex] ;

end;

function TvgCommandBufferPool.GetCommandQueue(Index: Integer): TpvVulkanQueue;

  Function FindQueue(aQueueList : TpvVulkanQueues; DefQueue:TpvVulkanQueue):TpvVulkanQueue;
  Begin
    If (Index >= Low(aQueueList)) and  (Index < High(aQueueList)) then
       Result := aQueueList[Index]
    else
       Result := DefQueue;
  End;

begin
  Result := Nil;
  If not assigned(fLogicalDevice) then exit;
  If not assigned(fLogicalDevice.VulkanDevice) then exit;

  If Index = -1 then
  Begin
      Case  fQueueFamilyType of
          VGT_UNIVERSAL : Result := fLogicalDevice.VulkanDevice.UniversalQueue;
            VGT_PRESENT : Result := fLogicalDevice.VulkanDevice.PresentQueue;
            VGT_GRAPHIC : Result := fLogicalDevice.VulkanDevice.GraphicsQueue;
            VGT_COMPUTE : Result := fLogicalDevice.VulkanDevice.ComputeQueue;
           VGT_TRANSFER : Result := fLogicalDevice.VulkanDevice.TransferQueue;
      End;
  end else
  Begin
      Case  fQueueFamilyType of
          VGT_UNIVERSAL : Result := FindQueue(fLogicalDevice.VulkanDevice.UniversalQueues, fLogicalDevice.VulkanDevice.UniversalQueue);
            VGT_PRESENT : Result := FindQueue(fLogicalDevice.VulkanDevice.PresentQueues,   fLogicalDevice.VulkanDevice.PresentQueue);
            VGT_GRAPHIC : Result := FindQueue(fLogicalDevice.VulkanDevice.GraphicsQueues,  fLogicalDevice.VulkanDevice.GraphicsQueue);
            VGT_COMPUTE : Result := FindQueue(fLogicalDevice.VulkanDevice.ComputeQueues,   fLogicalDevice.VulkanDevice.ComputeQueue);
           VGT_TRANSFER : Result := FindQueue(fLogicalDevice.VulkanDevice.TransferQueues,  fLogicalDevice.VulkanDevice.TransferQueue);
      End;
  end;
end;

function TvgCommandBufferPool.GetCurrentCommand: TvgCommandBuffer;
begin
  If (Length(fCommandLists)=0) or (Length(fCommandLists[0]) =0) then
    Result := nil
  else
    Result := fCommandLists[fCurrentFrame,fCurrentSubpass];
end;

function TvgCommandBufferPool.GetDevice: TvgLogicalDevice;
begin
  Result:=fLogicalDevice;
end;

function TvgCommandBufferPool.GetFrameIndex: TvkUint32;
begin
  Result := fCurrentFrame;
end;

function TvgCommandBufferPool.GetQueueCreateFlags: TVgCommandPoolCreateFlag;
begin
  Result := GetVGCommandPoolCreateFlags(fQueueCreateFlags);
end;

function TvgCommandBufferPool.GetQueueFamilyType: TvgQueueFamilyType;
begin
  Result:= fQueueFamilyType;
end;

function TvgCommandBufferPool.GetSubpassIndex: TvkUint32;
begin
  Result := fCurrentSubpass ;
end;

procedure TvgCommandBufferPool.Notification(AComponent: TComponent;  Operation: TOperation);
begin
    inherited Notification(AComponent, Operation);


    Case Operation of
       opInsert : Begin
                    If aComponent=self then exit;
                    If NotificationTestON and Not (csDesigning in ComponentState) then exit;     //don't mess with links at runtime

                    If (aComponent is TvgPhysicalDevice) and not assigned(fLogicalDevice) then
                    Begin
                      SetActiveState(False);
                      SetDevice(TvgLogicalDevice(aComponent));
                    End;

                  End;

       opRemove : Begin

                    If (aComponent is TvgLogicalDevice) and (TvgLogicalDevice(aComponent)=fLogicalDevice) then
                    Begin
                      SetActiveState(False);
                      fLogicalDevice:=nil;
                    End;

                  end;
    End;
end;

procedure TvgCommandBufferPool.ReadPoolData(Reader: TReader);
begin

  Reader.ReadListBegin;
  fQueueCreateFlags:=  ReadTvkUint32(Reader);
  Reader.ReadListEnd;

end;

procedure TvgCommandBufferPool.ReleaseCommand(aCommand: TvgCommandBuffer);
  Var I,J:Integer;
begin
  If not assigned( aCommand) then exit;
  If not (aCommand.fCommandPool = Self) then exit;
  If Length(fCommandLists)=0 then exit;

  For  J:=0 to Length(fCommandLists)-1 do
  Begin
   If Length(fCommandLists[J])>0 then
     For I:=0 to Length(fCommandLists[J])-1 do
       If fCommandLists[J,I]=aCommand then
       Begin
         FreeAndNil(fCommandLists[J,I]);
         Break;
       End;
  End;

end;

procedure TvgCommandBufferPool.ReleaseAllCommands(DoAll:Boolean=False);
  Var I,J,L:Integer;
begin
   If Length(fCommandLists)=0 then exit;

   If not DoAll then
   Begin
     If Length(fCommandLists[fCurrentFrame])>0 then
     Begin
       For I:=0 to Length(fCommandLists[fCurrentFrame]) - 1 do
          FreeAndNil(fCommandLists[fCurrentFrame,I]);
     End;
   End else
   Begin
     L:=Length(fCommandLists);
     For  J:=0 to L-1 do
     Begin
       If Length(fCommandLists[J])>0 then
       Begin
         For I:=0 to Length(fCommandLists[J])-1 do
            FreeAndNil(fCommandLists[J,I]);
       End;
     End;
   End;

end;

function TvgCommandBufferPool.RequestCommand(aFrameIndex,aSubpassIndex:TvkUint32;
                                             aLevel:TvgCommandBufferLevel;
                                             ResetNeeded:Boolean;
                                             UseFlags:TvgCommandBufferUsageFlags): TvgCommandBuffer;
  Var TempBuf : TvgCommandBuffer;

  Procedure FreeCommand;
  Begin
    if not assigned(TempBuf) then exit;
    FreeAndNil(TempBuf);
    fCommandLists[fCurrentFrame, fCurrentSubpass]:=nil;
  End;

begin
  Result  := Nil;
  TempBuf := Nil;

  If (Length(fCommandLists)=0) or (Length(fCommandLists[0])=0) then
     SetUpBufferArrays(1,1);

  assert (aFrameIndex < Length(fCommandLists), 'FrameIndex too large');
  assert (aSubpassIndex < Length(fCommandLists[0]), 'SubpassIndex too large');

  fCurrentFrame    := aFrameIndex;
  fCurrentSubpass  := aSubpassIndex;

  If assigned(fCommandLists[fCurrentFrame, fCurrentSubpass]) then
  Begin
    TempBuf := fCommandLists[fCurrentFrame, fCurrentSubpass];

    If ResetEnabled then
    Begin

       If (TempBuf.fBufferState in [BS_RECORDING,
                                    BS_EXECUTABLE,
                                    BS_PENDING]) then
       Begin
          TempBuf.Reset(TVkCommandBufferResetFlags(VK_COMMAND_BUFFER_RESET_RELEASE_RESOURCES_BIT)); //will handle fence wait/reset
       end else
       Begin
         If (TempBuf.fBufferState = BS_INVALID) then
            FreeCommand;
       end;

       if assigned(TempBuf) and not (TempBuf.fBufferState=BS_INITIAL) then
         FreeCommand;

    end else
      FreeCommand;

  End;

  if TempBuf = Nil then
  Begin
    TempBuf               := TvgCommandBuffer.Create;
    TempBuf.fCommandPool  := self;
    TempBuf.fCommandLevel := aLevel;
    TempBuf.UseFlags      := UseFlags;

    fCommandLists[fCurrentFrame,fCurrentSubpass] := TempBuf;
  //  Result := TempBuf;
  End;

  if assigned(TempBuf) then
     Result := TempBuf;
end;

function TvgCommandBufferPool.ResetEnabled: Boolean;
begin
  Result := (fQueueCreateFlags and TVkCommandPoolCreateFlags(VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT ) =  TVkCommandPoolCreateFlags(VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT ));
end;

procedure TvgCommandBufferPool.SetActive(const Value: Boolean);
begin
  If fActive=Value then exit;
  SetActiveState(Value);
end;

procedure TvgCommandBufferPool.SetDevice(const Value: TvgLogicalDevice);
begin

  If fLogicalDevice=Value then exit;
  SetActiveState(False);

  fLogicalDevice:=Value;

end;

procedure TvgCommandBufferPool.SetDisabled;
  Var I:Integer;
begin
  fActive:=False;

  If Length(fCommandLists)>0 then

  ReleaseAllCommands(True);

  For I:= 0 to Length(fCommandLists)-1  do
    SetLength(fCommandLists[I],0) ;
  SetLength(fCommandLists, 0);

  If assigned(fVulkanCommandPool) then
     FreeAndNil(fVulkanCommandPool);

end;

procedure TvgCommandBufferPool.SetEnabled(aComp:TvgBaseComponent=nil);
  Var QI: TvkUint32;
      // I: Integer;
begin
   fActive:=False;

   If Not assigned(fLogicalDevice) then exit;

//   If (Length(fCommandLists)=0) then
//     self.SetUpBufferArrays(fFrameCount,fSubPassCount);

   If not fLogicalDevice.Active then
   Begin
     fLogicalDevice.SetEnabled(self);
     Exit;
   End;

   If Not assigned(fLogicalDevice.VulkanDevice) then exit;

    Case  fQueueFamilyType of
        VGT_UNIVERSAL : QI := fLogicalDevice.VulkanDevice.UniversalQueueFamilyIndex;
          VGT_PRESENT : QI := fLogicalDevice.VulkanDevice.PresentQueueFamilyIndex;
          VGT_GRAPHIC : QI := fLogicalDevice.VulkanDevice.GraphicsQueueFamilyIndex;
          VGT_COMPUTE : QI := fLogicalDevice.VulkanDevice.ComputeQueueFamilyIndex;
         VGT_TRANSFER : QI := fLogicalDevice.VulkanDevice.TransferQueueFamilyIndex;
       else
         QI := fLogicalDevice.VulkanDevice.UniversalQueueFamilyIndex;
    End;

  Try

   fVulkanCommandPool := TpvVulkanCommandPool.Create(fLogicalDevice.VulkanDevice,
                                                     QI,
                                                     fQueueCreateFlags) ;

  Except
     On E: EpvVulkanException do
     Begin
        If fVulkanCommandPool<>nil then
           FreeAndNil(fVulkanCommandPool);
        fActive:=False;
        Raise;
     End;
  End;

  fActive  := Assigned(fVulkanCommandPool);

end;

procedure TvgCommandBufferPool.SetFrameIndex(const Value: TvkUint32);
begin
  If fCurrentFrame = Value then exit;
  If Length(fCommandLists)=0 then exit;

  If (Value > TvkUint32(High(fCommandLists))) then exit;

  fCurrentFrame := Value;
end;

procedure TvgCommandBufferPool.SetQueueCreateFlags( const Value: TVgCommandPoolCreateFlag);
  Var CP : TVkCommandPoolCreateFlags;
begin
  CP:=  GetVKCommandPoolCreateFlags(Value);
  If fQueueCreateFlags=CP then exit;
  SetActiveState(False);
  fQueueCreateFlags:=CP;
end;

procedure TvgCommandBufferPool.SetQueueFamilyType(const Value: TvgQueueFamilyType);
begin
  If fQueueFamilyType=Value then exit;
  SetActiveState(False);
  fQueueFamilyType:=Value;
end;

procedure TvgCommandBufferPool.SetSubpassIndex(const Value: TvkUint32);
begin
  If fCurrentSubpass = Value then exit;
  If Length(fCommandLists[fCurrentFrame])=0 then exit;

  If (Value > TvkUint32(High(fCommandLists[fCurrentFrame]))) then exit;
  fCurrentSubpass := Value;
end;

procedure TvgCommandBufferPool.SetUpBufferArrays(aFrameCount, aSubpassCount: TvkUint32);
  Var I,J:Integer;
      F,S:Integer;
begin
  If (aFrameCount<1)   then aFrameCount   := 1;  //must NOT be zero
  If (aSubPassCount<1) then aSubPassCount := 1;  //must NOT be zero
  F := aFrameCount;
  S := aSubPassCount;

  If (Length(fCommandLists)    = F) and
     (Length(fCommandLists[0]) = S) then exit;

  ReleaseAllCommands(True);

  Setlength(fCommandLists, F);
  For I:=0 to aFrameCount-1 do
  Begin
    SetLength(fCommandLists[I], S);
    For J:=0 to aSubpassCount-1 do
      fCommandLists[I,J] := Nil;
  end;

  fCurrentFrame   :=0;
  fCurrentSubpass :=0;
end;

procedure TvgCommandBufferPool.WritePoolData(Writer: TWriter);
begin

  Writer.WriteListBegin;
  WriteTvkUint32(Writer,fQueueCreateFlags);
  Writer.WriteListEnd;

end;

{ TvgCommand }

procedure TvgCommandBuffer.BeginRecording( const aInheritanceInfo: PVkCommandBufferInheritanceInfo);
begin
  if not assigned(fVulkanCommandBuffer) then exit;
  if (fVulkanCommandBuffer.Handle=VK_NULL_HANDLE) then exit;


  if (fBufferState=BS_INITIAL) then
  Begin
    Try
      fVulkanCommandBuffer.BeginRecording(fBufferUse, aInheritanceInfo);
      SetBufferState(BS_RECORDING);
      fCommandCount := 0;
    Except
      SetBufferState(BS_INVALID);
    End;
  End
  else
    Assert((fBufferState = BS_INITIAL) ,'Not valid Buffer State');
end;

procedure TvgCommandBuffer.BeginRecordingPrimary;
begin
  if not assigned(fVulkanCommandBuffer) then exit;
  if (fVulkanCommandBuffer.Handle=VK_NULL_HANDLE) then exit;

  if SetBufferState(BS_INITIAL) then
  Begin
    Try
      fVulkanCommandBuffer.BeginRecordingPrimary;
      SetBufferState(BS_RECORDING);
      fCommandCount := 0;
    Except
      SetBufferState(BS_INVALID);
    End;
  End
  else
    Assert((fBufferState = BS_INITIAL) ,'Not valid Buffer State');

end;

procedure TvgCommandBuffer.BeginRecordingSecondary(
  const aRenderPass: TVkRenderPass; const aSubPass: TvkUint32;
  const aFrameBuffer: TVkFramebuffer; const aOcclusionQueryEnable: boolean;
  const aQueryFlags: TVkQueryControlFlags;
  const aPipelineStatistics: TVkQueryPipelineStatisticFlags{;
  const aFlags: TVkCommandBufferUsageFlags});
begin
  if not assigned(fVulkanCommandBuffer) then exit;
  if (fVulkanCommandBuffer.Handle=VK_NULL_HANDLE) then exit;

  if (fBufferState=BS_INITIAL) then
  Begin
    Try
      fVulkanCommandBuffer.BeginRecordingSecondary(aRenderPass,
                                                   aSubPass,
                                                   aFrameBuffer,
                                                   aOcclusionQueryEnable,
                                                   aQueryFlags,
                                                   aPipelineStatistics,
                                                   fBufferUse);

      SetBufferState(BS_RECORDING);
      fCommandCount := 0;
    Except
      SetBufferState(BS_INVALID);
    End;
  End
  else
    Assert((fBufferState = BS_INITIAL) ,'Not valid Buffer State');

end;

procedure TvgCommandBuffer.CmdBeginQuery(queryPool: TVkQueryPool;
  query: TvkUint32; flags: TVkQueryControlFlags);
begin
  if not assigned(fVulkanCommandBuffer) then exit;
  if (fVulkanCommandBuffer.Handle=VK_NULL_HANDLE) then exit;

  if (fBufferState=BS_RECORDING) then
  Begin
    Try
      fVulkanCommandBuffer.CmdBeginQuery(queryPool,query,flags);
      Inc(fCommandCount);
    Except
      SetBufferState(BS_INVALID);
    End;
  End
  else
    Assert((fBufferState = BS_RECORDING) ,'Not valid Buffer State');

end;

procedure TvgCommandBuffer.CmdBeginRenderPass(const aRenderPassBegin: PVkRenderPassBeginInfo; contents: TVkSubpassContents);
begin
  if not assigned(fVulkanCommandBuffer) then exit;
  if (fVulkanCommandBuffer.Handle=VK_NULL_HANDLE) then exit;

  if (fBufferState=BS_RECORDING) then
  Begin
    Try
      fVulkanCommandBuffer.CmdBeginRenderPass(aRenderPassBegin,contents);
      Inc(fCommandCount);
    Except
      SetBufferState(BS_INVALID);
    End;
  End
  else
    Assert((fBufferState = BS_RECORDING) ,'Not valid Buffer State');

end;

procedure TvgCommandBuffer.CmdBindDescriptorSets(
  pipelineBindPoint: TVkPipelineBindPoint; layout: TVkPipelineLayout; firstSet,
  descriptorSetCount: TvkUint32; const aDescriptorSets: PVkDescriptorSet;
  dynamicOffsetCount: TvkUint32; const aDynamicOffsets: PvkUInt32);
begin
  if not assigned(fVulkanCommandBuffer) then exit;
  if (fVulkanCommandBuffer.Handle=VK_NULL_HANDLE) then exit;

  if (fBufferState=BS_RECORDING) then
  Begin
    Try
      fVulkanCommandBuffer.CmdBindDescriptorSets(pipelineBindPoint,
                                                 layout,
                                                 firstset,
                                                 descriptorSetCount,
                                                 aDescriptorSets,
                                                 dynamicOffsetCount,
                                                 PpvUint32(aDynamicOffsets));
      Inc(fCommandCount);
    Except
      SetBufferState(BS_INVALID);
    End;
  End
  else
    Assert((fBufferState = BS_RECORDING) ,'Not valid Buffer State');

end;

procedure TvgCommandBuffer.CmdBindIndexBuffer(buffer: TVkBuffer;
  offset: TVkDeviceSize; indexType: TVkIndexType);
begin
  if not assigned(fVulkanCommandBuffer) then exit;
  if (fVulkanCommandBuffer.Handle=VK_NULL_HANDLE) then exit;

  if (fBufferState=BS_RECORDING) then
  Begin
    Try
      fVulkanCommandBuffer.CmdBindIndexBuffer(buffer,
                                              Offset,
                                              indexType);
      Inc(fCommandCount);
    Except
      SetBufferState(BS_INVALID);
    End;
  End
  else
    Assert((fBufferState = BS_RECORDING) ,'Not valid Buffer State');

end;

procedure TvgCommandBuffer.CmdBindPipeline(
  pipelineBindPoint: TVkPipelineBindPoint; pipeline: TVkPipeline);
begin
  if not assigned(fVulkanCommandBuffer) then exit;
  if (fVulkanCommandBuffer.Handle=VK_NULL_HANDLE) then exit;

  if (fBufferState=BS_RECORDING) then
  Begin
    Try
      fVulkanCommandBuffer.CmdBindPipeline(pipelineBindPoint,
                                              pipeline);
      Inc(fCommandCount);
    Except
      SetBufferState(BS_INVALID);
    End;
  End
  else
    Assert((fBufferState = BS_RECORDING) ,'Not valid Buffer State');

end;

procedure TvgCommandBuffer.CmdBindVertexBuffers(firstBinding,
  bindingCount: TvkUint32; const aBuffers: PVkBuffer;
  const aOffsets: PVkDeviceSize);
begin
  if not assigned(fVulkanCommandBuffer) then exit;
  if (fVulkanCommandBuffer.Handle=VK_NULL_HANDLE) then exit;

  if (fBufferState=BS_RECORDING) then
  Begin
    Try
      fVulkanCommandBuffer.CmdBindVertexBuffers(firstBinding,
                                                bindingCount,
                                                aBuffers,
                                                aOffsets);
      Inc(fCommandCount);
    Except
      SetBufferState(BS_INVALID);
    End;
  End
  else
    Assert((fBufferState = BS_RECORDING) ,'Not valid Buffer State');

end;

procedure TvgCommandBuffer.CmdBlitImage(srcImage: TVkImage;
  srcImageLayout: TVkImageLayout; dstImage: TVkImage;
  dstImageLayout: TVkImageLayout; regionCount: TvkUint32;
  const aRegions: PVkImageBlit; filter: TVkFilter);
begin
  if not assigned(fVulkanCommandBuffer) then exit;
  if (fVulkanCommandBuffer.Handle=VK_NULL_HANDLE) then exit;

  if (fBufferState=BS_RECORDING) then
  Begin
    Try
      fVulkanCommandBuffer.CmdBlitImage(srcImage,
                                                srcImageLayout,
                                                dstImage,
                                                dstImageLayout,
                                                regionCount,
                                                aRegions,
                                                filter);
      Inc(fCommandCount);
    Except
      SetBufferState(BS_INVALID);
    End;
  End
  else
    Assert((fBufferState = BS_RECORDING) ,'Not valid Buffer State');

end;

procedure TvgCommandBuffer.CmdClearAttachments(attachmentCount: TvkUint32;
  const aAttachments: PVkClearAttachment; rectCount: TvkUint32;
  const aRects: PVkClearRect);
begin
  if not assigned(fVulkanCommandBuffer) then exit;
  if (fVulkanCommandBuffer.Handle=VK_NULL_HANDLE) then exit;

  if (fBufferState=BS_RECORDING) then
  Begin
    Try
      fVulkanCommandBuffer.CmdClearAttachments(attachmentCount,
                                                aAttachments,
                                                rectCount,
                                                aRects);
      Inc(fCommandCount);
    Except
      SetBufferState(BS_INVALID);
    End;
  End
  else
    Assert((fBufferState = BS_RECORDING) ,'Not valid Buffer State');

end;

procedure TvgCommandBuffer.CmdClearColorImage(image: TVkImage;
  imageLayout: TVkImageLayout; const aColor: PVkClearColorValue;
  rangeCount: TvkUint32; const aRanges: PVkImageSubresourceRange);
begin
  if not assigned(fVulkanCommandBuffer) then exit;
  if (fVulkanCommandBuffer.Handle=VK_NULL_HANDLE) then exit;

  if (fBufferState=BS_RECORDING) then
  Begin
    Try
      fVulkanCommandBuffer.CmdClearColorImage(image,
                                                imageLayout,
                                                aColor,
                                                rangeCount,
                                                aRanges);
      Inc(fCommandCount);
    Except
      SetBufferState(BS_INVALID);
    End;
  End
  else
    Assert((fBufferState = BS_RECORDING) ,'Not valid Buffer State');

end;

procedure TvgCommandBuffer.CmdClearDepthStencilImage(image: TVkImage;
  imageLayout: TVkImageLayout; const aDepthStencil: PVkClearDepthStencilValue;
  rangeCount: TvkUint32; const aRanges: PVkImageSubresourceRange);
begin
  if not assigned(fVulkanCommandBuffer) then exit;
  if (fVulkanCommandBuffer.Handle=VK_NULL_HANDLE) then exit;

  if (fBufferState=BS_RECORDING) then
  Begin
    Try
      fVulkanCommandBuffer.CmdClearDepthStencilImage(image,
                                                imageLayout,
                                                aDepthStencil,
                                                rangeCount,
                                                aRanges);
      Inc(fCommandCount);
    Except
      SetBufferState(BS_INVALID);
    End;
  End
  else
    Assert((fBufferState = BS_RECORDING) ,'Not valid Buffer State');

end;

procedure TvgCommandBuffer.CmdCopyBuffer(srcBuffer, dstBuffer: TVkBuffer;
  regionCount: TvkUint32; const aRegions: PVkBufferCopy);
begin
  if not assigned(fVulkanCommandBuffer) then exit;
  if (fVulkanCommandBuffer.Handle=VK_NULL_HANDLE) then exit;

  if (fBufferState=BS_RECORDING) then
  Begin
    Try
      fVulkanCommandBuffer.CmdCopyBuffer(srcBuffer,
                                                dstBuffer,
                                                regionCount,
                                                aRegions);
      Inc(fCommandCount);
    Except
      SetBufferState(BS_INVALID);
    End;
  End
  else
    Assert((fBufferState = BS_RECORDING) ,'Not valid Buffer State');

end;

procedure TvgCommandBuffer.CmdCopyBufferToImage(srcBuffer: TVkBuffer;
  dstImage: TVkImage; dstImageLayout: TVkImageLayout; regionCount: TvkUint32;
  const aRegions: PVkBufferImageCopy);
begin
  if not assigned(fVulkanCommandBuffer) then exit;
  if (fVulkanCommandBuffer.Handle=VK_NULL_HANDLE) then exit;

  if (fBufferState=BS_RECORDING) then
  Begin
    Try
      fVulkanCommandBuffer.CmdCopyBufferToImage(srcBuffer,
                                                dstImage,
                                                dstImageLayout,
                                                regionCount,
                                                aRegions);
      Inc(fCommandCount);
    Except
      SetBufferState(BS_INVALID);
    End;
  End
  else
    Assert((fBufferState = BS_RECORDING) ,'Not valid Buffer State');

end;

procedure TvgCommandBuffer.CmdCopyImage(srcImage: TVkImage;
  srcImageLayout: TVkImageLayout; dstImage: TVkImage;
  dstImageLayout: TVkImageLayout; regionCount: TvkUint32;
  const aRegions: PVkImageCopy);
begin
  if not assigned(fVulkanCommandBuffer) then exit;
  if (fVulkanCommandBuffer.Handle=VK_NULL_HANDLE) then exit;

  if (fBufferState=BS_RECORDING) then
  Begin
    Try
      fVulkanCommandBuffer.CmdCopyImage(srcImage,
                                        srcImageLayout,
                                                dstImage,
                                                dstImageLayout,
                                                regionCount,
                                                aRegions);
      Inc(fCommandCount);
    Except
      SetBufferState(BS_INVALID);
    End;
  End
  else
    Assert((fBufferState = BS_RECORDING) ,'Not valid Buffer State');

end;

procedure TvgCommandBuffer.CmdCopyImageToBuffer(srcImage: TVkImage;
  srcImageLayout: TVkImageLayout; dstBuffer: TVkBuffer; regionCount: TvkUint32;
  const aRegions: PVkBufferImageCopy);
begin
  if not assigned(fVulkanCommandBuffer) then exit;
  if (fVulkanCommandBuffer.Handle=VK_NULL_HANDLE) then exit;

  if (fBufferState=BS_RECORDING) then
  Begin
    Try
      fVulkanCommandBuffer.CmdCopyImageToBuffer(srcImage,
                                                srcImageLayout,
                                                dstBuffer,
                                                regionCount,
                                                aRegions);
      Inc(fCommandCount);
    Except
      SetBufferState(BS_INVALID);
    End;
  End
  else
    Assert((fBufferState = BS_RECORDING) ,'Not valid Buffer State');

end;

procedure TvgCommandBuffer.CmdCopyQueryPoolResults(queryPool: TVkQueryPool;
  firstQuery, queryCount: TvkUint32; dstBuffer: TVkBuffer; dstOffset,
  stride: TVkDeviceSize; flags: TVkQueryResultFlags);
begin
  if not assigned(fVulkanCommandBuffer) then exit;
  if (fVulkanCommandBuffer.Handle=VK_NULL_HANDLE) then exit;

  if (fBufferState=BS_RECORDING) then
  Begin
    Try
      fVulkanCommandBuffer.CmdCopyQueryPoolResults(queryPool,
                                                firstQuery,
                                                queryCount,
                                                dstBuffer,
                                                dstOffset,
                                                stride,
                                                flags);
      Inc(fCommandCount);
    Except
      SetBufferState(BS_INVALID);
    End;
  End
  else
    Assert((fBufferState = BS_RECORDING) ,'Not valid Buffer State');

end;

procedure TvgCommandBuffer.CmdDispatch(x, y, z: TvkUint32);
begin
  if not assigned(fVulkanCommandBuffer) then exit;
  if (fVulkanCommandBuffer.Handle=VK_NULL_HANDLE) then exit;

  if (fBufferState=BS_RECORDING) then
  Begin
    Try
      fVulkanCommandBuffer.CmdDispatch(X,Y,Z);
      Inc(fCommandCount);
    Except
      SetBufferState(BS_INVALID);
    End;
  End
  else
    Assert((fBufferState = BS_RECORDING) ,'Not valid Buffer State');

end;

procedure TvgCommandBuffer.CmdDispatchIndirect(buffer: TVkBuffer;
  offset: TVkDeviceSize);
begin
  if not assigned(fVulkanCommandBuffer) then exit;
  if (fVulkanCommandBuffer.Handle=VK_NULL_HANDLE) then exit;

  if (fBufferState=BS_RECORDING) then
  Begin
    Try
      fVulkanCommandBuffer.CmdDispatchIndirect(buffer,
                                                offset);
      Inc(fCommandCount);
    Except
      SetBufferState(BS_INVALID);
    End;
  End
  else
    Assert((fBufferState = BS_RECORDING) ,'Not valid Buffer State');

end;

procedure TvgCommandBuffer.CmdDraw(vertexCount, instanceCount, firstVertex,
  firstInstance: TvkUint32);
begin
  if not assigned(fVulkanCommandBuffer) then exit;
  if (fVulkanCommandBuffer.Handle=VK_NULL_HANDLE) then exit;

  if (fBufferState=BS_RECORDING) then
  Begin
    Try
      fVulkanCommandBuffer.CmdDraw(vertexCount,
                                   instanceCount,
                                   firstVertex,
                                   firstInstance);
      Inc(fCommandCount);
    Except
      SetBufferState(BS_INVALID);
    End;
  End
  else
    Assert((fBufferState = BS_RECORDING) ,'Not valid Buffer State');

end;

procedure TvgCommandBuffer.CmdDrawIndexed(indexCount, instanceCount,
  firstIndex: TvkUint32; vertexOffset: TvkInt32; firstInstance: TvkUint32);
begin
  if not assigned(fVulkanCommandBuffer) then exit;
  if (fVulkanCommandBuffer.Handle=VK_NULL_HANDLE) then exit;

  if (fBufferState=BS_RECORDING) then
  Begin
    Try
      fVulkanCommandBuffer.CmdDrawIndexed(indexCount,
                                   instanceCount,
                                   firstIndex,
                                   vertexOffset,
                                   firstInstance);
      Inc(fCommandCount);
    Except
      SetBufferState(BS_INVALID);
    End;
  End
  else
    Assert((fBufferState = BS_RECORDING) ,'Not valid Buffer State');

end;

procedure TvgCommandBuffer.CmdDrawIndexedIndirect(buffer: TVkBuffer;
  offset: TVkDeviceSize; drawCount, stride: TvkUint32);
begin
  if not assigned(fVulkanCommandBuffer) then exit;
  if (fVulkanCommandBuffer.Handle=VK_NULL_HANDLE) then exit;

  if (fBufferState=BS_RECORDING) then
  Begin
    Try
      fVulkanCommandBuffer.CmdDrawIndexedIndirect(buffer,
                                   offset,
                                   drawCount,
                                   stride);
      Inc(fCommandCount);
    Except
      SetBufferState(BS_INVALID);
    End;
  End
  else
    Assert((fBufferState = BS_RECORDING) ,'Not valid Buffer State');

end;

procedure TvgCommandBuffer.CmdDrawIndirect(buffer: TVkBuffer;
  offset: TVkDeviceSize; drawCount, stride: TvkUint32);
begin
  if not assigned(fVulkanCommandBuffer) then exit;
  if (fVulkanCommandBuffer.Handle=VK_NULL_HANDLE) then exit;

  if (fBufferState=BS_RECORDING) then
  Begin
    Try
      fVulkanCommandBuffer.CmdDrawIndirect(buffer,
                                   offset,
                                   drawCount,
                                   stride);
      Inc(fCommandCount);
    Except
      SetBufferState(BS_INVALID);
    End;
  End
  else
    Assert((fBufferState = BS_RECORDING) ,'Not valid Buffer State');

end;

procedure TvgCommandBuffer.CmdEndQuery(queryPool: TVkQueryPool;
  query: TvkUint32);
begin
  if not assigned(fVulkanCommandBuffer) then exit;
  if (fVulkanCommandBuffer.Handle=VK_NULL_HANDLE) then exit;

  if (fBufferState=BS_RECORDING) then
  Begin
    Try
      fVulkanCommandBuffer.CmdEndQuery(queryPool, query);
      Inc(fCommandCount);
    Except
      SetBufferState(BS_INVALID);
    End;
  End
  else
    Assert((fBufferState = BS_RECORDING) ,'Not valid Buffer State');

end;

procedure TvgCommandBuffer.CmdEndRenderPass;
begin
  if not assigned(fVulkanCommandBuffer) then exit;
  if (fVulkanCommandBuffer.Handle=VK_NULL_HANDLE) then exit;

  if (fBufferState=BS_RECORDING) then
  Begin
    Try
      fVulkanCommandBuffer.CmdEndRenderPass;
      Inc(fCommandCount);
    Except
      SetBufferState(BS_INVALID);
    End;
  End
  else
    Assert((fBufferState = BS_RECORDING) ,'Not valid Buffer State');

end;

procedure TvgCommandBuffer.CmdExecute( const aCommandBuffer: TpvVulkanCommandBuffer);
begin
  if not assigned(fVulkanCommandBuffer) then exit;
  if (fVulkanCommandBuffer.Handle=VK_NULL_HANDLE) then exit;

  if (fBufferState=BS_EXECUTABLE) and (fCommandCount>0) then
  Begin
    Try
      fVulkanCommandBuffer.CmdExecute(aCommandBuffer);


      if NOT TestCommandBufferUsageFlagsValue(fBufferUse,
                          TVkCommandBufferUsageFlags(VK_COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT) ) then
        SetBufferState(BS_PENDING)
      else
        SetBufferState(BS_INVALID);

    Except
      SetBufferState(BS_INVALID);
    End;
  End
  else
    Assert((fBufferState = BS_RECORDING) ,'Not valid Buffer State');

end;

procedure TvgCommandBuffer.CmdExecuteCommands(commandBufferCount: TvkUint32;
                                             const aCommandBuffers: PVkCommandBuffer);
begin
  if not assigned(fVulkanCommandBuffer) then exit;
  if (fVulkanCommandBuffer.Handle=VK_NULL_HANDLE) then exit;

  if (fBufferState=BS_RECORDING) then
  Begin
    Try
      fVulkanCommandBuffer.CmdExecuteCommands(commandBufferCount,
                                              aCommandBuffers);

      Inc(fCommandCount);
    Except
      SetBufferState(BS_INVALID);
    End;
  End ;
 // else
  //  Assert((fBufferState = BS_RECORDING) ,'Not valid Buffer State');

end;

procedure TvgCommandBuffer.CmdFillBuffer(dstBuffer: TVkBuffer; dstOffset,
  size: TVkDeviceSize; data: TvkUint32);
begin
  if not assigned(fVulkanCommandBuffer) then exit;
  if (fVulkanCommandBuffer.Handle=VK_NULL_HANDLE) then exit;

  if (fBufferState=BS_RECORDING) then
  Begin
    Try
      fVulkanCommandBuffer.CmdFillBuffer(dstBuffer,
                                         dstOffset,
                                         Size,
                                         data);

      Inc(fCommandCount);
    Except
      SetBufferState(BS_INVALID);
    End;
  End
  else
    Assert((fBufferState = BS_RECORDING) ,'Not valid Buffer State');

end;

procedure TvgCommandBuffer.CmdNextSubpass(contents: TVkSubpassContents);
begin
  if not assigned(fVulkanCommandBuffer) then exit;
  if (fVulkanCommandBuffer.Handle=VK_NULL_HANDLE) then exit;

  if (fBufferState=BS_RECORDING) then
  Begin
    Try
      fVulkanCommandBuffer.CmdNextSubpass(contents);
      Inc(fCommandCount);
    Except
      SetBufferState(BS_INVALID);
    End;
  End;
 // else
  //  Assert((fBufferState = BS_RECORDING) ,'Not valid Buffer State');

end;

procedure TvgCommandBuffer.CmdPipelineBarrier(srcStageMask,
  dstStageMask: TVkPipelineStageFlags; dependencyFlags: TVkDependencyFlags;
  memoryBarrierCount: TvkUint32; const aMemoryBarriers: PVkMemoryBarrier;
  bufferMemoryBarrierCount: TvkUint32;
  const aBufferMemoryBarriers: PVkBufferMemoryBarrier;
  imageMemoryBarrierCount: TvkUint32;
  const aImageMemoryBarriers: PVkImageMemoryBarrier);
begin
  if not assigned(fVulkanCommandBuffer) then exit;
  if (fVulkanCommandBuffer.Handle=VK_NULL_HANDLE) then exit;

  if (fBufferState=BS_RECORDING) then
  Begin
    Try
      fVulkanCommandBuffer.CmdPipelineBarrier(srcStageMask,
                                         dstStageMask,
                                         dependencyFlags,
                                         memoryBarrierCount,
                                         aMemoryBarriers,
                                         bufferMemoryBarrierCount,
                                         aBufferMemoryBarriers,
                                         imageMemoryBarrierCount,
                                         aImageMemoryBarriers);

      Inc(fCommandCount);
    Except
      SetBufferState(BS_INVALID);
    End;
  End
  else
    Assert((fBufferState = BS_RECORDING) ,'Not valid Buffer State');

end;

procedure TvgCommandBuffer.CmdPushConstants(layout: TVkPipelineLayout;
  stageFlags: TVkShaderStageFlags; offset, size: TvkUint32;
  const aValues: PVkVoid);
begin
  if not assigned(fVulkanCommandBuffer) then exit;
  if (fVulkanCommandBuffer.Handle=VK_NULL_HANDLE) then exit;

  if (fBufferState=BS_RECORDING)  then
  Begin
    Try
      fVulkanCommandBuffer.CmdPushConstants(layout,
                                            stageFlags,
                                            offset,
                                            size,
                                            aValues);
      Inc(fCommandCount);

    Except
      SetBufferState(BS_INVALID);
    End;
  End
  else
    Assert((fBufferState = BS_RECORDING) ,'Not valid Buffer State');

end;

procedure TvgCommandBuffer.CmdResetEvent(event: TVkEvent;
  stageMask: TVkPipelineStageFlags);
begin
  if not assigned(fVulkanCommandBuffer) then exit;
  if (fVulkanCommandBuffer.Handle=VK_NULL_HANDLE) then exit;

  if (fBufferState=BS_RECORDING)  then
  Begin
    Try
      fVulkanCommandBuffer.CmdResetEvent(event,
                                            stageMask);

      Inc(fCommandCount);
    Except
      SetBufferState(BS_INVALID);
    End;
  End
  else
    Assert((fBufferState = BS_RECORDING) ,'Not valid Buffer State');

end;

procedure TvgCommandBuffer.CmdResetQueryPool(queryPool: TVkQueryPool;
  firstQuery, queryCount: TvkUint32);
begin
  if not assigned(fVulkanCommandBuffer) then exit;
  if (fVulkanCommandBuffer.Handle=VK_NULL_HANDLE) then exit;

  if (fBufferState=BS_RECORDING)  then
  Begin
    Try
      fVulkanCommandBuffer.CmdResetQueryPool(queryPool,
                                            firstQuery,
                                            queryCount);

      Inc(fCommandCount);
    Except
      SetBufferState(BS_INVALID);
    End;
  End
  else
    Assert((fBufferState = BS_RECORDING) ,'Not valid Buffer State');

end;

procedure TvgCommandBuffer.CmdResolveImage(srcImage: TVkImage;
  srcImageLayout: TVkImageLayout; dstImage: TVkImage;
  dstImageLayout: TVkImageLayout; regionCount: TvkUint32;
  const aRegions: PVkImageResolve);
begin
  if not assigned(fVulkanCommandBuffer) then exit;
  if (fVulkanCommandBuffer.Handle=VK_NULL_HANDLE) then exit;

  if (fBufferState=BS_RECORDING)  then
  Begin
    Try
      fVulkanCommandBuffer.CmdResolveImage(srcImage,
                                            srcImageLayout,
                                            dstImage,
                                            dstImageLayout,
                                            regionCount,
                                            aRegions);
      Inc(fCommandCount);
    Except
      SetBufferState(BS_INVALID);
    End;
  End
  else
    Assert((fBufferState = BS_RECORDING) ,'Not valid Buffer State');

end;

procedure TvgCommandBuffer.CmdSetBlendConstants(const blendConstants: TvkFloat);
begin
  if not assigned(fVulkanCommandBuffer) then exit;
  if (fVulkanCommandBuffer.Handle=VK_NULL_HANDLE) then exit;

  if (fBufferState=BS_RECORDING) then
  Begin
    Try
      fVulkanCommandBuffer.CmdSetBlendConstants(blendConstants);
      Inc(fCommandCount);
    Except
      SetBufferState(BS_INVALID);
    End;
  End
  else
    Assert((fBufferState = BS_RECORDING) ,'Not valid Buffer State');

end;

procedure TvgCommandBuffer.CmdSetCullMode(const cullMode: TVkCullModeFlags);
begin
  if not assigned(fVulkanCommandBuffer) then exit;
  if (fVulkanCommandBuffer.Handle=VK_NULL_HANDLE) then exit;

  if (fBufferState=BS_RECORDING)  then
  Begin
    Try
      fVulkanCommandBuffer.CmdSetCullMode(cullMode);
      Inc(fCommandCount);
    Except
      SetBufferState(BS_INVALID);
    End;
  End
  else
    Assert((fBufferState = BS_RECORDING) ,'Not valid Buffer State');

end;

procedure TvgCommandBuffer.CmdSetDepthBias(depthBiasConstantFactor,
  depthBiasClamp, depthBiasSlopeFactor: TvkFloat);
begin
  if not assigned(fVulkanCommandBuffer) then exit;
  if (fVulkanCommandBuffer.Handle=VK_NULL_HANDLE) then exit;

  if (fBufferState=BS_RECORDING)  then
  Begin
    Try
      fVulkanCommandBuffer.CmdSetDepthBias(depthBiasConstantFactor,
                                           depthBiasClamp,
                                           depthBiasSlopeFactor);
      Inc(fCommandCount);
    Except
      SetBufferState(BS_INVALID);
    End;
  End
  else
    Assert((fBufferState = BS_RECORDING) ,'Not valid Buffer State');

end;

procedure TvgCommandBuffer.CmdSetDepthBounds(minDepthBounds,
  maxDepthBounds: TvkFloat);
begin
  if not assigned(fVulkanCommandBuffer) then exit;
  if (fVulkanCommandBuffer.Handle=VK_NULL_HANDLE) then exit;

  if (fBufferState=BS_RECORDING)  then
  Begin
    Try
      fVulkanCommandBuffer.CmdSetDepthBounds(minDepthBounds,
                                           maxDepthBounds);
      Inc(fCommandCount);
    Except
      SetBufferState(BS_INVALID);
    End;
  End
  else
    Assert((fBufferState = BS_RECORDING) ,'Not valid Buffer State');

end;

procedure TvgCommandBuffer.CmdSetEvent(event: TVkEvent;
  stageMask: TVkPipelineStageFlags);
begin
  if not assigned(fVulkanCommandBuffer) then exit;
  if (fVulkanCommandBuffer.Handle=VK_NULL_HANDLE) then exit;

  if (fBufferState=BS_RECORDING) then
  Begin
    Try
      fVulkanCommandBuffer.CmdSetEvent(event,
                                           stageMask);
      Inc(fCommandCount);
    Except
      SetBufferState(BS_INVALID);
    End;
  End
  else
    Assert((fBufferState = BS_RECORDING) ,'Not valid Buffer State');

end;

procedure TvgCommandBuffer.CmdSetLineWidth(lineWidth: TvkFloat);
begin
  if not assigned(fVulkanCommandBuffer) then exit;
  if (fVulkanCommandBuffer.Handle=VK_NULL_HANDLE) then exit;

  if (fBufferState=BS_RECORDING) then
  Begin
    Try
      fVulkanCommandBuffer.CmdSetLineWidth(lineWidth);
      Inc(fCommandCount);
    Except
      SetBufferState(BS_INVALID);
    End;
  End
  else
    Assert((fBufferState = BS_RECORDING) ,'Not valid Buffer State');

end;

procedure TvgCommandBuffer.CmdSetScissor(firstScissor, scissorCount: TvkUint32;
  const aScissors: PVkRect2D);
begin
  if not assigned(fVulkanCommandBuffer) then exit;
  if (fVulkanCommandBuffer.Handle=VK_NULL_HANDLE) then exit;

  if (fBufferState=BS_RECORDING)  then
  Begin
    Try
      fVulkanCommandBuffer.CmdSetScissor(firstScissor,
                                         scissorCount,
                                         aScissors);
      Inc(fCommandCount);
    Except
      SetBufferState(BS_INVALID);
    End;
  End
  else
    Assert((fBufferState = BS_RECORDING) ,'Not valid Buffer State');

end;

procedure TvgCommandBuffer.CmdSetStencilCompareMask(
  faceMask: TVkStencilFaceFlags; compareMask: TvkUint32);
begin
  if not assigned(fVulkanCommandBuffer) then exit;
  if (fVulkanCommandBuffer.Handle=VK_NULL_HANDLE) then exit;

  if (fBufferState=BS_RECORDING) then
  Begin
    Try
      fVulkanCommandBuffer.CmdSetStencilCompareMask(faceMask,
                                         compareMask);
      Inc(fCommandCount);
    Except
      SetBufferState(BS_INVALID);
    End;
  End
  else
    Assert((fBufferState = BS_RECORDING) ,'Not valid Buffer State');

end;

procedure TvgCommandBuffer.CmdSetStencilReference(faceMask: TVkStencilFaceFlags;
  reference: TvkUint32);
begin
  if not assigned(fVulkanCommandBuffer) then exit;
  if (fVulkanCommandBuffer.Handle=VK_NULL_HANDLE) then exit;

  if (fBufferState=BS_RECORDING)  then
  Begin
    Try
      fVulkanCommandBuffer.CmdSetStencilReference(faceMask,
                                         reference);
      Inc(fCommandCount);
    Except
      SetBufferState(BS_INVALID);
    End;
  End ;
 // else
  //  Assert((fBufferState = BS_RECORDING) ,'Not valid Buffer State');

end;

procedure TvgCommandBuffer.CmdSetStencilWriteMask(faceMask: TVkStencilFaceFlags;
  writeMask: TvkUint32);
begin
  if not assigned(fVulkanCommandBuffer) then exit;
  if (fVulkanCommandBuffer.Handle=VK_NULL_HANDLE) then exit;

  if (fBufferState=BS_RECORDING)  then
  Begin
    Try
      fVulkanCommandBuffer.CmdSetStencilWriteMask(faceMask,
                                         writeMask);
      Inc(fCommandCount);
    Except
      SetBufferState(BS_INVALID);
    End;
  End
  else
    Assert((fBufferState = BS_RECORDING) ,'Not valid Buffer State');

end;

procedure TvgCommandBuffer.CmdSetViewport(firstViewport,
  viewportCount: TvkUint32; const aViewports: PVkViewport);
begin
  if not assigned(fVulkanCommandBuffer) then exit;
  if (fVulkanCommandBuffer.Handle=VK_NULL_HANDLE) then exit;

  if (fBufferState=BS_RECORDING)  then
  Begin
    Try
      fVulkanCommandBuffer.CmdSetViewport(firstViewport,
                                         viewportCount,
                                         aViewports);
      Inc(fCommandCount);
    Except
      SetBufferState(BS_INVALID);
    End;
  End
  else
    Assert((fBufferState = BS_RECORDING) ,'Not valid Buffer State');

end;

procedure TvgCommandBuffer.CmdUpdateBuffer(dstBuffer: TVkBuffer; dstOffset,
  dataSize: TVkDeviceSize; const aData: PVkVoid);
begin
  if not assigned(fVulkanCommandBuffer) then exit;
  if (fVulkanCommandBuffer.Handle=VK_NULL_HANDLE) then exit;

  if (fBufferState=BS_RECORDING)  then
  Begin
    Try
      fVulkanCommandBuffer.CmdUpdateBuffer(dstBuffer,
                                         dstOffset,
                                         dataSize,
                                         aData);
      Inc(fCommandCount);
    Except
      SetBufferState(BS_INVALID);
    End;
  End
  else
    Assert((fBufferState = BS_RECORDING) ,'Not valid Buffer State');

end;

procedure TvgCommandBuffer.CmdWaitEvents(eventCount: TvkUint32;
  const aEvents: PVkEvent; srcStageMask, dstStageMask: TVkPipelineStageFlags;
  memoryBarrierCount: TvkUint32; const aMemoryBarriers: PVkMemoryBarrier;
  bufferMemoryBarrierCount: TvkUint32;
  const aBufferMemoryBarriers: PVkBufferMemoryBarrier;
  imageMemoryBarrierCount: TvkUint32;
  const aImageMemoryBarriers: PVkImageMemoryBarrier);
begin
  if not assigned(fVulkanCommandBuffer) then exit;
  if (fVulkanCommandBuffer.Handle=VK_NULL_HANDLE) then exit;

  if (fBufferState=BS_RECORDING)  then
  Begin
    Try
      fVulkanCommandBuffer.CmdWaitEvents(eventCount,
                                         aEvents,
                                         srcStageMask,
                                         dstStageMask,
                                         memoryBarrierCount,
                                         aMemoryBarriers,
                                         bufferMemoryBarrierCount,
                                         aBufferMemoryBarriers,
                                         imageMemoryBarrierCount,
                                         aImageMemoryBarriers);
      Inc(fCommandCount);
    Except
      SetBufferState(BS_INVALID);
    End;
  End
  else
    Assert((fBufferState = BS_RECORDING) ,'Not valid Buffer State');

end;

procedure TvgCommandBuffer.CmdWriteTimestamp(
  pipelineStage: TVkPipelineStageFlagBits; queryPool: TVkQueryPool;
  query: TvkUint32);
begin
  if not assigned(fVulkanCommandBuffer) then exit;
  if (fVulkanCommandBuffer.Handle=VK_NULL_HANDLE) then exit;

  if (fBufferState=BS_RECORDING)  then
  Begin
    Try
      fVulkanCommandBuffer.CmdWriteTimestamp(pipelineStage,
                                         queryPool,
                                         query);
      Inc(fCommandCount);
    Except
      SetBufferState(BS_INVALID);
    End;
  End
  else
    Assert((fBufferState = BS_RECORDING) ,'Not valid Buffer State');

end;

constructor TvgCommandBuffer.Create;
begin
 // inherited;
  fCommandLevel := CB_PRIMARY;
end;

destructor TvgCommandBuffer.Destroy;
begin
  SetDisabled;
  inherited;
end;

procedure TvgCommandBuffer.EndRecording;
begin
  if not assigned(fVulkanCommandBuffer) then exit;
  if (fVulkanCommandBuffer.Handle=VK_NULL_HANDLE) then exit;
                                                  //   problem here
  if (fBufferState=BS_RECORDING) then
  Begin
    Try
      if (fCommandCount>0) then
      Begin
          fVulkanCommandBuffer.EndRecording;
          SetBufferState(BS_EXECUTABLE);
      end else
      Begin
          fVulkanCommandBuffer.Reset(1);
          SetBufferState(BS_INITIAL);
      end;
    Except
      SetBufferState(BS_INVALID);
    End;
  End ;
//  else
//    Assert((fBufferState = BS_RECORDING) ,'Not valid Buffer State');

end;

procedure TvgCommandBuffer.Execute(const aQueue: TpvVulkanQueue;
  const aWaitDstStageFlags: TVkPipelineStageFlags; const aWaitSemaphore,
  aSignalSemaphore: TpvVulkanSemaphore;{ const aFence: TpvVulkanFence; }
  const aDoWaitAndResetFence: boolean);

  //  Var B:Boolean;
begin
  if not assigned(fVulkanCommandBuffer) then exit;
  if (fVulkanCommandBuffer.Handle=VK_NULL_HANDLE) then exit;
  if NOT assigned(fBufferFence) then exit;

  if (fCommandLevel=CB_SECONDARY) then exit;  //cant execute a secondary commend

  if (fBufferState=BS_EXECUTABLE) then
  Begin
    Try

     // if assigned(fBufferFence) and (fBufferFence.GetStatus = VK_SUCCESS) then
       //  fBufferFence.Reset;

      fVulkanCommandBuffer.Execute(aQueue,
                                   aWaitDstStageFlags,
                                   aWaitSemaphore,
                                   aSignalSemaphore,
                                   fBufferFence,
                                   aDoWaitAndResetFence);

      if assigned(fBufferFence)  then
         fFenceSet:=True;

      if aDoWaitAndResetFence then  //execute will wait on fence to be able to set command buffer state
      Begin
         if NOT TestCommandBufferUsageFlagsValue(fBufferUse,
                                   TVkCommandBufferUsageFlags(VK_COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT) ) then
              SetBufferState(BS_INITIAL)
         else
              SetBufferState(BS_INVALID);

         if assigned(fBufferFence) then
                     fBufferFence.Reset;
      End else
         SetBufferState(BS_PENDING);   //waiting to finish

    Except
      SetBufferState(BS_INVALID);
    End;
  End ;
 // else
 //   Assert((fBufferState = BS_RECORDING) ,'Not valid Buffer State');

end;

function TvgCommandBuffer.GetActive: Boolean;
begin
  Result:=fActive;
end;

function TvgCommandBuffer.GetCommandBufferLevel: TvgCommandBufferLevel;
begin
  Result:= fCommandLevel;
end;

function TvgCommandBuffer.GetUseFlags: TvgCommandBufferUsageFlags;
begin
  Result := GetVGCommandBufferUsageFlags(fBufferUse);
end;

procedure TvgCommandBuffer.MetaCmdDrawToPresentImageBarrier(
  const aImage: TpvVulkanImage; const aDoTransitionToPresentSrcLayout: boolean);
begin

  if not assigned(fVulkanCommandBuffer) then exit;
  if (fVulkanCommandBuffer.Handle=VK_NULL_HANDLE) then exit;
                                                  //   problem here
  if (fBufferState=BS_RECORDING)  then
  Begin
    Try
      fVulkanCommandBuffer.MetaCmdDrawToPresentImageBarrier(aImage,aDoTransitionToPresentSrcLayout);

    Except
      SetBufferState(BS_INVALID);
    End;
  End ;
end;

procedure TvgCommandBuffer.MetaCmdMemoryBarrier(const aSrcStageMask,
  aDstStageMask: TVkPipelineStageFlags; const aSrcAccessMask,
  aDstAccessMask: TVkAccessFlags);
begin
  if not assigned(fVulkanCommandBuffer) then exit;
  if (fVulkanCommandBuffer.Handle=VK_NULL_HANDLE) then exit;
                                                  //   problem here
  if (fBufferState=BS_RECORDING)  then
  Begin
    Try
      fVulkanCommandBuffer.MetaCmdMemoryBarrier(aSrcStageMask,aDstStageMask,aSrcAccessMask,aDstAccessMask);

    Except
      SetBufferState(BS_INVALID);
    End;
  End ;
end;

procedure TvgCommandBuffer.MetaCmdPresentToDrawImageBarrier(
  const aImage: TpvVulkanImage;
  const aDoTransitionToColorAttachmentOptimalLayout: boolean);
begin
  if not assigned(fVulkanCommandBuffer) then exit;
  if (fVulkanCommandBuffer.Handle=VK_NULL_HANDLE) then exit;
                                                  //   problem here
  if (fBufferState=BS_RECORDING)  then
  Begin
    Try
      fVulkanCommandBuffer.MetaCmdPresentToDrawImageBarrier(aImage, aDoTransitionToColorAttachmentOptimalLayout);

    Except
      SetBufferState(BS_INVALID);
    End;
  End ;
end;

procedure TvgCommandBuffer.Reset(const aFlags: TVkCommandBufferResetFlags);
   Var ResetOK :boolean;

begin
  if not assigned(fVulkanCommandBuffer) then exit;
  if (fVulkanCommandBuffer.Handle=VK_NULL_HANDLE) then exit;

  ResetOK :=  NOT TestCommandBufferUsageFlagsValue(fBufferUse,  TVkCommandBufferUsageFlags(VK_COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT) ) ;

  If (fBufferState=BS_PENDING) and WaitOnFence then //waitfor will reset the fBufferFence
  Begin
     If ResetOK then
        SetBufferState(BS_EXECUTABLE)
     else
        SetBufferState(BS_INVALID) ;
  End;

  if Assigned(fBufferFence) then
  Begin
       If (fBufferFence.GetStatus=VK_SUCCESS) then
         fBufferFence.Reset;
  End;

  if (fBufferState in [BS_RECORDING,
                       BS_EXECUTABLE]) then
  Begin

    Try

        if ResetOK then
        Begin
          fVulkanCommandBuffer.Reset(aFlags) ;
          SetBufferState(BS_INITIAL) ;

        end else
          SetBufferState(BS_INVALID) ;

    Except
      SetBufferState(BS_INVALID);
    End;
 End ;

  //else
  //  Assert((fBufferState = BS_RECORDING) ,'Not valid Buffer State');

end;

procedure TvgCommandBuffer.SetActive(const Value: Boolean);
begin
  If fActive=Value then exit;
  SetDisabled;
  fActive:=Value;
  If fActive then
    SetEnabled;
end;

Function TvgCommandBuffer.SetBufferState(aState: TvgBufferState; ForceState:Boolean=False):Boolean;
 // Var VR:TvkResult;

begin
  Result := True;

  if ForceState then
  Begin
    if assigned(fBufferFence) and (fBufferFence.GetStatus=VK_SUCCESS) and
      (aState in [BS_INITIAL,BS_INVALID,BS_INACTIVE]) then
       fBufferFence.Reset;
  end;


  if fBufferState=aState then exit;

  Result := False;

  case aState of
       BS_INACTIVE,
       BS_INITIAL   :Begin
                       If fBufferState in [BS_RECORDING, BS_EXECUTABLE]  then
                          Begin
                            if (fBufferState=BS_RECORDING) then
                            Begin
                               if assigned(fVulkanCommandBuffer)  then
                                  fVulkanCommandBuffer.EndRecording;
                               fBufferState := BS_EXECUTABLE;
                            end;

                            if assigned(fVulkanCommandBuffer) then
                            Begin
                              if (fBufferState=BS_EXECUTABLE) and NOT TestCommandBufferUsageFlagsValue(fBufferUse,
                                                    TVkCommandBufferUsageFlags(VK_COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT) ) then
                                fVulkanCommandBuffer.Reset(1)
                              else
                                fBufferState := BS_INVALID;
                            End else
                              fBufferState := BS_INACTIVE;
                          end;
                       If fBufferState in [BS_PENDING]  then
                          Begin
                           // need to wait until back in INITIAL or INVALID
                              if WaitOnFence then
                                 fBufferState := BS_INITIAL
                              else
                                 fBufferState := BS_INVALID;
                          end;
                     end;
       BS_RECORDING :if (ForceState = False) and NOT (fBufferState in [BS_INITIAL])    then exit;
       BS_EXECUTABLE:if (ForceState = False) and (NOT (fBufferState in [BS_RECORDING]) or (fCommandCount=0)) then exit;
       BS_PENDING   :if (ForceState = False) and (NOT (fBufferState in [BS_EXECUTABLE]) or (fCommandCount=0)) then exit;
       BS_INVALID   :;//If aState in [] then fBufferState := aState;
  end;

  If  fBufferState=aState then
  Begin
    Result := True;
    exit;
  End;

  case fBufferState of
       BS_INACTIVE  :If (aState in [BS_INITIAL]) or ForceState  then
                        Begin
                          fBufferState := aState;
                          Result       := True;
                          fCommandCount:= 0;
                        End;
       BS_INITIAL   :If (aState in [BS_INACTIVE, BS_RECORDING]) or ForceState then
                        Begin
                          fBufferState := aState;
                          Result       := True;
                          fCommandCount:= 0;
                        End;
       BS_RECORDING :If (aState in [BS_INITIAL,BS_EXECUTABLE]) or ForceState  then
                        Begin
                          fBufferState := aState;
                          Result       := True;
                          fCommandCount:= 0;
                        End;
       BS_EXECUTABLE:If (aState in [BS_INITIAL, BS_PENDING]) or ForceState   then
                        Begin
                          fBufferState := aState;
                          Result       := True;
                        End;
       BS_PENDING   :If (aState in [BS_INITIAL]) or ForceState  then
                        Begin
                          if WaitOnFence then
                          Begin
                            fBufferState := aState;
                            Result       := True;
                          End;
                        End;
       BS_INVALID   :If (aState in [BS_INACTIVE]) or ForceState   then
                        Begin
                          fBufferState := aState;
                          Result       := True;
                        End;
  end;

end;

procedure TvgCommandBuffer.SetCommandBufferLevel(  const Value: TvgCommandBufferLevel);
begin
  If fCommandLevel=Value then exit;
  SetDisabled;
  fCommandLevel:=Value;
end;

procedure TvgCommandBuffer.SetDisabled;
begin

  If assigned(fVulkanCommandBuffer) then
     FreeAndNil(fVulkanCommandBuffer);

  if assigned(fBufferFence) then
     FreeAndNil(fBufferFence);

  fActive:=False;

  SetBufferState(BS_INACTIVE);
end;

procedure TvgCommandBuffer.SetEnabled(aComp:TvgBaseComponent=nil);
  Var CL:TVkCommandBufferLevel;
begin
  fActive := False;

  Assert(assigned(fCommandPool),'Command Pool not assigned');
  Assert(assigned(fCommandPool.fVulkanCommandPool),'Command Pool NOT Active');


  Case fCommandLevel of
       CB_PRIMARY   : CL:= VK_COMMAND_BUFFER_LEVEL_PRIMARY;
       CB_SECONDARY : CL:= VK_COMMAND_BUFFER_LEVEL_SECONDARY;
    else
       CL := VK_COMMAND_BUFFER_LEVEL_PRIMARY;
  End;

  if assigned(fCommandPool) and assigned(fCommandPool.Device) and (fCommandPool.Device.Active)and
                            (CL = VK_COMMAND_BUFFER_LEVEL_PRIMARY) then

  fBufferFence := TpvVulkanFence.Create(fCommandPool.Device.VulkanDevice, 0);
                                   //        TVkFenceCreateFlags(VK_FENCE_CREATE_SIGNALED_BIT)); //fence created in signaled state

 Try

  fVulkanCommandBuffer := TpvVulkanCommandBuffer.Create(fCommandPool.fVulkanCommandPool, CL);

  fActive := Assigned(fVulkanCommandBuffer) and (fVulkanCommandBuffer.Handle<>VK_NULL_HANDLE);

  if fActive then
      SetBufferState(BS_INITIAL)
  else
      SetBufferState(BS_INACTIVE);

 Except
    On ExCeption : EpvVulkanResultException Do
    Begin
      fVulkanCommandBuffer:=nil;
      fActive := False;
      SetBufferState(BS_INVALID);
    End;

 End;
end;

procedure TvgCommandBuffer.SetUseFlags(const Value: TvgCommandBufferUsageFlags);
  Var V: TVkCommandBufferUsageFlags;
begin
   V:=GetVKCommandBufferUsageFlags(Value);
   if fBufferUse=V then exit;
   SetDisabled;
   fBufferUse := V;
end;

function TvgCommandBuffer.WaitOnFence: Boolean;
  Var VR:TvkResult;
begin
  Result:=True;

  Begin
    if assigned(fBufferFence) then
    Begin

      if fFenceSet then
      Begin
        VR := fBufferFence.GetStatus;
        if (VR = VK_TIMEOUT) then
          VR := fBufferFence.WaitFor(); //should wait until signaled  as LONG wait
        fFenceSet := False;
      end;

      fBufferFence.Reset
    End;

  End;

end;

{ TvgGraphicsPipeline }

procedure TvgGraphicPipeline.BindNodeResources(aCommandBuf: TvgCommandBuffer;
                                                 // Commands: TVulkan;
                                                  aWorkerIndex, aSubPassIndex: TvkUint32;
                                                  aNode: TvgRenderNode);
  Var FrameIndex     : TvkUint32;
      DescriptHandle : Array Of TVkDescriptorSet;
      DCount,SN,I    : Integer;
begin

    Assert(assigned(aCommandBuf),'Command not assigned');
    Assert(assigned(fRenderEngine),'Renderer not assigned');
    Assert(assigned(aNode),'Render Node not assigned');

    Assert((fActive=True),'Graphic Pipe not Active');

    Assert(assigned(fRenderEngine),'Renderer not assigned');

    Assert( Assigned(aCommandBuf.VulkanCommandBuffer),'Command Buffer NOT enabled');

    FrameIndex  := fRenderEngine.Linker.FrameIndex;

    //this needs to be done per NODE
    //BIND Node Resources  before call to draw

    DCount:=0;
    I     :=0;
    SN    :=0;

    If (RU_GLOBAL in fResourceUse) and Assigned(fRenderEngine) and assigned(fRenderEngine.GlobalRes) and (fRenderEngine.GlobalRes.Active) and
       (fRenderEngine.GlobalRes.fVulkanDescriptorSets[FrameIndex].handle<>VK_NULL_HANDLE) then
    Begin
       inc(SN);
       //Already Bound
    End;

    If (RU_GRAPHICPIPE in fResourceUse) and assigned(fGraphicPipeRes) and (fGraphicPipeRes.Active) and
       (fGraphicPipeRes.fVulkanDescriptorSets[FrameIndex].handle<>VK_NULL_HANDLE)  then
    Begin
      inc(SN);
      //already bound
    End;

    If (RU_MATERIAL in fResourceUse) and assigned(aNode) and assigned(aNode.MaterialRes[aSubPassIndex]) and
       (aNode.MaterialRes[aSubPassIndex].Active) and
       (aNode.MaterialRes[aSubPassIndex].fVulkanDescriptorSets[FrameIndex].handle<>VK_NULL_HANDLE) then
    Begin
      Inc(DCount);
      SetLength(DescriptHandle,DCount);
      DescriptHandle[I]:= aNode.MaterialRes[aSubPassIndex].fVulkanDescriptorSets[FrameIndex].Handle;
      Inc(I);
    End;

    If (RU_MODEL in fResourceUse) and assigned(aNode) and assigned(aNode.ModelRes[aSubPassIndex]) and
       (aNode.ModelRes[aSubPassIndex].Active) and
       (aNode.ModelRes[aSubPassIndex].fVulkanDescriptorSets[FrameIndex].handle<>VK_NULL_HANDLE) then
    Begin
      Inc(DCount);
      SetLength(DescriptHandle,DCount);
      DescriptHandle[I]:= aNode.ModelRes[aSubPassIndex].fVulkanDescriptorSets[FrameIndex].Handle;
    End;

   //binds the Node related resources

   If DCount>0 then
   Begin
      aCommandBuf.CmdBindDescriptorSets(     VK_PIPELINE_BIND_POINT_GRAPHICS,
                                             fPipelineLayoutHandle,    //important
                                             SN,     //SET value IMPORTANT
                                             DCount,
                                             @DescriptHandle[0],
                                             0,
                                             nil);
      SetLength(DescriptHandle,0);
   end;
end;

procedure TvgGraphicPipeline.BindPipeline(aCommandBuf: TvgCommandBuffer;  aWorkerIndex,aFrameIndex: TvkUint32);
  Var FrameIndex,
      WorkerIndex    : Integer;
begin
  Assert(assigned(fRenderEngine),'Renderer not assigned');

  Assert((fActive=True),'Graphic Pipe not Active');

  Assert(assigned(aCommandBuf),'Command not assigned');
  Assert( Assigned(aCommandBuf.VulkanCommandBuffer),'Command Buffer NOT enabled');

  WorkerIndex := aWorkerIndex;
  FrameIndex  := aFrameIndex;

   If (WorkerIndex < 0) or (WorkerIndex >= Length(fPipelineHandles)) then exit;
   If (FrameIndex  < 0) or (FrameIndex  >= Length(fPipelineHandles[WorkerIndex])) then exit;

  aCommandBuf.CmdBindPipeline(VK_PIPELINE_BIND_POINT_GRAPHICS,
                              fPipelineHandles[WorkerIndex,FrameIndex]);


end;

procedure TvgGraphicPipeline.BindPipelineResources( aCommandBuf: TvgCommandBuffer;
                                                    aWorkerIndex: TvkUint32;
                                                       aSubPassIndex : TvkUint32);
  Var FrameIndex     : TvkUint32;
      DescriptHandle : Array Of TVkDescriptorSet;
      DCount,SN,I    : Integer;
begin

    Assert(assigned(aCommandBuf),'Command not assigned');
    Assert(assigned(fRenderEngine),'Renderer not assigned');

    Assert((fActive=True),'Graphic Pipe not Active');

    Assert(assigned(fRenderEngine),'Renderer not assigned');

    Assert( Assigned(aCommandBuf.VulkanCommandBuffer),'Command Buffer NOT enabled');

    FrameIndex  := fRenderEngine.Linker.FrameIndex;

    //this needs to be done per Pipe change

    DCount:=0;
    I     :=0;
    SN    :=0;

    If (RU_GLOBAL in fResourceUse) and Assigned(fRenderEngine) and assigned(fRenderEngine.GlobalRes) and (fRenderEngine.GlobalRes.Active) and
       (fRenderEngine.GlobalRes.fVulkanDescriptorSets[FrameIndex].handle<>VK_NULL_HANDLE) then
    Begin
      Inc(DCount);
      SetLength(DescriptHandle,DCount);
      DescriptHandle[I]:= fRenderEngine.GlobalRes.fVulkanDescriptorSets[FrameIndex].Handle;
      Inc(I);
    End;

    If (RU_GRAPHICPIPE in fResourceUse) and assigned(fGraphicPipeRes) and (fGraphicPipeRes.Active) and
       (fGraphicPipeRes.fVulkanDescriptorSets[FrameIndex].handle<>VK_NULL_HANDLE)  then
    Begin
      Inc(DCount);
      SetLength(DescriptHandle,DCount);
      DescriptHandle[I]:= fGraphicPipeRes.fVulkanDescriptorSets[FrameIndex].Handle;
    End;

   //binds the Node related resources

   If DCount>0 then
   Begin
      aCommandBuf.CmdBindDescriptorSets(VK_PIPELINE_BIND_POINT_GRAPHICS,
                                             fPipelineLayoutHandle,    //important
                                             SN,     //SET value IMPORTANT
                                             DCount,
                                             @DescriptHandle[0],
                                             0,
                                             nil);
      SetLength(DescriptHandle,0);
   end;

end;

Function TvgGraphicPipeline.BuildFragmentShader:String;
begin
  Result := '';
end;

Function TvgGraphicPipeline.BuildGeometryShader:String;
begin
  Result := '';
end;

Function TvgGraphicPipeline.BuildVertexShader:String;
begin
  Result := '';
end;

procedure TvgGraphicPipeline.CheckDynamicStateCapabilities;
  Var I: Integer;
      D: TvgDynamicState;
      DS:TVkPhysicalDeviceExtendedDynamicStateFeaturesEXT;
begin
  If not fActive then exit;
  If fDynamicStates.Count=0 then exit;

  For I:=0 to fDynamicStates.Count-1 do
  Begin
    D:=fDynamicStates.Items[I];
    If assigned(D) then
    Begin
       DS.sType:=VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_EXTENDED_DYNAMIC_STATE_FEATURES_EXT;
       DS.pNext:=nil;
     //  DS.extendedDynamicState := D.fState;  not finished
    End;


  End;

end;

constructor TvgGraphicPipeline.Create(AOwner: TComponent);
begin

  fViewports         := TvgViewports.Create(self);
  fScissors          := TvgScissors.Create(self);

  fDynamicStates     := TvgDynamicStates.Create(self);

  Inherited  ;

  If (RU_GRAPHICPIPE in fResourceUse) then
  Begin
    If not assigned(FGraphicPipeRes) then
    Begin
       FGraphicPipeRes      := TvgDescriptorSet.Create(Self);
       FGraphicPipeRes.SetSubComponent(True);
       FGraphicPipeRes.Name := 'GPR';
    End;
  End;

   If (RU_MATERIAL in  fResourceUse) then
   Begin
       fGPMaterialRes := TvgDescriptorSet.Create(self);
       fGPMaterialRes.SetSubComponent(True);
       fGPMaterialRes.Name := 'MAR';
   End;

   If (RU_MODEL in  fResourceUse)  then
   Begin
       fGPModelRes    := TvgDescriptorSet.Create(self);
       fGPModelRes.SetSubComponent(True);
       fGPModelRes.Name := 'MOR';
   End;


  fVertexInputState  := TvgVertexInputState.Create(self);
  fVertexInputState.SetSubComponent(True);
  fVertexInputState.Name := 'VI';

  fInputAssemblyState  := TvgInputAssemblyState.Create(self);
  fInputAssemblyState.SetSubComponent(True);
  fInputAssemblyState.Name := 'IAS';

  fTessellationState  := TvgTessellationState.Create(self) ;
  fTessellationState.SetSubComponent(True);
  fTessellationState.Name := 'TS';

  fRasterizerState    := TvgRasterizerState.Create(self);
  fRasterizerState.SetSubComponent(True);
  fRasterizerState.Name := 'RS';

  fMultisamplingState := TvgMultisamplingState.Create(self);
  fMultisamplingState.SetSubComponent(True);
  fMultisamplingState.Name := 'MS';

  fDepthStencilState  := TvgDepthStencilState.Create(self);
  fDepthStencilState.SetSubComponent(True);
  fDepthStencilState.Name := 'DSS';

  fColorBlendingState  := TvgColorBlendingState.Create(self);
  fColorBlendingState.SetSubComponent(True);
  fColorBlendingState.Name := 'CB';

  fVertShader := TvgShaderModule.Create(self);
  fVertShader.SetSubComponent(True);
  fVertShader.Name := 'VS';

  fGeomShader := TvgShaderModule.Create(self);
  fGeomShader.SetSubComponent(True);
  fGeomShader.Name := 'GS';

  fFragShader := TvgShaderModule.Create(self);
  fFragShader.SetSubComponent(True);
  fFragShader.Name := 'FS';

  fPushConstantCol  := TvgPushConstantCol.Create(self);

  fFrameCount  := MaxFramesInFlight;   //Max Frames In Flight
  fThreadCount := 1;

   fSetLayoutCount        := 0;
//     fSetLayoutArray        : Array of TVkPipelineLayoutCreateInfo;
   fPushConstantRangeCount:= 0;;
//     fPushConstantRanges    : Array of TVkPushConstantRange;


   fUnderlayNodes := TvgRenderNodeList.Create;
   fStaticNodes   := TvgRenderNodeList.Create;
   fDynamicNodes  := TvgRenderNodeList.Create;
   fOverlayNodes  := TvgRenderNodeList.Create;

   fUnderlayNodes.fRenderer := Self.fRenderEngine;
   fStaticNodes.fRenderer   := Self.fRenderEngine;
   fDynamicNodes.fRenderer  := Self.fRenderEngine;
   fOverlayNodes.fRenderer  := Self.fRenderEngine;

end;

procedure TvgGraphicPipeline.DefineProperties(Filer: TFiler);
begin
  inherited;

end;

destructor TvgGraphicPipeline.Destroy;
begin
  SetActiveState(False);

  If assigned(fUnderlayNodes) then
  Begin
    fUnderlayNodes.Clear;
    FreeAndNil(fUnderlayNodes);
  End;

  If assigned(fStaticNodes) then
  Begin
    fStaticNodes.Clear;
    FreeAndNil(fStaticNodes);
  End;

  If assigned(fDynamicNodes) then
  Begin
    fDynamicNodes.Clear;
    FreeAndNil(fDynamicNodes);
  End;

  If assigned(fOverlayNodes) then
  Begin
    fOverlayNodes.Clear;
    FreeAndNil(fOverlayNodes);
  End;

  If assigned(FGraphicPipeRes) then
     FreeAndNil(FGraphicPipeRes);

  If assigned(fGPMaterialRes) then
     FreeAndNil(fGPMaterialRes);

  If assigned(fGPModelRes) then
     FreeAndNil(fGPModelRes);

  If assigned(fVertShader) then
  Begin
    fVertShader.SetSubComponent(False);
    FreeAndNil(fVertShader);
  End;

  If assigned(fGeomShader) then
  Begin
    fGeomShader.SetSubComponent(False);
    FreeAndNil(fGeomShader);
  End;

  If assigned(fFragShader) then
  Begin
    fFragShader.SetSubComponent(False);
    FreeAndNil(fFragShader);
  End;

  If assigned(fVertexInputState) then
  Begin
    fVertexInputState.SetSubComponent(False);
    FreeAndNil(fVertexInputState);
  End;

  If assigned(fTessellationState) then
  Begin
    fTessellationState.SetSubComponent(False);
    FreeAndNil(fTessellationState);
  End;

  If assigned(fMultisamplingState) then
  Begin
    fMultisamplingState.SetSubComponent(False);
    FreeAndNil(fMultisamplingState);
  End;

  If assigned(fRasterizerState) then
  Begin
    fRasterizerState.SetSubComponent(False);
    FreeAndNil(fRasterizerState);
  End;

  If assigned(fDepthStencilState) then
  Begin
    fDepthStencilState.SetSubComponent(False);
    FreeAndNil(fDepthStencilState);
  End;

  If assigned(fColorBlendingState) then
  Begin
    fColorBlendingState.SetSubComponent(False);
    FreeAndNil(fColorBlendingState);
  End;

  If Assigned(fViewports) then FreeAndNil(fViewports) ;
  If Assigned(fScissors) then FreeAndNil(fScissors) ;

  If assigned(fDynamicStates) then FreeAndNil(fDynamicStates);

  If assigned(fPushConstantCol) then
     FreeAndNil(fPushConstantCol);

  inherited;
end;

function TvgGraphicPipeline.GetActive: Boolean;
begin
  Result:=fActive  ;
end;

function TvgGraphicPipeline.GetDynamicStates: TvgDynamicStates;
begin
  Result:= fDynamicStates;
end;

function TvgGraphicPipeline.GetPipeCreateFlags: TvgPipelineCreateFlagBits;
begin
  Result := GetVGPipelineCreateFlags(self.fPipeCreateFlags);
end;

function TvgGraphicPipeline.GetPipeHandle(aThread, aFrame : Integer): TVkPipeline;
begin
   Result := VK_NULL_HANDLE;

   If (aThread<0) or (aThread>High(fPipelineHandles)) then exit;
   If (aFrame<0)  or (aFrame>High(fPipelineHandles[aThread])) then exit;

   Result :=  fPipelineHandles[aThread,aFrame];

end;

class function TvgGraphicPipeline.GetPropertyName: String;
begin
  Result := 'GraphicPipeline';
end;

function TvgGraphicPipeline.GetRenderEngine: TvgRenderEngine;
begin
  Result := fRenderEngine;
end;

function TvgGraphicPipeline.GetScissors: TvgScissors;
begin
  Result:=self.fScissors;
end;

function TvgGraphicPipeline.GetScreenDevice: TvgScreenRenderDevice;
begin
  If assigned(fRenderEngine) and
     assigned(fRenderEngine.Linker) and
     assigned(fRenderEngine.Linker.ScreenDevice) then
    Result:= fRenderEngine.Linker.ScreenDevice
  else
    Result:=nil;
end;

function TvgGraphicPipeline.GetSubPassRef: Integer;
begin
  Result := fSubPassRef;
end;

function TvgGraphicPipeline.GetViewPorts: TvgViewports;
begin
  Result:= fViewports;
end;

function TvgGraphicPipeline.GetLinker: TvgLinker;
begin
  If assigned(fRenderEngine) then
    Result := fRenderEngine.Linker
  else
    Result := Nil;
end;

function TvgGraphicPipeline.GetLinkerFrameCount: TvkUint32;
begin
  Result := MaxFramesInFlight;
  If Not assigned(fRenderEngine) then exit;
  If not assigned(fRenderEngine.Linker) then exit;
  Result := fRenderEngine.Linker.FrameCount;
end;

function TvgGraphicPipeline.GetNodeCount: Integer;
begin
//  Result := 0;
  Result := fUnderlayNodes.count +
            fStaticNodes.count +
            fDynamicNodes.count +
            fOverlayNodes.count;
end;

function TvgGraphicPipeline.IsDynamicStateEnabled( aState: TVkDynamicState ; UpdateState:Boolean=False) : Boolean;
  Var I:Integer;
      DS : TvgDynamicState;
begin
 // Check and fix
  Result:=False;
  If fDynamicStates.Count=0 then exit;
  For I:=0 to  fDynamicStates.Count-1 do
  Begin
    DS := fDynamicStates.Items[I];
    If DS.fDynamicState=aState then
    Begin
       Result := (DS.fState<>DS_NOTSET);
       If UpdateState and not (DS.fState <> DS_SET) then
         DS.fState := DS_SET;
       Exit;
    End;
  End;
end;

procedure TvgGraphicPipeline.SetActive(const Value: Boolean);
begin
  If fActive = Value then exit;
  SetActiveState(Value)  ;
end;

procedure TvgGraphicPipeline.SetCurrentFrame(const Value: TvkUint32);
begin
  fCurrentFrame := Value;

  If assigned(fGraphicPipeRes) then
     fGraphicPipeRes.CurrentFrame := fCurrentFrame;
  If assigned(fGPMaterialRes) then
     fGPMaterialRes.CurrentFrame := fCurrentFrame;
  If assigned(fGPModelRes) then
     fGPModelRes.CurrentFrame := fCurrentFrame;
end;

procedure TvgGraphicPipeline.SetDesigning;
begin
 // inherited;

end;

procedure TvgGraphicPipeline.SetDisabled;
  Var SD:TvgScreenRenderDevice;
      SDVD : TpvVulkanDevice;
      I,J : Integer;

    Procedure DisableNodes(aList:TvgRenderNodeList);
      Var J:Integer;
    Begin
      If not assigned(aList) then exit;
      For J:=0 to aList.Count-1 do
      If assigned( aList.Items[J]) and (aList.Items[J].Active) then
          aList.Items[J].Active := False;
    End;

begin
  fActive:=False;

  DisableNodes(fUnderlayNodes);
  DisableNodes(fStaticNodes);
  DisableNodes(fDynamicNodes);
  DisableNodes(fOverlayNodes);

  If assigned(FGraphicPipeRes) then
     FGraphicPipeRes.Active := False;

  If assigned(fGPMaterialRes) then
      fGPMaterialRes.ClearDescriptorSetLayout;

  If assigned(fGPModelRes) then
      fGPModelRes.ClearDescriptorSetLayout;

  SD := GetScreenDevice;

  If not assigned(SD) then exit;
  SDVD := SD.VulkanDevice;
  If not assigned(SDVD) then exit;

  If assigned(fInputAssemblyState) then  fInputAssemblyState.Active:=False;
  If assigned(fDepthStencilState)  then  fDepthStencilState.Active :=False;
  If assigned(fRasterizerState)    then  fRasterizerState.Active   :=False;
  If assigned(fMultisamplingState) then  fMultisamplingState.Active:=False;
  If assigned(fColorBlendingState) then  fColorBlendingState.Active:=False;

  If assigned(fVertShader) then  fVertShader.Active:=False;
  If assigned(fGeomShader) then  fGeomShader.Active:=False;
  If assigned(fFragShader) then  fFragShader.Active:=False;

  For I:= 0 to High(fPipelineHandles) do
    For J:=0 to High(fPipelineHandles[I]) do
      If fPipelineHandles[I,J]<>VK_NULL_HANDLE then
      Begin

         SD.VulkanDevice.Commands.DestroyPipeline( SDVD.Handle,
                                                   fPipelineHandles[I,J],
                                                   SDVD.AllocationCallbacks);
         fPipelineHandles[I,J] :=  VK_NULL_HANDLE;
      End;

  If fPipelineLayoutHandle<>VK_NULL_HANDLE then
  Begin
     SD.VulkanDevice.Commands.DestroyPipelineLayout( SDVD.Handle,
                                                    fPipelineLayoutHandle,
                                                    SDVD.AllocationCallbacks);
     fPipelineLayoutHandle :=  VK_NULL_HANDLE;
  End;

  SetLength(fDynamicStateArray ,0);

end;

procedure TvgGraphicPipeline.SetDynamicStates(const Value: TvgDynamicStates);
begin
  If not assigned(Value) then exit;
  SetActiveState(False);
  fDynamicStates.Clear;
  fDynamicStates.Assign(Value);
end;

procedure TvgGraphicPipeline.SetEnabled(aComp:TvgBaseComponent=nil);

  Var I, ShaderC: Integer;
      WC   : TvkUint32;
      WL   : TvgLinker;
      SD   : TvgScreenRenderDevice;
      SDVD : TpvVulkanDevice;
      Info : Array of TVkGraphicsPipelineCreateInfo;
    //  TempArray : Array of TVkPipeline  ;
begin

    fActive := False;

    Assert( assigned(fRenderEngine),'Renderer not assigned');
    Assert( assigned(fRenderEngine.RenderPass),'Renderer Renderpass not assigned');
    Assert( assigned(fRenderEngine.RenderPass.SubPasses),'Renderer Renderpass subpass collection not assigned');

    If (fSubPassRef  >= fRenderEngine.fRenderPass.SubPasses.count) then exit;

    Assert((fValidStructure=True),'Structure NOT valid');

     WL := GetLinker;
     Assert(assigned(WL),'Window Linker not assigned');
     SD := GetScreenDevice;
     Assert(assigned(SD),'Screen Device not assigned');
     SDVD := SD.VulkanDevice;
     Assert(assigned(SDVD),'Screen Device not active');
     Assert((SDVD.Handle<> VK_NULL_HANDLE),'Screen Device Handle NOT assigned');
     Assert(assigned(SDVD.commands),'Screen Device Commands');

     Assert( assigned(fVertShader),'Vertex Shader not created');
     Assert( assigned(fGeomShader),'Geometry Shader not created');
     Assert( assigned(fFragShader),'Fragment Shader not created');
  Try
     fFrameCount := GetLinkerFrameCount;

     SetUpViewPortAndScissors ;

     fVertShader.SetDevice(SD);
     fVertShader.SetEnabled;

     fGeomShader.SetDevice(SD);
     fGeomShader.SetEnabled;

     fFragShader.SetDevice(SD);
     fFragShader.SetEnabled;

     ShaderC:=0;
     FillChar(fShaderStages[ShaderC],SizeOf(fShaderStages),#0);
     If fVertShader.active then
     Begin
       fShaderStages[ShaderC].sType := VK_STRUCTURE_TYPE_PIPELINE_SHADER_STAGE_CREATE_INFO;
       fShaderStages[ShaderC].stage := VK_SHADER_STAGE_VERTEX_BIT;
       fShaderStages[ShaderC].module:= fVertShader.ShaderHandle;
       fShaderStages[ShaderC].pName := PVkChar(fVertShader.fMainName);
       inc(ShaderC);
     End;

     If fGeomShader.active then
     Begin
       fShaderStages[ShaderC].sType := VK_STRUCTURE_TYPE_PIPELINE_SHADER_STAGE_CREATE_INFO;
       fShaderStages[ShaderC].stage := VK_SHADER_STAGE_GEOMETRY_BIT;
       fShaderStages[ShaderC].module:= fGeomShader.ShaderHandle;
       fShaderStages[ShaderC].pName := PVkChar(fGeomShader.fMainName);
       inc(ShaderC);
     End;

     If fFragShader.active then
     Begin
       fShaderStages[ShaderC].sType := VK_STRUCTURE_TYPE_PIPELINE_SHADER_STAGE_CREATE_INFO;
       fShaderStages[ShaderC].stage := VK_SHADER_STAGE_FRAGMENT_BIT;
       fShaderStages[ShaderC].module:= fFragShader.ShaderHandle;
       fShaderStages[ShaderC].pName := PVkChar(fFragShader.fMainName);
       inc(ShaderC);
     End;

     FillChar(fvp,SizeOf(fvp),#0);
     fvp.x := 0;
     fvp.y := 0;
     fvp.width  := WL.fSwapChain.ImageWidth;
     fvp.height := WL.fSwapChain.ImageHeight;
     fvp.minDepth := 0.0;
     fvp.maxDepth := 1.0;

     FillChar(fSC,SizeOf(fSC),#0);
     fSC.offset.x := 0;
     fSC.offset.y := 0;
     fSC.extent.width  := WL.fSwapChain.ImageWidth;
     fSC.extent.height := WL.fSwapChain.ImageHeight;

     FillChar(fvpCreateInfo,SizeOf(fvpCreateInfo),#0);
     fvpCreateInfo.sType         := VK_STRUCTURE_TYPE_PIPELINE_VIEWPORT_STATE_CREATE_INFO;
     fvpCreateInfo.viewportCount := 1;
     fvpCreateInfo.pViewports    := @fvp;
     fvpCreateInfo.scissorCount  := 1;
     fvpCreateInfo.pScissors     := @fSC;

     FillChar(fDynamicState,SizeOf(TVkPipelineDynamicStateCreateInfo),#0);
     fDynamicState.sType:=VK_STRUCTURE_TYPE_PIPELINE_DYNAMIC_STATE_CREATE_INFO;
     fDynamicState.pNext:=nil;
     fDynamicState.flags:=0;

     If fDynamicStates.Count>0 then
     begin
       fDynamicState.dynamicStateCount := fDynamicStates.Count;
       SetLength(fDynamicStateArray,fDynamicStates.Count);
       For I:=0 to fDynamicStates.Count-1 do
           fDynamicStateArray[I]:= fDynamicStates.Items[I].fDynamicState;   //need the VK version
       fDynamicState.pDynamicStates := @fDynamicStateArray[0];
     end;

     If assigned(fRenderEngine) and
        assigned(fRenderEngine.RenderPass) and
        fRenderEngine.RenderPass.IsMSAAOn then
     Begin
       fMultisamplingState.fSampleShadingEnable  := True;
       fMultisamplingState.fRasterizationSamples := GetVKSampleCountFlagBit(fRenderEngine.RenderPass.MSAASample);
     End;

     If assigned(fVertexInputState)   then fVertexInputState.Active  := True;
     If assigned(fInputAssemblyState) then fInputAssemblyState.Active:= True;
     If assigned(fTessellationState)  then fTessellationState.Active := True ;
     If assigned(fRasterizerState)    then fRasterizerState.Active   := True  ;
     If assigned(fMultisamplingState) then fMultisamplingState.Active:= True ;
     If assigned(fDepthStencilState)  then fDepthStencilState.Active := True;
     If assigned(fColorBlendingState) then fColorBlendingState.Active:= True;

  //must stay here

    If assigned(FGraphicPipeRes) then
    Begin
      If not assigned(FGraphicPipeRes.LogicalDevice) then
        FGraphicPipeRes.LogicalDevice := SD;

      FGraphicPipeRes.Active := True;
    End;

 //layout for resources used
     SetUpPipeLineLayout;

     FillChar(fPipelineLayout,SizeOf(fPipelineLayout),#0);
     fPipelineLayout.sType          :=  VK_STRUCTURE_TYPE_PIPELINE_LAYOUT_CREATE_INFO;
     fPipelineLayout.pNext          := nil;
     fPipelineLayout.flags          := 0;
     fPipelineLayout.setLayoutCount := fSetLayoutCount;
     If fSetLayoutCount>0 then
       fPipelineLayout.pSetLayouts    := @fSetLayoutArray[0]
     else
       fPipelineLayout.pSetLayouts    := nil;

  //Push Constants used
     SetUpPipeLinePushConstants;

     fPipelineLayout.pushConstantRangeCount := fPushConstantRangeCount;
     If fPushConstantRangeCount>0 then
       fPipelineLayout.pPushConstantRanges  := @fPushConstantRanges[0]
     else
       fPipelineLayout.pPushConstantRanges  := nil;

     VulkanCheckResult(SDVD.Commands.CreatePipelineLayout( SDVD.Handle,
                                                            @fPipelineLayout,
                                                            SDVD.AllocationCallbacks,
                                                            @fPipelineLayoutHandle));

     If fRenderEngine.WorkerCount=0 then
        WC := 1
     else
        WC := fRenderEngine.WorkerCount;

    SetLength(fPipelineHandles, WC);

    For I:=0 to High(fPipelineHandles) do
        SetLength(fPipelineHandles[I], fFrameCount);

    SetLength(Info, fFrameCount);
    For I:=0 to fFrameCount-1 do
    Begin
        FillChar(Info[I],SizeOf(TVkGraphicsPipelineCreateInfo),#0);

        Info[I].sType               := VK_STRUCTURE_TYPE_GRAPHICS_PIPELINE_CREATE_INFO;
        Info[I].stageCount          := ShaderC;
        Info[I].pStages             := @fShaderStages[0];
        Info[I].pVertexInputState   := @fVertexInputState.fvertexInputInfo;
        Info[I].pInputAssemblyState := @fInputAssemblyState.fpipelineIACreateInfo;
        Info[I].pTessellationState  := @fTessellationState.fTessCreateInfo;
        Info[I].pViewportState      := @fvpCreateInfo;
        Info[I].pDepthStencilState  := @fDepthStencilState.fDepthStencilInfo  ;
        Info[I].pRasterizationState := @fRasterizerState.fRastCreateInfo ;
        Info[I].pMultisampleState   := @fMultisamplingState.fPipelineMSCreateInfo;
        Info[I].pColorBlendState    := @fColorBlendingState.fBlendCreateInfo;
        Info[I].renderPass          := fRenderEngine.RenderPass.RenderPassHandle; //RENDERPASS Handle  check
        Info[I].subpass             := fSubPassRef;
        Info[I].basePipelineIndex   := VK_NULL_HANDLE;
        Info[I].layout              := fPipelineLayoutHandle;
        If fDynamicStates.Count>0 then
          Info[I].pDynamicState    := @fDynamicState;

    end;

    For I:= 0 to WC-1 do   //thread   count
    Begin

      VulkanCheckResult(SDVD.Commands.CreateGraphicsPipelines(SDVD.Handle,
                                                                VK_NULL_HANDLE,
                                                                fFrameCount,  //1 is minimum
                                                                @Info[0],
                                                                SDVD.AllocationCallbacks,
                                                                @fPipelineHandles[I,0]));
    End;

     SetLength(Info,0);

     fActive := True;

     If fActive then
       CheckDynamicStateCapabilities;

  Except
      On E:Exception do
      Begin
        fActive:=False;
        Raise;
      end;
  end;

end;

procedure TvgGraphicPipeline.SetFrameCount(const Value: TvkUint32);
begin
  If fFrameCount = Value then exit;
  SetActiveState(False);
  fFrameCount := Value;
  If fFrameCount = 0 then
     GetLinkerFrameCount;
end;

procedure TvgGraphicPipeline.SetPipeCreateFlags( const Value: TvgPipelineCreateFlagBits);
  Var V:TVkPipelineCreateFlags;
begin
  V:=GetVKPipelineCreateFlags(Value);
  If self.fPipeCreateFlags=V then exit;
  SetActiveState(False);
  fPipeCreateFlags:=V;
end;

procedure TvgGraphicPipeline.SetRenderEngine(const Value: TvgRenderEngine);
begin
  If fRenderEngine=Value then exit;

  SetActiveState(False);

  fUnderlayNodes.fRenderer := nil;
  fStaticNodes.fRenderer   := nil;
  fDynamicNodes.fRenderer  := nil;
  fOverlayNodes.fRenderer  := nil;

  fRenderEngine  := Value;

  If assigned(fRenderEngine) and assigned(fRenderEngine.Linker) and assigned(fRenderEngine.Linker.ScreenDevice) then
  Begin
    If assigned(FGraphicPipeRes) then
       FGraphicPipeRes.LogicalDevice := fRenderEngine.Linker.ScreenDevice;

    If assigned(fGPMaterialRes) then
       fGPMaterialRes.LogicalDevice  := fRenderEngine.Linker.ScreenDevice;

    If assigned(fGPModelRes) then
      fGPModelRes.LogicalDevice      := fRenderEngine.Linker.ScreenDevice;
  End;

  If assigned(fRenderEngine) then
  Begin
      fUnderlayNodes.fRenderer := fRenderEngine;
      fStaticNodes.fRenderer   := fRenderEngine;
      fDynamicNodes.fRenderer  := fRenderEngine;
      fOverlayNodes.fRenderer  := fRenderEngine;
  End;

end;

procedure TvgGraphicPipeline.SetResourceUse(const Value: TvgResourceUse);
begin
  If fResourceUse = Value  then exit;
  SetActiveState(False);

  fResourceUse := Value;

  If (RU_GRAPHICPIPE in fResourceUse) then
  Begin
    If not assigned(FGraphicPipeRes) then
    Begin
       FGraphicPipeRes     := TvgDescriptorSet.Create(Self);
       FGraphicPipeRes.SetSubComponent(True);
       FGraphicPipeRes.Name:='GPR';
    End;
  End else
    If assigned(FGraphicPipeRes) then
       FreeAndNil(FGraphicPipeRes);

  If (RU_MATERIAL in fResourceUse) then
  Begin
    If not assigned(fGPMaterialRes) then
    Begin
       fGPMaterialRes     := TvgDescriptorSet.Create(Self);
       fGPMaterialRes.SetSubComponent(True);
       fGPMaterialRes.Name:='MaR';
    End;
  End else
    If assigned(fGPMaterialRes) then
       FreeAndNil(fGPMaterialRes);

  If (RU_MODEL in fResourceUse) then
  Begin
    If not assigned(fGPModelRes) then
    Begin
       fGPModelRes     := TvgDescriptorSet.Create(Self);
       fGPModelRes.SetSubComponent(True);
       fGPModelRes.Name:='MoR';
    End;
  End else
    If assigned(fGPModelRes) then
       FreeAndNil(fGPModelRes);
end;

procedure TvgGraphicPipeline.SetScissors(const Value: TvgScissors);
begin
  If not assigned(Value) then exit;
  SetActiveState(False);
  fScissors.Clear;
  fScissors.Assign(Value);
end;

procedure TvgGraphicPipeline.SetSubPassRef(const Value: Integer);
begin
  If fSubPassRef = Value then exit;
  SetActiveState(False);
  fSubPassRef := Value;
end;

procedure TvgGraphicPipeline.SetThreadCount(const Value: TvkUint32);
begin
  If fThreadCount = Value then exit;
  SetActiveState(False);
  fThreadCount := Value;
end;

procedure TvgGraphicPipeline.SetUpDepthStencilState(DepthON,  StencilON: Boolean; CompareOP:TVkCompareOp);
begin
  If not assigned(fDepthStencilState) then exit;

  fDepthStencilState.SetUpDepthStencilState(DepthON,  StencilON, CompareOP);
end;

procedure TvgGraphicPipeline.SetUpDynamicStateExtensions(aExtensions : TvgExtensions; aVer: TvkUint32);
  var I:Integer;
begin

  assert(assigned(fDynamicStates),'Dynamic State not assigned.');
  If fDynamicStates.Count=0 then exit;
  If not assigned(aExtensions) then exit;
  if aExtensions.Count=0 then exit;

  For I:=0 to fDynamicStates.Count-1 do
     fDynamicStates.Items[I].SetUpDynamicStateExtension(aExtensions, aVer);

end;

procedure TvgGraphicPipeline.SetUpPipeline;
begin
  //do nothing yet
end;

procedure TvgGraphicPipeline.SetUpPipeLineLayout;

 Procedure AddResource(aResource:TvgDescriptorSet);
 Begin
    If aResource=nil then exit;

    If assigned(aResource.fVulkanDescriptorSetLayout) and
               (aResource.fVulkanDescriptorSetLayout.Handle <> VK_NULL_HANDLE) then
    Begin
      Inc(fSetLayoutCount);
      Setlength(fSetLayoutArray, fSetLayoutCount); //should copy data
      fSetLayoutArray[fSetLayoutCount-1] := aResource.fVulkanDescriptorSetLayout.Handle;
    End;
 end;

begin
  fSetLayoutCount        := 0;

 //order sets the SET value for resources
  If (RU_GLOBAL in fResourceUse) and assigned(fRenderEngine) and Assigned(fRenderEngine.GlobalRes) then
     AddResource(fRenderEngine.GlobalRes);

  If (RU_GRAPHICPIPE in fResourceUse)  and Assigned(fGraphicPipeRes) then
     AddResource(fGraphicPipeRes);

  If (RU_MATERIAL in fResourceUse) and assigned(fGPMaterialRes) then
  Begin
     fGPMaterialRes.BuildDescriptorSetLayout;  //don't activate these as they will be used VIA the NODE
     AddResource(fGPMaterialRes);
  End;

  If (RU_MODEL in fResourceUse) and assigned(fGPModelRes)  then
  Begin
     fGPModelRes.BuildDescriptorSetLayout;   //don't activate these as they will be used VIA the NODE
     AddResource(fGPModelRes);
  End;

end;

procedure TvgGraphicPipeline.SetUpPipeLinePushConstants;
   Var L,I:Integer;
       PC : TvgPushConstant;
       Offset : TvkUint32;
begin
  fPushConstantRangeCount := 0;
  Setlength(fPushConstantRanges,0);

  L:= fPushConstantCol.count;
  If L=0 then exit;

  Offset := 0;

  For I:=0 to L-1 do
  Begin
    PC := fPushConstantCol.Items[I].PushConstant;
    If assigned(PC) and (PC.ShaderFlags<>[]) and (PC.DataSize>0) then
    Begin
      PC.Active := True;
      Inc(fPushConstantRangeCount);
      Setlength(fPushConstantRanges, fPushConstantRangeCount);

      fPushConstantRanges[fPushConstantRangeCount-1].stageFlags := GetVKStageFlags(PC.ShaderFlags);//  TVkShaderStageFlags(VK_SHADER_STAGE_VERTEX_BIT);
      fPushConstantRanges[fPushConstantRangeCount-1].offset     := Offset;
      fPushConstantRanges[fPushConstantRangeCount-1].size       := PC.DataSize;

      OffSet := Offset + PC.DataSize;
    End;
  End;

end;

procedure TvgGraphicPipeline.SetUpViewPortAndScissors;
  Var I:Integer;
      V:TvgViewport;
      S:TvgScissor;
      W,H:Integer;
      WL:TvgLinker;
begin

  WL:=GetLinker;
  Assert(assigned(WL),'Window Link NOT assigned');

  W:=WL.SwapChain.ImageWidth;
  H:=WL.SwapChain.ImageHeight;

  If Assigned(fViewports) and (fViewports.Count>0) then
  Begin
    For I:=0 to fViewports.Count-1 do
    Begin
      V:=fViewports.Items[I];
      If V.fWinSize=AUTO_SIZE then
      Begin
        V.fWidth   :=  W;
        V.fHeight  :=  H;
      End;
    End;
  End;

  If Assigned(fScissors) and (fScissors.Count>0) then
  Begin
    For I:=0 to fScissors.Count-1 do
    Begin
      S:=fScissors.Items[I];
      If S.fWinSize=AUTO_SIZE then
      Begin
        S.fWidth   :=  W;
        S.fHeight  :=  H;
      End;
    End;
  End;

end;

procedure TvgGraphicPipeline.SetViewPorts(const Value: TvgViewports);
begin
  If not assigned(Value) then exit;
  SetActiveState(False);
  fViewports.Clear;
  fViewports.Assign(Value);
end;

procedure TvgGraphicPipeline.UpdateConnections;
  Var SD:TvgScreenRenderDevice;
begin
  SD:=self.GetScreenDevice;
  Assert(Assigned(SD),'Scren Device not assigned');

  If assigned(fVertShader) then
     fVertShader.SetDevice(SD);
  If assigned(fGeomShader) then
     fGeomShader.SetDevice(SD);
  If assigned(fFragShader) then
     fFragShader.SetDevice(SD);
end;

procedure TvgGraphicPipeline.UpdatePushConstantData(aIndex: TvkUint32);
  Var I  :Integer;
      PC : TvgPushConstant;
begin
  Assert(assigned(fPushConstantCol),'Push Constant Collection NOT created');
  If fPushConstantCol.count =0 then exit;

  For I:= 0 to fPushConstantCol.count-1 do
  Begin
    PC := fPushConstantCol.items[I].PushConstant;
    If assigned(PC) then
      PC.SetupData(aIndex);
  End;
end;

{ TvgVertexBindingDesc }

procedure TvgVertexBindingDesc.Assign(Source: TPersistent);
  var L:TvgVertexBindingDesc;
begin
  if Source is TvgVertexBindingDesc then
  begin
    L:=TvgVertexBindingDesc(Source);
    self.fName        := L.fName;
    self.fBinding     := L.fBinding;
    self.fStride      := L.fStride;
    self.fInputRate   := L.fInputRate;
  end
  else
  inherited Assign(Source);
end;

constructor TvgVertexBindingDesc.Create(Collection: TCollection);
begin
  inherited Create(Collection);

  If assigned(Collection) then
    fName:='VertexBinding ' + IntToStr(Collection.Count);
end;

procedure TvgVertexBindingDesc.DefineProperties(Filer: TFiler);
begin
  inherited;
  Filer.DefineProperty('BindingData', ReadData, WriteData, True);
end;

function TvgVertexBindingDesc.GetBinding: TvkUint32;
begin
  Result:= fBinding;
end;

function TvgVertexBindingDesc.GetDisplayName: string;
begin
  Result:=fName;
end;

function TvgVertexBindingDesc.GetInputRate: TvgVertexInputRate;
begin
  Result:= GetVGVertexInputRate(Self.fInputRate);
end;

function TvgVertexBindingDesc.GetName: String;
begin
  Result:=fName;
end;

function TvgVertexBindingDesc.GetStride: TvkUint32;
begin
  Result:=fStride;
end;

procedure TvgVertexBindingDesc.ReadData(Reader: TReader);
begin
  Reader.ReadListBegin;
  fBinding :=   ReadTvkUint32(Reader);
  fStride  :=   ReadTvkUint32(Reader);
  Reader.ReadListEnd;
end;

procedure TvgVertexBindingDesc.SetBinding(const Value: TvkUint32);
begin
  If fBinding=Value then exit;
  SetDisabled;
  fBinding:=Value;
end;

procedure TvgVertexBindingDesc.SetDisabled;
begin
  If assigned(Collection) and (Collection is TvgVertexBindingDescs) and Assigned(TvgVertexBindingDescs(Collection).FComp)  then
     TvgVertexBindingDescs(Collection).FComp.SetDisabled;
end;

procedure TvgVertexBindingDesc.SetInputRate(const Value: TvgVertexInputRate);
  Var IR: TVkVertexInputRate;
begin
  IR:= GetVKVertexInputRate(Value) ;
  If IR=fInputRate then exit;
  SetDisabled;
  fInputRate:= IR;
end;

procedure TvgVertexBindingDesc.SetName(const Value: String);
begin
  fName:=Value;
end;

procedure TvgVertexBindingDesc.SetStride(const Value: TvkUint32);
begin
  If fStride=Value then exit;
  SetDisabled;
  fStride:=Value;
end;

procedure TvgVertexBindingDesc.WriteData(Writer: TWriter);
begin
  Writer.WriteListBegin;
  WriteTvkUint32(Writer,fBinding);
  WriteTvkUint32(Writer,fStride);
  Writer.WriteListEnd;
end;

{ TvgVertexBindingDescs }

function TvgVertexBindingDescs.Add: TvgVertexBindingDesc;
begin
  Result := TvgVertexBindingDesc(inherited Add);
end;

function TvgVertexBindingDescs.AddItem(Item: TvgVertexBindingDesc; Index: Integer): TvgVertexBindingDesc;
begin
  if Item = nil then
    Result := TvgVertexBindingDesc.Create(self)
  else
    Result := Item;

  if Assigned(Result) then
  begin
    Result.Collection := Self;
    if Index < 0 then
      Index := Count - 1;
    Result.Index := Index;
  end;
end;

constructor TvgVertexBindingDescs.Create( CollOwner: TvgVertexInputState);
begin
  Inherited Create(TvgVertexBindingDesc);
  fComp := CollOwner;
end;

function TvgVertexBindingDescs.GetItem(Index: Integer): TvgVertexBindingDesc;
begin
  Result := TvgVertexBindingDesc(inherited GetItem(Index));
end;

function TvgVertexBindingDescs.GetOwner: TPersistent;
begin
  Result:=fComp;
end;

function TvgVertexBindingDescs.Insert(Index: Integer): TvgVertexBindingDesc;
begin
  Result := AddItem(nil, Index);
end;

procedure TvgVertexBindingDescs.SetItem(Index: Integer;  const Value: TvgVertexBindingDesc);
begin
  inherited SetItem(Index, Value);
end;

procedure TvgVertexBindingDescs.Update(Item: TCollectionItem);
begin
  //inherited;

end;

{ TvgVertexAttributeDesc }

procedure TvgVertexAttributeDesc.Assign(Source: TPersistent);
  var L:TvgVertexAttributeDesc;
begin
  if Source is TvgVertexAttributeDesc then
  begin
    L:=TvgVertexAttributeDesc(Source);
    self.fName     := L.fName;
    self.fLocation := L.fLocation;
    self.fBinding  := L.fBinding;
    self.fFormat   := L.fFormat;
    self.fOffset   := L.fOffset;
  end
  else
  inherited Assign(Source);
end;

constructor TvgVertexAttributeDesc.Create(Collection: TCollection);
begin
  inherited Create(Collection);

  If assigned(Collection) then
  Begin
    fName:='AD' + IntToStr(Collection.Count);
  end else
    fName:='AD0';

end;

procedure TvgVertexAttributeDesc.DefineProperties(Filer: TFiler);
begin
  inherited;
  Filer.DefineProperty('AttributeData', ReadData, WriteData, True);
end;

function TvgVertexAttributeDesc.GetAttributeType: TvgAttributeType;
begin
  Result := fAttributeType;
end;

function TvgVertexAttributeDesc.GetBinding: TvkUint32;
begin
  Result:=fBinding;
end;

function TvgVertexAttributeDesc.GetDataType: TvgDataType;
begin
  Result := fType;
end;

function TvgVertexAttributeDesc.GetDisplayName: string;
begin
  Result:=fName;
end;

function TvgVertexAttributeDesc.GetFormat: TvgFormat;
begin
  Result:= GetVGFormat(fFormat) ;
end;

function TvgVertexAttributeDesc.GetLocation: TvkUint32;
begin
  Result:=fLocation;
end;

function TvgVertexAttributeDesc.GetName: String;
begin
  Result:=fName;
end;

function TvgVertexAttributeDesc.GetOffset: TvkUint32;
begin
  Result:=fOffset;
end;

function TvgVertexAttributeDesc.GetShaderHeadTemplate: String;
  Var S1:String;
begin
  S1 := GetDataTypeAsString(fType);
  Result := Format('layout(location = %d) in %s %s', [fLocation, S1, fName]);
end;

procedure TvgVertexAttributeDesc.ReadData(Reader: TReader);
begin
  Reader.ReadListBegin;
  self.fLocation :=  REadTvkUint32(Reader);
  self.fBinding  :=  REadTvkUint32(Reader);
  self.fOffset   :=  REadTvkUint32(Reader);
  Reader.ReadListEnd;
end;

procedure TvgVertexAttributeDesc.SetAttributeType(  const Value: TvgAttributeType);
begin
  If fAttributeType=Value then exit;
  SetDisabled;
  fAttributeType := Value;
end;

procedure TvgVertexAttributeDesc.SetBinding(const Value: TvkUint32);
begin
  If fBinding=Value then exit;
  SetDisabled;
  fBinding:=Value;
end;

procedure TvgVertexAttributeDesc.SetDataType(const Value: TvgDataType);
begin
  If fType = Value then exit;
  SetDisabled;
  fType := Value;
end;

procedure TvgVertexAttributeDesc.SetDisabled;
begin

 Try
  If assigned(Collection) and
    (Collection is TvgVertexAttributeDescs) and
    Assigned(TvgVertexAttributeDescs(Collection).FComp)  then
     TvgVertexAttributeDescs(Collection).FComp.SetDisabled;
 Except
    On E:Exception do
 End;
end;

procedure TvgVertexAttributeDesc.SetFormat(const Value: TvgFormat);
  Var F:TVkFormat;
begin
  F:=  GetVKFormat(Value)   ;
  If fFormat=F then exit;
  SetDisabled;
  fFormat:=F;
end;

procedure TvgVertexAttributeDesc.SetLocation(const Value: TvkUint32);
begin
  If fLocation=Value then exit;
  SetDisabled;
  fLocation:=Value;
end;

procedure TvgVertexAttributeDesc.SetName(const Value: String);
begin
  fName:=Value;
end;

procedure TvgVertexAttributeDesc.SetOffset(const Value: TvkUint32);
begin
  If fOffset=Value then exit;
  SetDisabled;
  fOffset:=Value;
end;

procedure TvgVertexAttributeDesc.WriteData(Writer: TWriter);
begin
  Writer.WriteListBegin;
  WriteTvkUint32(Writer,fLocation);
  WriteTvkUint32(Writer,fBinding);
  WriteTvkUint32(Writer,fOffset);
  Writer.WriteListEnd;
end;

{ TvgVertexAttributeDescs }

function TvgVertexAttributeDescs.Add: TvgVertexAttributeDesc;
begin
  Result := TvgVertexAttributeDesc(inherited Add);
end;

function TvgVertexAttributeDescs.AddItem(Item: TvgVertexAttributeDesc;  Index: Integer): TvgVertexAttributeDesc;
begin
  if Item = nil then
    Result := TvgVertexAttributeDesc.Create(self)
  else
    Result := Item;

  if Assigned(Result) then
  begin
    Result.Collection := Self;
    if Index < 0 then
      Index := Count - 1;
    Result.Index := Index;
  end;
end;

constructor TvgVertexAttributeDescs.Create(  CollOwner: TvgVertexInputState);
begin
  Inherited Create(TvgVertexAttributeDesc);
  fComp := CollOwner;
end;

function TvgVertexAttributeDescs.GetItem(  Index: Integer): TvgVertexAttributeDesc;
begin
  Result := TvgVertexAttributeDesc(inherited GetItem(Index));
end;

function TvgVertexAttributeDescs.GetOwner: TPersistent;
begin
  Result:= fComp;
end;

function TvgVertexAttributeDescs.Insert(Index: Integer): TvgVertexAttributeDesc;
begin
  Result := AddItem(nil, Index);
end;

procedure TvgVertexAttributeDescs.SetItem(Index: Integer;  const Value: TvgVertexAttributeDesc);
begin
  inherited SetItem(Index, Value);
end;

procedure TvgVertexAttributeDescs.Update(Item: TCollectionItem);
begin
  //inherited;

end;

{ TvgViewport }

procedure TvgViewport.Assign(Source: TPersistent);
  var L:TvgViewport;
begin
  if Source is TvgViewport then
  begin
    L:=TvgViewport(Source);
    self.fName     := L.fName;
    self.fWinSize  := L.fWinSize;

    self.fLeft   := L.fLeft;
    self.fTop    := L.fTop;
    self.fWidth  := L.fWidth;
    self.fHeight := L.fHeight;
    self.fMinZ   := L.fMinZ;
    self.fMaxZ   := L.fMaxZ;
  end
  else
  inherited Assign(Source);
end;

constructor TvgViewport.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  fName :=  'ViewPort ' +  IntToStr(Collection.Count)
end;

function TvgViewport.GetDisplayName: string;
begin
  Result:=fName;
end;

function TvgViewport.GetHeight: TvkFloat;
begin
  Result:= self.fHeight;
end;

function TvgViewport.GetLeft: TvkFloat;
begin
  Result:= self.fLeft;
end;

function TvgViewport.GetMaxZ: TvkFloat;
begin
  Result:= self.fMaxZ;
end;

function TvgViewport.GetMinZ: TvkFloat;
begin
  Result:= self.fMinZ;
end;

function TvgViewport.GetName: String;
begin
  Result:= self.fName;
end;

function TvgViewport.GetSize: TvgWinSize;
begin
  result:=  fWinSize ;
end;

function TvgViewport.GetTop: TvkFloat;
begin
  Result:= self.fTop;
end;

function TvgViewport.GetWidth: TvkFloat;
begin
  Result:= self.fWidth;
end;

function TvgViewport.IsValid: Boolean;
begin
  Result := (fMinZ>=0) and(fMinZ<1) and (fMaxZ>=0) and (fMaxZ<=1) and ((fWidth-fLeft) >0) and ((fHeight-fTop)>0);
end;

procedure TvgViewport.SetHeight(const Value: TvkFloat);
begin
  If IsZero(fHeight-Value) then exit;
  self.fHeight := Value;
  fWinSize := CUSTOM_SIZE;
end;

procedure TvgViewport.SetLeft(const Value: TvkFloat);
begin
  If IsZero(fLeft-Value) then exit;
  self.fLeft := Value;
  fWinSize := CUSTOM_SIZE;
end;

procedure TvgViewport.SetMaxZ(const Value: TvkFloat);
begin
  If IsZero(fMaxZ-Value) then exit;
  self.fMaxZ := Value;
  fWinSize := CUSTOM_SIZE;
end;

procedure TvgViewport.SetMinZ(const Value: TvkFloat);
begin
  If IsZero(fMinZ-Value) then exit;
  self.fMinZ := Value;
  fWinSize := CUSTOM_SIZE;
end;

procedure TvgViewport.SetName(const Value: String);
begin
  self.fName := Value;
end;

procedure TvgViewport.SetSize(const Value: TvgWinSize);
begin
  self.fWinSize := Value;
end;

procedure TvgViewport.SetTop(const Value: TvkFloat);
begin
  If IsZero(fTop-Value) then exit;
  self.fTop := Value;
  fWinSize := CUSTOM_SIZE;
end;

procedure TvgViewport.SetWidth(const Value: TvkFloat);
begin
  If IsZero(fWidth-Value) then exit;
  self.fWidth := Value;
  fWinSize := CUSTOM_SIZE;
end;

{ TvgViewports }

function TvgViewports.Add: TvgViewport;
begin
  Result := TvgViewport(inherited Add);
end;

function TvgViewports.AddItem(Item: TvgViewport; Index: Integer): TvgViewport;
begin
  if Item = nil then
    Result := TvgViewport.Create(self)
  else
    Result := Item;

  if Assigned(Result) then
  begin
    Result.Collection := Self;
    if Index < 0 then
      Index := Count - 1;
    Result.Index := Index;
  end;
end;

constructor TvgViewports.Create(CollOwner: TvgGraphicPipeline);
begin
  Inherited Create(TvgViewport);
  fComp := CollOwner;
end;

function TvgViewports.GetItem(Index: Integer): TvgViewport;
begin
  Result := TvgViewport(inherited GetItem(Index));
end;

function TvgViewports.GetOwner: TPersistent;
begin
  Result:=fComp;
end;

function TvgViewports.Insert(Index: Integer): TvgViewport;
begin
  Result := AddItem(nil, Index);
end;

procedure TvgViewports.SetItem(Index: Integer; const Value: TvgViewport);
begin
  inherited SetItem(Index, Value);
end;

procedure TvgViewports.Update(Item: TCollectionItem);
begin
  //inherited;

end;

{ TvgScissor }

procedure TvgScissor.Assign(Source: TPersistent);
  var L:TvgScissor;
begin
  if Source is TvgScissor then
  begin
    L:=TvgScissor(Source);
    self.fName     := L.fName;
    self.fWinSize  := L.fWinSize;
    self.fLeft   := L.fLeft;
    self.fTop    := L.fTop;
    self.fWidth  := L.fWidth;
    self.fHeight := L.fHeight;
  end
  else
  inherited Assign(Source);

end;

constructor TvgScissor.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  fName := 'Scissor ' +  IntToStr(Collection.Count)

end;

function TvgScissor.GetDisplayName: string;
begin
  Result:=fName;
end;

function TvgScissor.GetHeight: TvkFloat;
begin
  Result:=self.fHeight;
end;

function TvgScissor.GetLeft: TvkFloat;
begin
  Result:=self.fLeft;
end;

function TvgScissor.GetName: String;
begin
  Result:=self.fName;
end;

function TvgScissor.GetSize: TvgWinSize;
begin
  Result:=fWinSize;
end;

function TvgScissor.GetTop: TvkFloat;
begin
  Result:=self.fTop;
end;

function TvgScissor.GetWidth: TvkFloat;
begin
  Result:=self.fWidth;
end;

procedure TvgScissor.SetHeight(const Value: TvkFloat);
begin
  If IsZero(fHeight-Value) then exit;
  self.fHeight := Value;
  fWinSize:=CUSTOM_SIZE;
end;

procedure TvgScissor.SetLeft(const Value: TvkFloat);
begin
  If IsZero(fLeft-Value) then exit;

  self.fLeft := Value;
  fWinSize:=CUSTOM_SIZE;
end;

procedure TvgScissor.SetName(const Value: String);
begin
  self.fName := Value;
end;

procedure TvgScissor.SetSize(const Value: TvgWinSize);
begin
  fWinsize:=Value;
end;

procedure TvgScissor.SetTop(const Value: TvkFloat);
begin
  If IsZero(fTop-Value) then exit;
  self.fTop := Value;
  fWinSize:=CUSTOM_SIZE;
end;

procedure TvgScissor.SetWidth(const Value: TvkFloat);
begin
  If IsZero(fWidth-Value) then exit;
  self.fWidth := Value;
  fWinSize:=CUSTOM_SIZE;
end;

{ TvgScissors }

function TvgScissors.Add: TvgScissor;
begin
  Result := TvgScissor(inherited Add);
end;

function TvgScissors.AddItem(Item: TvgScissor; Index: Integer): TvgScissor;
begin
  if Item = nil then
    Result := TvgScissor.Create(self)
  else
    Result := Item;

  if Assigned(Result) then
  begin
    Result.Collection := Self;
    if Index < 0 then
      Index := Count - 1;
    Result.Index := Index;
  end;
end;

constructor TvgScissors.Create(CollOwner: TvgGraphicPipeline);
begin
  Inherited Create(TvgScissor);
  fComp := CollOwner;
end;

function TvgScissors.GetItem(Index: Integer): TvgScissor;
begin
  Result := TvgScissor(inherited GetItem(Index));
end;

function TvgScissors.GetOwner: TPersistent;
begin
  Result:=fComp;
end;

function TvgScissors.Insert(Index: Integer): TvgScissor;
begin
  Result := AddItem(nil, Index);
end;

procedure TvgScissors.SetItem(Index: Integer; const Value: TvgScissor);
begin
  inherited SetItem(Index, Value);
end;

procedure TvgScissors.Update(Item: TCollectionItem);
begin
 // inherited;

end;

{ TvgDynamicState }

procedure TvgDynamicState.Assign(Source: TPersistent);
  var L:TvgDynamicState;
begin
  if Source is TvgDynamicState then
  begin
    L:=TvgDynamicState(Source);
    self.fName     := L.fName;
    self.fState := L.fState;
  end
  else
  inherited Assign(Source);
end;

constructor TvgDynamicState.Create(Collection: TCollection);
  Var I:Integer;
begin
  inherited Create(Collection);

  fDynamicState:=VK_DYNAMIC_STATE_VIEWPORT;
  I:= Ord(GetVGDynamicState( fDynamicState))  ;
  fName := GetEnumName(typeInfo(TvgDynamicStateBit ), I);

end;

function TvgDynamicState.GetDisplayName: string;
begin
  Result:=fName;
end;

function TvgDynamicState.GetDynamicState: TvgDynamicStateBit;
begin
  Result := GetVGDynamicState(fDynamicState);
end;

function TvgDynamicState.GetName: String;
begin
  Result:=fName;
end;

procedure TvgDynamicState.SetDisabled;
begin
  If assigned(Collection) and (Collection is TvgDynamicStates) and Assigned(TvgDynamicStates(Collection).FComp)  then
     TvgDynamicStates(Collection).FComp.SetDisabled;
end;

procedure TvgDynamicState.SetDynamicState(const Value: TvgDynamicStateBit);
  Var V:TVkDynamicState;

    Function AlreadyExists:Boolean;   //can only allow 1 instance of each state requested
      Var C:TCollection;
          I:Integer;
          D:TvgDynamicState;
    Begin
      Result:=False;
      C:=Collection;
      If C.Count>0 then
      For I:=0  to C.count-1 do
      Begin
        If C.Items[I] is TvgDynamicState then
        Begin
          D:= TvgDynamicState(C.Items[I]);
          If (D<>Self) and (D.fDynamicState=V) then
          Begin
             Result:=True ;
             exit;
          End;
        End;
      End;

    End;

    Procedure SetUpVerAndDepInfo(aVer:TvgAPI_Version; aExtName:String);
      Var Ver:TvkUint32;
    Begin
      Case aVer of
         VG_API_VERSION     : Ver := VK_API_VERSION;
         VG_API_VERSION_1_0 : Ver := VK_API_VERSION_1_0;
         VG_API_VERSION_1_1 : Ver := VK_API_VERSION_1_1;
         VG_API_VERSION_1_2 : Ver := VK_API_VERSION_1_2;
         VG_API_VERSION_1_3 : Ver := VK_API_VERSION_1_3;
      else
         Ver := VK_API_VERSION_1_3;
      End;

      fMinVer := Ver;
      If aExtName<>'' then
         fExtName:=aExtName;
    End;
begin
  V := GetVKDynamicState(Value);

  If AlreadyExists then
  Begin
    exit;
  end;

  If fDynamicState=V then exit;
  SetDisabled;
  fDynamicState:= V;
  fName := GetEnumName(typeInfo(TvgDynamicStateBit ), Ord(Value));

  Case fDynamicState of
       VK_DYNAMIC_STATE_VIEWPORT                  : SetUpVerAndDepInfo(VG_API_VERSION_1_0,'');
       VK_DYNAMIC_STATE_SCISSOR                   : SetUpVerAndDepInfo(VG_API_VERSION_1_0,'');
       VK_DYNAMIC_STATE_LINE_WIDTH                : SetUpVerAndDepInfo(VG_API_VERSION_1_0,'');
       VK_DYNAMIC_STATE_DEPTH_BIAS                : SetUpVerAndDepInfo(VG_API_VERSION_1_0,'');
       VK_DYNAMIC_STATE_BLEND_CONSTANTS           : SetUpVerAndDepInfo(VG_API_VERSION_1_0,'');
       VK_DYNAMIC_STATE_DEPTH_BOUNDS              : SetUpVerAndDepInfo(VG_API_VERSION_1_0,'');
       VK_DYNAMIC_STATE_STENCIL_COMPARE_MASK      : SetUpVerAndDepInfo(VG_API_VERSION_1_0,'');
       VK_DYNAMIC_STATE_STENCIL_WRITE_MASK        : SetUpVerAndDepInfo(VG_API_VERSION_1_0,'');
       VK_DYNAMIC_STATE_STENCIL_REFERENCE         : SetUpVerAndDepInfo(VG_API_VERSION_1_0,'');
       VK_DYNAMIC_STATE_VIEWPORT_W_SCALING_NV     : SetUpVerAndDepInfo(VG_API_VERSION_1_0,'');
       VK_DYNAMIC_STATE_DISCARD_RECTANGLE_EXT     : SetUpVerAndDepInfo(VG_API_VERSION_1_0,'');
       VK_DYNAMIC_STATE_SAMPLE_LOCATIONS_EXT      : SetUpVerAndDepInfo(VG_API_VERSION_1_0,'');
       VK_DYNAMIC_STATE_VIEWPORT_SHADING_RATE_PALETTE_NV: SetUpVerAndDepInfo(VG_API_VERSION_1_0,'');
       VK_DYNAMIC_STATE_VIEWPORT_COARSE_SAMPLE_ORDER_NV: SetUpVerAndDepInfo(VG_API_VERSION_1_0,'');
       VK_DYNAMIC_STATE_EXCLUSIVE_SCISSOR_NV      : SetUpVerAndDepInfo(VG_API_VERSION_1_0,'');
       VK_DYNAMIC_STATE_FRAGMENT_SHADING_RATE_KHR : SetUpVerAndDepInfo(VG_API_VERSION_1_0,'');
       VK_DYNAMIC_STATE_LINE_STIPPLE_EXT          : SetUpVerAndDepInfo(VG_API_VERSION_1_0,'');
       VK_DYNAMIC_STATE_CULL_MODE                 : SetUpVerAndDepInfo(VG_API_VERSION_1_3,VK_EXT_extended_dynamic_state_EXTENSION_NAME);         //1_3
       VK_DYNAMIC_STATE_FRONT_FACE                : SetUpVerAndDepInfo(VG_API_VERSION_1_3,VK_EXT_extended_dynamic_state_EXTENSION_NAME);           //1_3
       VK_DYNAMIC_STATE_PRIMITIVE_TOPOLOGY        : SetUpVerAndDepInfo(VG_API_VERSION_1_3,VK_EXT_extended_dynamic_state_EXTENSION_NAME);    //1_3
       VK_DYNAMIC_STATE_VIEWPORT_WITH_COUNT       : SetUpVerAndDepInfo(VG_API_VERSION_1_3,VK_EXT_extended_dynamic_state_EXTENSION_NAME);    //1_3
       VK_DYNAMIC_STATE_SCISSOR_WITH_COUNT        : SetUpVerAndDepInfo(VG_API_VERSION_1_3,VK_EXT_extended_dynamic_state_EXTENSION_NAME);      //1_3
       VK_DYNAMIC_STATE_VERTEX_INPUT_BINDING_STRIDE: SetUpVerAndDepInfo(VG_API_VERSION_1_3,VK_EXT_extended_dynamic_state_EXTENSION_NAME);    //1_3
       VK_DYNAMIC_STATE_DEPTH_TEST_ENABLE         : SetUpVerAndDepInfo(VG_API_VERSION_1_3,VK_EXT_extended_dynamic_state_EXTENSION_NAME);      //1_3
       VK_DYNAMIC_STATE_DEPTH_WRITE_ENABLE        : SetUpVerAndDepInfo(VG_API_VERSION_1_3,VK_EXT_extended_dynamic_state_EXTENSION_NAME);      //1_3
       VK_DYNAMIC_STATE_DEPTH_COMPARE_OP          : SetUpVerAndDepInfo(VG_API_VERSION_1_3,VK_EXT_extended_dynamic_state_EXTENSION_NAME);          //1_3
       VK_DYNAMIC_STATE_DEPTH_BOUNDS_TEST_ENABLE  : SetUpVerAndDepInfo(VG_API_VERSION_1_3,VK_EXT_extended_dynamic_state_EXTENSION_NAME);     //1_3
       VK_DYNAMIC_STATE_STENCIL_TEST_ENABLE       : SetUpVerAndDepInfo(VG_API_VERSION_1_3,VK_EXT_extended_dynamic_state_EXTENSION_NAME);        //1_3
       VK_DYNAMIC_STATE_STENCIL_OP                : SetUpVerAndDepInfo(VG_API_VERSION_1_3,VK_EXT_extended_dynamic_state_EXTENSION_NAME);         //1_3
       VK_DYNAMIC_STATE_RAY_TRACING_PIPELINE_STACK_SIZE_KHR: SetUpVerAndDepInfo(VG_API_VERSION_1_0,VK_KHR_ray_tracing_pipeline_EXTENSION_NAME);
       VK_DYNAMIC_STATE_VERTEX_INPUT_EXT          : SetUpVerAndDepInfo(VG_API_VERSION_1_0,VK_EXT_vertex_input_dynamic_state_EXTENSION_NAME);
       VK_DYNAMIC_STATE_PATCH_CONTROL_POINTS_EXT  : SetUpVerAndDepInfo(VG_API_VERSION_1_0,VK_EXT_EXTENDED_DYNAMIC_STATE_2_EXTENSION_NAME);
       VK_DYNAMIC_STATE_RASTERIZER_DISCARD_ENABLE : SetUpVerAndDepInfo(VG_API_VERSION_1_3,VK_EXT_EXTENDED_DYNAMIC_STATE_2_EXTENSION_NAME);
       VK_DYNAMIC_STATE_DEPTH_BIAS_ENABLE         : SetUpVerAndDepInfo(VG_API_VERSION_1_3,VK_EXT_EXTENDED_DYNAMIC_STATE_2_EXTENSION_NAME);
       VK_DYNAMIC_STATE_LOGIC_OP_EXT              : SetUpVerAndDepInfo(VG_API_VERSION_1_0,VK_EXT_EXTENDED_DYNAMIC_STATE_2_EXTENSION_NAME);
       VK_DYNAMIC_STATE_PRIMITIVE_RESTART_ENABLE  : SetUpVerAndDepInfo(VG_API_VERSION_1_3,VK_EXT_extended_dynamic_state_EXTENSION_NAME);
       VK_DYNAMIC_STATE_COLOR_WRITE_ENABLE_EXT    : SetUpVerAndDepInfo(VG_API_VERSION_1_0,VK_EXT_color_write_enable_EXTENSION_NAME);
       (*
       VK_DYNAMIC_STATE_CULL_MODE_EXT=VK_DYNAMIC_STATE_CULL_MODE,
       VK_DYNAMIC_STATE_DEPTH_BIAS_ENABLE_EXT=VK_DYNAMIC_STATE_DEPTH_BIAS_ENABLE,
       VK_DYNAMIC_STATE_DEPTH_BOUNDS_TEST_ENABLE_EXT=VK_DYNAMIC_STATE_DEPTH_BOUNDS_TEST_ENABLE,
       VK_DYNAMIC_STATE_DEPTH_COMPARE_OP_EXT=VK_DYNAMIC_STATE_DEPTH_COMPARE_OP,
       VK_DYNAMIC_STATE_DEPTH_TEST_ENABLE_EXT=VK_DYNAMIC_STATE_DEPTH_TEST_ENABLE,
       VK_DYNAMIC_STATE_DEPTH_WRITE_ENABLE_EXT=VK_DYNAMIC_STATE_DEPTH_WRITE_ENABLE,
       VK_DYNAMIC_STATE_FRONT_FACE_EXT=VK_DYNAMIC_STATE_FRONT_FACE,
       VK_DYNAMIC_STATE_PRIMITIVE_RESTART_ENABLE_EXT=VK_DYNAMIC_STATE_PRIMITIVE_RESTART_ENABLE,
       VK_DYNAMIC_STATE_PRIMITIVE_TOPOLOGY_EXT=VK_DYNAMIC_STATE_PRIMITIVE_TOPOLOGY,
       VK_DYNAMIC_STATE_RASTERIZER_DISCARD_ENABLE_EXT=VK_DYNAMIC_STATE_RASTERIZER_DISCARD_ENABLE,
       VK_DYNAMIC_STATE_SCISSOR_WITH_COUNT_EXT=VK_DYNAMIC_STATE_SCISSOR_WITH_COUNT,
       VK_DYNAMIC_STATE_STENCIL_OP_EXT=VK_DYNAMIC_STATE_STENCIL_OP,
       VK_DYNAMIC_STATE_STENCIL_TEST_ENABLE_EXT=VK_DYNAMIC_STATE_STENCIL_TEST_ENABLE,
       VK_DYNAMIC_STATE_VERTEX_INPUT_BINDING_STRIDE_EXT=VK_DYNAMIC_STATE_VERTEX_INPUT_BINDING_STRIDE,
       VK_DYNAMIC_STATE_VIEWPORT_WITH_COUNT_EXT=VK_DYNAMIC_STATE_VIEWPORT_WITH_COUNT
       *)

  End;


end;

procedure TvgDynamicState.SetName(const Value: String);
begin
  fName:=Value;
end;

procedure TvgDynamicState.SetUpDynamicStateExtension( aExtensions: TvgExtensions; aVer: TvkUint32);
  Var I : Integer;
      E : TvgExtension;
begin
  fstate := DS_NOTSET;

  If (aVer>=fMinVer) then
     fState := DS_READY
  else
  Begin
    If fExtName='' then exit;
    If not assigned(aExtensions) then exit;
    If aExtensions.Count=0 then exit;

    For I:=0 to aExtensions.count-1 do
    Begin
      E:= aExtensions.Items[I];
      If CompareText(fExtName,String(E.fExtensionName))=0 then
      Begin
        E.ExtMode := VGE_MUST_HAVE;
        fState    := DS_READY;
        exit;
      End;
    End;
  End;

end;

{ TvgDynamicStates }

function TvgDynamicStates.Add: TvgDynamicState;
begin
  Result := TvgDynamicState(inherited Add);
end;

function TvgDynamicStates.AddItem(Item: TvgDynamicState; Index: Integer): TvgDynamicState;
begin
  if Item = nil then
    Result := TvgDynamicState.Create(self)
  else
    Result := Item;

  if Assigned(Result) then
  begin
    Result.Collection := Self;
    if Index < 0 then
      Index := Count - 1;
    Result.Index := Index;
  end;
end;

constructor TvgDynamicStates.Create(CollOwner: TvgGraphicPipeline);
begin
  Inherited Create(TvgDynamicState);
  fComp := CollOwner;
end;

function TvgDynamicStates.GetItem(Index: Integer): TvgDynamicState;
begin
  Result := TvgDynamicState(inherited GetItem(Index));
end;

function TvgDynamicStates.GetOwner: TPersistent;
begin
  Result:=fComp;
end;

function TvgDynamicStates.Insert(Index: Integer): TvgDynamicState;
begin
  Result := AddItem(nil, Index);
end;

procedure TvgDynamicStates.SetItem(Index: Integer; const Value: TvgDynamicState);
begin
  inherited SetItem(Index, Value);
end;

procedure TvgDynamicStates.Update(Item: TCollectionItem);
begin
  //inherited;

end;

{ TvgRenderPassAttachment }

procedure TvgAttachment.Assign(Source: TPersistent);
begin
  inherited;

end;

constructor TvgAttachment.Create(Collection: TCollection);
begin
  inherited;

   fIndex := High(TvkUint32);

   fFlags          := 0;  //not used
   fFormat         := VK_FORMAT_R8G8B8A8_SRGB;  //  SET FROM SWAP CHAIN
   fsamples        := VK_SAMPLE_COUNT_1_BIT;
   floadOp         := VK_ATTACHMENT_LOAD_OP_CLEAR;
   fstoreOp        := VK_ATTACHMENT_STORE_OP_STORE;
   fstencilLoadOp  := VK_ATTACHMENT_LOAD_OP_DONT_CARE;
   fstencilStoreOp := VK_ATTACHMENT_STORE_OP_DONT_CARE;
   finitialLayout  := VK_IMAGE_LAYOUT_UNDEFINED;
   ffinalLayout    := VK_IMAGE_LAYOUT_PRESENT_SRC_KHR;

   If assigned(Collection) then
     fName := System.SysUtils.Format('Attach - %d',[Collection.Count -1]);

   fImageBufferSize := 1;

end;

procedure TvgAttachment.DefineProperties(Filer: TFiler);
begin
  inherited;

end;

destructor TvgAttachment.Destroy;
  Var I:Integer;
begin
  If Length(fImageBufferArray)>0 then
  Begin
    for I:=0 to Length(fImageBufferArray)-1 do
    Begin
     fImageBufferArray[I].Active:=False;
     fImageBufferArray[I].SetSubComponent(False);
     FreeAndNil(fImageBufferArray[I]);
    End;
    SetLength(fImageBufferArray,0);
  End;

  inherited;
end;

function TvgAttachment.GetDisplayName: string;
begin
  Result:=fName;
end;

function TvgAttachment.GetFinalLayout: TvgImageLayout;
begin
  Result := GetVGImageLayout(fFinalLayout)  ;
end;

function TvgAttachment.GetFormat: TvgFormat;
begin
  Result := GetVGFormat(fFormat);
end;

function TvgAttachment.GetImageBuffer(Index: Integer): TvgResourceImageBuffer;
begin
  Result := nil;
  if (Index>=0) and (Index<Length(fImageBufferArray)) then
     Result := fImageBufferArray[Index];
end;

function TvgAttachment.GetInitialLayout: TvgImageLayout;
begin
  Result := GetVGImageLayout(finitialLayout)  ;
end;

function TvgAttachment.GetLoadOp: TvgAttachmentLoadOp;
begin
  Result := GetVGLoadOp(self.floadOp)  ;
end;

function TvgAttachment.getName: String;
begin
  Result:=fName;
end;

function TvgAttachment.GetRenderPass: TvgRenderPass;
begin
  If assigned(Collection) and
     (Collection is TvgAttachmentCol) and
     assigned(TvgAttachmentCol(Collection).RenderPass) then
    Result := TvgAttachmentCol(Collection).RenderPass
  else
    Result:=Nil;
end;

function TvgAttachment.GetSamples: TvgSampleCountFlagBits;
begin
  Result := GetVGSampleCountFlagBit(self.fsamples)  ;
end;

function TvgAttachment.GetStencilLoadOp: TvgAttachmentLoadOp;
begin
  Result := GetVGLoadOp(self.fstencilLoadOp)  ;
end;

function TvgAttachment.GetStencilStoreOp: TvgAttachmentStoreOp;
begin
  Result := GetVGStoreOp(self.fstencilStoreOp)  ;
end;

function TvgAttachment.GetStoreOp: TvgAttachmentStoreOp;
begin
  Result := GetVGStoreOp(self.fstoreOp)  ;
end;

function TvgAttachment.GetType: TvgAttachmentType;
begin
  Result:= fType;
end;

procedure TvgAttachment.SetDisabled;
  Var I:Integer;
begin

  If Length(fImageBufferArray)>0 then
  Begin
    for I:=0 to Length(fImageBufferArray)-1 do
    Begin
     fImageBufferArray[I].Active:=False;
     fImageBufferArray[I].SetSubComponent(False);
     FreeAndNil(fImageBufferArray[I]);
    End;
    SetLength(fImageBufferArray,0);
  End;

  fActive := False;
end;

procedure TvgAttachment.SetEnabled;
  Var aWinLink  : TvgLinker;
      I:Integer;
begin
  fActive := True;

  If not assigned(Collection) or
     not (Collection is TvgAttachmentCol) or
     not assigned(TvgAttachmentCol(Collection).RenderPass) or
     not assigned(TvgAttachmentCol(Collection).RenderPass.Linker) then exit;

  aWinLink := TvgAttachmentCol(Collection).RenderPass.Linker;

  if assigned(aWinLink) then
      case TvgAttachmentCol(Collection).RenderPass.Linker.RenderTarget of
          RT_SCREEN : fImageBufferSize := aWinLink.SwapChain.ImageCount;
          RT_FRAME  : fImageBufferSize := aWinLink.FrameCount;
       else
          fImageBufferSize := 1;
      end;

  If not(fType in [atScreen, atFrame]) then
  Begin
      If Length(fImageBufferArray)<>fImageBufferSize then
      Begin
          SetLength(fImageBufferArray,fImageBufferSize);

          for I := 0 to Length(fImageBufferArray)-1 do
          Begin
            If not assigned(fImageBufferArray[I]) then
            Begin
              fImageBufferArray[I]       := TvgResourceImageBuffer.Create(nil);
              fImageBufferArray[I].Name  := System.SysUtils.Format('Image_%d',[I]);
              fImageBufferArray[I].SetSubComponent(True);
              fImageBufferArray[I].Linker := aWinLink;
            End;
          end;
      end;

      SetUpImageResources;

      for I := 0 to Length(fImageBufferArray)-1 do
      Begin
        If assigned(fImageBufferArray[I]) then
        begin
           fImageBufferArray[I].Active  := True;
        end;
      end;
  end;



end;

procedure TvgAttachment.SetFinalLayout(const Value: TvgImageLayout);
  Var V: TVkImageLayout;
begin
  V:=GetVKImageLayout(Value);
  If self.ffinalLayout=V then exit;
  SetDisabled;
  ffinalLayout:=V;
end;

procedure TvgAttachment.SetFormat(const Value: TvgFormat);
  Var V:TvkFormat;
      I:Integer;
begin
  V:= GetVKFormat(Value);
  If fFormat=V then exit;
  Setdisabled;
  fFormat := V;

  if Length(fImageBufferArray)>0 then
  Begin
    for I := 0 to Length(fImageBufferArray)-1 do
    Begin
      if assigned(fImageBufferArray[I]) then
      Begin
         fImageBufferArray[I].fFormat := fFormat;
      End;
    End;
  end;
end;

procedure TvgAttachment.SetImageBufferSize(const Value: Integer);
begin
  if fImageBufferSize=Value then exit;
  SetDisabled;
  fImageBufferSize := Value;

end;

procedure TvgAttachment.SetInitialLayout(const Value: TvgImageLayout);
  Var V: TVkImageLayout;
begin
  V:=GetVKImageLayout(Value);
  If self.finitialLayout=V then exit;
  SetDisabled;
  finitialLayout:=V;
end;

procedure TvgAttachment.SetLoadOp(const Value: TvgAttachmentLoadOp);
  Var V: TVkAttachmentLoadOp;
begin
  V:=GetVKLoadOp(Value);
  If floadOp=V then exit;
  SetDisabled;
  fLoadOp:=V;
end;

procedure TvgAttachment.SetName(const Value: String);
begin
  fName:=Value;
  If fName='' then
     fName:='Attachment';
end;

procedure TvgAttachment.SetSamples(const Value: TvgSampleCountFlagBits);
  Var V: TVkSampleCountFlagBits;
begin
  V:=GetVKSampleCountFlagBit(Value);
  If fsamples=V then exit;
  SetDisabled;
  fsamples:=V;
end;

procedure TvgAttachment.SetStencilLoadOp( const Value: TvgAttachmentLoadOp);
  Var V: TVkAttachmentLoadOp;
begin
  V:=GetVKLoadOp(Value);
  If fstencilLoadOp=V then exit;
  SetDisabled;
  fstencilLoadOp:=V;
end;

procedure TvgAttachment.SetStencilStoreOp(const Value: TvgAttachmentStoreOp);
  Var V: TVkAttachmentStoreOp;
begin
  V:=GetVKStoreOp(Value);
  If fstencilStoreOp=V then exit;
  SetDisabled;
  fstencilStoreOp:=V;
end;

procedure TvgAttachment.SetStoreOp(const Value: TvgAttachmentStoreOp);
  Var V: TVkAttachmentStoreOp;
begin
  V:=GetVKStoreOp(Value);
  If fstoreOp=V then exit;
  SetDisabled;
  fstoreOp:=V;
end;

procedure TvgAttachment.SetType(const Value: TvgAttachmentType);
begin
  If Value = fType then exit;
  SetDisabled;
  fType := Value;

  SetUpForType;

end;

procedure TvgAttachment.SetUpForType;
  Var RP     : TvgRenderPass;
      MSAAOn : Boolean;
  //    I      : Integer;
begin

//  SetDisabled;
  RP := GetRenderPass;
  If not assigned(RP) then exit;

//  WL     := RP.Linker;

  MSAAOn := RP.IsMSAAOn;

  Case fType of
     atCustom:Begin
                 fName           := 'Custom';

               //  fImageBuffer.Name  := 'Asset_Custom';
     end;

     atScreen :Begin
                    //Checked OK
                 fName              := 'Screen_Attachment';
                 if (RP.fColourFormat<> VK_FORMAT_UNDEFINED) then
                    fformat            := RP.fColourFormat;
                 fsamples           := VK_SAMPLE_COUNT_1_BIT;    //should stay as 1 bit if resolve
                 fInitialLayout     := VK_IMAGE_LAYOUT_UNDEFINED;
                 ffinalLayout       := VK_IMAGE_LAYOUT_PRESENT_SRC_KHR;
                 floadOp            := VK_ATTACHMENT_LOAD_OP_CLEAR ;
                 fStoreOp           := VK_ATTACHMENT_STORE_OP_STORE;
                 fstencilLoadOp     := VK_ATTACHMENT_LOAD_OP_DONT_CARE;
                 fstencilStoreOp    := VK_ATTACHMENT_STORE_OP_DONT_CARE;
                 fflags             := 0;

                 //no image buffer needed for Screen
               End;
     atFrame: Begin
     //used as off screen buffer for rendering
                 fName           := 'OffColour_Attachment';
                 if (RP.fColourFormat<> VK_FORMAT_UNDEFINED) then
                    fformat      := RP.fColourFormat ;     //needs to be same format as screen?? check
              //   else
              //      fformat      := VK_FORMAT_R32G32B32A32_SFLOAT;//high res image//RP.fColourFormat;   CHECK

                 fsamples        := VK_SAMPLE_COUNT_1_BIT;         //should stay as 1 bit if resolve
                 finitialLayout  := VK_IMAGE_LAYOUT_UNDEFINED;
                 ffinalLayout    := VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL;
                 floadOp         := VK_ATTACHMENT_LOAD_OP_CLEAR;
                 fStoreOp        := VK_ATTACHMENT_STORE_OP_STORE;
                 fstencilLoadOp  := VK_ATTACHMENT_LOAD_OP_DONT_CARE;
                 fstencilStoreOp := VK_ATTACHMENT_STORE_OP_DONT_CARE;
                 fflags          := 0;

               End;

     atColour :Begin

                 fName           := 'Colour_Attachment';
                 if (RP.fColourFormat<> VK_FORMAT_UNDEFINED) then
                     fformat     := RP.fColourFormat;//VK_FORMAT_R32G32B32A32_SFLOAT;//high res image//
                 fsamples        := VK_SAMPLE_COUNT_1_BIT;
                 finitialLayout  := VK_IMAGE_LAYOUT_UNDEFINED;
                 ffinalLayout    := VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL;
                 floadOp         := VK_ATTACHMENT_LOAD_OP_DONT_CARE;
                 fStoreOp        := VK_ATTACHMENT_STORE_OP_STORE;
                 fstencilLoadOp  := VK_ATTACHMENT_LOAD_OP_DONT_CARE;
                 fstencilStoreOp := VK_ATTACHMENT_STORE_OP_DONT_CARE;
                 fflags          := 0;

               End;

     atDepthStencil  :Begin
                 fName           := 'DepthStencil_Attachment';
                 fformat         := RP.fDepthStencilFormat;
                 If NOT MSAAOn then
                    fsamples     := VK_SAMPLE_COUNT_1_BIT
                 else
                    fsamples     :=  RP.fMSAASampleCount ;
                 finitialLayout  := VK_IMAGE_LAYOUT_UNDEFINED;
                 ffinalLayout    := VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL;
                 floadOp         := VK_ATTACHMENT_LOAD_OP_CLEAR;
                 fStoreOp        := VK_ATTACHMENT_STORE_OP_DONT_CARE;;
                 fstencilLoadOp  := VK_ATTACHMENT_LOAD_OP_CLEAR;
                 fstencilStoreOp := VK_ATTACHMENT_STORE_OP_DONT_CARE;
                 fflags          := 0;

            End;

     atMSAA :Begin
                   //Checked OK
                 fName           := 'MSAA';
                 fformat         := VK_FORMAT_R8G8B8A8_UNORM;
                 fsamples        := RP.fMSAASampleCount;
                 finitialLayout  := VK_IMAGE_LAYOUT_UNDEFINED;
                 ffinalLayout    := VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL;
                 floadOp         := VK_ATTACHMENT_LOAD_OP_CLEAR;
                 fStoreOp        := VK_ATTACHMENT_STORE_OP_DONT_CARE;
                 fstencilLoadOp  := VK_ATTACHMENT_LOAD_OP_DONT_CARE;
                 fstencilStoreOp := VK_ATTACHMENT_STORE_OP_DONT_CARE;
                 fflags          := 0;

               End;
  End;

end;

procedure TvgAttachment.SetUpImageResources;
  Var RP     : TvgRenderPass;
      MSAAOn : Boolean;
      I      : Integer;
    //  ImgFmt : TvkFormat;
begin

  RP := GetRenderPass;
  If not assigned(RP) then exit;
  If not assigned(RP.Linker) then exit;

  Assert( assigned(RP.Linker.Renderer),'Renderer not assigned');

  MSAAOn := RP.IsMSAAOn;

  Case fType of
     atCustom:Begin
     end;

     atScreen :Begin
      (*
         if (fFormat<> RP.Linker.ImageFormat) and (RP.Linker.ImageFormat<>VK_FORMAT_UNDEFINED) then
         Begin
           fFormat := RP.Linker.ImageFormat;

            If (Length(fImageBufferArray)>0) then
            Begin
              for I := 0 to Length(fImageBufferArray)-1 do
              Begin
               fImageBufferArray[I].Name      := System.SysUtils.Format('Asset_Screen_%d',[I]);
               fImageBufferArray[I].fMSAAOn   := MSAAOn;
               fImageBufferArray[I].ImageMode := imColour;
              End;
            end;
         End;
     *)
     End;


     atFrame: Begin
     (*
                if (RP.Linker.RenderTarget=RT_FRAME) and (RP.Linker.FrameCount>0) then
                Begin
                  for I := 0 to RP.Linker.FrameCount-1 do
                  Begin
                     if assigned(RP.Linker.Frame[I].FrameImageBuffer) then
                     Begin
                       RP.Linker.Frame[I].FrameImageBuffer.Name      := System.SysUtils.Format('Asset_Frame_%d',[I]);
                       RP.Linker.Frame[I].FrameImageBuffer.MSAAOn    := MSAAOn;
                       RP.Linker.Frame[I].FrameImageBuffer.ImageMode := imFrame;
                     End;
                  End;
                end;
      *)
               End;

     atColour :Begin
                  If (Length(fImageBufferArray)>0) then
                    for I := 0 to Length(fImageBufferArray)-1 do
                    Begin
                     fImageBufferArray[I].Name      := System.SysUtils.Format('Asset_Color_%d',[I]);
                     fImageBufferArray[I].fMSAAOn   := MSAAOn;
                     fImageBufferArray[I].ImageMode := imColour;
                    End;
               End;

     atDepthStencil  :Begin
                  If (Length(fImageBufferArray)>0) then
                    for I := 0 to Length(fImageBufferArray)-1 do
                    Begin
                     fImageBufferArray[I].Name        := System.SysUtils.Format('Asset_DS_%d',[I]);
                     fImageBufferArray[I].fMSAAOn     := MSAAOn;
                     If not RP.StencilBufOn then
                        fImageBufferArray[I].ImageMode   := imDepth
                     else
                        fImageBufferArray[I].ImageMode   := imDepthStencil;
                    End;
            End;

     atMSAA :Begin
                  If (Length(fImageBufferArray)>0) then
                    for I := 0 to Length(fImageBufferArray)-1 do
                    Begin
                     fImageBufferArray[I].Name      := System.SysUtils.Format('Asset_MSAA_%d',[I]);
                     fImageBufferArray[I].fMSAAOn   := MSAAOn;
                     fImageBufferArray[I].ImageMode := imMSAA;
                    End;
               End;

  end;

  If (Length(fImageBufferArray)>0) then
  Begin
       fFormat := fImageBufferArray[0].fFormat;
       fSamples:= fImageBufferArray[0].fSamples;
  End;

end;

{ TvgRenderPassAttachmentCol }

function TvgAttachmentCol.Add: TvgAttachment;
begin
  Result := TvgAttachment(inherited Add);
end;

function TvgAttachmentCol.AddItem(Item: TvgAttachment; Index: Integer): TvgAttachment;
begin
  if Item = nil then
    Result := TvgAttachment.Create(self)
  else
    Result := Item;

  if Assigned(Result) then
  begin
    Result.Collection := Self;
    if Index < 0 then
      Index := Count - 1;
    Result.Index := Index;
  end;
end;

constructor TvgAttachmentCol.Create(CollOwner: TvgRenderPass);
begin
  Inherited Create(TvgAttachment);
  fComp := CollOwner;
end;

function TvgAttachmentCol.GetAttachmentType( aType: TvgAttachmentType): TvgAttachment;
   Var L,I:Integer;
begin
  Result:=nil;
  L:= self.Count;
  If L=0 then exit;
  For I:=0 to L-1 do
    If Items[I].fType = aType then
    Begin
      Result:=Items[I];
      Break;
    End;
end;

function TvgAttachmentCol.GetItem(  Index: Integer): TvgAttachment;
begin
  Result := TvgAttachment(inherited GetItem(Index));
end;

function TvgAttachmentCol.GetOwner: TPersistent;
begin
  Result := fComp;
end;

function TvgAttachmentCol.GetRenderPass: TvgRenderPass;
begin
  Result := FComp;
end;

function TvgAttachmentCol.Insert( Index: Integer): TvgAttachment;
begin
  Result := AddItem(nil, Index);
end;

procedure TvgAttachmentCol.Notify(Item: TCollectionItem;  Action: TCollectionNotification);
  Var RP:TvgRenderpass;
       I:Integer;
      SP:TvgSubPass;

   Procedure CheckAttachmentRef(aRef:TvgSubPassAttachmentCol);
     Var I:Integer;
         AR: TvgSubPassAttachment;
   Begin
     If aRef.Count=0 then exit;
     For I:=0 to aRef.Count-1 do
     Begin
       AR:= aRef.Items[I];
       If (AR.fAttachment = Item) then
           AR.fAttachment:=nil;
     end;
   end;

begin
  inherited;
  If not assigned(Item) then exit;

  Case Action of
     cnExtracting,
     cnDeleting     :
     Begin
          If (Owner<>nil) and (Owner is TvgRenderpass) then
          Begin
            RP := TvgRenderPass(Owner) ;
            If RP.fSubPasses.Count>0 then
            Begin
              For I:=0 to RP.fSubPasses.Count-1 do
              Begin
                SP:= RP.fSubPasses.Items[I];
                CheckAttachmentRef(SP.fInputAttachmentRefs);
                CheckAttachmentRef(SP.fColorAttachmentRefs);
                CheckAttachmentRef(SP.fResolveAttachmentRefs);
                CheckAttachmentRef(SP.fDepthStencilAttachmentRef);
                CheckAttachmentRef(SP.fPreserveAttachmentRefs);
              End;
            End;
          End;
     End;
  End;

end;

procedure TvgAttachmentCol.SetItem(Index: Integer; const Value: TvgAttachment);
begin
    inherited SetItem(Index, Value);
end;

procedure TvgAttachmentCol.Update(Item: TCollectionItem);
begin
 // inherited;

end;

{ TvgRenderPass }

procedure TvgRenderPass.AddFrameToScreenSubPass;
    Var// MSAAon:Boolean;
            SP: TvgSubPass;
            A : TvgAttachment;
            AR: TvgSubPassAttachment;
            SD: TvgSubPassDependency;
            CF:Boolean;

    Function CheckForFrameAttachment:Boolean;
      Var I:Integer;
    Begin
      Result := False;
      if fAttachments.Count=0  then exit;
      for I := 0 to fAttachments.Count-1 do
         if fAttachments.Items[I].fType=atFrame then
         Begin
           Result := True;
           exit;
         End;
    End;

begin
  // build a sub pass to copy Frame to Screen
  Assert(assigned(fLinker),'TvgRenderPass: Linker not connected');
  if not (fLinker.RenderTarget=RT_FRAME) then exit;

  CF :=  CheckForFrameAttachment ;
//  Assert(CF,'FRAME attachment not included in Attachments');
  if not CF then exit;

  SP:= fSubPasses.Add;  //sub pass #0

  Assert(Assigned(SP),'SubPass not assigned');

  If (SP.PipelineBindPoint <>  BP_GRAPHICS) then
      SP.PipelineBindPoint :=  BP_GRAPHICS;

  SP.Name := 'FrameToScreen_1';

  //Screen Attachment Target for rendering
  A := fAttachments.Add;
  If assigned(A) then
  Begin
           A.Name              := 'FTSScreen_Attach_1';
           A.AttachType        := atScreen;//  screen image buffer

           If Assigned(SP) then
           Begin
             AR := SP.ColorAttachments.Add;

             If Assigned(AR) then
             Begin
               AR.Attachment := A;
               AR.Layout     := COLOR_ATTACHMENT_OPTIMAL;
             End;
           end;

        //SubPass Dependancy
          SD := fSubPassDependencies.add;

          If Assigned(SD) then
          Begin
            SD.Name             := 'FTSDependency_2';
            SD.SrcSubPass       := Nil;
            SD.DstSubpass       := SP;
            SD.SrcStageMask     := [COLOR_ATTACHMENT_OUTPUT_BIT];
            SD.DstStageMask     := [COLOR_ATTACHMENT_OUTPUT_BIT];
            SD.SrcAccessMask    := [];
            SD.DstAccessMask    := [COLOR_ATTACHMENT_WRITE_BIT,
                                    COLOR_ATTACHMENT_READ_BIT];
          end;   //dependency

  end;//screen

  //Frame should already be in attachments maybe check


end;

procedure TvgRenderPass.BuildStructure;
begin
(*
  If fSubPasses.Count>0 then exit;    //already a structure in place

  Assert(assigned(fSubPasses),'SubPass collection not created');
  Assert(assigned(fAttachments),'Attachment collection not created');
  Assert(assigned(fSubPassDependencies),'Dependancies collection not created');
 *)
 // BuildDefaultStructure;

end;


procedure TvgRenderPass.CheckDepthFormatSupport(Tiling:TVkImageTiling);
  Var Props :  TVkFormatProperties ;

  Procedure UpdateFormat;
  Begin
    fDepthStencilFormat := fLinker.fPhysicalDevice.VulkanPhysicalDevice.GetBestSupportedDepthFormat(fStencilBufOn);
  End;

begin
  Assert(Assigned(fLinker),'TvgLinker not assigned');
  Assert(Assigned(fLinker.fPhysicalDevice),'Physical Device not assigned');
  Assert(Assigned(fLinker.fPhysicalDevice.VulkanPhysicalDevice),'Vulkan Physical Device not assigned');
  Assert(Assigned(fLinker.fPhysicalDevice.fInstance),'Instance not assigned');
  Assert(Assigned(fLinker.fPhysicalDevice.fInstance.VulkanInstance),'Vulkan Instance not assigned');
  Assert(Assigned(fLinker.fPhysicalDevice.fInstance.VulkanInstance.Commands),'Vulkan Instance Commands not assigned');

  fLinker.fPhysicalDevice.fInstance.VulkanInstance.Commands.GetPhysicalDeviceFormatProperties(fLinker.fPhysicalDevice.VulkanPhysicalDevice.Handle,
                                                       fDepthStencilFormat,
                                                       @Props);

  If (Tiling = VK_IMAGE_TILING_LINEAR) then
  Begin
    If ((Props.linearTilingFeatures and TVkFormatFeatureFlags(VK_FORMAT_FEATURE_DEPTH_STENCIL_ATTACHMENT_BIT))<>0)  then
       exit
    else
      UpdateFormat;
  end else
  If (Tiling = VK_IMAGE_TILING_OPTIMAL) then
  Begin
    If ((Props.optimalTilingFeatures and ORD(VK_FORMAT_FEATURE_DEPTH_STENCIL_ATTACHMENT_BIT)) = ORD(VK_FORMAT_FEATURE_DEPTH_STENCIL_ATTACHMENT_BIT))  then
       exit
    else
      UpdateFormat;
  End;

end;

function TvgRenderPass.CheckValidity: Boolean;
begin
  Result:=True;

end;

constructor TvgRenderPass.Create(AOwner: TComponent);
begin
  fAttachments         := TvgAttachmentCol.Create(self);
  fSubPasses           := TvgSubPassCol.Create(self);
  fSubPassDependencies := TvgSubPassDependencyCol.Create(Self);

  fRenderPassHandle := VK_NULL_HANDLE;

  inherited;

  //depth test default setup
  fDepthBufOn      :=True;
  fStencilBufOn    :=False;
  SetDepthFormat(DB_D32_SFLOAT);   //check
  fDepthClear      := 1.0;
  fStencilClear    := 0;
  fDepthCompare    := VK_COMPARE_OP_LESS_OR_EQUAL;

//MSAA Default
  fMSAASampleCount := VK_SAMPLE_COUNT_8_BIT;    //=MSAA OFF

end;

destructor TvgRenderPass.Destroy;
begin
  SetActiveState(False);

  If assigned(fAttachments)         then FreeAndNil(fAttachments);
  If assigned(fSubPasses)           then FreeAndNil(fSubPasses);
  If assigned(fSubPassDependencies) then FreeAndNil(fSubPassDependencies);

  inherited;
end;

procedure TvgRenderPass.FrameBuffersClear;
  Var I,L:Integer;
begin
    L:=Length(fFrameBufferHandles);
    If L=0 then exit;

    Assert(assigned(fLinker),'Linker NOT assigned');
    Assert(assigned(fLinker.ScreenDevice),'Linker Screen Device NOT assigned');
    Assert(assigned(fLinker.ScreenDevice.VulkanDevice),'Linker Screen Device Vulkan Device NOT assigned');

    For I:=0 to L-1 do
      fLinker.ScreenDevice.VulkanDevice.Commands.DestroyFramebuffer(fLinker.ScreenDevice.VulkanDevice.Handle,
                                                                    fFrameBufferHandles[I], nil);
    SetLength(fFrameBufferHandles,0);

end;

procedure TvgRenderPass.FrameBuffersSetUp;
  Var I,L,J  : Integer;
      VD     : TpvVulkanDevice;
           A : TvgAttachment;

      AssetCount : TvkUint32;
      AssetArray : Array of TVkImageView;
      FrameBufferCreateInfo : TVkFramebufferCreateInfo;

begin
  FrameBuffersClear;

  Assert(assigned(fLinker),'Linker NOT assigned');

  Assert(Assigned(fLinker.ScreenDevice));
  If not assigned(fLinker.ScreenDevice.VulkanDevice) then exit;

  Assert(Assigned(fLinker.SwapChain));
  If not assigned(fLinker.SwapChain.VulkanSwapChain) then exit;

  Assert(Assigned(fRenderEngine),'Render Engine NOT assigned');

  case  fLinker.RenderTarget of
      RT_SCREEN : L := fLinker.SwapChain.ImageCount;
      RT_FRAME  : L := fLinker.FrameCount;
    else
      L := 1;
  end;

  If L=0 then exit;

  SetLength(fFrameBufferHandles, L);
  FillChar(fFrameBufferHandles[0],SizeOf(TVkFrameBuffer) * L,#0);

  VD := fLinker.ScreenDevice.VulkanDevice;

  AssetCount :=  fAttachments.Count;

  SetLength(AssetArray, AssetCount);
  FillChar(AssetArray[0],SizeOf(TVkImageView)*AssetCount,#0);

  FillChar(FrameBufferCreateInfo,SizeOf(TVkFramebufferCreateInfo),#0);
  FrameBufferCreateInfo.sType          := VK_STRUCTURE_TYPE_FRAMEBUFFER_CREATE_INFO;
  FrameBufferCreateInfo.pNext          := nil;
  FrameBufferCreateInfo.flags          := 0;
  FrameBufferCreateInfo.renderPass     := fRenderPassHandle;
  FrameBufferCreateInfo.attachmentCount:= AssetCount;
  FrameBufferCreateInfo.pAttachments   := @AssetArray[0];
  FrameBufferCreateInfo.width          := fLinker.SwapChain.ImageWidth;
  FrameBufferCreateInfo.height         := fLinker.SwapChain.ImageHeight;
  FrameBufferCreateInfo.layers         := 1;

  For I:=0 to L-1 do
  Begin

      For J:=0 to AssetCount-1 do
      Begin

        A:= fAttachments.Items[J];

        case A.fType of
          atScreen    : AssetArray[J] := fLinker.SwapChain.fFrameBufferAtachments[I].ImageView.Handle;
          atFrame     : AssetArray[J] := fLinker.Frame[I].FrameImageBuffer.FrameBufferAttachment.ImageView.Handle;
          Else
          Begin
              If assigned(A.ImageBuffer[I]) and
                 A.ImageBuffer[I].Active and
                 assigned(A.ImageBuffer[I].FrameBufferAttachment) and
                 assigned(A.ImageBuffer[I].FrameBufferAttachment.ImageView) then
                   AssetArray[J] := A.ImageBuffer[I].FrameBufferAttachment.ImageView.Handle;
          End;
        end;
      End;

     VulkanCheckResult(VD.Commands.CreateFramebuffer(VD.Handle,
                                                        @FrameBufferCreateInfo,
                                                        nil,
                                                        @fFrameBufferHandles[I]));

  End;

  SetLength(AssetArray,0);

end;

function TvgRenderPass.GetActive: Boolean;
begin
  Result:=fActive;
end;

function TvgRenderPass.GetAttachmentOfType( aType: TvgAttachmentType): TvgAttachment;
  Var I:Integer;
begin
  Result:=Nil;
  If fAttachments.Count=0 then exit;
  For I:=0 to fAttachments.Count-1 do
  Begin
    If (fAttachments.Items[I].fType=aType) then
    Begin
      Result := fAttachments.Items[I];
      Break;
    End;
  end;
end;

function TvgRenderPass.getAttachments: TvgAttachmentCol;
begin
  Result:=fAttachments;
end;

function TvgRenderPass.GetBufDepthCompare: TvgCompareOpBit;
begin
  Result := GetVGCompareOp(self.fDepthCompare);

end;

function TvgRenderPass.GetClearCol(Index: Integer): TVkClearValue;
  Var C:TVkClearValue;
begin
  If (Index<0) or (index >= Length(fClearColArray)) then
  Begin
    C.color.float32[0]:= 0.0;
    C.color.float32[1]:= 0.0;
    C.color.float32[2]:= 0.0;
    C.color.float32[3]:= 1.0;

    Result := C
  end else
    Result := fClearColArray[Index];
end;

function TvgRenderPass.GetClearColArray: PVkClearValue;
begin
  Result := @fClearColArray[0];
end;

function TvgRenderPass.GetClearColCount: Integer;
begin
  Result := Length(fClearColArray);
end;

function TvgRenderPass.GetColourFormat: TvgFormat;
begin
  Result:=  GetVGFormat(fColourFormat);
end;

function TvgRenderPass.GetDepthBufON: Boolean;
begin
  Result := fDepthBufOn;
end;

function TvgRenderPass.GetDepthFormat: TvgDepthBufferFormat;
begin
  Result := GetVGDeptBufferFormat(fDepthStencilFormat);
end;

function TvgRenderPass.GetFrameBufferHandle(Index: Integer): TVkFrameBuffer;
begin
  Result := VK_NULL_HANDLE;
  if (Index<0) or (Index>=Length(fFrameBufferHandles)) then exit;
  Result :=  fFrameBufferHandles[Index];
end;

function TvgRenderPass.IsMSAAOn: Boolean;
begin
  Result := fMSAASampleCount<>VK_SAMPLE_COUNT_1_BIT;
end;

function TvgRenderPass.GetSampleCount: TvgSampleCountFlagBits;
begin
  Result :=  GetVGSampleCountFlagBit(fMSAASampleCount);
end;

function TvgRenderPass.GetStencilBufON: Boolean;
begin
  Result := fStencilBufOn;
end;

function TvgRenderPass.GetSubPassDependencies: TvgSubPassDependencyCol;
begin
  Result := fSubPassDependencies;
end;

function TvgRenderPass.GetSubPasses: TvgSubPassCol;
begin
  Result:=fSubPasses;
end;

function TvgRenderPass.GetLinker: TvgLinker;
begin
  Result := fLinker;
end;

procedure TvgRenderPass.Loaded;
  Var I : Integer;
      SP: TvgSubPass;
      SD: TvgSubPassDependency;

   Procedure UpDateLinks(aRef:TvgSubPassAttachmentCol);
      Var J : Integer;
          AR: TvgSubPassAttachment;
   Begin
     If not assigned(aRef) or(aRef.Count=0) then exit;
     For J:=0 to aRef.Count-1 do
     Begin
       AR:= aRef.Items[J];
       If AR.fAttachmentIndex>=0 then
          AR.Attachment:= fAttachments.Items[AR.fAttachmentIndex];
     End;
   End;

begin
  inherited Loaded;

  If fSubPasses.Count>0 then
    For  I := 0 to fSubPasses.Count-1 do
    Begin
      SP:=fSubPasses.Items[I];

      If assigned(SP) then
      Begin
        UpdateLinks(SP.fInputAttachmentRefs);
        UpdateLinks(SP.fColorAttachmentRefs);
        UpdateLinks(SP.fResolveAttachmentRefs);
        UpdateLinks(SP.fDepthStencilAttachmentRef);
        UpdateLinks(SP.fPreserveAttachmentRefs);
      End;

    End;

  If fSubPassDependencies.Count>0 then
  Begin
    For I:=0 to fSubPassDependencies.Count-1 do
    Begin
      SD:= fSubPassDependencies.Items[I];
      If SD.fSrcSubpassIndex>=0 then
         SD.fSrcSubpass:= fSubPasses.Items[SD.fSrcSubpassIndex];
      If SD.fDstSubpassIndex>=0 then
         SD.fDstSubpass:= fSubPasses.Items[SD.fDstSubpassIndex];
    end;
  end;

end;

procedure TvgRenderPass.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);

  Case Operation of
     opInsert : Begin
                  If aComponent=self then exit;
                  If NotificationTestON and Not (csDesigning in ComponentState) then exit ;      //don't mess with links at runtime
                End;

     opRemove : Begin
                end;
  End;
end;

procedure TvgRenderPass.ClearStructure;
begin
  fSubPassDependencies.Clear;
  fSubPasses.Clear;
  fAttachments.Clear;

end;

procedure TvgRenderPass.SetActive(const Value: Boolean);
begin
  If fActive=Value then exit;
  SetActiveState(Value) ;
end;

procedure TvgRenderPass.SetAttachments(const Value: TvgAttachmentCol);
begin
  If not assigned(Value) then exit;
  fAttachments.Clear;
  fAttachments.Assign(Value);
end;

procedure TvgRenderPass.SetBufDepthCompare(const Value: TvgCompareOpBit);
  Var V: TVkCompareOp;
begin
  V:=GetVKCompareOp(Value);
  If fDepthCompare=V then exit;
  SetActiveState(False);
  fDepthCompare := V ;
end;

procedure TvgRenderPass.SetColourFormat(const Value: TvgFormat);
  Var V:TvkFormat;
begin
  V:= GetVKFormat(Value);
  If fColourFormat=V then exit;
  SetActiveState(False);
  fColourFormat:=V;   //OK
end;

procedure TvgRenderPass.SetDepthBufON(const Value: Boolean);
begin
  If fDepthBufOn = Value then exit;
  SetActiveState(False);
  fDepthBufOn := Value;
  If not fStencilBufOn then
    fDepthStencilFormat  :=  GetVKDeptBufferFormat(DB_D32_SFLOAT)
  else
    fDepthStencilFormat  :=  GetVKDeptBufferFormat(DB_D32_SFLOAT_S8_UINT);

end;

procedure TvgRenderPass.SetDepthFormat(const Value: TvgDepthBufferFormat);
  Var V : TvkFormat;
begin
  V:= GetVKDeptBufferFormat(Value);
  If fDepthStencilFormat=V then exit;
  SetActiveState(False);
  fDepthStencilFormat := V;
end;

procedure TvgRenderPass.SetDisabled;
  Procedure DisableAttachments;
    Var I    : Integer;
        RPA  : TvgAttachment;
  Begin
      For i:= 0 to fAttachments.Count-1 do
      Begin
        RPA:= fAttachments.items[I];
        If assigned(RPA) then
           RPA.SetDisabled;
      End;
  End;

begin
  fActive:=False;

  FrameBuffersClear;

  SetLength(fClearColArray,0);

  DisableAttachments;

 if (fRenderPassHandle<>VK_NULL_HANDLE) then
 begin
  fLinker.ScreenDevice.fVulkanDevice.Commands.DestroyRenderPass(fLinker.ScreenDevice.fVulkanDevice.Handle,  fRenderPassHandle, nil);
  fRenderPassHandle := VK_NULL_HANDLE;
 end;

end;

procedure TvgRenderPass.SetEnabled(aComp:TvgBaseComponent=nil);

   Var
       RenderPassCreateInfo : TvkRenderPassCreateInfo;
       AttachmentCount      : Integer;
       Attachments          : Array of TVkAttachmentDescription;
       SubPassCount         : Integer;
       SubPasses            : Array of TvkSubpassDescription;
       DependancyCount      : Integer;
       Dependancies         : Array of TVkSubpassDependency;
       ColAttachmentRef     : TvkAttachmentReference;

  Procedure SetUpAttachments;
    Var I    : Integer;
        RPA  : TvgAttachment;
  Begin
    AttachmentCount := fAttachments.Count;

    If (AttachmentCount=0) then
    Begin

      SetLength(Attachments,1);
      FillChar(Attachments[0],Sizeof(TVkAttachmentDescription),#0);
      Inc(AttachmentCount);

      Attachments[0].format                := fColourFormat;
      Attachments[0].samples               := VK_SAMPLE_COUNT_1_BIT;
      Attachments[0].loadOp                := VK_ATTACHMENT_LOAD_OP_CLEAR;
      Attachments[0].storeOp               := VK_ATTACHMENT_STORE_OP_STORE;
      Attachments[0].stencilLoadOp         := VK_ATTACHMENT_LOAD_OP_DONT_CARE;
      Attachments[0].stencilStoreOp        := VK_ATTACHMENT_STORE_OP_DONT_CARE;
      Attachments[0].initialLayout         := VK_IMAGE_LAYOUT_UNDEFINED;
      Attachments[0].finalLayout           := VK_IMAGE_LAYOUT_PRESENT_SRC_KHR;

    end else
    Begin

      SetLength(Attachments,AttachmentCount);
      FillChar(Attachments[0],Sizeof(TVkAttachmentDescription)*AttachmentCount,#0);

      For I:= 0 to fAttachments.Count-1 do
      Begin
        RPA := fAttachments.items[I];

        Attachments[I].format                := RPA.fformat;
        Attachments[I].samples               := RPA.fsamples;
        Attachments[I].loadOp                := RPA.floadOp;
        Attachments[I].storeOp               := RPA.fstoreOp;
        Attachments[I].stencilLoadOp         := RPA.fStencilLoadOp;
        Attachments[I].stencilStoreOp        := RPA.fstencilStoreOp;
        Attachments[I].initialLayout         := RPA.finitialLayout;
        Attachments[I].finalLayout           := RPA.ffinalLayout;

      end;
    End;

  End;

  Procedure SetUpDependancies;
    Var I   : Integer;
        DP  : TvgSubPassDependency;
  Begin
    DependancyCount:=self.fSubPassDependencies.Count;

    If DependancyCount=0 then
    Begin
      SetLength(Dependancies,1);
      FillChar(Dependancies[0],Sizeof(TVkSubpassDependency),#0);
      Inc(DependancyCount);

      Dependancies[0].srcSubpass             := VK_SUBPASS_EXTERNAL;
      Dependancies[0].dstSubpass             := 0;
      Dependancies[0].srcStageMask           := TVkPipelineStageFlags(VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT);
      Dependancies[0].dstStageMask           := TVkPipelineStageFlags(VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT);
      Dependancies[0].srcAccessMask          := 0;
      Dependancies[0].dstAccessMask          := TVkAccessFlags(VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT);

    end else
    Begin

      SetLength(Dependancies,DependancyCount);
      FillChar(Dependancies[0],Sizeof(TVkSubpassDependency)*DependancyCount,#0);

      For I:=0 to DependancyCount-1 do
      Begin

        DP:= self.fSubPassDependencies.Items[I] ;

        If DP.fSrcSubpass=nil then
           Dependancies[I].srcSubpass   := VK_SUBPASS_EXTERNAL
        else
           Dependancies[I].srcSubpass   := self.fSubPasses.IndexOf(DP.fSrcSubpass);
        If DP.dstSubpass=nil then
           Dependancies[I].dstSubpass   := VK_SUBPASS_EXTERNAL
        else
           Dependancies[I].dstSubpass   := self.fSubPasses.IndexOf(DP.fDstSubpass);
        Dependancies[I].srcStageMask    := DP.fSrcStageMask;
        Dependancies[I].dstStageMask    := DP.fdstStageMask;
        Dependancies[I].srcAccessMask   := DP.fSrcAccessMask;
        Dependancies[I].dstAccessMask   := DP.fDstAccessMask;

      End;
    End;
  End;

  Procedure SetUpSubPasses;
    Var J : Integer;
        SP: TvgSubPass;

  Begin
    SubPassCount:=0;

    If fSubPasses.Count=0 then
    Begin

      SubPassCount:=1;
      SetLength(SubPasses,1);
      FillChar(SubPasses[0],Sizeof(TvkSubpassDescription),#0);

      FillChar(ColAttachmentRef,Sizeof(TvkAttachmentReference),#0);

      ColAttachmentRef.attachment            := 0;
      ColAttachmentRef.layout                := VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL;

      SubPasses[0].pipelineBindPoint         := VK_PIPELINE_BIND_POINT_GRAPHICS;
      SubPasses[0].inputAttachmentCount      := 0;
      SubPasses[0].pInputAttachments         := Nil;
      SubPasses[0].colorAttachmentCount      := 1;
      SubPasses[0].pColorAttachments         := @ColAttachmentRef;
      SubPasses[0].pDepthStencilAttachment   := Nil ;
      SubPasses[0].preserveAttachmentCount   := 0;
      SubPasses[0].pPreserveAttachments      := Nil;

    end else
    Begin
      SubPassCount := fSubPasses.Count;
      SetLength(SubPasses, SubPassCount);
      FillChar(SubPasses[0],Sizeof(TvkSubpassDescription)*SubPassCount ,#0);

      For J:= 0 to fSubPasses.Count-1 do
      Begin
        SP:=fSubPasses.Items[J];

        If assigned(SP) then
        Begin
          SP.fpipelineBindPoint         := VK_PIPELINE_BIND_POINT_GRAPHICS;

          SP.SetUpAttachmentArrays;    //setup transfer arrays.

          If SP.fInputAttachmentRefs.fRefCount>0 then
          Begin
            SubPasses[J].inputAttachmentCount    := SP.fInputAttachmentRefs.fRefCount;
            SubPasses[J].pInputAttachments       := @SP.fInputAttachmentRefs.fRefArray[0];
          End;
          If SP.fResolveAttachmentRefs.fRefCount>0 then
          Begin
          //  SubPasses[J].inputAttachmentCount    := SP.fResolveAttachmentRefs.fRefCount;     //same as color count
            SubPasses[J].pResolveAttachments       := @SP.fResolveAttachmentRefs.fRefArray[0];
          End;
          If SP.fColorAttachmentRefs.fRefCount>0 then
          Begin
            SubPasses[J].colorAttachmentCount    := SP.fColorAttachmentRefs.fRefCount;
            SubPasses[J].pColorAttachments       := @SP.fColorAttachmentRefs.fRefArray[0];
          End;
          If SP.fDepthStencilAttachmentRef.fRefCount>0 then
          Begin
            SubPasses[J].pDepthStencilAttachment := @SP.fDepthStencilAttachmentRef.fRefArray[0];
          End;
          If SP.fPreserveAttachmentRefs.fRefCount>0 then
          Begin
            SubPasses[J].preserveAttachmentCount := SP.fPreserveAttachmentRefs.fRefCount;
            SubPasses[J].pPreserveAttachments    := @SP.fPreserveAttachmentRefs.fRefArray[0];
          End;
        End;

      end;
    End;
  End;

  Procedure EnableAttachments;
    Var I    : Integer;
        RPA  : TvgAttachment;
  Begin
      For i:= 0 to fAttachments.Count-1 do
      Begin
        RPA:= fAttachments.items[I];
        If assigned(RPA) then
           RPA.SetEnabled;
      End;
  End;

begin

  fActive:=False;

  Assert(Assigned(fLinker),'VulkanLink not assigned.');
  Assert(Assigned(fLinker.ScreenDevice),'Screen Device not created in VulkanLink');
  Assert(Assigned(fLinker.ScreenDevice.fVulkanDevice),'Screen Device NOT Active');

  If not CheckValidity then exit;

  fColourFormat := fLinker.SwapChain.ImageFormat;

  BuildStructure;

  if fLinker.RenderTarget = RT_FRAME then
    AddFrameToScreenSubPass;

  UpdateAttachmentFormats;

  EnableAttachments;

  SetUpAttachments;

  SetUpDependancies;

  SetUpSubPasses;

  SetUpClearColorArray;

  FillChar(RenderPassCreateInfo,Sizeof(TVkRenderPassCreateInfo),#0);
  RenderPassCreateInfo.sType           := VK_STRUCTURE_TYPE_RENDER_PASS_CREATE_INFO;
  RenderPassCreateInfo.pNext           := nil;
  RenderPassCreateInfo.attachmentCount := AttachmentCount;
  RenderPassCreateInfo.pAttachments    := @Attachments[0];
  RenderPassCreateInfo.subpassCount    := SubPassCount;
  RenderPassCreateInfo.pSubpasses      := @SubPasses[0];
  RenderPassCreateInfo.dependencyCount := DependancyCount;
  RenderPassCreateInfo.pDependencies   := @Dependancies[0];

  VulkanCheckResult( fLinker.ScreenDevice.fVulkanDevice.Commands.CreateRenderPass(fLinker.ScreenDevice.fVulkanDevice.Handle,
                                                                                   @RenderPassCreateInfo,
                                                                                   nil,
                                                                                   @fRenderPassHandle));

  fActive:=True;

  SetLength(Attachments,0);
  SetLength(Dependancies,0);
  SetLength(SubPasses,0);

  FrameBuffersSetUp;

end;

procedure TvgRenderPass.SetSampleCount(const Value: TvgSampleCountFlagBits);
  Var V:TVkSampleCountFlagBits;
begin
  V:=GetVKSampleCountFlagBit(Value);
  If fMSAASampleCount=V then exit;
  SetActiveState(False);
  fMSAASampleCount:=V;

  If (Value<>COUNT_01_BIT) then
    SetRequiredSamplingExtension;
end;

procedure TvgRenderPass.SetStencilBufON(const Value: Boolean);
begin
  If fStencilBufOn = Value then exit;
  SetActiveState(False);
  fStencilBufOn := Value;
  If not fStencilBufOn then
    fDepthStencilFormat  :=  GetVKDeptBufferFormat(DB_D32_SFLOAT)
  else
    fDepthStencilFormat  :=  GetVKDeptBufferFormat(DB_D32_SFLOAT_S8_UINT);
end;

procedure TvgRenderPass.SetSubPassDependencies( const Value: TvgSubPassDependencyCol);
begin
  If not assigned(Value) then exit;
  fSubPassDependencies.Clear;
  fSubPassDependencies.Assign(Value);
end;

procedure TvgRenderPass.SetSubPasses(const Value: TvgSubPassCol);
begin
  If not assigned(Value) then exit;
  fSubPasses.Clear;
  fSubPasses.Assign(Value);
end;

procedure TvgRenderPass.SetUpClearColorArray;
 Var //RPass : TvgRenderPass;
     CL,I:Integer;
      A : TvgAttachment;
begin
  Assert(assigned(fLinker),'Vulkan Link not attached');
//  Assert(assigned(fRenderPass),'Render Pass not created');

//  RPass :=  fLinker.RenderPass;

  CL := fAttachments.Count;

  SetLength(fClearColArray,CL);

  For  I:=0 to CL-1 do
  Begin
    A:=fAttachments.Items[I];
    Case A.fType of
        atScreen,
        atFrame,
        atColour :Begin
                    If assigned(fLinker.Surface) and assigned(fLinker.Surface.WindowIntf) then
                       fLinker.Surface.WindowIntf.vgWindowBackgroundColor(fClearColArray[I])
                    else
                    Begin
                      fClearColArray[I].color.float32[0]:= 0.0;
                      fClearColArray[I].color.float32[1]:= 0.0;
                      fClearColArray[I].color.float32[2]:= 0.0;
                      fClearColArray[I].color.float32[3]:= 1.0;
                    end;
                  end;
        atDepthStencil:Begin
                        fClearColArray[I].depthStencil.depth  := fDepthClear;
                        fClearColArray[I].depthStencil.stencil:= fStencilClear;
                       end;
        atMSAA:Begin
                  end;          //Multi sampling AntiAliasing attachment
        atSelect:Begin  //check
                      fClearColArray[I].color.float32[0]:= 0.0;
                      fClearColArray[I].color.float32[1]:= 0.0;
                      fClearColArray[I].color.float32[2]:= 0.0;
                      fClearColArray[I].color.float32[3]:= 0.0;
                  end;        //attachment to handle Object selection from the an image
        atCustom:Begin
                  end;       //a manual setup attachment resource
    else
    End;


  End;
end;

procedure TvgRenderPass.UpdateAttachmentFormats;
    Var I   : Integer;
          A : TvgAttachment;

begin

  if attachments.Count=0 then exit;
  if not assigned(fLinker) then exit;


  for I := 0 to attachments.Count-1 do
  Begin
    A := Attachments.Items[I];
    if assigned(A) then
    Begin
      case A.fType of

         atScreen : Begin
                       if (A.Format<>self.ColourFormat) then
                           A.Format := self.GetColourFormat;
         End;
         (*
         atFrame : Begin
                       if (A.Format<>self.ColourFormat) then
                          A.Format := self.GetColourFormat;
         End;
         atColour : Begin
                       if (A.Format<>self.ColourFormat) then
                          A.Format := self.GetColourFormat;

         End;
         *)
         atMSAA  : Begin
                       if (A.Format<>self.ColourFormat) then
                           A.Format := self.GetColourFormat;

         End;
         (*
         atDepthStencil : Begin
                       F := GetVGFormat(fDepthStencilFormat);

                       if A.Format<>F then
                          A.Format := F;

         End;
         atCustom : Begin


         End;
         *)
      end;
    End;


  End;


 //   CheckFormat( atColour, aFormat);//VK_FORMAT_R32G32B32A32_SFLOAT);
 //   CheckFormat( atFrame,  aFormat);
 //   CheckFormat( atScreen, aFormat);
 //   CheckFormat( atMSAA  , aFormat);//VK_FORMAT_R32G32B32A32_SFLOAT);
  //  CheckFormat( atSelect);
end;

procedure TvgRenderPass.UpdateWindowSize;
  Var A:TvgAttachment;
      I,L,J:Integer;
begin
 Assert(Assigned(fLinker),'Linker NOT assigned');
 If fAttachments.Count=0 then exit;

 For I:=0 to self.fAttachments.Count-1 do
   Begin
     A:= fAttachments.Items[I];

     If assigned(A) then
     Begin
        L:=Length(A.fImageBufferArray);

        If (L>0) then
        Begin
          for J := 0 to L-1 do
            if assigned(A.fImageBufferArray[I]) then
            Begin
               A.fImageBufferArray[J].fImageWidth  := fLinker.fSwapChain.ImageWidth;
               A.fImageBufferArray[J].fImageHeight := fLinker.fSwapChain.ImageHeight;
            End;
        End;

     End;
   End;

end;

procedure TvgRenderPass.SetLinker(const Value: TvgLinker);
begin
  If fLinker = Value then exit;
  SetActiveState(False);

  fLinker := Value;

end;

procedure TvgRenderPass.SetRequiredSamplingExtension;
begin
  Assert(assigned(fLinker),'Linker not connected');
  Assert(assigned(fLinker.ScreenDevice),'Screen Device not assigned');

//  fLinker.ScreenDevice.TurnOnExtension(VK_AMD_MIXED_ATTACHMENT_SAMPLES_EXTENSION_NAME);
//  fLinker.ScreenDevice.TurnOnExtension(VK_NV_FRAMEBUFFER_MIXED_SAMPLES_EXTENSION_NAME);

end;

{ TvgRenderPassAttachmentRef }

procedure TvgSubPassAttachment.Assign(Source: TPersistent);
begin
  inherited;
  If source is TvgSubPassAttachment then
  Begin
    fLayout:= TvgSubPassAttachment(Source).fLayout;
  End;
end;

constructor TvgSubPassAttachment.Create(Collection: TCollection);
begin
  inherited Create(Collection);

  fAttachmentIndex := -1;
  fLayout          := VK_IMAGE_LAYOUT_UNDEFINED;
  SetName( GetEnumName(typeInfo(TvgImageLayout ), Ord(fLayout)));
end;

procedure TvgSubPassAttachment.DefineProperties(Filer: TFiler);
begin
  inherited;

  Filer.DefineProperty('AttachmentIndex', ReadAttachment, WriteAttachment, True);

end;

function TvgSubPassAttachment.GetAttachment: TvgAttachment;
begin
  Result:=fAttachment;
end;

function TvgSubPassAttachment.GetDisplayName: string;
begin
  Result:=fName;
end;

function TvgSubPassAttachment.GetLayout: TvgImageLayout;
begin
  Result := GetVGImageLayout(fLayout);
end;

function TvgSubPassAttachment.getName: String;
begin
  Result:=fName;
end;

function TvgSubPassAttachment.GetRenderPass: TvgRenderPass;
  Var P:TPersistent;
      C:TCollection ;
      CI:TCollectionItem;
begin
  Result:=nil;

  CI:= TCollectionItem(self);
  C := CI.Collection;       //
  If not Assigned(C) then exit;
  P := C.Owner ;             //TvgSubPass level

  If not Assigned(P) or Not (P is TvgSubPass) then exit;

  Result:= TvgSubPass(P).GetRenderPass;
end;

procedure TvgSubPassAttachment.ReadAttachment(Reader: TReader);
begin
   fAttachmentIndex := Reader.ReadInteger ;
end;

procedure TvgSubPassAttachment.SetAttachment( const Value: TvgAttachment);
begin
  If fAttachment=Value then exit;
  SetDisabled;
  fAttachment:=Value;
end;

procedure TvgSubPassAttachment.SetDisabled;
  Var RP:TvgRenderPass;
begin
  RP:=GetRenderPass;

  If assigned(RP) and RP.Active then
     RP.Active:=False;
end;

procedure TvgSubPassAttachment.SetLayout(const Value: TvgImageLayout);
  Var V: TVKImageLayout;
begin
  V:=GetVKImageLayout(Value);
  If fLayout=V then exit;
  SetDisabled;
  fLayout:=V;

  SetName( GetEnumName(typeInfo(TvgImageLayout ), Ord(Value)));

end;

procedure TvgSubPassAttachment.SetName(const Value: String);
begin
  fName:=Value;
end;

procedure TvgSubPassAttachment.WriteAttachment(Writer: TWriter);
  Var RP:TvgRenderPass;
      I :Integer;
begin
  RP := GetRenderPass;
  fAttachmentIndex :=-1;

  If assigned(RP) and assigned(fAttachment) then
  Begin
    For I:=0 to RP.Attachments.Count-1 do
    Begin
      If RP.Attachments.Items[I]=fAttachment then
      Begin
         fAttachmentIndex := I;
         Break;
      End;
    End;
  end;

  Writer.WriteInteger(fAttachmentIndex) ;
end;

{ TvgRenderPassAttachmentRefCol }

function TvgSubPassAttachmentCol.Add: TvgSubPassAttachment;
begin
  If ((fLimit>0) and (Count<fLimit)) or (fLimit<0) then
  Begin
    Result:=TvgSubPassAttachment(inherited Add) ;  //can't change this
    if assigned(Result) then
    Begin
     // Result.Index:= self.Count-1;
      Result.Name := Format('SubPassAttach_%d',[Result.Index]);
    End;

  end else
  Begin
    Result:=Nil;
  End;
end;

function TvgSubPassAttachmentCol.AddItem(Item: TvgSubPassAttachment; Index: Integer): TvgSubPassAttachment;
begin
  If ((fLimit>0) and (Count<fLimit))  or (fLimit<0) then
  Begin
    if Item = nil then
      Result := TvgSubPassAttachment.Create(self)
    else
      Result := Item;

    if Assigned(Result) then
    begin
      Result.Collection := Self;
      if Index < 0 then
        Index := Count - 1;
      Result.Index := Index;
    end;
  End else
  Begin
    If assigned(Item) then FreeAndNil(Item);
    Result:=Nil;
   // raise EpvVulkanException.Create( Format('Collection Limit of %d has been reached',[fLimit]));
  End;
end;

procedure TvgSubPassAttachmentCol.BuildRefArray;
   Var CI   : TvgSubPassAttachment;
       I,J  : Integer;
       INDX : TvkUint32;
begin
   ClearRefArray;
   if Count=0 then exit;

   fRefCount:=0;
   For I:=0 to Count-1 do
     If assigned(Items[I].fAttachment) then
        Inc(fRefCount)
     else
        Raise EvgVulkanResultException.Create(VK_ERROR_UNKNOWN,'Attachment Ref does not have an Attachment assigned..'+Items[I].fName);

   SetLength(fRefArray, fRefCount);
   FillChar(fRefArray[0],SizeOf(TvkAttachmentReference)*fRefCount,#0);

   J:=0;
   For I:=0 to Count-1 do
     If assigned(Items[I].Attachment) then
     Begin
       CI:=Items[I];
       INDX:=  CI.fAttachment.Index;
       fRefArray[J].attachment := INDX;
       fRefArray[J].layout     := CI.fLayout;
       inc(J);
     End;
end;

procedure TvgSubPassAttachmentCol.ClearRefArray;
begin
  fRefCount := 0;
  SetLength(fRefArray,0);
end;

constructor TvgSubPassAttachmentCol.Create( CollOwner: TvgSubPass);
begin
  Inherited Create(TvgSubPassAttachment);
  fComp := CollOwner;
  fLimit:=-1;    //no limit
end;

procedure TvgSubPassAttachmentCol.DefineProperties(Filer: TFiler);
begin
  inherited;

end;

destructor TvgSubPassAttachmentCol.Destroy;
begin
  ClearRefArray;
  inherited;
end;

function TvgSubPassAttachmentCol.GetItem( Index: Integer): TvgSubPassAttachment;
begin
  Result := TvgSubPassAttachment(inherited GetItem(Index));
end;

function TvgSubPassAttachmentCol.GetLimit: Integer;
begin
  Result:=fLimit;
end;

function TvgSubPassAttachmentCol.GetOwner: TPersistent;
begin
  Result := fComp;
end;

function TvgSubPassAttachmentCol.Insert(Index: Integer): TvgSubPassAttachment;
begin
  Result := AddItem(nil, Index);
end;

procedure TvgSubPassAttachmentCol.Notify(Item: TCollectionItem;  Action: TCollectionNotification);
begin
  case Action of
    cnAdded: If (fLimit>0) and (Count>fLimit) then    //item has already been added so need to exceed limit
         Raise EpvVulkanException.Create( Format('Collection Limit of %d has been reached',[fLimit]));
   // cnDeleting: Deleting(Item);
  end;

  Inherited;
end;

procedure TvgSubPassAttachmentCol.SetItem(Index: Integer; const Value: TvgSubPassAttachment);
begin
    inherited SetItem(Index, Value);
end;

procedure TvgSubPassAttachmentCol.SetLimit(const Value: Integer);
begin
  If (Value>Count) then
    fLimit:=Value
  else
    fLimit:=Count;
end;

procedure TvgSubPassAttachmentCol.Update(Item: TCollectionItem);
begin
//  inherited;

end;

{ TvgRenderPassSubPass }

procedure TvgSubPass.Assign(Source: TPersistent);
begin
  inherited;
end;

procedure TvgSubPass.ClearAttachmentArrays;
begin
  fInputAttachmentRefs.ClearRefArray;
  fColorAttachmentRefs.ClearRefArray;
  fResolveAttachmentRefs.ClearRefArray;
  fDepthStencilAttachmentRef.ClearRefArray;
  fPreserveAttachmentRefs.ClearRefArray;
end;

constructor TvgSubPass.Create(Collection: TCollection);
begin
  Inherited Create(Collection);

   self.fPipelineBindPoint   :=  VK_PIPELINE_BIND_POINT_GRAPHICS ;//default
   fIndex:=High(TvkUint32);

   fInputAttachmentRefs        := TvgSubPassAttachmentCol.Create(self) ;
   fColorAttachmentRefs        := TvgSubPassAttachmentCol.Create(self)  ;
   fResolveAttachmentRefs      := TvgSubPassAttachmentCol.Create(self) ;
   fDepthStencilAttachmentRef  := TvgSubPassAttachmentCol.Create(self) ;
   fDepthStencilAttachmentRef.Limit := 1;
   fPreserveAttachmentRefs     := TvgSubPassAttachmentCol.Create(self) ;

   If assigned(Collection) then
     fName := Format('SubPass - %d',[Index]);
end;

procedure TvgSubPass.DefineProperties(Filer: TFiler);
begin
  inherited;
end;

destructor TvgSubPass.Destroy;
begin
  If Assigned(fInputAttachmentRefs) then FreeAndNil(fInputAttachmentRefs);
  If Assigned(fColorAttachmentRefs) then FreeAndNil(fColorAttachmentRefs);
  If Assigned(fResolveAttachmentRefs) then FreeAndNil(fResolveAttachmentRefs);
  If Assigned(fDepthStencilAttachmentRef) then FreeAndNil(fDepthStencilAttachmentRef);
  If Assigned(fPreserveAttachmentRefs) then FreeAndNil(fPreserveAttachmentRefs);
  inherited;
end;

function TvgSubPass.GetColorAttachments: TvgSubPassAttachmentCol;
begin
  Result:= fColorAttachmentRefs ;
end;

function TvgSubPass.GetDepthStencilAttachment: TvgSubPassAttachmentCol;
begin
  Result:= fDepthStencilAttachmentRef ;
end;

function TvgSubPass.GetDisplayName: string;
begin
  Result:=fName;
end;

function TvgSubPass.GetInputAttachments: TvgSubPassAttachmentCol;
begin
  Result:= fInputAttachmentRefs ;
end;

function TvgSubPass.GetName: String;
begin
  Result:=fName;
end;

function TvgSubPass.GetPipelineBindPoint: TvgPipelineBindPoint;
begin
  Result:= GetVGPipelineBindPoint( fPipelineBindPoint);
end;

function TvgSubPass.GetPreserveAttachments: TvgSubPassAttachmentCol;
begin
  Result:= fPreserveAttachmentRefs ;
end;

function TvgSubPass.GetRenderPass: TvgRenderPass;
  Var P:TPersistent;
      C:TCollection ;
      CI:TCollectionItem;
begin
  Result:=nil;

  CI:= TCollectionItem(self);
  C := CI.Collection;       //
  If not Assigned(C) then exit;
  P := C.Owner ;             //TvgRenderPass level

  If not assigned(P) or not (P is TvgRenderPass) then exit;
  Result:= TvgRenderPass(P);

end;

function TvgSubPass.GetResolveAttachment: TvgSubPassAttachmentCol;
begin
  Result:= fResolveAttachmentRefs ;
end;

procedure TvgSubPass.SetColorAttachments( const Value: TvgSubPassAttachmentCol);
begin
  If not assigned(Value) then exit;
  fColorAttachmentRefs.Clear;
  fColorAttachmentRefs.Assign(Value);
end;

procedure TvgSubPass.SetDepthStencilAttachment(const Value: TvgSubPassAttachmentCol);
begin
  If not assigned(Value) then exit;
  fDepthStencilAttachmentRef.Clear;
  fDepthStencilAttachmentRef.Assign(Value);
end;

procedure TvgSubPass.SetDisabled;
  Var RP:TvgRenderPass;
begin
  RP:=GetRenderPass;

  If assigned(RP) and RP.Active then
     RP.Active:=False;
end;

procedure TvgSubPass.SetInputAttachments(const Value: TvgSubPassAttachmentCol);
begin
  If not assigned(Value) then exit;
  fInputAttachmentRefs.Clear;
  fInputAttachmentRefs.Assign(Value);
end;

procedure TvgSubPass.SetMode(const Value: TvgRenderPassMode);
begin
  if fMode=Value then  exit;
  SetDisabled;
  fMode := Value;
end;

procedure TvgSubPass.SetName(const Value: String);
begin
   fName:=Value;
end;

procedure TvgSubPass.SetPipelineBindPoint(const Value: TvgPipelineBindPoint);
  Var V:TVkPipelineBindPoint ;
begin
  V:= GetVKPipelineBindPoint(Value);
  If fPipelineBindPoint=V then exit;
 // SetDisabled;
  fPipelineBindPoint:=V;
end;

procedure TvgSubPass.SetPreserveAttachments(const Value: TvgSubPassAttachmentCol);
begin
  If not assigned(Value) then exit;
  fPreserveAttachmentRefs.Clear;
  fPreserveAttachmentRefs.Assign(Value);
end;

procedure TvgSubPass.SetResolveAttachment(const Value: TvgSubPassAttachmentCol);
begin
  If not assigned(Value) then exit;
  fResolveAttachmentRefs.Clear;
  fResolveAttachmentRefs.Assign(Value);
end;

procedure TvgSubPass.SetUpAttachmentArrays;
begin

   ClearAttachmentArrays;

   fInputAttachmentRefs.BuildRefArray;
   fColorAttachmentRefs.BuildRefArray;
   fResolveAttachmentRefs.BuildRefArray;
   fDepthStencilAttachmentRef.BuildRefArray;
   fPreserveAttachmentRefs.BuildRefArray;

end;

{ TvgSubPassCol }

function TvgSubPassCol.Add: TvgSubPass;
begin
  Result := TvgSubPass(inherited Add);
end;

function TvgSubPassCol.AddItem(Item: TvgSubPass; Index: Integer): TvgSubPass;
begin
  if Item = nil then
    Result := TvgSubPass.Create(self)
  else
    Result := Item;

  if Assigned(Result) then
  begin
    Result.Collection := Self;
    if Index < 0 then
      Index := Count - 1;
    Result.Index := Index;
  end;
end;

constructor TvgSubPassCol.Create(CollOwner: TvgRenderPass);
begin
  Inherited Create(TvgSubPass);
  fComp:=CollOwner;
end;

function TvgSubPassCol.GetItem(Index: Integer): TvgSubPass;
begin
  Result := TvgSubPass(inherited GetItem(Index));
end;

function TvgSubPassCol.GetOwner: TPersistent;
begin
  Result:=fComp;
end;

function TvgSubPassCol.IndexOf(aItem: TvgSubPass): Integer;
Var I:Integer;
begin
  Result:=-1;
  If self.Count=0 then exit;
  If not assigned(aItem) then exit;
  For I:=0 to count-1 do
  Begin
    If Items[I]=aItem then
    Begin
      Result:=I;
      Exit;
    End;
  End;
end;

function TvgSubPassCol.Insert(Index: Integer): TvgSubPass;
begin
  Result := AddItem(nil, Index);
end;

procedure TvgSubPassCol.Notify(Item: TCollectionItem;  Action: TCollectionNotification);
  Var RP : TvgRenderPass;
       I : Integer;
begin
  inherited;

  Case Action of
    cnExtracting,
    cnDeleting :
    Begin
      If (Owner<>nil) and (Owner is TvgRenderpass) then
      Begin
        RP := TvgRenderPass(Owner) ;
        If RP.fSubPassDependencies.Count>0 then
        Begin
          For I:=0 to RP.fSubPassDependencies.Count-1 do
          Begin
            If  RP.fSubPassDependencies.Items[I].fSrcSubpass  = Item then
                RP.fSubPassDependencies.Items[I].fSrcSubpass := nil;
            If  RP.fSubPassDependencies.Items[I].fDstSubpass  = Item then
                RP.fSubPassDependencies.Items[I].fDstSubpass := nil;
          End;
        End;
      End;
    End;

  End;


end;

procedure TvgSubPassCol.SetItem(Index: Integer; const Value: TvgSubPass);
begin
  inherited SetItem(Index, Value);
end;

procedure TvgSubPassCol.Update(Item: TCollectionItem);
begin
  inherited;

end;

{ TvgSubPassDependency }

procedure TvgSubPassDependency.Assign(Source: TPersistent);
begin
  inherited;
  If source is TvgSubPassDependency then
  Begin

  End;

end;

constructor TvgSubPassDependency.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  If assigned(Collection) then
    fName := Format('SubPass Dependency - %d',[Collection.Count -1]);


end;

procedure TvgSubPassDependency.DefineProperties(Filer: TFiler);
begin
  inherited;
  Filer.DefineProperty('SubPassLinks', ReadSubPasses, WriteSubPasses, True);

end;

destructor TvgSubPassDependency.Destroy;
begin

  inherited;
end;

function TvgSubPassDependency.GetDependencyFlags: TvgDependencyFlagBits;
begin
  Result:= GetVGDependencyFlagBits(self.fDependencyFlags);
end;

function TvgSubPassDependency.GetDisplayName: string;
begin
  Result:=fName;
end;

function TvgSubPassDependency.GetDstAccessMask: TvgAccessFlagBits;
begin
  Result:= GetVGAccessFlagBits(self.fDstAccessMask);
end;

function TvgSubPassDependency.GetDstStageMask: TvgPipelineStageFlagBits;
begin
  Result:= GetVGPipelineStageFlagBits(fDstStageMask);
end;

function TvgSubPassDependency.GetDstSubPass: TvgSubPass;
begin
  Result:=self.fDstSubpass;
end;

function TvgSubPassDependency.GetName: String;
begin
  Result:=fName;
end;

function TvgSubPassDependency.GetRenderPass: TvgRenderPass;
  Var P:TPersistent;
      C:TCollection ;
      CI:TCollectionItem;
begin
  Result:=nil;

  CI:= TCollectionItem(self);
  C := CI.Collection;       //
  If not Assigned(C) then exit;
  P := C.Owner ;             //TvgRenderPass level

  If not assigned(P) or not (P is TvgRenderPass) then exit;
  Result:= TvgRenderPass(P);
end;

function TvgSubPassDependency.GetSrcAccessMask: TvgAccessFlagBits;
begin
  Result:= GetVGAccessFlagBits(self.fSrcAccessMask);
end;

function TvgSubPassDependency.getSrcStageMask: TvgPipelineStageFlagBits;
begin
  Result:= GetVGPipelineStageFlagBits(fSrcStageMask);
end;

function TvgSubPassDependency.GetSrcSubPass: TvgSubPass;
begin
  Result:=self.fSrcSubpass;
end;

procedure TvgSubPassDependency.ReadSubPasses(Reader: TReader);
begin
  Reader.ReadListBegin;
  fSrcSubpassIndex:= Reader.ReadInteger;
  fDstSubpassIndex:= Reader.ReadInteger;
  Reader.ReadListEnd;
end;

procedure TvgSubPassDependency.SetDependencyFlags( const Value: TvgDependencyFlagBits);
  Var V:TVkDependencyFlags;
begin
  V:=GetVKDependencyFlagBits(Value);
  If V=fDependencyFlags then exit;
  SetDisabled;
  fDependencyFlags:=V;
end;

procedure TvgSubPassDependency.SetDisabled;
  Var RP:TvgRenderPass;
begin
  RP:=self.GetRenderPass;

  If assigned(RP) and RP.Active then
     RP.Active:=False;
end;

procedure TvgSubPassDependency.SetDstAccessMask(const Value: TvgAccessFlagBits);
  Var V:TVkAccessFlags;
begin
  V := GetVKAccessFlagBits(Value);
  If V = fDstAccessMask then exit;
  SetDisabled;
  fDstAccessMask := V;
end;

procedure TvgSubPassDependency.SetDstStageMask( const Value: TvgPipelineStageFlagBits);
  Var V: TVkPipelineStageFlags;
begin
  V:= GetVKPipelineStageFlagBits(Value);
  If fDstStageMask=V then exit;
  SetDisabled;
  fDstStageMask:=V;
end;

procedure TvgSubPassDependency.SetDstSubPass(const Value: TvgSubPass);
begin
  If fDstSubpass=Value then exit;
  SetDisabled;
  fDstSubpass:=Value;
end;

procedure TvgSubPassDependency.SetName(const Value: String);
begin
  fName:=Value;
end;

procedure TvgSubPassDependency.SetSrcAccessMask(const Value: TvgAccessFlagBits);
  Var V:TVkAccessFlags;
begin
  V := GetVKAccessFlagBits(Value);
  If V = fSrcAccessMask then exit;
  SetDisabled;
  fSrcAccessMask := V;
end;

procedure TvgSubPassDependency.SetSrcStageMask( const Value: TvgPipelineStageFlagBits);
  Var V: TVkPipelineStageFlags;
begin
  V:= GetVKPipelineStageFlagBits(Value);
  If fSrcStageMask=V then exit;
  SetDisabled;
  fSrcStageMask := V;
end;

procedure TvgSubPassDependency.SetSrcSubPass(const Value: TvgSubPass);
begin
  If fSrcSubpass=Value then exit;
  SetDisabled;
  fSrcSubpass:=Value;
end;

procedure TvgSubPassDependency.WriteSubPasses(Writer: TWriter);
  Var RP:TvgRenderPass;
begin
  fSrcSubpassIndex:=-1;
  fDstSubpassIndex:=-1;

  RP:= GetRenderPass;
  If assigned(RP) then
  Begin
    If Assigned(fSrcSubpass) then
       fSrcSubpassIndex := RP.fSubPasses.IndexOf(fSrcSubpass);
    If Assigned(fDstSubpass) then
       fDstSubpassIndex := RP.fSubPasses.IndexOf(fDstSubpass);
  end;

  Writer.WriteListBegin;
  Writer.WriteInteger(fSrcSubpassIndex);
  Writer.WriteInteger(fDstSubpassIndex);
  Writer.WriteListEnd;

end;

{ TvgSubPassDependencyRefs }

function TvgSubPassDependencyCol.Add: TvgSubPassDependency;
begin
  Result := TvgSubPassDependency(inherited Add);
end;

function TvgSubPassDependencyCol.AddItem(Item: TvgSubPassDependency; Index: Integer): TvgSubPassDependency;
begin
  if Item = nil then
    Result := TvgSubPassDependency.Create(self)
  else
    Result := Item;

  if Assigned(Result) then
  begin
    Result.Collection := Self;
    if Index < 0 then
      Index := Count - 1;
    Result.Index := Index;
  end;
end;

constructor TvgSubPassDependencyCol.Create(CollOwner: TvgRenderPass);
begin
  Inherited Create(TvgSubPassDependency);

  fComp:=CollOwner;
end;

function TvgSubPassDependencyCol.GetItem(Index: Integer): TvgSubPassDependency;
begin
  Result := TvgSubPassDependency(inherited GetItem(Index));
end;

function TvgSubPassDependencyCol.GetOwner: TPersistent;
begin
  Result:=fComp;
end;

function TvgSubPassDependencyCol.Insert(Index: Integer): TvgSubPassDependency;
begin
  Result := AddItem(nil, Index);
end;

procedure TvgSubPassDependencyCol.SetItem(Index: Integer;  const Value: TvgSubPassDependency);
begin
  inherited SetItem(Index, Value);
end;

procedure TvgSubPassDependencyCol.Update(Item: TCollectionItem);
begin
  inherited;

end;

{ TvgImageBufferAsset }

procedure TvgResourceImageBuffer.CheckFormat(aInstance : TpvVulkanInstance; aPhysicalDevice : TpvVulkanPhysicalDevice);
begin
  //see depth buffer for implementation !!!! Not implemented here YET
end;

procedure TvgResourceImageBuffer.CheckImageType;
begin

  Case fImageType of
       VK_IMAGE_TYPE_1D: If not (fImageViewType in [VK_IMAGE_VIEW_TYPE_1D,
                                                    VK_IMAGE_VIEW_TYPE_1D_ARRAY]) then
                         Begin
                           SetActiveState(False);
                           fImageViewType := VK_IMAGE_VIEW_TYPE_1D;
                         End;
       VK_IMAGE_TYPE_2D:If not (fImageViewType in [VK_IMAGE_VIEW_TYPE_2D,
                                                   VK_IMAGE_VIEW_TYPE_2D_ARRAY,
                                                   VK_IMAGE_VIEW_TYPE_CUBE,
                                                   VK_IMAGE_VIEW_TYPE_CUBE_ARRAY]) then
                        Begin
                           SetActiveState(False);
                           fImageViewType := VK_IMAGE_VIEW_TYPE_2D;
                        End;
       VK_IMAGE_TYPE_3D: If not (fImageViewType in [VK_IMAGE_VIEW_TYPE_3D]) then
                        Begin
                           SetActiveState(False);
                           fImageViewType := VK_IMAGE_VIEW_TYPE_3D;
                        End;
  End;

end;

constructor TvgResourceImageBuffer.Create(AOwner: TComponent);
begin
  inherited;

  Name            := 'Image_Buffer';

  fDepth          := 1;

  fImageType      := VK_IMAGE_TYPE_2D;
  fFormat         := VK_FORMAT_D32_SFLOAT;
  fSamples        := VK_SAMPLE_COUNT_1_BIT ;
  fUsage          := TVkImageUsageFlags(VK_IMAGE_USAGE_DEPTH_STENCIL_ATTACHMENT_BIT);
  fSharingMode    := VK_SHARING_MODE_EXCLUSIVE;
  fInitialLayout  := VK_IMAGE_LAYOUT_UNDEFINED;
  fMipLevels      := 1;
  fArrayLayers    := 1;
  fImageTiling    := VK_IMAGE_TILING_OPTIMAL;

  fMemoryProperty := TvkFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT) ;

  fImageViewType      := VK_IMAGE_VIEW_TYPE_2D;
  fComponentRed       := VK_COMPONENT_SWIZZLE_R;
  fComponentGreen     := VK_COMPONENT_SWIZZLE_G;
  fComponentBlue      := VK_COMPONENT_SWIZZLE_B;
  fComponentAlpha     := VK_COMPONENT_SWIZZLE_A;
  fImageAspectFlags   := TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT);
  fBaseMipLevel       := 0;
  fCountMipMapLevels  := 1;
  fBaseArrayLayer     := 0;
  fCountArrayLayers   := 1;

end;

procedure TvgResourceImageBuffer.DefineProperties(Filer: TFiler);
begin
  inherited;

end;

destructor TvgResourceImageBuffer.Destroy;
begin

  inherited;
end;

function TvgResourceImageBuffer.GetActive: Boolean;
begin
  Result := fActive ;
end;

function TvgResourceImageBuffer.GetArrayLayers: TvkUint32;
begin
  Result:= self.fArrayLayers;
end;

function TvgResourceImageBuffer.GetDepth: TvkUint32;
begin
  Result:= self.fDepth;
end;

function TvgResourceImageBuffer.GetFormat: TvgFormat;
begin
  Result := GetVGFormat(fFormat);
end;

function TvgResourceImageBuffer.GetImageAspect: TvgImageAspectFlagBits;
begin
  Result := GetVGImageAspectFlags(fImageAspectFlags);
end;

function TvgResourceImageBuffer.GetImageHeight: TvkUint32;
begin
  Result := fImageHeight;
end;

function TvgResourceImageBuffer.GetImageMode: TvgImageMode;
begin
  Result := fImageMode;
end;

function TvgResourceImageBuffer.GetImageTiling: TvgImageTiling;
begin
  Result:= GetVGImageTiling(fImageTiling);
end;

function TvgResourceImageBuffer.GetImageType: TvgImageType;
begin
  Result :=  GetVGImageType(fImageType);
end;

function TvgResourceImageBuffer.GetImageWidth: TvkUint32;
begin
  Result := fImageWidth;
end;

function TvgResourceImageBuffer.GetInitialLayout: TvgImageLayout;
begin
  Result :=  GetVGImageLayout(fInitialLayout);
end;

function TvgResourceImageBuffer.GetMemoryProperty: TvgMemoryPropertyFlagBits;
begin
  Result:=GetVGMemoryPropertyFlagBits(self.fMemoryProperty);
end;

function TvgResourceImageBuffer.GetMemoryType: TvgImageMemoryType;
begin
  Result := GetVGImageMemoryType(self.fMemoryType);
end;

function TvgResourceImageBuffer.GetMipLevels: TvkUint32;
begin
  Result:= self.fMipLevels;
end;

function TvgResourceImageBuffer.GetMSAAON: Boolean;
begin
  Result := fMSAAOn;
end;

function TvgResourceImageBuffer.GetSamples: TvgSampleCountFlagBits;
begin
  Result :=  GetVGSampleCountFlagBit(self.fSamples);
end;

function TvgResourceImageBuffer.GetSharingMode: TvgSharingMode;
begin
  Result :=  GetVGSharingMode(self.fSharingMode);
end;

function TvgResourceImageBuffer.GetUsage: TvgImageUsageFlagBits;
begin
  Result :=  GetVGImageUsageFlagBits(self.fUsage);
end;

function TvgResourceImageBuffer.GetLinker: TvgLinker;
begin
  Result := fLinker;
end;

procedure TvgResourceImageBuffer.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);

  Case Operation of
     opInsert : Begin
                  If aComponent=self then exit;
                  If NotificationTestON and Not (csDesigning in ComponentState) then exit ;      //don't mess with links at runtime
                End;

     opRemove : Begin
                end;
  End;
end;

procedure TvgResourceImageBuffer.SetActive(const Value: Boolean);
begin
  If fActive = Value then exit;
  SetActiveState(Value) ;
end;

procedure TvgResourceImageBuffer.SetArrayLayers(const Value: TvkUint32);
begin
  If self.fArrayLayers=Value then exit;
  SetActiveState(False);
  fArrayLayers := Value;
  fImageMode := imCustom;
end;

procedure TvgResourceImageBuffer.SetDepth(const Value: TvkUint32);
begin
  If self.fDepth=Value then exit;
  SetActiveState(False);
  fDepth := Value;
  fImageMode := imCustom;
end;

procedure TvgResourceImageBuffer.SetDisabled;
  Var Device         : TpvVulkanDevice;
begin
  fActive:=False;

  If assigned(fFrameBufferAttachment) then
    FreeAndNil(fFrameBufferAttachment);

  if assigned(fMemoryBlock) then
  begin
   Assert(assigned(fLinker),'VulkanLink connection not set');
   Assert(assigned(fLinker.ScreenDevice),'VulkanLink Screen Device not set');
   Assert(assigned(fLinker.ScreenDevice.VulkanDevice),'VulkanLink Screen Device NOT active');

   Device  := fLinker.ScreenDevice.VulkanDevice;
   fMemoryBlock.AssociatedObject:=nil;
   Device.MemoryManager.FreeMemoryBlock(fMemoryBlock);
   fMemoryBlock:=nil;
  end;

end;

procedure TvgResourceImageBuffer.SetEnabled(aComp:TvgBaseComponent=nil);
  Var   Device     : TpvVulkanDevice;
        aImage     : TpvVulkanImage ;
        aImageView : TpvVulkanImageView ;


  Procedure GetRequiredMemoryAndBind;
    Var MemoryRequirements           : TVkMemoryRequirements;
        RequiresDedicatedAllocation,
        PrefersDedicatedAllocation   : Boolean;
        MemoryBlockFlags             : TpvVulkanDeviceMemoryBlockFlags;

  Begin
    MemoryRequirements := Device.MemoryManager.GetImageMemoryRequirements(aImage.Handle ,
                                                                           RequiresDedicatedAllocation,
                                                                           PrefersDedicatedAllocation);

    MemoryBlockFlags:=[];

    if RequiresDedicatedAllocation or PrefersDedicatedAllocation then
      Include(MemoryBlockFlags,TpvVulkanDeviceMemoryBlockFlag.DedicatedAllocation);


    fMemoryBlock := Device.MemoryManager.AllocateMemoryBlock(MemoryBlockFlags,
                                                             MemoryRequirements.size,
                                                             MemoryRequirements.alignment,
                                                             MemoryRequirements.memoryTypeBits,
                                                             fMemoryProperty,//  TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT),
                                                             0,
                                                             0,
                                                             0,
                                                             0,
                                                             0,
                                                             0,
                                                             0,
                                                             fMemoryType,//TpvVulkanDeviceMemoryAllocationType.ImageOptimal,
                                                             @aImage.Handle);

    Assert(Assigned(fMemoryBlock),'Memory Block not created.');


   fMemoryBlock.AssociatedObject := self;

   VulkanCheckResult(Device.Commands.BindImageMemory(Device.Handle,
                                                          aImage.Handle,
                                                          fMemoryBlock.MemoryChunk.Handle,
                                                          fMemoryBlock.Offset));

  End;



begin

 fActive:=False;

 Assert(assigned(fLinker),'VulkanLink connection not set');
 Assert(assigned(fLinker.SwapChain),'VulkanLink swapchain not set');
 Assert(assigned(fLinker.ScreenDevice),'VulkanLink Screen Device not set');
 Assert(assigned(fLinker.ScreenDevice.VulkanDevice),'VulkanLink Screen Device NOT active');

 Assert((fFormat <> VK_FORMAT_UNDEFINED),'Format is NOT set');

 if (fImageWidth=0) or (fImageHeight=0) then exit;


 (*
 If () then
 Begin
    fFormat:=VK_FORMAT_B8G8R8A8_SRGB;


 End;
 *)
 //  SetUpForImageMode;

 Try

   Device := fLinker.ScreenDevice.VulkanDevice;

   aImage := TpvVulkanImage.Create(Device,
                                    0,
                                    fImageType,
                                    fFormat,
                                    fImageWidth,
                                    fImageHeight,
                                    fDepth,
                                    fMipLevels,
                                    fArrayLayers,
                                    fSamples,
                                    fImageTiling,
                                    fUsage,
                                    fSharingMode,
                                    0,
                                    Nil,
                                    fInitialLayout);

   Assert(assigned(aImage), 'Image not created');

  //assign memory and Bind to Image
   GetRequiredMemoryAndBind;

  //create ImageView
   aImageView := TpvVulkanImageView.Create(Device,
                                           aImage,
                                           fImageViewType,
                                           fFormat,
                                           fComponentRed,
                                           fComponentGreen,
                                           fComponentBlue,
                                           fComponentAlpha,
                                           fImageAspectFlags,
                                           fBaseMipLevel,
                                           fCountMipMapLevels,
                                           fBaseArrayLayer,
                                           fCountArrayLayers);

   Assert(Assigned(aImageView) , 'Image View creation failed.');

   fFrameBufferAttachment := TpvVulkanFrameBufferAttachment.Create(Device,
                                                                   aImage,
                                                                   aImageView,
                                                                   fLinker.SwapChain.ImageWidth,
                                                                   fLinker.SwapChain.ImageHeight,
                                                                   fFormat,
                                                                   True);
   fActive:=True;

 Except
    On EpvVulkanResultException do
    Begin

    End;
 End;
end;

procedure TvgResourceImageBuffer.SetFormat(const Value: TvgFormat);
  Var V:TvkFormat;
begin
  V := GetVKFormat(Value);
  if fFormat = V then exit;
  SetActiveState(False);
  fFormat := V;
end;

procedure TvgResourceImageBuffer.SetImageAspect( const Value: TvgImageAspectFlagBits);
  var V:TVkImageAspectFlags;
begin
  V:=GetVKImageAspectFlags(Value);
  If fImageAspectFlags =V then exit;
  SetActiveState(False);
  fImageAspectFlags := V;
  fImageMode        := imCustom;
end;

procedure TvgResourceImageBuffer.SetImageHeight(const Value: TvkUint32);
begin
  if Value = fImageHeight then exit;
  SetActiveState(False);
  fImageHeight := Value;
end;

procedure TvgResourceImageBuffer.SetImageMode(const Value: TvgImageMode);
begin
  If fImageMode=Value then exit;
  SetActiveState(False);
  fImageMode := Value;
  SetUpForImageMode;
end;

procedure TvgResourceImageBuffer.SetImageTiling(const Value: TvgImageTiling);
  Var V : TVkImageTiling;
begin
  V:= GetVKImageTiling(Value);
  If self.fImageTiling=V then exit;
  SetActiveState(False);
  fImageTiling:=V;
  fImageMode := imCustom;
end;

procedure TvgResourceImageBuffer.SetImageType(const Value: TvgImageType);
  Var V : TVkImageType;
begin
  V:= GetVKImageType(Value);
  If self.fImageType=V then exit;
  SetActiveState(False);
  fImageType:=V;
  fImageMode := imCustom;

  self.CheckImageType;

end;

procedure TvgResourceImageBuffer.SetImageWidth(const Value: TvkUint32);
begin
  if Value = fImageWidth then exit;
  SetActiveState(False);
  fImageWidth := Value;
end;

procedure TvgResourceImageBuffer.SetInitialLayout(const Value: TvgImageLayout);
  Var V : TVkImageLayout;
begin
  V:= GetVKImageLayout(Value);
  If self.fInitialLayout=V then exit;
  SetActiveState(False);
  fInitialLayout:=V;
  fImageMode := imCustom;
end;

procedure TvgResourceImageBuffer.SetMemoryProperty( const Value: TvgMemoryPropertyFlagBits);
  Var V: TVkMemoryPropertyFlags;

begin
  V := GetVKMemoryPropertyFlagBits( Value);
  If fMemoryProperty=V then exit;
  SetActiveState(False);
  fMemoryProperty := V;
  fImageMode := imCustom;
end;

procedure TvgResourceImageBuffer.SetMemoryType(const Value: TvgImageMemoryType);
  Var V : TpvVulkanDeviceMemoryAllocationType;
begin
   V := GetVKImageMemoryType(Value);
   If self.fMemoryType=V then exit;
   SetActiveState(False);
   fMemoryType := V;
  fImageMode := imCustom;
end;

procedure TvgResourceImageBuffer.SetMipLevels(const Value: TvkUint32);
begin
  If self.fMipLevels=Value then exit;
  SetActiveState(False);
  fMipLevels := Value;
  fImageMode := imCustom;
end;

procedure TvgResourceImageBuffer.SetMSAAOn(const Value: Boolean);
begin
  if fMSAAOn=Value then exit;
  SetActiveState(False);
  fMSAAOn := Value;
end;

procedure TvgResourceImageBuffer.SetSamples(const Value: TvgSampleCountFlagBits);
  Var V : TVkSampleCountFlagBits;
begin
  V:= GetVKSampleCountFlagBit(Value);
  If fSamples=V then exit;
  SetActiveState(False);
  fSamples:=V;
  fImageMode := imCustom;
end;

procedure TvgResourceImageBuffer.SetSharingMode(const Value: TvgSharingMode);
  Var V : TVkSharingMode;
begin
  V:= GetVKSharingMode(Value);
  If self.fSharingMode=V then exit;
  SetActiveState(False);
  fSharingMode:=V;
  fImageMode := imCustom;
end;

procedure TvgResourceImageBuffer.SetUpForImageMode;
  Var DFormat : TvkFormat;

  Procedure GetDepthFormat;
  Begin
    DFormat:=fLinker.SwapChain.ImageFormat;
  End;


begin
  If not assigned(fLinker) then exit;
  If not (fLinker.active) then exit;
  If not assigned(fLinker.SwapChain) then exit;
  If not assigned(fLinker.Renderer) then exit;
  If not assigned(fLinker.Renderer.RenderPass) then exit;

  fImageWidth        := fLinker.SwapChain.ImageWidth;
  fImageHeight       := fLinker.SwapChain.ImageHeight;

  Case fImageMode of
     imNone         :;
     imColour       :Begin
                        fDepth          := 1;
                        fMipLevels      := 1;
                        fArrayLayers    := 1;

                        fImageType      := VK_IMAGE_TYPE_2D;
                     //   fFormat         := fLinker.SwapChain.ImageFormat;
                     //   fSamples        := GetVKSampleCountFlagBit(fLinker.Renderer.RenderPass.MSAASample) ;
                        fUsage          := TVkImageUsageFlags(VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT) +
                                           TVkImageUsageFlags(VK_IMAGE_USAGE_TRANSFER_SRC_BIT);
                        fSharingMode    := VK_SHARING_MODE_EXCLUSIVE;
                        fInitialLayout  := VK_IMAGE_LAYOUT_UNDEFINED;
                        fFinalLayout    := VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL;
                        fImageTiling    := VK_IMAGE_TILING_OPTIMAL;

                        fMemoryProperty := TvkFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT) ;
                        fMemoryType     := TpvVulkanDeviceMemoryAllocationType.ImageOptimal;

                        fImageViewType      := VK_IMAGE_VIEW_TYPE_2D;
                        fComponentRed       := VK_COMPONENT_SWIZZLE_R;
                        fComponentGreen     := VK_COMPONENT_SWIZZLE_G;
                        fComponentBlue      := VK_COMPONENT_SWIZZLE_B;
                        fComponentAlpha     := VK_COMPONENT_SWIZZLE_A;
                        fImageAspectFlags   := TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT);
                        fBaseMipLevel       := 0;
                        fCountMipMapLevels  := 1;
                        fBaseArrayLayer     := 0;
                        fCountArrayLayers   := 1;
                     end;
     imFrame : Begin
                        fDepth          := 1;
                        fMipLevels      := 1;
                        fArrayLayers    := 1;

                        fImageType      := VK_IMAGE_TYPE_2D;
                        fFormat         := fLinker.SwapChain.ImageFormat;
                     //   fSamples        := GetVKSampleCountFlagBit(fLinker.Renderer.RenderPass.MSAASample) ;
                        fUsage          := TVkImageUsageFlags(VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT) +
                                           TVkImageUsageFlags(VK_IMAGE_USAGE_TRANSFER_SRC_BIT);
                        fSharingMode    := VK_SHARING_MODE_EXCLUSIVE;
                        fInitialLayout  := VK_IMAGE_LAYOUT_UNDEFINED;
                        fFinalLayout    := VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL;
                        fImageTiling    := VK_IMAGE_TILING_OPTIMAL;

                        fMemoryProperty := TvkFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT) ;
                        fMemoryType     := TpvVulkanDeviceMemoryAllocationType.ImageOptimal;

                        fImageViewType      := VK_IMAGE_VIEW_TYPE_2D;
                        fComponentRed       := VK_COMPONENT_SWIZZLE_R;
                        fComponentGreen     := VK_COMPONENT_SWIZZLE_G;
                        fComponentBlue      := VK_COMPONENT_SWIZZLE_B;
                        fComponentAlpha     := VK_COMPONENT_SWIZZLE_A;
                        fImageAspectFlags   := TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT);
                        fBaseMipLevel       := 0;
                        fCountMipMapLevels  := 1;
                        fBaseArrayLayer     := 0;
                        fCountArrayLayers   := 1;
     End;
     imDepth :Begin
                        fDepth          := 1;
                        fMipLevels      := 1;
                        fArrayLayers    := 1;

                        fImageType      := VK_IMAGE_TYPE_2D;
                        fFormat         := fLinker.Renderer.RenderPass.fDepthStencilFormat;
                        fSamples        := GetVKSampleCountFlagBit(fLinker.Renderer.RenderPass.MSAASample) ;
                        fUsage          := TVkImageUsageFlags(VK_IMAGE_USAGE_DEPTH_STENCIL_ATTACHMENT_BIT);
                        fSharingMode    := VK_SHARING_MODE_EXCLUSIVE;
                        fInitialLayout  := VK_IMAGE_LAYOUT_UNDEFINED;
                        fFinalLayout    := VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL;
                        fImageTiling    := VK_IMAGE_TILING_OPTIMAL;

                        fMemoryProperty := TvkFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT) ;
                        fMemoryType     := TpvVulkanDeviceMemoryAllocationType.ImageOptimal;

                        fImageViewType      := VK_IMAGE_VIEW_TYPE_2D;
                        fComponentRed       := VK_COMPONENT_SWIZZLE_R;
                        fComponentGreen     := VK_COMPONENT_SWIZZLE_G;
                        fComponentBlue      := VK_COMPONENT_SWIZZLE_B;
                        fComponentAlpha     := VK_COMPONENT_SWIZZLE_A;

                        fImageAspectFlags   := TVkImageAspectFlags(VK_IMAGE_ASPECT_DEPTH_BIT) ;

                        fBaseMipLevel       := 0;
                        fCountMipMapLevels  := 1;
                        fBaseArrayLayer     := 0;
                        fCountArrayLayers   := 1;

                     end;

     imDepthStencil :Begin
                        fDepth          := 1;
                        fMipLevels      := 1;
                        fArrayLayers    := 1;

                        fImageType      := VK_IMAGE_TYPE_2D;
                        fFormat         := fLinker.Renderer.RenderPass.fDepthStencilFormat;
                        fSamples        := GetVKSampleCountFlagBit(fLinker.Renderer.RenderPass.MSAASample) ;
                        fUsage          := TVkImageUsageFlags(VK_IMAGE_USAGE_DEPTH_STENCIL_ATTACHMENT_BIT);
                        fSharingMode    := VK_SHARING_MODE_EXCLUSIVE;
                        fInitialLayout  := VK_IMAGE_LAYOUT_UNDEFINED;
                        fFinalLayout    := VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL;
                        fImageTiling    := VK_IMAGE_TILING_OPTIMAL;

                        fMemoryProperty := TvkFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT) ;
                        fMemoryType     := TpvVulkanDeviceMemoryAllocationType.ImageOptimal;

                        fImageViewType      := VK_IMAGE_VIEW_TYPE_2D;
                        fComponentRed       := VK_COMPONENT_SWIZZLE_R;
                        fComponentGreen     := VK_COMPONENT_SWIZZLE_G;
                        fComponentBlue      := VK_COMPONENT_SWIZZLE_B;
                        fComponentAlpha     := VK_COMPONENT_SWIZZLE_A;

                        fImageAspectFlags   := TVkImageAspectFlags(VK_IMAGE_ASPECT_DEPTH_BIT) +
                                               TVkImageAspectFlags(VK_IMAGE_ASPECT_STENCIL_BIT);
                        fBaseMipLevel       := 0;
                        fCountMipMapLevels  := 1;
                        fBaseArrayLayer     := 0;
                        fCountArrayLayers   := 1;
                     end;
     imMSAA         :Begin
     //don't mess with these values
                        fDepth          := 1;
                        fMipLevels      := 1;
                        fArrayLayers    := 1;

                        fImageType      := VK_IMAGE_TYPE_2D;
                        fFormat         := fLinker.SwapChain.ImageFormat;
                        fSamples        := GetVKSampleCountFlagBit(fLinker.Renderer.RenderPass.MSAASample) ;
                        fUsage          := TVkImageUsageFlags(VK_IMAGE_USAGE_TRANSIENT_ATTACHMENT_BIT ) +
                                           TVkImageUsageFlags(VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT );
                        fSharingMode    := VK_SHARING_MODE_EXCLUSIVE;
                        fInitialLayout  := VK_IMAGE_LAYOUT_UNDEFINED;
                        fFinalLayout    := VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL;
                        fImageTiling    := VK_IMAGE_TILING_OPTIMAL;

                        fMemoryProperty := TvkFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT) ;
                        fMemoryType     := TpvVulkanDeviceMemoryAllocationType.ImageOptimal;

                        fImageViewType      := VK_IMAGE_VIEW_TYPE_2D;
                        fComponentRed       := VK_COMPONENT_SWIZZLE_R;
                        fComponentGreen     := VK_COMPONENT_SWIZZLE_G;
                        fComponentBlue      := VK_COMPONENT_SWIZZLE_B;
                        fComponentAlpha     := VK_COMPONENT_SWIZZLE_A;
                        fImageAspectFlags   := TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT);
                        fBaseMipLevel       := 0;
                        fCountMipMapLevels  := 1;
                        fBaseArrayLayer     := 0;
                        fCountArrayLayers   := 1;
                     end;
     imSelect       :Begin

                     end;
     imTexture      :Begin

                     end;
     imCustom       :;

  End;

end;

procedure TvgResourceImageBuffer.SetUsage(const Value: TvgImageUsageFlagBits);
  Var V : TVkImageUsageFlags;
begin
  V:= GetVKImageUsageFlagBits(Value);
  If self.fUsage=V then exit;
  SetActiveState(False);
  fUsage:=V;
  fImageMode := imCustom;
end;

procedure TvgResourceImageBuffer.SetLinker(const Value: TvgLinker);
begin
  If fLinker=Value then exit;
  SetActiveState(False);
  fLinker:=Value;
  If not assigned(fLinker) then exit;

 // SetUpForImageMode;
end;

{ TvgDescriptorItem }

constructor TvgDescriptorItem.Create(Collection: TCollection);
begin
  inherited Create(Collection);

  fDescriptorType := Nil;

end;

destructor TvgDescriptorItem.Destroy;
begin
  If assigned(fDescriptor) then
     FreeAndNil(fDescriptor) ;
  inherited;
end;

function TvgDescriptorItem.GetActive: Boolean;
begin
  Result := fActive;
end;

function TvgDescriptorItem.GetDevice: TvgLogicalDevice;
begin
  Result := fDevice  ;
end;

function TvgDescriptorItem.GetDisplayName: string;
begin
  Result := fName;
  If Result='' then
    Inherited GetDisplayName;

end;

function TvgDescriptorItem.GetName: String;
begin
  Result := fName;
end;

function TvgDescriptorItem.GetDescriptor: TvgDescriptor;
begin
  Result := fDescriptor;
end;

function TvgDescriptorItem.GetDescriptorName: String;
begin
  If not assigned(fDescriptorType) then
     Result := '<NONE>'
  else
     Result := fDescriptorType.GetPropertyName;
end;

procedure TvgDescriptorItem.SetActive(const Value: Boolean);
begin
  If fActive=Value then exit;
  fActive := Value;
end;

procedure TvgDescriptorItem.SetDevice(Value: TvgLogicalDevice);
begin
  If fDevice=Value then exit;

  fDevice := Value;
end;

procedure TvgDescriptorItem.SetName(const Value: String);
Begin
  fName := Value;
end;

procedure TvgDescriptorItem.SetDescriptorName(const Value: String);
  Var I:Integer;
begin
  If Value = '' then
     SetDescriptorType(nil)
  else
  Begin
    For I:= 0 to DescriptorTypeList.count-1 do
    Begin
      If  CompareStr(Value, DescriptorTypeList.Items[I].GetPropertyName)=0 then
      Begin
        SetDescriptorType(DescriptorTypeList.Items[I]);
        exit;
      End;
    End;
  End;

end;

procedure TvgDescriptorItem.SetDescriptorType(const Value: TvgDescriptorType);
begin
  If fDescriptorType = Value then exit;

  If assigned(fDescriptor) then
     FreeAndNil(fDescriptor);

  fDescriptorType := Value ;

  If  fDescriptorType = Nil then exit;

  fDescriptor := CreateDescriptorFromType(fDescriptorType, TvgDescriptorCol(Collection).DescriptorSet);

  If assigned(fDescriptor) then
  Begin
     fDescriptor.SetSubComponent(True);
     fDescriptor.Descriptor := Self;  //important

   //  If fDescriptor.FrameCount=0 then
   //     fDescriptor.FrameCount := TvgDescriptorSet(TvgDescriptorCol(Collection).Owner).FrameCount;
  end;

end;

{ TvgDepthStencilImageBufferAsset }

procedure TvgDepthStencilImageBufferAsset.CheckFormat(aInstance : TpvVulkanInstance; aPhysicalDevice : TpvVulkanPhysicalDevice);

   Function CheckForSupport:Boolean;
      var FormatProperties:TVkFormatProperties2;
      begin
          result:=False;
          If Assigned(aInstance.Commands.commands.GetPhysicalDeviceFormatProperties2KHR) then
             aInstance.Commands.GetPhysicalDeviceFormatProperties2KHR(aPhysicalDevice.Handle, fFormat, @FormatProperties)
          else
             aInstance.Commands.GetPhysicalDeviceFormatProperties2(aPhysicalDevice.Handle, fFormat, @FormatProperties) ;

          If fMemoryType = TpvVulkanDeviceMemoryAllocationType.ImageOptimal then
           Begin
              if (FormatProperties.formatProperties.optimalTilingFeatures and TVkFormatFeatureFlags(VK_FORMAT_FEATURE_DEPTH_STENCIL_ATTACHMENT_BIT))<>0 then
                result:=True;
           End else
          If fMemoryType =  TpvVulkanDeviceMemoryAllocationType.ImageLinear  Then
           Begin
              if (FormatProperties.formatProperties.linearTilingFeatures and TVkFormatFeatureFlags(VK_FORMAT_FEATURE_DEPTH_STENCIL_ATTACHMENT_BIT))<>0 then
                result:=True;
           End else

            Begin
                if (FormatProperties.formatProperties.bufferFeatures and TVkFormatFeatureFlags(VK_FORMAT_FEATURE_DEPTH_STENCIL_ATTACHMENT_BIT))<>0 then
                  result:=True;
            End;

      End;
begin


   Try
      If not CheckForSupport then
        fFormat := aPhysicalDevice.GetBestSupportedDepthFormat(fStencilON);

   Except
   End;
end;

constructor TvgDepthStencilImageBufferAsset.Create(AOwner: TComponent);
begin
  inherited;

  Name            := 'Depth_Buffer';
  fImageType      := VK_IMAGE_TYPE_2D;
  fFormat         := VK_FORMAT_D32_SFLOAT;
  fSamples        := VK_SAMPLE_COUNT_1_BIT ;
  fUsage          := TVkImageUsageFlags(VK_IMAGE_USAGE_DEPTH_STENCIL_ATTACHMENT_BIT);
  fSharingMode    := VK_SHARING_MODE_EXCLUSIVE;
  fInitialLayout  := VK_IMAGE_LAYOUT_UNDEFINED;

  fMemoryProperty := TvkFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT) ;

  fImageViewType      := VK_IMAGE_VIEW_TYPE_2D;
  fComponentRed       := VK_COMPONENT_SWIZZLE_R;
  fComponentGreen     := VK_COMPONENT_SWIZZLE_G;
  fComponentBlue      := VK_COMPONENT_SWIZZLE_B;
  fComponentAlpha     := VK_COMPONENT_SWIZZLE_A;
  fImageAspectFlags   := TVkImageAspectFlags(VK_IMAGE_ASPECT_DEPTH_BIT);
  fBaseMipLevel       := 0;
  fCountMipMapLevels  := 1;
  fBaseArrayLayer     := 0;
  fCountArrayLayers   := 1;

end;

destructor TvgDepthStencilImageBufferAsset.Destroy;
begin
  SetActiveState(False);
  inherited;
end;

function TvgDepthStencilImageBufferAsset.GetFormat: TvgDepthBufferFormat;
begin
  Result := GetVGDeptBufferFormat(self.fFormat);
end;

function TvgDepthStencilImageBufferAsset.GetUseStencil: Boolean;
begin
  Result:= fStencilON;
end;

procedure TvgDepthStencilImageBufferAsset.SetDisabled;
begin
  inherited;

end;

procedure TvgDepthStencilImageBufferAsset.SetEnabled(aComp:TvgBaseComponent=nil);
begin
  inherited;

end;

procedure TvgDepthStencilImageBufferAsset.SetFormat(const Value: TvgDepthBufferFormat);
  Var V: TVkFormat;
begin
  V:= GetVKDeptBufferFormat( Value);
  If fFormat=V then exit;
  SetActiveState(False);
  fFormat := V;
end;

procedure TvgDepthStencilImageBufferAsset.SetUseStencil(const Value: Boolean);
begin
  If fStencilON=Value then exit;
  SetActiveState(False);
  fStencilON:=Value;
  If  fStencilON then
  Begin
    fFormat            := VK_FORMAT_D32_SFLOAT_S8_UINT;
    fImageAspectFlags  := TVkImageAspectFlags(VK_IMAGE_ASPECT_DEPTH_BIT) OR TVkImageAspectFlags(VK_IMAGE_ASPECT_STENCIL_BIT);
  end else
  Begin
    fFormat            := VK_FORMAT_D32_SFLOAT;
    fImageAspectFlags  := TVkImageAspectFlags(VK_IMAGE_ASPECT_DEPTH_BIT);
  End;

end;

{ TvgWindowLink }

procedure TvgLinker.BuildSwapChainColorSpaces;
  Var aInstance:TvgInstance;
      B1,B2:Boolean;
begin
  B1:=False;
  B2:=False;
  aInstance := fPhysicalDevice.Instance;
 Try
  Assert(assigned(fPhysicalDevice), 'Device not connected.');
  Assert(Assigned(fSurface), 'Surface not attached.');
  Assert(assigned(aInstance), 'Instance not connected to Device');

  Assert(Assigned(fSwapChain), 'SwapChain not created.');

  If not assigned(aInstance.VulkanInstance) then
  Begin
     aInstance.SetDesigning;
     B1:=assigned(aInstance.VulkanInstance);
  End;
  Assert(assigned(aInstance.VulkanInstance), 'Unable to create a valid Vulkan Instance.');

  If not assigned(fSurface.VulkanSurface) then
  Begin
    fSurface.SetDesigning;
    B2:=assigned(fSurface.VulkanSurface);
  End;
  Assert(assigned(fSurface.VulkanSurface), 'Vulkan Surface not created');

  fSwapChain.BuildALLImagesColorSpaces;

  If B2 then
     fSurface.SetActiveState(False);
  If B1 then
     aInstance.SetActiveState(False);

 Except
    On E:Exception do
    Begin
      If B2 then
         fSurface.SetActiveState(False);
      If B1 then
         aInstance.SetActiveState(False);
      Raise;
    End;
 End;
end;

procedure TvgLinker.BuildSwapChainPresentationModes;
  Var aInstance:TvgInstance;
      B1,B2:Boolean;
begin
  B1:=False;
  B2:=False;
  aInstance := Nil;
 Try
  Assert(assigned(fPhysicalDevice), 'Device not connected.');
  Assert(Assigned(fSurface), 'Internal Surface not attached.');
  Assert(Assigned(fSwapChain), 'Internal SwapChain not created.');

  aInstance := fPhysicalDevice.Instance;
  Assert(assigned(aInstance), 'Instance not connected to Device');

  If not assigned(aInstance.VulkanInstance) then
  Begin
     aInstance.SetDesigning;
     B1:=assigned(aInstance.VulkanInstance);
  End;
  Assert(assigned(aInstance.VulkanInstance), 'Unable to create a valid Vulkan Instance.');

  If not assigned(fSurface.VulkanSurface) then
  Begin
    fSurface.SetDesigning;
    B2:=True;
  End;
  Assert(assigned(fSurface.VulkanSurface), 'Vulkan Surface not created');

  fSwapChain.BuildALLPresentationModes;

  If B2 then
     fSurface.SetActiveState(False);

  If B1 and assigned(aInstance) then
     aInstance.SetActiveState(False);

 Except
    On E:Exception do
    Begin
      If B2 then
         fSurface.SetActiveState(False);
      If B1 then
         aInstance.SetActiveState(False);
      Raise;
    End;
 End;
end;

procedure TvgLinker.UpdateConnections;

begin
    If (csLoading in ComponentState) then exit;

 //   Assert(Assigned(fLinkerPresentCommandPool),'Presentation Command Pool not created.');
 //   fLinkerPresentCommandPool.Device := fScreenDevice;
 //   fLinkerGraphicCommandPool.Device := fScreenDevice;

    Assert(Assigned(fSurface),'Internal Surface not created.');
    fSurface.PhysicalDevice := fPhysicalDevice;
    fSurface.WindowIntf     := fWindowIntf;

    Assert(Assigned(fScreenDevice),'Internal Screen Device not created.');
    fScreenDevice.PhysicalDevice := fPhysicalDevice;
    If assigned(fPhysicalDevice) then
        fScreenDevice.Instance   := fPhysicalDevice.Instance
    else
        fScreenDevice.Instance   := Nil;
    fScreenDevice.Linker        := Self;

    Assert(Assigned(fSwapChain),'Internal Swap Chain not created.');
    fSwapChain.Device          := fScreenDevice;
    fSwapChain.fLinker         := Self;

    UpdateFormats;
end;

procedure TvgLinker.UpdateFormats;

begin
//fix this
    Assert(assigned(fSwapChain));
    if (fSwapChain.ImageFormat<>VK_FORMAT_UNDEFINED) then
       fImageFormat := fSwapChain.ImageFormat;

end;

procedure TvgLinker.UpdateWindowSize;
  Var  aWinWidth, aWinHeight : TvkUint32;
begin

  If assigned(fSurface) then
     fSurface.GetWindowSize(aWinWidth, aWinHeight )
  else
  Begin
     aWinWidth :=0;
     aWinHeight:=0;
  End;

  Assert(Assigned(fSwapChain));
  fSwapChain.fImageWidth  := aWinWidth;
  fSwapChain.fImageHeight := aWinWidth;

  Assert(Assigned(fRenderer),'Renderer not assigned');
  Assert(Assigned(fRenderer.RenderPass),'Renderer RenderPass not assigned');
  fRenderer.RenderPass.UpdateWindowSize;
end;

constructor TvgLinker.Create(AOwner: TComponent);
begin

  fSurface      := TvgSurface.Create(self);    //subcomponent for managing presentation commands
  fSurface.Name := 'SF';//'Surface';
  fSurface.SetSubComponent(True);
  FreeNotification(fSurface);
  fSurface.PhysicalDevice := fPhysicalDevice;    //important
  fSurface.Linker := self;

  fScreenDevice := TvgScreenRenderDevice.Create(Self);   //subcomponent
  fScreenDevice.Name:='SD';//'Screen_Device';
  fScreenDevice.SetSubComponent(True);
  FreeNotification(fScreenDevice);
  fScreenDevice.PhysicalDevice := fPhysicalDevice;    //important
  fScreenDevice.Linker := self;

  fSwapChain := TvgSwapChain.Create(Self);   //subcomponent
  fSwapChain.Name:='SC';//'Swap_Chain';
  fSwapChain.SetSubComponent(True);
  FreeNotification(fSwapChain);
  fSwapChain.Surface := fSurface;

  inherited;    //must stay here

  fRenderTarget    := RT_SCREEN; //default     RT_FRAME;

  fFrameCount        := MaxFramesInFlight;

  if fFrameCount=0 then fFrameCount := 1;
  if fFrameCount=1 then
  Begin
    fCurrentFrameIndex :=0;
    fNextFrameIndex    :=0;
  End else
  Begin
    fCurrentFrameIndex :=0;
    fNextFrameIndex    :=1;
  End;
end;

destructor TvgLinker.Destroy;
Begin
 Try
    SetActiveState(False);

    If assigned(fSwapChain) then
    Begin
      fSwapChain.Surface:=nil;
      fSwapChain.SetSubComponent(False);
      RemoveFreeNotification(fSwapChain);
      FreeAndNil(fSwapChain);
    End;

    If assigned(fScreenDevice) then
    Begin
      fScreenDevice.Linker:=nil;
      fScreenDevice.SetSubComponent(False);
      RemoveFreeNotification(fScreenDevice);
      FreeAndNil(fScreenDevice);
    End;

    If assigned(fSurface) then
    Begin
      fSurface.Linker:=nil;
      fSurface.fWindowIntf := Nil;
      fSurface.SetSubComponent(False);
      RemoveFreeNotification(fSurface);
      FreeAndNil(fSurface);
    End;

    If assigned(fWindowIntf) then
    Begin
       fWindowIntf.Linker :=nil;
       fWindowIntf := Nil;
    End;

    If assigned(fPhysicalDevice) then
       fPhysicalDevice.RemoveLinker(self);

    inherited;
 Except
   On E:Exception do
   Begin
     If (csDesigning in ComponentState) then
        Raise;
   End;
 End;
end;

procedure TvgLinker.DisableParent(ToRoot:Boolean=False);
begin
  If assigned(fPhysicalDevice) and fPhysicalDevice.Active then
     fPhysicalDevice.DisableParent(ToRoot);
end;

function TvgLinker.getActive: Boolean;
begin
  Result:= fActive;
end;

function TvgLinker.GetCurrentFrame: TvgFrame;
begin
  Result:= fFrames[fCurrentFrameIndex];
end;

function TvgLinker.GetCurrentFrameIndex: Integer;
begin
  Result := fCurrentFrameIndex;
end;

function TvgLinker.GetDevice: TvgPhysicalDevice;
begin
  result := fPhysicalDevice;
end;

function TvgLinker.GetFrame(Index: Integer): TvgFrame;
begin
  Result := Nil;
  if (index<0) or (index>=Length(fFrames)) then exit;
  Result := fFrames[Index];
end;

function TvgLinker.GetFramesInFlight: TvkUint32;
begin
  Result := fFrameCount;
end;

function TvgLinker.GetRenderer: TvgRenderEngine;
begin
 Result:=fRenderer;
end;

function TvgLinker.GetScreenDevice: TvgScreenRenderDevice;
begin
  Result := fScreenDevice;
end;

function TvgLinker.GetSurface: TvgSurface;
begin
  Result := fSurface;
end;

function TvgLinker.GetSwapChain: TvgSwapChain;
begin
  Result := fSwapChain;
end;

function TvgLinker.GetUseThread: Boolean;
begin
  Result := fUseThread;
end;

function TvgLinker.GetWindowIntf: IvgVulkanWindow;
begin
  Result := nil;
  Assert(Assigned(fSurface),'Internal Surface not created');
  Result := fWindowIntf;
end;

procedure TvgLinker.IncFrame(Var aCurrentFrame, aNextFrame:Integer);
  Var L:TvkUint32;
begin
  Inc(aCurrentFrame);
  aNextFrame := aCurrentFrame + 1;

  L:=  length(fFrames) ;

  If aCurrentFrame >= L then
     aCurrentFrame:=0;

  If aNextFrame >= L then
     aNextFrame:=0;
end;

procedure TvgLinker.Loaded;
begin
  Inherited Loaded;

  UpdateConnections;
end;

procedure TvgLinker.Notification(AComponent: TComponent;   Operation: TOperation);
  Var Intf : IvgVulkanWindow;
begin
  inherited Notification(AComponent, Operation);

  Case Operation of
     opInsert : Begin
                  If aComponent=self then exit;
                  If NotificationTestON and Not (csDesigning in ComponentState) then exit ;      //don't mess with links at runtime

                  If (aComponent is TvgPhysicalDevice) and not assigned(fPhysicalDevice) then
                  Begin
                    SetDevice(TvgPhysicalDevice(aComponent));
                  End;

                  If supports(aComponent, IvgVulkanWindow,Intf) and not assigned(fWindowIntf) then
                  Begin
                     SetWindowIntf(aComponent as IvgVulkanWindow) ;
                  End;

                  If (aComponent is TvgRenderEngine) and not assigned(fRenderer) then
                  Begin
                    SetRenderer(TvgRenderEngine(aComponent));
                  End;
                End;

     opRemove : Begin

                  If (aComponent is TvgPhysicalDevice) and (TvgPhysicalDevice(aComponent)=fPhysicalDevice) then
                  Begin
                    SetActiveState(False);
                    fPhysicalDevice:=nil;
                  End;

                  If supports(aComponent, IvgVulkanWindow, Intf) and (fWindowIntf = Intf) then
                  Begin
                    SetActiveState(False);
                    fWindowIntf          := nil;
                    fSurface.fWindowIntf := nil;
                  End;

                  If (aComponent is TvgRenderEngine) and (TvgRenderEngine(aComponent)=fRenderer) then
                  Begin
                    SetRenderer(nil) ;
                  End;
                end;
  End;

    If assigned(fScreenDevice) then
       fScreenDevice.Notification(aComponent,Operation);

    If assigned(fSwapChain) then
       fSwapChain.Notification(aComponent,Operation);

    If assigned(fSurface) then
       fSurface.Notification(aComponent,Operation);

end;

procedure TvgLinker.BuildFeaturesStructure;
begin
  Assert(assigned(fPhysicalDevice),'Logical Device not assigned');
  Assert(assigned(fPhysicalDevice.Instance),'Instance not assigned');
  Assert(assigned(fScreenDevice),'Screen Device not assigned');
  Assert(assigned(fScreenDevice.fFeatures),'Screen Device Features not assigned');

  fScreenDevice.fFeatures.SetDesigning;
  fScreenDevice.fFeatures.SetActiveState(False);



end;

procedure TvgLinker.SetActive(const Value: Boolean);
begin
  If Value = fActive then exit;
  SetActiveState(Value) ;

  TriggerWindowRepaint;
end;

procedure TvgLinker.SetDesigning;
begin
  UpdateConnections;

  If not fSurface.Active  then
     fSurface.Active:=True;

end;

procedure TvgLinker.SetDevice(const Value: TvgPhysicalDevice);
begin
  If fPhysicalDevice = Value then exit;
  SetActiveState(False);
  If Assigned(fPhysicalDevice) then
     fPhysicalDevice.RemoveLinker(self);
  fPhysicalDevice := Nil;
  If assigned(Value) then
     Value.AddLinker(self)
  else
    fPhysicalDevice :=  Nil;

  UpdateConnections;
end;

procedure TvgLinker.SetDisabled;
  Var I:Integer;
begin
  fActive:=False;

  VulkanWaitIdle;

  //order is IMPORTANT

  If assigned(fRenderer) and fRenderer.Active then
       fRenderer.Active := False;

  If Length(fFrames)>0 then
  For I:=0 to High(fFrames) do
    fFrames[I].Active:=False;

  If assigned(fSwapChain) and (fSwapChain.Active) then
     fSwapChain.Active:=False;

  If assigned(fScreenDevice) and (fScreenDevice.Active) then
     fScreenDevice.Active:=False;

  If assigned(fSurface) and (fSurface.Active) then
     fSurface.Active:=False;

  If length(fFrames)>0 then
  Begin
    For I:=0 to High(fFrames) do
    Begin
      fFrames[I].SetSubComponent(False);
      RemoveFreeNotification(fFrames[I]);
      FreeAndNil(fFrames[I]);
    end;
    SetLength(fFrames,0);
  End;

  TriggerWindowRepaint;
end;

procedure TvgLinker.SetEnabled(aComp:TvgBaseComponent=nil);
   Var I:Integer;
begin
  fActive := False;

   Try
    Assert(assigned(fPhysicalDevice) , 'Vulkan Graphics Device not connected.' );
    If not  fPhysicalDevice.Active then
    Begin
      fPhysicalDevice.SetEnabled(self);
      Exit;
    End;
    Assert(assigned(fPhysicalDevice.Instance.VulkanInstance), 'Vulkan Instance not Active.');

    Assert(assigned(fSurface) , 'Internal Surface not attached.');
    If not assigned(fSurface.VulkanSurface) then
      fSurface.Active := True;
    Assert(assigned(fSurface.VulkanSurface), 'Vulkan Surface not Active.');

 //all sub components
    Assert(assigned(fScreenDevice) , 'Internal Screen Device not assigned.');
    Assert(assigned(fSwapChain) , 'Internal Swap Chain not created.');

//    Assert(assigned(fRenderPass),'Render Pass not created.');

    UpdateWindowSize;
    UpdateConnections;

//order is important
    fScreenDevice.Active := True;
    Assert(assigned(fScreenDevice.VulkanDevice) , 'Vulkan Device not created.');

    SetUpCapabilities ;   //must stay here

    fSwapChain.BuildALLImagesColorSpaces;
    fSwapChain.BuildALLPresentationModes;

    fSwapChain.Active:=True;
    Assert(assigned(fSwapChain.VulkanSwapChain) , 'Vulkan Swap Chain not created.');

    UpdateFormats;

    if fFrameCount=0 then
       fFrameCount:=1;

    SetLength(fFrames,fFrameCount);
    For I:=0 to fFrameCount-1 do
    Begin
      fFrames[I]             := TvgFrame.Create(self);
      fFrames[I].Name        := Format('Frame_%d',[I]);
      fFrames[I].SetSubComponent(True);
      FreeNotification(fFrames[I]);
      fFrames[I].Linker      := self;
      fFrames[I].FrameIndex  := I;
      fFrames[I].Active      :=True;
    end;

    fActive := True;  //must stay here

    If assigned(fRenderer) then
       fRenderer.Active := True;

    If fActive then
    Begin
       If assigned(fOnEnabled) then
          fOnEnabled(self);
    End;

   Except
       On E:Exception do
       Begin
         fActive:=False;
         Raise;
       End;
   End;
end;

procedure TvgLinker.SetFramesInFlight(const Value: TvkUint32);
begin
  If fFrameCount=Value then exit;
  SetActiveState(False);
  fFrameCount := Value;
end;

procedure TvgLinker.SetRenderer(const Value: TvgRenderEngine);
begin
  If fRenderer = Value then exit;
  SetActiveState(False);

  If assigned(fRenderer) then
    fRenderer.Linker:=Nil;

  fRenderer := Value;

  If assigned(fRenderer) then
    fRenderer.Linker:=Self;

end;

procedure TvgLinker.SetRenderTarget(const Value: TvgRenderPassTarget);
begin
  if fRenderTarget=Value then exit;
  SetActiveState(False);
  fRenderTarget := Value;
end;

procedure TvgLinker.SetWindowIntf(const Value: IvgVulkanWindow);
begin
  If fWindowIntf = Value then exit;
  SetActiveState(False);

 Try
  If Assigned(fWindowIntf) and (fWindowIntf.Linker=self) then
     fWindowIntf.Linker := Nil;

  fWindowIntf           := Value;
  fSurface.fWindowIntf  := Value;

  If Assigned(fWindowIntf) and (fWindowIntf.Linker<>self) then
     fWindowIntf.Linker := Self;

 Except
   On E:Exception do
      fWindowIntf:=nil;
 End;

end;

procedure TvgLinker.SetUpCapabilities;

   Procedure SetUpQueSurfaceSupport(aQueFamily:TvgQueueFamily);
   Begin
     aQueFamily.fSupportSurface := fPhysicalDevice.VulkanPhysicalDevice.GetSurfaceSupport(aQueFamily.fQueueFamilyIndex,
                                                                                          fSurface.VulkanSurface);
   End;

begin
  Assert(assigned(fPhysicalDevice) , 'Device not assigned.');
  Assert(assigned(fPhysicalDevice.VulkanPhysicalDevice) , 'Vulkan Device not assigned');

  Assert(assigned(fSurface) , 'Device Surface link not set.');
  Assert(assigned(fSurface.VulkanSurface) , 'Vulkan Surface not assigned');

  Assert(assigned(fScreenDevice),'Screen Logical Device not created');
  Assert(assigned(fScreenDevice.fVulkanDevice),'Vulkan Screen Logical Device not created');

  SetUpQueSurfaceSupport(fScreenDevice.fUniversalQueue);
  SetUpQueSurfaceSupport(fScreenDevice.fPresentQueue);
  SetUpQueSurfaceSupport(fScreenDevice.fGraphicsQueue);
  SetUpQueSurfaceSupport(fScreenDevice.fComputeQueue);
  SetUpQueSurfaceSupport(fScreenDevice.fTransferQueue);

  fSurface.GetSurfaceCapabilities;

end;

procedure TvgLinker.SetUseThread(const Value: Boolean);
begin
  If fUseThread = Value then exit;
  SetActiveState(False);
  fUseThread := Value;

end;

procedure TvgLinker.SwapChainRebuild;
  Var I:Integer;
begin
  fRebuildNeeded := False;

  VulkanWaitIdle;

  If Length(fFrames)>0 then
  For I:= 0 to High(fFrames) do
    fFrames[I].Active := False;

  //FrameBuffersClear;

  fRenderer.Active := False;

  SetUpCapabilities;

  UpdateWindowSize;

  fSwapChain.RecreateSwapChain;

  fRenderer.Active := True;

//  FrameBuffersSetUp;

  If Length(fFrames)>0 then
  For I:= 0 to High(fFrames) do
    fFrames[I].Active := True;

  TriggerWindowRepaint;
end;

procedure TvgLinker.TriggerWindowRepaint;
begin
  VulkanPaint_Start;
end;

function TvgLinker.VulkanPaint_Cancel: Boolean;
begin
  Result      := True;
//  fRenderLock := False;

//  fFrames[fCurrentFrameIndex].ExecuteFrame;
  fFrames[fCurrentFrameIndex].PresentFrame;

  IncFrame(fCurrentFrameIndex,fNextFrameIndex);
end;

function TvgLinker.VulkanPaint_Finish: Boolean;
begin
  Result := False;

  fFrames[fCurrentFrameIndex].ExecuteFrame;
  fFrames[fCurrentFrameIndex].PresentFrame;
  IncFrame(fCurrentFrameIndex,fNextFrameIndex);

  If fRenderRequested then
  Begin
    VulkanPaint_Start;
    Result := True;
  End;

end;

function TvgLinker.VulkanPaint_Start: Boolean;
begin
  Result           := False;
  fRenderRequested := False;
(*
  If fRenderLock then
  Begin
    fRenderRequested := True;
    exit;
  end;
*)
  If fRebuildNeeded then
  Begin
    SwapChainRebuild;
    Result:=True;
    exit;
  End;

  If not fActive then exit;

  If Length(fFrames)>0 then
  Begin
  //  fRenderLock := True;
    fFrames[fCurrentFrameIndex].PrepareFrame;

    If not fUseThread then
      VulkanPaint_Finish;
  End;

  Result := True;
end;

procedure TvgLinker.VulkanWaitIdle;
begin
    Assert( assigned(fScreenDevice) , 'Screen Device not created');
    fScreenDevice.WaitIdle;
end;

procedure TvgLinker.FlagSwapChainRebuild;
begin
  fRebuildNeeded := True;
end;

{ TvgStencilOp }

constructor TvgStencilOp.Create(AOwner: TComponent);
begin
  inherited;

  self.fFailOp      := VK_STENCIL_OP_KEEP;
  self.fPassOp      := VK_STENCIL_OP_KEEP;
  self.fDepthFailOp := VK_STENCIL_OP_KEEP;
  self.fCompareOp   := VK_COMPARE_OP_NEVER;
  self.fCompareMask := 0;
  self.fWriteMask   := 0;
  self.fReference   := 0;
end;

procedure TvgStencilOp.DefineProperties(Filer: TFiler);
begin
  inherited;
  Filer.DefineProperty('StencilOpData', ReadData, WriteData, True);

end;

destructor TvgStencilOp.Destroy;
begin

  inherited;
end;

function TvgStencilOp.getActive: Boolean;
begin
  Result:=fActive;
end;

function TvgStencilOp.GetCompareMask: TvkUint32;
begin
   Result:= fCompareMask;
end;

function TvgStencilOp.GetCompareOp: TvgCompareOpBit;
begin
  Result:= GetVGCompareOp(fCompareOp);
end;

function TvgStencilOp.GetDepthFailOp: TvgStencilOpBit;
begin
  Result:= GetVGStencilOp(fDepthFailOp);
end;

function TvgStencilOp.GetFailOp: TvgStencilOpBit;
begin
  Result:= GetVGStencilOp(fFailOp);
end;

function TvgStencilOp.GetPassOp: TvgStencilOpBit;
begin
  Result:= GetVGStencilOp(fPassOp);
end;

function TvgStencilOp.GetReference: TvkUint32;
begin
   Result:= self.fReference;
end;

function TvgStencilOp.GetWriteMask: TvkUint32;
begin
   Result:= self.fWriteMask;
end;

procedure TvgStencilOp.ReadData(Reader: TReader);
begin
  Reader.ReadListBegin;
  fCompareMask:= ReadTvkUint64(Reader);
  fWriteMask:= ReadTvkUint64(Reader);
  fReference:= ReadTvkUint64(Reader);
  Reader.ReadListEnd;
end;

procedure TvgStencilOp.SetActive(const Value: Boolean);
begin
  If fActive = Value then exit;
  SetActiveState(Value);
end;

procedure TvgStencilOp.SetCompareMask(const Value: TvkUint32);
begin
  If IsZero(fCompareMask-Value) then exit;
  SetActiveState(False);
  fCompareMask := Value;
end;

procedure TvgStencilOp.SetCompareOp(const Value: TvgCompareOpBit);
  Var V: TVkCompareOp    ;
begin
  V:= GetVKCompareOp(Value);
  If fCompareOp=V then exit;
  SetActiveState(False);
  fCompareOp:=V;
end;

procedure TvgStencilOp.SetDepthFailOp(const Value: TvgStencilOpBit);
  Var V: TvkStencilOp    ;
begin
  V:= GetVKStencilOp(Value);
  If fDepthFailOp=V then exit;
  SetActiveState(False);
  fDepthFailOp:=V;
end;

procedure TvgStencilOp.SetDisabled;
 // Var G: TvgGraphicsPipeline;
Begin
  fActive:=False;
(*
  G:=GetGraphicsPipeline;
  If assigned(G) then
     G.Active:=False;
 *)
end;

procedure TvgStencilOp.SetEnabled(aComp:TvgBaseComponent=nil);
//  Var G: TvgGraphicsPipeline;
Begin
  fActive := True;
(*
  G:=GetGraphicsPipeline;
  If assigned(G) then
     G.Active:=True;
*)
end;

procedure TvgStencilOp.SetFailOp(const Value: TvgStencilOpBit);
  Var V: TvkStencilOp    ;
begin
  V:= GetVKStencilOp(Value);
  If fFailOp=V then exit;
  SetActiveState(False);
  fFailOp:=V;
end;

procedure TvgStencilOp.SetPassOp(const Value: TvgStencilOpBit);
  Var V: TvkStencilOp    ;
begin
  V:= GetVKStencilOp(Value);
  If fPassOp=V then exit;
  SetActiveState(False);
  fPassOp:=V;
end;

procedure TvgStencilOp.SetReference(const Value: TvkUint32);
begin
  If IsZero(fReference -Value) then exit;
  SetActiveState(False);
  fReference:=Value;
end;

procedure TvgStencilOp.SetWriteMask(const Value: TvkUint32);
begin
  If IsZero(fWriteMask -Value) then exit;
  SetActiveState(False);
  fWriteMask:=Value;
end;

procedure TvgStencilOp.WriteData(Writer: TWriter);
begin
  Writer.WriteListBegin;
  WriteTvkUint32(Writer, fCompareMask);
  WriteTvkUint32(Writer, fWriteMask);
  WriteTvkUint32(Writer, fReference);
  Writer.WriteListEnd;
end;
(*
{ TvgStencilOpsCol }

function TvgStencilOpsCol.Add: TvgStencilOp;
begin
  Result := TvgStencilOp(inherited Add);
end;

function TvgStencilOpsCol.AddItem(Item: TvgStencilOp; Index: Integer): TvgStencilOp;
begin
  if Item = nil then
    Result := TvgStencilOp.Create(self)
  else
    Result := Item;

  if Assigned(Result) then
  begin
    Result.Collection := Self;
    if Index < 0 then
      Index := Count - 1;
    Result.Index := Index;
  end;
end;

constructor TvgStencilOpsCol.Create(CollOwner: TvgGraphicsPipeline);
begin
  Inherited Create(TvgStencilOp);

  fComp:=CollOwner;
end;

function TvgStencilOpsCol.GetItem(Index: Integer): TvgStencilOp;
begin
  Result := TvgStencilOp(inherited GetItem(Index));
end;

function TvgStencilOpsCol.GetOwner: TPersistent;
begin
  Result:=fComp;
end;

function TvgStencilOpsCol.Insert(Index: Integer): TvgStencilOp;
begin
  Result := AddItem(nil, Index);
end;

procedure TvgStencilOpsCol.SetItem(Index: Integer; const Value: TvgStencilOp);
begin
  inherited SetItem(Index, Value);
end;

procedure TvgStencilOpsCol.Update(Item: TCollectionItem);
begin
  //inherited;

end;
*)
{ TvgVulkanAllocationManager }

function TvgVulkanAllocationManager.AllocationCallback(const Size,  Alignment: TVkSize; const Scope: TVkSystemAllocationScope): PVkVoid;
  Var I   : Integer;

begin

  GetMem(Result, Size);

//  R.AlignedMem := Pointer((NativeInt(R.OriginalMem) and $FFFFFFF0) + Alignment);
//  Result := R.AlignedMem;

  If  (fAllocatedList.Count + 10 >= fAllocatedList.Capacity) then
     fAllocatedList.Capacity := fAllocatedList.Capacity + 200;

  If not fAllocatedList.BinarySearch(Result, I )  then
     fAllocatedList.Insert(I,Result);

end;

constructor TvgVulkanAllocationManager.Create;
begin
 inherited Create;

 fAllocatedList  := TList<Pointer>.create;
 fAllocatedList.Capacity := 200;
(*
 fComparer       := TComparer<TvgAllocationRecord>.Construct(
                                                  function(const Left, Right: TvgAllocationRecord): Integer
                                                  begin
                                                     If PByte(Left.AlignedMem)< PByte(Right.AlignedMem) then Result:=-1
                                                     else
                                                     If PByte(Left.AlignedMem)< PByte(Right.AlignedMem) then Result:=1
                                                     else
                                                     Result:=0;
                                                  end ) ;
  *)
end;

destructor TvgVulkanAllocationManager.Destroy;
begin
  If  fAllocatedList.Count>0 then
     FreeAllMemory;

  If assigned(fAllocatedList) then
    FreeAndNil(fAllocatedList);

  inherited;
end;

procedure TvgVulkanAllocationManager.FreeAllMemory;
  Var I : Integer;
begin
  For I:=0 to fAllocatedList.Count-1 do
     FreeMem(fAllocatedList.Items[I]);
  fAllocatedList.Clear;
end;

procedure TvgVulkanAllocationManager.FreeCallback(const Memory: PVkVoid);
  Var I   : Integer;

begin

    If fAllocatedList.BinarySearch(Memory,I) then
    Begin
      Try
        FreeMem(Memory);
        fAllocatedList.Delete(I);
      Except
     //    On E:Exception do   handles bad call should never occur

      End;
    end;

end;

function TvgVulkanAllocationManager.ReallocationCallback( const Original: PVkVoid; const Size, Alignment: TVkSize;
                                                          const Scope: TVkSystemAllocationScope): PVkVoid;

  Var I:Integer;
begin
  Result  := Original;

  If fAllocatedList.BinarySearch(Result, I ) then
       fAllocatedList.Delete(I) ;

  ReallocMem(Result, Size);

  If not fAllocatedList.BinarySearch(Result,I) then
       fAllocatedList.Insert(I,Result);
end;

{ TvgScreenRenderDevice }

constructor TvgScreenRenderDevice.Create(AOwner: TComponent);
begin
  inherited;
  Name  :='Screen_Device';

  fMSAA := VK_SAMPLE_COUNT_1_BIT;
end;

destructor TvgScreenRenderDevice.Destroy;
begin
  SetActiveState(False);
  fLinker:=nil;
  inherited;
end;

function TvgScreenRenderDevice.GetLinker: TvgLinker;

begin
  Result:=fLinker;
end;

function TvgScreenRenderDevice.IsExtensionEnabled(aName: String): Boolean;
  Var I:Integer;
      E:TvgExtension;
begin
  Result := False;
  If aName='' then exit;
  If fExtensions.Count=0 then exit;

  For I:=0 to fExtensions.count-1 do
  Begin
    E :=  fExtensions.Items[I];
    If (CompareText(aName, String(E.fExtensionName))=0) and (E.fEnabled)  then
    Begin
      Result:=True;
      Exit;
    end;
  End;
end;

procedure TvgScreenRenderDevice.Notification(AComponent: TComponent;  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);

  Case Operation of
     opInsert : Begin
                  If aComponent=self then exit;
                  If NotificationTestON and Not (csDesigning in ComponentState) then exit ;      //don't mess with links at runtime

                  If (aComponent is TvgLinker) and not assigned(fLinker) then
                  Begin
                    SetLinker(TvgLinker(aComponent));
                  End;

                End;

     opRemove : Begin

                  If (aComponent is TvgLinker) and (TvgLinker(aComponent)=fLinker) then
                  Begin
                    SetLinker(Nil);
                  End;

                end;
  End;

end;

procedure TvgScreenRenderDevice.SetDisabled;
begin

  If assigned(fVulkanDevice) then
     FreeAndNil(fVulkanDevice);

  Inherited;
end;

procedure TvgScreenRenderDevice.SetEnabled(aComp:TvgBaseComponent=nil);

Begin
  Assert(assigned(fPhysicalDevice),'Physical Device not connected');
  Assert(assigned(fPhysicalDevice.VulkanPhysicalDevice),'Physical Device not Active');
  Assert(assigned(fInstance),'Instance not connected');
  Assert(assigned(fInstance.VulkanInstance),'Instance not Active');
  Assert(Assigned(fLinker),'Window Link not assigned');
  Assert(Assigned(fLinker.Surface),'Surface not assigned');
  Assert(Assigned(fLinker.Surface.fVulkanSurface),'Vulkan Surface not created.');


  fVulkanDevice       := TpvVulkanDevice.create(fInstance.VulkanInstance,
                                                fPhysicalDevice.VulkanPhysicalDevice,
                                                fLinker.Surface.fVulkanSurface,
                                                fInstance.AllocationManager,
                                                True)  ;

  If Assigned(fVulkanDevice) then
  Begin
    SetUpExtensions;
    SetUpLayers;

    fVulkanDevice.AddQueues(Nil);     //need to check  seems OK

    fVulkanDevice.OnBeforeDeviceCreate := OnDeviceCreateEvent; //setup features during initialization
    fVulkanDevice.Initialize;

    SetUpQueueFamilies;

    fActive := True;    //must stay here

  end;

end;

procedure TvgScreenRenderDevice.SetPhysicalDevice( const Value: TvgPhysicalDevice);
begin
  If fPhysicalDevice=Value then exit;

  inherited;

  If assigned(fPhysicalDevice) then
     SetUpMSAA;

end;

procedure TvgScreenRenderDevice.SetUpDynamicStateExtensions;
begin
  If not assigned(fLinker) then exit;
  if not assigned(fPhysicalDevice) then exit;
  if not assigned(fPhysicalDevice.fVulkanPhysicalDevice) then exit;

  //need to used DEVICE version NOT instance version
  Assert(assigned(fExtensions), 'Extensions collection not created');
  Assert((fExtensions.Count>0),'No extensions defined');

 // fVulkanLink.fGraphicsPipe.SetUpDynamicStateExtensions(fExtensions, fPhysicalDevice.fPhysicalDevice.Properties.apiVersion);
end;

procedure TvgScreenRenderDevice.SetUpExtensions;
  Var I:Integer;
      E:TvgExtension;
      B:Boolean;
      ES:String;

   Function IsExtensionAvailable(aExt : TvgExtension):Boolean;
     Var J:Integer;
         S1:String;
         AE: TpvVulkanAvailableExtension;
   Begin
     Result:=False;

     If not assigned(fPhysicalDevice) then exit;
     S1:=Trim(String(aExt.fExtensionName));
     J := fPhysicalDevice.VulkanPhysicalDevice.AvailableExtensionNames.IndexOf(S1);
     If J=-1 then exit;
     AE:=fPhysicalDevice.VulkanPhysicalDevice.AvailableExtensions[J];
     Result:= (aExt.fSpecVersion <= AE.SpecVersion);
   End;

   Procedure DeleteNotRequired;
     Var J:Integer;
         EI:TvgExtension;
   Begin
     If (csDesigning in ComponentState) then exit;

     For J:=fExtensions.Count-1 downto 0 do
     Begin
       EI:= TvgExtension(fExtensions.Items[J]);
       If EI.fExtMode=VGE_NOT_REQUIRED then
          fExtensions.Delete(J);
     End;
   End;

   Var BI:Boolean;
begin
   Assert( assigned(fInstance),'Instance not connected');
   Assert(assigned(fInstance.VulkanInstance),'Instance not active');

   If not assigned(fExtensions) then  exit;

   Assert( assigned( fPhysicalDevice),'Vulkan Physical Device not connected') ;

   If not assigned(fPhysicalDevice.VulkanPhysicalDevice) then
   Begin
     fPhysicalDevice.SetEnabled;
     BI:=True;
   end else
     BI:=False;

   Assert(assigned(fPhysicalDevice.VulkanPhysicalDevice),'Vulkan Device not available') ;

   DeleteNotRequired;       //delete not required design time layers
//   BuildALLExtensions;      //build any new extensions in current hardware/platform

   If assigned(fOnExtensionSetup) then
      fOnExtensionSetup(fExtensions);    //run time can update required extensions available on current hardware

   BuildALLExtensions;   //build again in case render to screen layers not included

   SetUpScreenExtensions;//Must stay here will handle RenderToScreen and NOT RenderToScreen
   SetUpDynamicStateExtensions; //Must stay here will handle Dynamic State extension requirements

   DeleteNotRequired;    //tidy up before creating the instance

   For I:=0 to fExtensions.count-1 do
   Begin
     E:= TvgExtension(fExtensions.Items[I]);
     e.fEnabled := False;
     If (E.fExtMode=VGE_NOT_REQUIRED) then  continue;

     B := IsExtensionAvailable(E)  ;

     Case E.fExtMode of
       //  vglNotRequired:;  //do not need to initialize default
          VGE_MUST_HAVE  :Begin
                          if Not B then
                          Begin
                             ES:= Format('%s (%s) %s',['Must have instance extension (', String(E.ExtensionName), ') NOT available on this hardware.']);
                             raise EvgVulkanResultException.Create(VK_ERROR_EXTENSION_NOT_PRESENT, ES);
                          end else
                          Begin
                             fVulkanDevice.EnabledExtensionNames.Add(String(E.ExtensionName));
                             E.fEnabled:=True;
                          end;
                        end;     //Instance initialization MUST have this layer
          VGE_OPTIONAL  :If B then
                        Begin
                          fVulkanDevice.EnabledExtensionNames.Add(String(E.ExtensionName));     //Instance may have the layer
                          E.fEnabled:=True;
                        end;
        VGE_ON_VALIDATION:If B and fInstance.Validation then
                        Begin
                          fVulkanDevice.EnabledLayerNames.Add(String(E.ExtensionName));
                          E.fEnabled:=True;
                        end;

     end;
   End;

   If BI then SetActiveState(False);

end;

procedure TvgScreenRenderDevice.SetUpLayers;
begin
  Inherited;
end;

procedure TvgScreenRenderDevice.SetUpMSAA;
  Var counts : TVkSampleCountFlags ;
      B1,B2:Boolean;
begin
  B1:=False;
  B2:=False;

 Try
  Assert(assigned(fPhysicalDevice) , 'Physical Device not assigned.');
  Assert(assigned(fPhysicalDevice.fInstance) , 'Instance not assigned.');

  If not fPhysicalDevice.fInstance.Active then
  Begin
    fPhysicalDevice.fInstance.SetDesigning;
    B1:=True;
  End;

  If not  fPhysicalDevice.Active then
  Begin
    fPhysicalDevice.SetDesigning;
    B2:=True;
  End;

  Assert(assigned(fPhysicalDevice.VulkanPhysicalDevice),'Physical Device not Active');

  Counts := fPhysicalDevice.VulkanPhysicalDevice.Properties.limits.framebufferColorSampleCounts and
            fPhysicalDevice.VulkanPhysicalDevice.Properties.limits.framebufferDepthSampleCounts;

  If (TVkSampleCountFlags(VK_SAMPLE_COUNT_64_BIT) and Counts = TVkSampleCountFlags(VK_SAMPLE_COUNT_64_BIT)) then fMSAA := VK_SAMPLE_COUNT_64_BIT  else
  If (TVkSampleCountFlags(VK_SAMPLE_COUNT_32_BIT) and Counts = TVkSampleCountFlags(VK_SAMPLE_COUNT_32_BIT)) then fMSAA := VK_SAMPLE_COUNT_32_BIT  else
  If (TVkSampleCountFlags(VK_SAMPLE_COUNT_16_BIT) and Counts = TVkSampleCountFlags(VK_SAMPLE_COUNT_16_BIT)) then fMSAA := VK_SAMPLE_COUNT_16_BIT  else
  If (TVkSampleCountFlags(VK_SAMPLE_COUNT_8_BIT)  and Counts = TVkSampleCountFlags(VK_SAMPLE_COUNT_8_BIT))  then fMSAA := VK_SAMPLE_COUNT_8_BIT  else
  If (TVkSampleCountFlags(VK_SAMPLE_COUNT_4_BIT)  and Counts = TVkSampleCountFlags(VK_SAMPLE_COUNT_4_BIT))  then fMSAA := VK_SAMPLE_COUNT_4_BIT  else
  If (TVkSampleCountFlags(VK_SAMPLE_COUNT_2_BIT)  and Counts = TVkSampleCountFlags(VK_SAMPLE_COUNT_2_BIT))  then fMSAA := VK_SAMPLE_COUNT_2_BIT ;

  If B2 then
     fPhysicalDevice.SetActiveState(False);

  If B1 then
     fPhysicalDevice.fInstance.SetActiveState(False);
 Except

 End;
end;

procedure TvgScreenRenderDevice.SetUpScreenExtensions;
     Var
         E:TvgExtension;
         I:Integer;
         B1:Boolean;


   Function TestNames(aName:String):Boolean;
   Begin
     Result:=False;
     If (CompareText(String(aName),String(VK_KHR_SWAPCHAIN_EXTENSION_NAME))=0)                   then result:=True;
     If (CompareText(String(aName),String(VK_KHR_GET_MEMORY_REQUIREMENTS_2_EXTENSION_NAME))=0)   then result:=True;
     If (CompareText(String(aName),String(VK_KHR_DEDICATED_ALLOCATION_EXTENSION_NAME))=0)        then result:=True;
     If (CompareText(String(aName),String(VK_EXT_SHADER_VIEWPORT_INDEX_LAYER_EXTENSION_NAME))=0) then result:=True;
     If (CompareText(String(aName),String(VK_EXT_HOST_QUERY_RESET_EXTENSION_NAME))=0)            then result:=True;
     If (CompareText(String(aName),String(VK_EXT_FULL_SCREEN_EXCLUSIVE_EXTENSION_NAME))=0)       then result:=True;

     If (CompareText(String(aName),String(VK_EXT_EXTENDED_DYNAMIC_STATE_EXTENSION_NAME))=0)      then result:=True;

  //   If (CompareText(String(aName),String())=0) then result:=True;

   End;
Begin

     B1:=False;

     For I:=0 to fExtensions.Count-1 do
     Begin
       E := TvgExtension(fExtensions.Items[I]);

       If TestNames(String(E.ExtensionName))  then
         Begin
            E.fExtMode:=VGE_MUST_HAVE;
            B1:=True;
         End;
     End;

     If not B1 then
        raise EvgVulkanResultException.Create(VK_ERROR_EXTENSION_NOT_PRESENT, 'Required Screen Display Extension NOT found');
end;

Function TvgScreenRenderDevice.TurnOnExtension(aName: String):Boolean;
     Var
         E:TvgExtension;
         I:Integer;

   Function TestNames(TestName:String):Boolean;
   Begin
     If (CompareText(aName,TestName)=0)  then
       result := True
     else
       Result := False;
   End;

Begin
  Assert((aName<>''),'Name of extension NOT provided');

     Result:=False;

     For I:=0 to fExtensions.Count-1 do
     Begin
       E := TvgExtension(fExtensions.Items[I]);

       If TestNames(String(E.ExtensionName))  then
         Begin
            E.fExtMode:=VGE_MUST_HAVE;
            Result:=True;
         End;
     End;

end;

procedure TvgScreenRenderDevice.SetLinker(const Value: TvgLinker);
begin
  If fLinker=Value then exit;
  SetActiveState(False);
  fLinker:=Value;

end;

procedure TvgScreenRenderDevice.WaitIdle;
begin
  If not assigned(fVulkanDevice) then exit;
  Try
    fVulkanDevice.WaitIdle;
  Except
      On E:Exception do
      Begin


      End;
  End;
end;

{ TvgShaderModule }

constructor TvgShaderModule.Create(AOwner: TComponent);
begin
  inherited;
  fFileName:='';
  fShaderModuleHandle := VK_NULL_HANDLE;
  fMainName := 'main';
end;

destructor TvgShaderModule.Destroy;
begin
  SetActiveState(False);

  inherited;
end;

function TvgShaderModule.GetActive: Boolean;
begin
  Result:=fActive;
end;

function TvgShaderModule.GetFileName: String;
begin
  Result:= fFileName;
end;

function TvgShaderModule.GetMainName: TvkCharString;
begin
  Result := fMainName;
end;

procedure TvgShaderModule.SetActive(const Value: Boolean);
begin
   If fActive = Value then exit;
   SetActiveState(Value);
end;

procedure TvgShaderModule.SetDesigning;
begin
end;

procedure TvgShaderModule.SetDevice(aDevice: TvgScreenRenderDevice);
begin
  If fDevice=aDevice then exit;

  SetActiveState(False);
  fDevice := aDevice;
end;

procedure TvgShaderModule.SetDisabled;
begin
  fActive:=False;

  If assigned(fDevice) and assigned(fDevice.VulkanDevice) and (fDevice.Active) then
    fDevice.VulkanDevice.Commands.DestroyShaderModule(fDevice.VulkanDevice.Handle, fShaderModuleHandle, nil);

  fShaderModuleHandle:= VK_NULL_HANDLE;

  If assigned(fData) then
  Begin
    FreeMem(fData);
    fData:=nil;
    fDataAligned:=nil;
    fDataSize:=0;
  End;
end;

procedure TvgShaderModule.SetEnabled(aComp:TvgBaseComponent=nil);
  Var FileStream : TFileStream;
      SHInfo     : TVkShaderModuleCreateInfo ;
      FileS      : String;
begin

  fShaderModuleHandle := VK_NULL_HANDLE;
  fActive             := False;

  If (fFileName='') then exit;
  FileS := fFileName;                       //use file name

  If not FileExists(FileS) and (ShaderFolderPath<>'') then
    FileS := ShaderFolderPath + ExtractFileName(fFileName);   //else try with folder path

  If not FileExists(FileS) then
    FileS := GetCurrentDir + '\' + ExtractFileName(fFileName);  //else try the current directory

  If not FileExists(FileS) and (ExecutableFolderPath<>'') then
    FileS := ExecutableFolderPath + ExtractFileName(fFileName);  //else try the current directory

  Assert(FileExists(FileS),'Cannot find specified Shader File : '+ fFileName);   //give up

  FileStream:=TFileStream.Create(FileS,fmOpenRead or fmShareDenyWrite);
    try

     fData        := nil;
     fDataAligned := nil;

     fDataSize:=FileStream.Size;
     if (fDataSize and 3)<>0 then
        inc(fDataSize,4-(fDataSize and 3));

      GetMem(fData,fDataSize+4);
      fDataAligned:=fData;
      if (TvkPtrUInt(fDataAligned) and 3)<>0 then
          inc(TvkPtrUint(fDataAligned),4-(TvkPtrUint(fDataAligned) and 3));

       if FileStream.Seek(0,soBeginning)<>0 then
        raise EInOutError.Create('Stream seek error');

       if FileStream.Read(fData^,FileStream.Size)<>FileStream.Size then
        raise EInOutError.Create('Stream read error');

       FillChar(SHInfo,SizeOf(SHInfo),#0);
       SHInfo.sType  := VK_STRUCTURE_TYPE_SHADER_MODULE_CREATE_INFO;
       SHInfo.codeSize := fDataSize;
       SHInfo.pCode    := fData;

       VulkanCheckResult(fDevice.VulkanDevice.Commands.CreateShaderModule(fDevice.VulkanDevice.Handle,
                                                                          @SHInfo,
                                                                          Nil,
                                                                          @fShaderModuleHandle));
       fActive := True;

     finally
       FileStream.Free;
     end;
end;

procedure TvgShaderModule.SetFileName(const Value: String);
begin
  If CompareText(Value,fFileName)<>0 then
     SetActiveState(False);
  fFileName:=Trim(Value);
end;

procedure TvgShaderModule.SetMainName(const Value: TvkCharString);
begin
  If CompareText(String(Value),String(fMainName))=0 then exit;
  SetActiveState(False);
  fMainName := Value;
end;

{ TvgFrame }

procedure TvgFrame.ResetPrepareCommandBuffer;
  Var VR:TVkResult;
      I :Integer;
begin
  If not assigned(fFrameGraphicCommandPool) then exit;

  Assert(((CP_RESET_COMMAND_BUFFER in fFrameGraphicCommandPool.QueueCreateFlags)=True),'Command Pool not in RESET mode');

  If assigned(fFramePrepareCommandBuffer) and (CP_RESET_COMMAND_BUFFER in fFrameGraphicCommandPool.QueueCreateFlags)  then
    fFramePrepareCommandBuffer.Reset;
end;

constructor TvgFrame.Create(AOwner: TComponent);
begin
  inherited;

  fFrameGraphicCommandPool  := TvgCommandBufferPool.Create(self);

  fFrameGraphicCommandPool.QueueFamilyType  := VGT_GRAPHIC;  //IMPORTANT
  fFrameGraphicCommandPool.QueueCreateFlags := [CP_TRANSIENT,
                                                CP_RESET_COMMAND_BUFFER]; //important for RESET

end;

destructor TvgFrame.Destroy;
begin
  SetActiveState(False);

  If assigned(fFrameGraphicCommandPool) then
    FreeAndNil( fFrameGraphicCommandPool);

  inherited;
end;

procedure TvgFrame.ExecuteFrame;
  {$IFDEF TIMINGON}
  Var StopWatch  : TStopwatch;
  {$ENDIF}
begin

  Assert(fActive ,'Frame not active' );
//  Assert(assigned(fGraphicQueue) ,'Graphic Queue not assigned' );

  Assert(assigned(fLinker) ,'Window Link not defined' );
  Assert(Assigned(fLinker.fRenderer),'Vulkan Renderer not assigned.');

  Assert((fLinker.fRenderer.Active=True),'Vulkan Renderer not ACTIVE.');

  Assert(Assigned(fFramePrepareCommandBuffer),'Prepare CommandBuffer NOT created');

  {$IFDEF TIMINGON}
  StopWatch   := TStopwatch.StartNew;
  {$ENDIF}

  Try

    fGraphicQueue := fFrameGraphicCommandPool.Queue[fFrameIndex]; // get the queue to match Frame Index


    fFramePrepareCommandBuffer.Execute(fGraphicQueue,
                                TVkPipelineStageFlags(VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT),
                                fImageAvailableSemaphore,     //wait for image
                                fRenderingFinishedSemaphore,  //signal when finished
                                false);//True);//fWaitToExecute);              //wait for commend to complete  default is FALSE
                                //may be able to NOT wait???
  Finally
  End;

  {$IFDEF TIMINGON}
     Stopwatch.Stop;
     fExecuteFrameTime := StopWatch.ElapsedMilliseconds;
  {$ENDIF}


end;

function TvgFrame.GetActive: Boolean;
begin
  Result:=fActive;
end;

function TvgFrame.GetFrameBufferHandle: TVkFramebuffer;
begin
  Result := VK_NULL_HANDLE;

  if NOT assigned(fFrameImageBuffer) then exit;
  if not (fFrameImageBuffer.Active) then  exit;


  Assert(Assigned(fFrameImageBuffer.FrameBufferAttachment),'Frame Buffer Image Attachment NOT available');
  Assert(Assigned(fFrameImageBuffer.FrameBufferAttachment.ImageView),'Frame Buffer Image Attachment ImageView NOT available');

  Result := fFrameImageBuffer.FrameBufferAttachment.ImageView.Handle;

end;

function TvgFrame.GetLinker: TvgLinker;
begin
  Result := fLinker;
end;

function TvgFrame.IsFrameLocked: Boolean;
begin
  Result := False;

end;

procedure TvgFrame.PrepareFrame;
  {$IFDEF TIMINGON}
  Var StopWatch  : TStopwatch;
  {$ENDIF}
begin
  Assert(fActive ,'Frame not active' );

  Assert(assigned(fLinker) ,'Window Link not defined' );
  Assert(Assigned(fLinker.fRenderer),'Vulkan Renderer not assigned.');

  Assert((fLinker.fRenderer.Active=True),'Vulkan Renderer not ACTIVE.');

//  Assert(Assigned(fFramePrepareCommandBuffer),'Prepare CommandBuffer NOT set');

  {$IFDEF TIMINGON}
  StopWatch   := TStopwatch.StartNew;
  {$ENDIF}

    fImageIndex   := 0;
 (*
    ResetPrepareCommandBuffer;

    If assigned(fLinker.fRenderer) then
                fLinker.fRenderer.RenderAFrame_Start(fImageIndex, self) ;
                //NO need to be inside the Aquire/Present loop
  *)
    //Execute Frame and PresentFrame will complete this action


  If fLinker.SwapChain.AcquireNextImage(fImageAvailableSemaphore) then
  Begin

    fImageIndex   := fLinker.SwapChain.VulkanSwapChain.CurrentImageIndex;

    fGraphicQueue := fFrameGraphicCommandPool.Queue[-1]; //graphic queue based on Pool type

    if not assigned(fFramePrepareCommandBuffer) then
    Begin
       fFramePrepareCommandBuffer  := fFrameGraphicCommandPool.RequestCommand(0,0,CB_PRIMARY, True, [BU_SIMULTANEOUS_USE_BIT]);
       Assert(Assigned(fFramePrepareCommandBuffer),'Command not assigned');
       fFramePrepareCommandBuffer.Active   := True;
    End else
       ResetPrepareCommandBuffer;

    If assigned(fLinker.fRenderer) then
                fLinker.fRenderer.RenderAFrame_Start(fImageIndex, self) ;
                //needs to be inside the Aquire/Present loop

    //PresentFrame will complete this action
  end else
  Begin
    //aquire fails

  End;


  {$IFDEF TIMINGON}
     Stopwatch.Stop;
     fPrepareFrameTime := StopWatch.ElapsedMilliseconds;
  {$ENDIF}

end;

procedure TvgFrame.PresentFrame;
  {$IFDEF TIMINGON}
  Var StopWatch  : TStopwatch;
  {$ENDIF}
begin

  Assert(fActive ,'Frame not active' );
  Assert(assigned(fGraphicQueue) ,'Graphic Queue not assigned' );

  Assert(assigned(fLinker) ,'Window Link not defined' );
  Assert(Assigned(fLinker.SwapChain.VulkanSwapChain),'Vulkan Swap Chain not created.');
  Assert(Assigned(fLinker.fRenderer),'Vulkan Renderer not assigned.');

  Assert((fLinker.fRenderer.Active=True),'Vulkan Renderer not ACTIVE.');

  {$IFDEF TIMINGON}
  StopWatch   := TStopwatch.StartNew;
  {$ENDIF}

  Try

//  If fLinker.SwapChain.AcquireNextImage(fImageAvailableSemaphore) then
  Begin
     // need to copy Image to Screen using Command Buffer, RenderPass and GraphicPipe

    fLinker.SwapChain.QueuePresent(fGraphicQueue, fRenderingFinishedSemaphore);
  end ;

  {$IFDEF TIMINGON}
     Stopwatch.Stop;
     fPresentFrame := StopWatch.ElapsedMilliseconds;
  {$ENDIF}

  Finally
   // fFrameLock := False;
  End;
end;

procedure TvgFrame.SetActive(const Value: Boolean);
begin
  If fActive = Value then exit;
  SetActiveState(Value) ;
end;

procedure TvgFrame.SetDisabled;
begin

  fActive:=False;

  ResetPrepareCommandBuffer;

  if assigned(fFrameImageBuffer) then
     FreeAndNil(fFrameImageBuffer);

  If assigned(fFrameGraphicCommandPool) then
     fFrameGraphicCommandPool.Active := False;

  If assigned(fImageAvailableSemaphore) then
     FreeAndNil(fImageAvailableSemaphore);

  If assigned(fRenderingFinishedSemaphore) then
     FreeAndNil(fRenderingFinishedSemaphore);

end;

procedure TvgFrame.SetEnabled(aComp: TvgBaseComponent);
begin
  fActive:=False;

  Assert(assigned(fLinker),'Vulkan Link not assigned');
  Assert(assigned(fLinker.ScreenDevice),'Vulkan Link not assigned a  ScreenDevice');
  Assert(assigned(fLinker.SwapChain),'Vulkan Link not assigned a  SwapChain');
  Assert(assigned(fLinker.ScreenDevice.VulkanDevice),'Screen Device not active');
  Assert(assigned(fLinker.Renderer),'Renderer not assigned');

  Assert(assigned(fFrameGraphicCommandPool),'Command Pool not assigned');

  fFrameGraphicCommandPool.Device := fLinker.ScreenDevice;
  fFrameGraphicCommandPool.Active := True;

  fFrameGraphicCommandPool.SetUpBufferArrays(1,1);

  fImageAvailableSemaphore   := TpvVulkanSemaphore.Create(fLinker.ScreenDevice.VulkanDevice, 0);
  fRenderingFinishedSemaphore:= TpvVulkanSemaphore.Create(fLinker.ScreenDevice.VulkanDevice, 0);

  if fLinker.RenderTarget=RT_FRAME then
  Begin

    fFrameImageBuffer             := TvgResourceImageBuffer.Create(self);
    fFrameImageBuffer.Name        := Format('Frame_Buffer_%d',[fFrameIndex]);
    fFrameImageBuffer.Linker      := fLinker;
    fFrameImageBuffer.ImageMode   := imColour;
    fFrameImageBuffer.ImageWidth  := fLinker.SwapChain.ImageWidth;
    fFrameImageBuffer.ImageHeight := fLinker.SwapChain.ImageHeight;
    fFrameImageBuffer.Format      := GetVGFormat(fLinker.ImageFormat); //OK
    fFrameImageBuffer.Samples     := COUNT_01_BIT;
    fFrameImageBuffer.Usage       := [IU_COLOR_ATTACHMENT_BIT,
                                      IU_TRANSFER_SRC_BIT];

                     //< Can be used as off screen render target
    fFrameImageBuffer.Active := True;
  End;

  fActive := True;
end;

procedure TvgFrame.SetFrameIndex(const Value: TvkUint32);
begin
  If fFrameIndex=Value then exit;
  fFrameIndex := Value;
end;

procedure TvgFrame.SetLinker(const Value: TvgLinker);
begin
  If fLinker=Value then exit;
  SetActiveState(False);
  fLinker := Value;

  If assigned(fFrameGraphicCommandPool)  then
  Begin
     If  assigned(fLinker) then
        fFrameGraphicCommandPool.Device := fLinker.ScreenDevice
     else
        fFrameGraphicCommandPool.Device := nil;
  End;
end;

procedure TvgFrame.SetWaitToExecute(const Value: Boolean);
begin
  if fWaitToExecute=Value then exit;
  SetActiveState(False);
  fWaitToExecute := Value;
end;
 (*
procedure TvgFrame.WaitIdle; check
  Var
     VR : TVkResult;
begin
  If not fActive then exit;

  Assert(assigned(fLinker) ,'Window Link not defined' );
  Assert(assigned(fLinker.SwapChain) ,'Window Swap Chain not defined' );
  Assert(Assigned(fLinker.SwapChain.VulkanSwapChain),'Vulkan Swap Chain not created.');
  Assert(Assigned(fFramePrepareCommandBuffer),'Command Buffer not assigned');

end;
 *)
{ TvgVertexInputState }

constructor TvgVertexInputState.Create(AOwner: TComponent);
begin
  fVertexBindingDescs   := TvgVertexBindingDescs.Create(self);
  fVertexAttributeDescs := TvgVertexAttributeDescs.Create(self);

  inherited;
end;

destructor TvgVertexInputState.Destroy;
begin
  SetActiveState(False) ;

  If Assigned(fVertexBindingDescs) then FreeAndNil(fVertexBindingDescs) ;
  If Assigned(fVertexAttributeDescs) then FreeAndNil(fVertexAttributeDescs) ;

  inherited;

end;

function TvgVertexInputState.GetActive: Boolean;
begin
  Result:=fActive;
end;

function TvgVertexInputState.GetVertexAttributeDescs: TvgVertexAttributeDescs;
begin
  Result:= fVertexAttributeDescs;
end;

function TvgVertexInputState.GetVertexBindingDescs: TvgVertexBindingDescs;
begin
  Result := fVertexBindingDescs;
end;

procedure TvgVertexInputState.SetActive(const Value: Boolean);
begin
  If fActive = Value then exit;
  SetActiveState(Value);
end;

procedure TvgVertexInputState.SetDisabled;
begin
  fActive := False;

  SetLength(fBindingDesc,0);
  SetLength(fAttributeDesc,0);

end;

procedure TvgVertexInputState.SetEnabled(aComp: TvgBaseComponent);
   Procedure SetUpBinding;
     Var B:TvgVertexBindingDesc;
   Begin
     If fVertexBindingDescs.Count>0 then
     Begin
       SetLength(fBindingDesc, fVertexBindingDescs.Count);
       FillChar(fBindingDesc[0],SizeOf(TVkVertexInputBindingDescription) * fVertexBindingDescs.Count,#0);
       B := fVertexBindingDescs.Items[0];
       fBindingDesc[0].binding   := B.fBinding;
       fBindingDesc[0].stride    := B.fStride;
       fBindingDesc[0].inputRate := B.fInputRate;
     End;
   End;

   Procedure SetUpAttributes;
     Var A:TvgVertexAttributeDesc;
         I:Integer;
   Begin
     If  fVertexAttributeDescs.Count>0 then
     Begin
       SetLength(fAttributeDesc, fVertexAttributeDescs.Count);
       FillChar(fAttributeDesc[0],SizeOf(TVkVertexInputAttributeDescription) * fVertexAttributeDescs.Count,#0);
       For I:=0 to fVertexAttributeDescs.Count-1 do
       Begin
         A :=fVertexAttributeDescs.Items[I];
         fAttributeDesc[I].location   := A.fLocation;
         fAttributeDesc[I].binding    := A.fBinding;
         fAttributeDesc[I].format     := A.fFormat;
         fAttributeDesc[I].offset     := A.fOffset;
       End;
     End;
   End;
begin
  fActive := True;

  FillChar(fvertexInputInfo,SizeOf( TVkPipelineVertexInputStateCreateInfo),#0);
  fvertexInputInfo.sType := VK_STRUCTURE_TYPE_PIPELINE_VERTEX_INPUT_STATE_CREATE_INFO;
  fvertexInputInfo.pNext := nil;
  fvertexInputInfo.flags := 0;

  If fVertexBindingDescs.Count>0 then
  Begin
    SetUpBinding;
    fvertexInputInfo.vertexBindingDescriptionCount   := fVertexBindingDescs.Count;
    fvertexInputInfo.pVertexBindingDescriptions      := @fBindingDesc[0];
  end;

  If fVertexAttributeDescs.Count>0 then
  Begin
    SetUpAttributes;
    fvertexInputInfo.vertexAttributeDescriptionCount := fVertexAttributeDescs.Count;
    fvertexInputInfo.pVertexAttributeDescriptions    := @fAttributeDesc[0];
  end;
end;

procedure TvgVertexInputState.SetVertexAttributeDesc( const Value: TvgVertexAttributeDescs);
begin
  If not assigned(Value) then exit;
  SetActiveState(False);
  fVertexAttributeDescs.Clear;
  fVertexAttributeDescs.Assign(Value);
end;

procedure TvgVertexInputState.SetVertexBindingDesc( const Value: TvgVertexBindingDescs);
begin
  If not assigned(Value) then exit;
  SetActiveState(False);
  fVertexBindingDescs.Clear;
  fVertexBindingDescs.Assign(Value);
end;

{ TvgTessellationState }

constructor TvgTessellationState.Create(AOwner: TComponent);
begin
  inherited;

end;

procedure TvgTessellationState.DefineProperties(Filer: TFiler);
begin
  inherited;
  Filer.DefineProperty('TessellationStateData', ReadData, WriteData, True);
end;

destructor TvgTessellationState.Destroy;
begin
  inherited;
end;

function TvgTessellationState.GetActive: Boolean;
begin
   Result:=fActive;
end;

function TvgTessellationState.GetPatchControlPoints: TvkUint32;
begin
  Result := fPatchControlPoints;
end;

procedure TvgTessellationState.ReadData(Reader: TReader);
begin
  Reader.ReadListBegin;
  fPatchControlPoints:= ReadTvkUint32(Reader);
  Reader.ReadListEnd;
end;

procedure TvgTessellationState.SetActive(const Value: Boolean);
begin
  If fActive = Value then exit;
  SetActiveState(Value);
end;

procedure TvgTessellationState.SetDisabled;
begin
  fActive := False;
end;

procedure TvgTessellationState.SetEnabled(aComp: TvgBaseComponent);
begin
  fActive := True;
end;

procedure TvgTessellationState.SetPatchControlPoints(const Value: TvkUint32);
begin
  If fPatchControlPoints=Value then exit;
  SetActiveState(False);
  fPatchControlPoints:=Value;
end;

procedure TvgTessellationState.WriteData(Writer: TWriter);
begin
  Writer.WriteListBegin;
  WriteTvkUint32(Writer, fPatchControlPoints) ;
  Writer.WriteListEnd;
end;

{ TvgRasterizerState }

constructor TvgRasterizerState.Create(AOwner: TComponent);
begin
  inherited;

   fDepthClampEnable        :=False;
   fRasterizerDiscardEnable :=False;
   fPolygonMode             :=VK_POLYGON_MODE_FILL;
   fLineWidth               :=1.0;
   fCullMode                :=TVkCullModeFlags(VK_CULL_MODE_NONE);
   fFrontFace               :=VK_FRONT_FACE_CLOCKWISE;
   fDepthBiasEnable         :=False;
   fDepthBiasConstantFactor :=0.0;
   fDepthBiasClamp          :=0.0;
   fDepthBiasSlopeFactor    :=0.0;

end;

destructor TvgRasterizerState.Destroy;
begin

  inherited;
end;

function TvgRasterizerState.GetActive: Boolean;
begin
  Result:=fActive;
end;

function TvgRasterizerState.GetCullMode: TvgCullMode;
begin
  Result:= getVGCullMode(fCullMode);
end;

function TvgRasterizerState.GetDepthBiasClamp: TvkFloat;
begin
  Result:=fDepthBiasClamp;
end;

function TvgRasterizerState.GetDepthBiasConstantFactor: TvkFloat;
begin
  Result:=fDepthBiasConstantFactor;
end;

function TvgRasterizerState.GetDepthBiasEnable: Boolean;
begin
  Result:=fDepthBiasEnable;
end;

function TvgRasterizerState.GetDepthBiasSlopeFactor: TvkFloat;
begin
  Result:=fDepthBiasSlopeFactor;
end;

function TvgRasterizerState.GetDepthClampEnable: Boolean;
begin
  Result:=fDepthClampEnable ;
end;

function TvgRasterizerState.GetFrontFace: TvgFrontFace;
begin
  Result:= getVGFrontFace(fFrontFace);
end;

function TvgRasterizerState.GetLineWidth: TvkFloat;
begin
  Result:=fLineWidth ;
end;

function TvgRasterizerState.GetPolygonMode: TvgPolygonMode;
begin
  Result:= GetVGPolygonMode(self.fPolygonMode);
end;

function TvgRasterizerState.GetRasterizerDiscardEnable: Boolean;
begin
  Result:=fRasterizerDiscardEnable;
end;

procedure TvgRasterizerState.SetActive(const Value: Boolean);
begin
  If fActive = Value then exit;
  SetActiveState(Value);
end;

procedure TvgRasterizerState.SetCullMode(const Value: TvgCullMode);
  Var CM:TVkCullModeFlags;
begin
  CM:=GetVKCullMode(Value);
  If fCullMode=CM then exit;
  SetActiveState(False);
  fCullMode:=CM;
end;

procedure TvgRasterizerState.SetDepthBiasClamp(const Value: TvkFloat);
begin
   If IsZero(fDepthBiasClamp,Value) then exit;
   SetActiveState(False);
   fDepthBiasClamp:=Value;
end;

procedure TvgRasterizerState.SetDepthBiasConstantFactor(const Value: TvkFloat);
begin
   If IsZero(fDepthBiasConstantFactor,Value) then exit;
   SetActiveState(False);
   fDepthBiasConstantFactor:=Value;
end;

procedure TvgRasterizerState.SetDepthBiasEnable(const Value: Boolean);
begin
   If (fDepthBiasEnable=Value) then exit;
   SetActiveState(False);
   fDepthBiasEnable:=Value;
end;

procedure TvgRasterizerState.SetDepthBiasSlopeFactor(const Value: TvkFloat);
begin
   If IsZero(fDepthBiasSlopeFactor,Value) then exit;
   SetActiveState(False);
   fDepthBiasSlopeFactor:=Value;
end;

procedure TvgRasterizerState.SetDepthClampEnable(const Value: Boolean);
begin
   If (fDepthClampEnable=Value) then exit;
   SetActiveState(False);
   fDepthClampEnable:=Value;
end;

procedure TvgRasterizerState.SetDisabled;
begin
  fActive := False;
end;

procedure TvgRasterizerState.SetEnabled(aComp: TvgBaseComponent);
   Function GetVK32Boolean(aval:Boolean):TVkBool32;
   Begin
     If aVal then
        Result := VK_TRUE
     else
        Result := VK_FALSE;
   End;
begin
   FillChar(frastCreateInfo,SizeOf(frastCreateInfo),#0);
   frastCreateInfo.sType  := VK_STRUCTURE_TYPE_PIPELINE_RASTERIZATION_STATE_CREATE_INFO;
   frastCreateInfo.pNext  := Nil;

   frastCreateInfo.depthClampEnable        := GetVK32Boolean(fDepthClampEnable);
   frastCreateInfo.rasterizerDiscardEnable := GetVK32Boolean(fRasterizerDiscardEnable);
   frastCreateInfo.polygonMode             := fPolygonMode;
   frastCreateInfo.cullMode                := fCullMode;
   frastCreateInfo.frontFace               := fFrontFace;
   frastCreateInfo.lineWidth               := fLineWidth;

   fActive := True;

end;

procedure TvgRasterizerState.SetFrontFace(const Value: TvgFrontFace);
  Var FF:TvkFrontFace ;
begin
  FF:=GetVKFrontFace(Value);
  If fFrontFace=FF then exit;
  SetActiveState(False);
  fFrontFace:=FF;
end;

procedure TvgRasterizerState.SetLineWidth(const Value: TvkFloat);
begin
  If IsZero(fLineWidth,Value) then exit;
  SetActiveState(False);
  fLineWidth:=Value;
end;

procedure TvgRasterizerState.SetPolygonMode(const Value: TvgPolygonMode);
  Var PM:TvkPolygonMode;
begin
  PM:=GetVKPolyGonMode(Value);
  If fPolygonMode=PM then exit;
  SetActiveState(False);
  fPolygonMode:=PM;
end;

procedure TvgRasterizerState.SetRasterizerDiscardEnable(const Value: Boolean);
begin
  If fRasterizerDiscardEnable=Value then exit;
  SetActiveState(False);
  fRasterizerDiscardEnable:=Value;
end;

{ TvgMultisamplingState }

constructor TvgMultisamplingState.Create(AOwner: TComponent);
begin
  inherited;

   fSampleShadingEnable   := False;
   frasterizationSamples  := VK_SAMPLE_COUNT_1_BIT;
   fminSampleShading      := 1.0;
//   fSampleMask    finish
   falphaToCoverageEnable := False;
   falphaToOneEnable      := False;

end;

destructor TvgMultisamplingState.Destroy;
begin
  inherited;
end;

function TvgMultisamplingState.GetActive: Boolean;
begin
  Result:=fActive;
end;

function TvgMultisamplingState.GetAlphaToCoverageEnable: boolean;
begin
  Result:=fAlphaToCoverageEnable
end;

function TvgMultisamplingState.GetAlphaToOneEnable: boolean;
begin
  Result:=fAlphaToOneEnable;
end;

function TvgMultisamplingState.GetMinSampleShading: TvkFloat;
begin
  Result:=fMinSampleShading;
end;

function TvgMultisamplingState.GetRasterizationSample: TvgSampleCountFlagBits;
begin
  Result:=GetVGSampleCountFlagBit(self.fRasterizationSamples);
end;

function TvgMultisamplingState.GetSampleShadingEnable: boolean;
begin
  Result:=fSampleShadingEnable;
end;

procedure TvgMultisamplingState.SetActive(const Value: Boolean);
begin
  If fActive = Value then exit;
  SetActiveState(Value);
end;

procedure TvgMultisamplingState.SetAlphaToCoverageEnable(const Value: boolean);
begin
  If self.fAlphaToCoverageEnable=Value then exit;
  SetActiveState(False);
  fAlphaToCoverageEnable:=Value;
end;

procedure TvgMultisamplingState.SetAlphaToOneEnable(const Value: boolean);
begin
  If self.fAlphaToOneEnable=Value then exit;
  SetActiveState(False);
  fAlphaToOneEnable:=Value;
end;

procedure TvgMultisamplingState.SetDisabled;
begin
  fActive := False;
end;

procedure TvgMultisamplingState.SetEnabled(aComp: TvgBaseComponent);
  Function GetVK32Bool(aVal:Boolean):TVkBool32;
  Begin
    If aVal then
       Result:=VK_TRUE
    else
       Result:=VK_FALSE;
  End;
begin
   fActive := True;
   FillChar(fpipelineMSCreateInfo,SizeOf(fpipelineMSCreateInfo),#0);
   fpipelineMSCreateInfo.sType := VK_STRUCTURE_TYPE_PIPELINE_MULTISAMPLE_STATE_CREATE_INFO;
   fpipelineMSCreateInfo.pNext := Nil;

   fpipelineMSCreateInfo.sampleShadingEnable   := VK_FALSE;//GetVK32Bool(fSampleShadingEnable);
   fpipelineMSCreateInfo.rasterizationSamples  := fRasterizationSamples;
   fpipelineMSCreateInfo.minSampleShading      := fMinSampleShading;
   //sampl mask needs handling    finish
   fpipelineMSCreateInfo.alphaToCoverageEnable := GetVK32Bool(fAlphaToCoverageEnable);
   fpipelineMSCreateInfo.alphaToOneEnable      := GetVK32Bool(fAlphaToOneEnable);
end;

procedure TvgMultisamplingState.SetMinSampleShading(const Value: TvkFloat);
begin
  If IsZero(self.fMinSampleShading-Value) then exit;
  SetActiveState(False);
  fMinSampleShading:=Value;
end;

procedure TvgMultisamplingState.SetRasterizationSample( const Value: TvgSampleCountFlagBits);
  Var SC: TvkSampleCountFlagBits ;
begin
  SC:= GetVKSampleCountFlagBit(Value);
  If fRasterizationSamples=SC then exit;
  SetActiveState(False);
  fRasterizationSamples:=SC;
end;

procedure TvgMultisamplingState.SetSampleShadingEnable(const Value: boolean);
begin
  If fSampleShadingEnable=Value then exit;
  SetActiveState(False);
  fSampleShadingEnable:=Value;
end;

{ TvgDepthStencilState }

constructor TvgDepthStencilState.Create(AOwner: TComponent);
begin
  inherited;

   fFrontOp  :=  TvgStencilOp.Create(self);
   fFrontOp.SetSubComponent(True);
   FreeNotification(fFrontOp);

   fBackOp   := TvgStencilOp.Create(self);
   fBackOp.SetSubComponent(True);
   FreeNotification(fBackOp);


  //   fflags              :=0;
   fdepthTestEnable        := False;
   fdepthWriteEnable       := False;
   fDepthCompareOp         :=VK_COMPARE_OP_LESS_OR_EQUAL;
   fDepthBoundsTestEnable  :=False;
   fstencilTestEnable      :=False;
   fminDepthBounds         :=0.0;
   fmaxDepthBounds         :=1.0;

end;

destructor TvgDepthStencilState.Destroy;
begin
  If assigned(fFrontOp) then
  Begin
    RemoveFreeNotification(fFrontOp);
    fFrontOp.SetSubComponent(False);
    FreeAndNil(fFrontOp);
  End;
  If assigned(fBackOp) then
  Begin
    RemoveFreeNotification(fBackOp);
    fBackOp.SetSubComponent(False);
    FreeAndNil(fBackOp);
  End;

  inherited;
end;

function TvgDepthStencilState.GetActive: Boolean;
begin
  Result := fActive;
end;

function TvgDepthStencilState.GetDepthBoundsTestEnable: boolean;
begin
  Result := fDepthBoundsTestEnable ;
end;

function TvgDepthStencilState.GetDepthCompareOp: TvgCompareOpBit;
begin
  Result:= GetVGCompareOp(fDepthCompareOp) ;
end;

function TvgDepthStencilState.GetDepthTestEnable: boolean;
begin
  Result:= fDepthTestEnable ;
end;

function TvgDepthStencilState.GetDepthWriteEnable: boolean;
begin
  Result:= fDepthWriteEnable ;
end;

function TvgDepthStencilState.GetMaxDepthBounds: TvkFloat;
begin
  Result:=self.fMaxDepthBounds ;
end;

function TvgDepthStencilState.GetMinDepthBounds: TvkFloat;
begin
  Result:= fMinDepthBounds ;
end;

function TvgDepthStencilState.GetStencilTestEnable: boolean;
begin
  Result:= fStencilTestEnable ;
end;

procedure TvgDepthStencilState.SetActive(const Value: Boolean);
begin
  If fActive = Value then exit;
  SetActiveState(Value);
end;

procedure TvgDepthStencilState.SetDepthBoundsTestEnable(const Value: boolean);
begin
   If fDepthBoundsTestEnable=Value then exit;
   SetActiveState(False);
   fDepthBoundsTestEnable:=Value;
end;

procedure TvgDepthStencilState.SetDepthCompareOp(const Value: TvgCompareOpBit);
  Var V:TvkCompareOp ;
begin
  V:= GetVkCompareOp(Value);
  If fDepthCompareOp=V then exit;
  SetActiveState(False) ;
  fDepthCompareOp:=V ;
end;

procedure TvgDepthStencilState.SetDepthTestEnable(const Value: boolean);
begin
  If fDepthTestEnable=Value then exit;
  SetActiveState(False);
  fDepthTestEnable:=Value;
end;

procedure TvgDepthStencilState.SetDepthWriteEnable(const Value: boolean);
begin
  If fDepthWriteEnable=Value then exit;
  SetActiveState(False);
  fDepthWriteEnable:=Value;
end;

procedure TvgDepthStencilState.SetDisabled;
begin
  fActive:=False;
end;

procedure TvgDepthStencilState.SetEnabled(aComp: TvgBaseComponent);
  Function GetVK32Bool(aVal:Boolean):TVkBool32;
  Begin
    If aVal then
       Result:=VK_TRUE
    else
       Result:=VK_FALSE;
  End;

begin

     Assert(assigned(fFrontOp),'Front Op not assigned');
     Assert(assigned(fBackOp),'Back Op not assigned');

     fFrontOp.Active :=True;
     fBackOp.Active  :=True;

     fActive:=True;

     FillChar(fDepthStencilInfo , SizeOf(fDepthStencilInfo),#0);
     fDepthStencilInfo.sType:=VK_STRUCTURE_TYPE_PIPELINE_DEPTH_STENCIL_STATE_CREATE_INFO;
     fDepthStencilInfo.pNext:=nil;

     fDepthStencilInfo.flags              :=0;    //need to set??

     fDepthStencilInfo.depthTestEnable    := GetVK32Bool(fDepthTestEnable) ;  //must be true  for test
     fDepthStencilInfo.depthWriteEnable   := GetVK32Bool(fDepthWriteEnable) ; //true be true  for test

     fDepthStencilInfo.depthCompareOp     :=  fDepthCompareOp;
     fDepthStencilInfo.depthBoundsTestEnable:= GetVK32Bool(fDepthBoundsTestEnable);

     fDepthStencilInfo.stencilTestEnable  := GetVK32Bool(fStencilTestEnable);

     fDepthStencilInfo.front.failOp       := fFrontOp.fFailOp;
     fDepthStencilInfo.front.passOp       := fFrontOp.fPassOp ;
     fDepthStencilInfo.front.depthFailOp  := fFrontOp.fDepthFailOp ;
     fDepthStencilInfo.front.compareOp    := fFrontOp.fCompareOp ;
     fDepthStencilInfo.front.compareMask  := fFrontOp.fCompareMask ;
     fDepthStencilInfo.front.writeMask    := fFrontOp.fWriteMask ;
     fDepthStencilInfo.front.reference    := fFrontOp.fReference ;

     fDepthStencilInfo.back.failOp        := fBackOp.fFailOp;
     fDepthStencilInfo.back.passOp        := fBackOp.fPassOp;
     fDepthStencilInfo.back.depthFailOp   := fBackOp.fDepthFailOp;
     fDepthStencilInfo.back.compareOp     := fBackOp.fCompareOp;
     fDepthStencilInfo.back.compareMask   := fBackOp.fCompareMask;
     fDepthStencilInfo.back.writeMask     := fBackOp.fWriteMask;
     fDepthStencilInfo.back.reference     := fBackOp.fReference;

     fDepthStencilInfo.minDepthBounds     := fMinDepthBounds;
     fDepthStencilInfo.maxDepthBounds     := fMaxDepthBounds;
end;

procedure TvgDepthStencilState.SetMaxDepthBounds(const Value: TvkFloat);
begin
  If IsZero(fMaxDepthBounds-Value) then exit;
  SetActiveState(False);
  fMaxDepthBounds:=Value;
end;

procedure TvgDepthStencilState.SetMinDepthBounds(const Value: TvkFloat);
begin
  If IsZero(fMinDepthBounds-Value) then exit;
  SetActiveState(False);
  fMinDepthBounds:=Value;
end;
procedure TvgDepthStencilState.SetStencilTestEnable(const Value: boolean);
begin
  If fStencilTestEnable=Value then exit;
  SetActiveState(False);
  fStencilTestEnable:=Value;
end;

procedure TvgDepthStencilState.SetUpDepthStencilState(DepthON, StencilON: Boolean; CompareOP:TVkCompareOp);
begin
  If (fDepthTestEnable = DepthON) and (fStencilTestEnable = StencilON) then exit;

//depth
  fDepthTestEnable   := DepthON;
  fDepthWriteEnable  := DepthON;
  fDepthCompareOp    := CompareOP;
  fMinDepthBounds    := 0.0;
  fMaxDepthBounds    := 1.0;

//stencil
  fStencilTestEnable := StencilON;


end;

{ TvgColorBlendAttachment }

procedure TvgColorBlendAttachment.Assign(Source: TPersistent);
begin
  inherited;

end;

constructor TvgColorBlendAttachment.Create(Collection: TCollection);
begin
  inherited;

  fBlendEnable := False;
  fSrcColorBlendFactor :=  VK_BLEND_FACTOR_ZERO;
  fDstColorBlendFactor :=  VK_BLEND_FACTOR_ZERO;
  fColorBlendOp        :=  VK_BLEND_OP_ADD;
  fSrcAlphaBlendFactor :=  VK_BLEND_FACTOR_ZERO;
  fDstAlphaBlendFactor :=  VK_BLEND_FACTOR_ZERO;
  fAlphaBlendOp        :=  VK_BLEND_OP_ADD;
  fColorWriteMask      := TVkColorComponentFlags( VK_COLOR_COMPONENT_R_BIT) +
                          TVkColorComponentFlags(VK_COLOR_COMPONENT_G_BIT) +
                          TVkColorComponentFlags(VK_COLOR_COMPONENT_B_BIT) +
                          TVkColorComponentFlags(VK_COLOR_COMPONENT_A_BIT)

end;

function TvgColorBlendAttachment.GetActive: Boolean;
begin
  Result:=fActive;
end;

function TvgColorBlendAttachment.GetAlphaBlendOp: TvgBlendOp;
begin
  Result:= GetVGBlendOp(fAlphaBlendOp);
end;

function TvgColorBlendAttachment.GetBlendEnable: boolean;
begin
  Result:=fBlendEnable;
end;

function TvgColorBlendAttachment.GetColorBlendOp: TvgBlendOp;
begin
  Result:= GetVGBlendOp(fColorBlendOp);
end;

function TvgColorBlendAttachment.GetColorWriteMask: TvgColorComponentFlagBits;
begin
  Result:=GetVGColorComponent(self.fColorWriteMask);
end;

function TvgColorBlendAttachment.GetDisplayName: string;
begin
  Result:=fName;
end;

function TvgColorBlendAttachment.GetDstAlphaBlendFactor: TvgBlendFactor;
begin
  Result:=GetVGBlendFactor(fDstAlphaBlendFactor);
end;

function TvgColorBlendAttachment.GetDstColorBlendFactor: TvgBlendFactor;
begin
  Result:=GetVGBlendFactor(self.fDstColorBlendFactor);
end;

function TvgColorBlendAttachment.GetName: String;
begin
  Result:=fName;
end;

function TvgColorBlendAttachment.GetSrcAlphaBlendFactor: TvgBlendFactor;
begin
  Result:=GetVGBlendFactor(self.fSrcAlphaBlendFactor);
end;

function TvgColorBlendAttachment.GetSrcColorBlendFactor: TvgBlendFactor;
begin
  Result:=GetVGBlendFactor(self.fSrcColorBlendFactor);
end;

procedure TvgColorBlendAttachment.SetActive(const Value: Boolean);
begin
  If fActive = Value then exit;
  If Value then
     SetEnabled
  else
     SetDisabled;
end;

procedure TvgColorBlendAttachment.SetAlphaBlendOp(const Value: TvgBlendOp);
  var CB:TVkBlendOp;
begin
  CB:=GetVKBlendOp(Value);
  If CB=self.fAlphaBlendOp then exit;
  SetDisabled;
  fAlphaBlendOp:=CB;
end;

procedure TvgColorBlendAttachment.SetBlendEnable(const Value: boolean);
begin
  If self.fBlendEnable=Value then exit;
  SetDisabled;
  fBlendEnable:=Value;
end;

procedure TvgColorBlendAttachment.SetColorBlendOp(const Value: TvgBlendOp);
  var CB:TVkBlendOp;
begin
  CB:=GetVKBlendOp(Value);
  If CB=self.fColorBlendOp then exit;
  SetDisabled;
  fColorBlendOp:=CB;
end;

procedure TvgColorBlendAttachment.SetColorWriteMask(const Value: TvgColorComponentFlagBits);
  Var CM:TVkColorComponentFlags;
begin
  CM:=GetVKColorComponent(Value);
  If self.fColorWriteMask=CM then exit;
  SetDisabled;
  fColorWriteMask := CM;
end;

procedure TvgColorBlendAttachment.SetDisabled;
begin
  fActive := False;
end;

procedure TvgColorBlendAttachment.SetDstAlphaBlendFactor( const Value: TvgBlendFactor);
  Var AB:TVkBlendFactor;
begin
  AB:=GetVKBlendFactor(Value);
  If fDstAlphaBlendFactor=AB then exit;
  SetDisabled;
  fDstAlphaBlendFactor:=AB;
end;

procedure TvgColorBlendAttachment.SetDstColorBlendFactor( const Value: TvgBlendFactor);
  Var AB:TVkBlendFactor;
begin
  AB:=GetVKBlendFactor(Value);
  If fDstColorBlendFactor=AB then exit;
  SetDisabled;
  fDstColorBlendFactor:=AB;
end;

procedure TvgColorBlendAttachment.SetEnabled;
begin
  fActive := True;

end;

procedure TvgColorBlendAttachment.SetName(const Value: String);
begin
  fName := Value;
end;

procedure TvgColorBlendAttachment.SetSrcAlphaBlendFactor( const Value: TvgBlendFactor);
  Var AB:TVkBlendFactor;
begin
  AB:=GetVKBlendFactor(Value);
  If fSrcAlphaBlendFactor=AB then exit;
  SetDisabled;
  fSrcAlphaBlendFactor:=AB;
end;

procedure TvgColorBlendAttachment.SetSrcColorBlendFactor( const Value: TvgBlendFactor);
  Var AB:TVkBlendFactor;
begin
  AB:=GetVKBlendFactor(Value);
  If fSrcColorBlendFactor=AB then exit;
  SetDisabled;
  fSrcColorBlendFactor:=AB;
end;

{ TvgColorBlendAttachmentCol }

function TvgColorBlendAttachmentCol.Add: TvgColorBlendAttachment;
begin
  Result := TvgColorBlendAttachment(inherited Add);
end;

function TvgColorBlendAttachmentCol.AddItem(Item: TvgColorBlendAttachment; Index: Integer): TvgColorBlendAttachment;
begin
  if Item = nil then
    Result := TvgColorBlendAttachment.Create(self)
  else
    Result := Item;

  if Assigned(Result) then
  begin
    Result.Collection := Self;
    if Index < 0 then
      Index := Count - 1;
    Result.Index := Index;
  end;
end;

constructor TvgColorBlendAttachmentCol.Create(CollOwner: TvgColorBlendingState);
begin
  Inherited Create(TvgColorBlendAttachment);

  fComp:=CollOwner;
end;

function TvgColorBlendAttachmentCol.GetItem(Index: Integer): TvgColorBlendAttachment;
begin
  Result := TvgColorBlendAttachment(inherited GetItem(Index));
end;

function TvgColorBlendAttachmentCol.GetOwner: TPersistent;
begin
  Result:=fComp;
end;

function TvgColorBlendAttachmentCol.Insert( Index: Integer): TvgColorBlendAttachment;
begin
  Result := AddItem(nil, Index);
end;

procedure TvgColorBlendAttachmentCol.SetItem(Index: Integer; const Value: TvgColorBlendAttachment);
begin
  inherited SetItem(Index, Value);
end;

procedure TvgColorBlendAttachmentCol.Update(Item: TCollectionItem);
begin
  inherited;

end;


{ TvgColorBlendingState }

constructor TvgColorBlendingState.Create(AOwner: TComponent);
 // Var C: TvgColorBlendAttachment;
begin
  fColorAttachments:= TvgColorBlendAttachmentCol.Create(self);

  inherited;

  fLogicOpEnable:= False;
  fLogicOp      := VK_LOGIC_OP_CLEAR;

  fColorAttachments.Add;   //check
end;

destructor TvgColorBlendingState.Destroy;
begin
  If assigned(fColorAttachments) then
  Begin
    fColorAttachments.Clear;
    FreeAndNil(fColorAttachments);
  End;

  inherited;
end;

function TvgColorBlendingState.GetActive: Boolean;
begin
  Result := fActive;
end;

function TvgColorBlendingState.GetLogicOp: TvgLogicOp;
begin
  Result:= GetVGLogicOp(fLogicOp);
end;

function TvgColorBlendingState.GetLogicOpEnable: Boolean;
begin
  Result := fLogicOpEnable;
end;

procedure TvgColorBlendingState.SetActive(const Value: Boolean);
begin
  If fActive = Value then exit;
  SetActiveState(Value);
end;

procedure TvgColorBlendingState.SetDisabled;
begin
  fActive := False;
  SetLength(fBlendAttachState,0);
end;

procedure TvgColorBlendingState.SetEnabled(aComp: TvgBaseComponent);
  Var I,L:Integer;
      C  : TvgColorBlendAttachment;

  Function GetVK32Bool(aVal:Boolean):TVkBool32;
  Begin
    If aVal then
       Result:=VK_TRUE
    else
       Result:=VK_FALSE;
  End;

begin
     fActive := True;

     Assert(assigned(fColorAttachments),'Color Attachments not assigned.');

     L:= fColorAttachments.Count  ;
     If L>0 then
     Begin
       SetLength(fBlendAttachState, L);
       FillChar(fBlendAttachState[0], SizeOf(TVkPipelineColorBlendAttachmentState)*L,#0);

       For I:=0 to L-1 do
       Begin
         C:= fColorAttachments.Items[I];
         If assigned(C) then
         Begin
           fBlendAttachState[I].blendEnable         := GetVK32Bool(C.fBlendEnable);
           fBlendAttachState[I].srcColorBlendFactor := C.fSrcColorBlendFactor;
           fBlendAttachState[I].dstColorBlendFactor := C.fDstColorBlendFactor;
           fBlendAttachState[I].colorBlendOp        := C.fColorBlendOp;
           fBlendAttachState[I].srcAlphaBlendFactor := C.fSrcAlphaBlendFactor;
           fBlendAttachState[I].dstAlphaBlendFactor := C.fDstAlphaBlendFactor;
           fBlendAttachState[I].alphaBlendOp        := C.fAlphaBlendOp;
           fBlendAttachState[I].colorWriteMask      := C.fColorWriteMask;
         end;
       end;
     end else
       SetLength(fBlendAttachState,0);

     FillChar(fBlendCreateInfo,SizeOf(fBlendCreateInfo),#0);
     fBlendCreateInfo.sType   := VK_STRUCTURE_TYPE_PIPELINE_COLOR_BLEND_STATE_CREATE_INFO;
     fBlendCreateInfo.pNext   := nil;

     fBlendCreateInfo.logicOpEnable   := GetVK32Bool(fLogicOpEnable);
     fBlendCreateInfo.logicOp         := fLogicOp;
     fBlendCreateInfo.attachmentCount := L;
     If L>0 then
       fBlendCreateInfo.pAttachments    := @fBlendAttachState[0]
     else
       fBlendCreateInfo.pAttachments    := nil;
end;

procedure TvgColorBlendingState.SetLogicOp(const Value: TvgLogicOp);
  Var V:TvkLogicOp;
begin
   V:= GetVKLogicOp(Value);
   If fLogicOp=V then exit;
   SetActiveState(False);
   fLogicOp:=V;
end;

procedure TvgColorBlendingState.SetLogicOpEnable(const Value: Boolean);
begin
  If fLogicOpEnable=Value then exit;
  SetActiveState(False);
  fLogicOpEnable:=Value;
end;

{ TvgInputAssemblyState }

constructor TvgInputAssemblyState.Create(AOwner: TComponent);
begin
  inherited;
  fTopology               := VK_PRIMITIVE_TOPOLOGY_TRIANGLE_LIST;
  fPrimitiveRestartEnable := False;
end;

destructor TvgInputAssemblyState.Destroy;
begin

  inherited;
end;

function TvgInputAssemblyState.GetActive: Boolean;
begin
  Result:=fActive;
end;

function TvgInputAssemblyState.GetPrimitiveRestartEnable: Boolean;
begin
  Result := fPrimitiveRestartEnable;
end;

function TvgInputAssemblyState.GetTopology: TvgPrimitiveTopology;
begin
  Result := GetVGPrimitiveTopology(fTopology);
end;

procedure TvgInputAssemblyState.SetActive(const Value: Boolean);
begin
  If fActive = Value then exit;
  SetActiveState(Value);
end;

procedure TvgInputAssemblyState.SetDisabled;
begin
  fActive := False;
end;

procedure TvgInputAssemblyState.SetEnabled(aComp: TvgBaseComponent);
  Function GetVK32Bool(aVal:Boolean):TVkBool32;
  Begin
    If aVal then
       Result:=VK_TRUE
    else
       Result:=VK_FALSE;
  End;

begin
  fActive := True;

   FillChar(fpipelineIACreateInfo,SizeOf(fpipelineIACreateInfo),#0);
   fpipelineIACreateInfo.sType := VK_STRUCTURE_TYPE_PIPELINE_INPUT_ASSEMBLY_STATE_CREATE_INFO;
   fpipelineIACreateInfo.pNext := Nil;

   fpipelineIACreateInfo.topology               := fTopology;
   fpipelineIACreateInfo.primitiveRestartEnable := GetVK32Bool(fPrimitiveRestartEnable);

end;

procedure TvgInputAssemblyState.SetPrimitiveRestartEnable(const Value: Boolean);
begin
  If fPrimitiveRestartEnable=Value then exit;
  SetActiveState(False);
  fPrimitiveRestartEnable:=Value;
end;

procedure TvgInputAssemblyState.SetTopology(const Value: TvgPrimitiveTopology);
  Var V: TvkPrimitiveTopology ;
begin
  V:=GetVKPrimitiveTopology(Value);
  If fTopology=V then exit;
  SetActiveState(False);
  fTopology:=V;
end;

{ TvsRenderNode }

procedure TvgRenderNode.ClearPipeLineList;
  Var I,L:Integer;
begin
  L:=Length(fGraphicPipelineList);
  If L=0 then exit;

  For I := 0 To L-1 do
     FillChar(fGraphicPipelineList[I],SizeOf(TvgPipelineRec),#0);
end;

constructor TvgRenderNode.Create(aRenderObject : TvgRenderObject=nil);
begin
  Inherited Create;

  fChildren    := TvgRenderNodeList.Create;

  fSection     := TvgCriticalSection.Create ;
  fUseStaging  := True;

  NodeSetUp;    //MUST stay last

end;

procedure TvgRenderNode.CreateDataBuffer;
  Var UseFlags : TVkBufferUsageFlags;
      VSize,
      ISize    : TvkUint32;
      ITypeSize: TvkUint32;

begin
  If GetVertexDataSize=0 then exit;
  If assigned(fDataBuffer) then exit;

  Assert(assigned(fRenderer),'Renderer not attached');
  Assert(assigned(fRenderer.Linker),'Window Link NOT assigned');
  Assert((fRenderer.Linker.active=True),'Window Link NOT active');
  Assert(assigned(fRenderer.Linker.ScreenDevice.VulkanDevice),'Window Link NOT active');

  UseFlags := 0;                            //TVkBufferUsageFlags(VK_BUFFER_USAGE_STORAGE_BUFFER_BIT)
  VSize    := GetVertexDataSize;
  ISize    := GetIndexDataSize;

  Case  GetIndexType of
    VK_INDEX_TYPE_UINT16 :  ITypeSize := SizeOf(TVkUInt16);
    VK_INDEX_TYPE_UINT32 :  ITypeSize := SizeOf(TvkUint32);
    else
      ITypeSize := SizeOf(TvkUint32);
  end;

  fVToIGap := ITypeSize - ((VSize MOD ITypeSize) * ITypeSize);

  If VSize>0 then
     UseFlags := UseFlags or TVkBufferUsageFlags(VK_BUFFER_USAGE_VERTEX_BUFFER_BIT);
  If ISize>0 then
     UseFlags := UseFlags or TVkBufferUsageFlags(VK_BUFFER_USAGE_INDEX_BUFFER_BIT);
  If fUseStaging then
     UseFlags := UseFlags or TVkBufferUsageFlags(VK_BUFFER_USAGE_TRANSFER_DST_BIT);


  fDataBuffer := TpvVulkanBuffer.Create(fRenderer.Linker.ScreenDevice.VulkanDevice,                  //TpvVulkanDevice;
                                          VSize + ISize + fVToIGap,          //TVkDeviceSize;
                                          UseFlags,                   //TVkBufferUsageFlags;
                                          VK_SHARING_MODE_EXCLUSIVE,   //VK_SHARING_MODE_CONCURRENT                       // TVkSharingMode;
                                          [],         // QueueFamilyIndices:array of TvkUint32;
                                          TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT) or //TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_COHERENT_BIT) or
                                          TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_COHERENT_BIT),//TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT),  // MemoryRequiredPropertyFlags:TVkMemoryPropertyFlags;
                                          0,  // MemoryPreferredPropertyFlags:TVkMemoryPropertyFlags;
                                          0,                                                  // MemoryAvoidPropertyFlags:TVkMemoryPropertyFlags;
                                          0,//TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT),   // MemoryPreferredNotPropertyFlags:TVkMemoryPropertyFlags;
                                          0,                                                  // MemoryRequiredHeapFlags:TVkMemoryHeapFlags;
                                          0,                                                  // MemoryAvoidHeapFlags:TVkMemoryHeapFlags;
                                          0,                                                  // MemoryPreferredNotHeapFlags:TVkMemoryHeapFlags;
                                          0,                                                  // MemoryPreferredNotHeapFlags:TVkMemoryHeapFlags;
                                          [{TpvVulkanBufferFlag.PersistentMapped}]) ;          // TpvVulkanBufferFlags


end;

procedure TvgRenderNode.DeleteDataBuffer;
begin
   If assigned(fDataBuffer) then
   Begin
     FreeAndNil(fDataBuffer);
   End;
end;

destructor TvgRenderNode.Destroy;
  Var I,L:Integer;
begin
  L:= Length( fGraphicPipelineList) ;
  If L>0 then
  Begin
    For I:=0 to L-1 do
    Begin
      If assigned(fGraphicPipelineList[I].MaterialRes) then
         FreeAndNil(fGraphicPipelineList[I].MaterialRes) ;
      If assigned(fGraphicPipelineList[I].ModelRes) then
         FreeAndNil(fGraphicPipelineList[I].ModelRes) ;
      If assigned(fGraphicPipelineList[I].PushConstant) then
         FreeAndNil(fGraphicPipelineList[I].PushConstant) ;

    End;
    SetLength(fGraphicPipelineList,0);
  End;

  If assigned(fSection) then
  Begin
    fSection.Release;
    FreeAndNil(fSection);
  End;

  DeleteDataBuffer;

  If assigned(fChildren) then
  Begin
    FreeAndNil(fChildren);
  End;

  inherited;
end;

function TvgRenderNode.GetActive: Boolean;
begin
  Result := fActive;
end;
(*
function TvgRenderNode.GetGraphicPipeline: TvgGraphicPipeline;
begin
  Result := self.fGraphicPipeline;
end;
*)
function TvgRenderNode.GetGraphicPipeline(Index: Integer): TvgGraphicPipeline;
begin
  Result := nil;
  If (Index<0) or (Index>=Length(fGraphicPipelineList))   then exit;
  Result := fGraphicPipelineList[Index].GraphicPipe;

end;

function TvgRenderNode.GetGraphicPipelineName: String;
begin
  Result := TvgGraphicPipeline.ClassName;
end;

function TvgRenderNode.GetGraphicPipelineType: TvgGraphicsPipelineType;
//override with correct type for RenderNode
begin
  Result := TvgGraphicPipeline;
end;

function TvgRenderNode.GetIndexCount: TvkUint32;
begin
  Result:=0;
end;

function TvgRenderNode.GetIndexDataPointer: Pointer;
begin
  Result:=Nil;
end;

function TvgRenderNode.GetIndexDataSize: TvkUint32;
begin
  Result:=0;
end;

function TvgRenderNode.GetIndexTYpe: TVkIndexType;
begin
  Result:=VK_INDEX_TYPE_UINT16;
end;

function TvgRenderNode.GetMaterialRes(Index: Integer): TvgDescriptorSet;
begin
  Result := nil;
  If (Index<0) or (Index>=Length(fGraphicPipelineList))   then exit;
  Result := fGraphicPipelineList[Index].MaterialRes;
end;

function TvgRenderNode.GetModelRes(Index: Integer): TvgDescriptorSet;
begin
  Result := nil;
  If (Index<0) or (Index>=Length(fGraphicPipelineList))   then exit;
  Result := fGraphicPipelineList[Index].ModelRes;
end;

function TvgRenderNode.GetNodeMode: TvgNodeMode;
begin
  Result:=fRenderMode;
end;

function TvgRenderNode.GetPipelineCount: Integer;
begin
  Result := Length(fGraphicPipelineList);
end;

function TvgRenderNode.GetPushConstant(Index: Integer): TvgPushConstantCol;
begin
  Result := nil;
  If (Index<0) or (Index>=Length(fGraphicPipelineList))   then exit;
  Result := fGraphicPipelineList[Index].PushConstant;
end;

function TvgRenderNode.GetRenderer: TvgRenderEngine;
begin
    Result := self.fRenderer;
end;

function TvgRenderNode.GetVertexCount: TvkUint32;
begin
  Result:=0;
end;

function TvgRenderNode.GetVertexDataPointer: Pointer;
begin
  Result:=nil;
end;

function TvgRenderNode.GetVertexDataSize: TvkUint32;
begin
  Result:=0;
end;

Class function TvgRenderNode.GetVertexStride: TvkUint32;
begin
  Result:=0;
end;

function TvgRenderNode.LockData( aWaitFor: Boolean=False): Boolean;
begin
  Assert(Assigned(fSection),'Data Lock not assigned');
  If aWaitFor then
  Begin
     fSection.Enter;
     Result:=True;
  end else
     Result := fSection.TryEnter;

end;

procedure TvgRenderNode.NodeSetUp;
begin
  fRenderMode := NM_STATIC;
//  fNodeType   := NT_CUSTOM;
end;

procedure TvgRenderNode.RecordVulkanCommand(aCommandBuf  : TvgCommandBuffer;
                                            aSubPassIndex: TvkUint32);

begin
  Assert(assigned(aCommandBuf),'Command not assigned');

  Try
    VulkanDraw( aCommandBuf, aSubPassIndex);

  Finally
  end;

end;

procedure TvgRenderNode.SetActive(const Value: Boolean);
begin
  If fActive = Value then exit;

  If fActive then
     SetDisabled;
  fActive := Value;
  If fActive then
     SetEnabled;

end;

procedure TvgRenderNode.SetCurrentFrame(Value: TvkUint32);
  Var L,I:Integer;
begin
 // If assigned(fPushConstantCol) then
 //    fPushConstantCol.
  L:=Length(fGraphicPipelineList);
  If L=0 then exit;
  For I:=0 to L-1 do
  Begin
    If assigned(fGraphicPipelineList[I].MaterialRes) then
       fGraphicPipelineList[I].MaterialRes.CurrentFrame := Value;
    If assigned(fGraphicPipelineList[I].ModelRes) then
       fGraphicPipelineList[I].ModelRes.CurrentFrame := Value;
  End;
end;

procedure TvgRenderNode.SetDisabled;
     var L,I:Integer;

begin

  If fActive then
  Begin
    DeleteDataBuffer;

    L := length(fGraphicPipelineList);
    If L>0 then
    For I:=0 to L-1 do
    Begin
      If assigned(fGraphicPipelineList[I].MaterialRes) then
        fGraphicPipelineList[I].MaterialRes.SetDisabled;

      If assigned(fGraphicPipelineList[I].ModelRes) then
        fGraphicPipelineList[I].ModelRes.SetDisabled;
    End;
  end;

  fActive:=False;
end;

procedure TvgRenderNode.SetEnabled;
  Var L,I:Integer;
begin
  fUploadNeeded := True;

  L:=Length(fGraphicPipelineList);

  If (L>0) and assigned(fRenderer) and assigned(fRenderer.Linker) and assigned(fRenderer.Linker.ScreenDevice) and
     (fRenderer.Linker.ScreenDevice.Active) then
  Begin
    For I:=0 to L-1 do
    Begin
      If assigned(fGraphicPipelineList[I].MaterialRes) then
      Begin
         If not assigned(fGraphicPipelineList[I].MaterialRes.LogicalDevice) then
            fGraphicPipelineList[I].MaterialRes.LogicalDevice:= fRenderer.Linker.ScreenDevice;
         fGraphicPipelineList[I].MaterialRes.Active := True;
      End;

      If assigned(fGraphicPipelineList[I].ModelRes) then
      Begin
         If not assigned(fGraphicPipelineList[I].ModelRes.LogicalDevice) then
            fGraphicPipelineList[I].ModelRes.LogicalDevice  := fRenderer.Linker.ScreenDevice;
         fGraphicPipelineList[I].ModelRes.Active := True;
      End;

      If assigned(fGraphicPipelineList[I].PushConstant) then
      Begin
         fGraphicPipelineList[I].PushConstant.Active := True;
      End;

    end;
  end;

  fActive := True;
end;
procedure TvgRenderNode.SetGraphicPipeline(Index: Integer;  const Value: TvgGraphicPipeline);
begin
  If (Index<0) or (Index>=Length(fGraphicPipelineList))   then exit;
  If fGraphicPipelineList[Index].GraphicPipe=Value then exit;

  If assigned(fGraphicPipelineList[Index].GraphicPipe) then
  Begin

    If assigned(fGraphicPipelineList[Index].MaterialRes) then
       FreeAndNil(fGraphicPipelineList[Index].MaterialRes);

    If assigned(fGraphicPipelineList[Index].ModelRes) then
       FreeAndNil(fGraphicPipelineList[Index].ModelRes);

    If assigned(fGraphicPipelineList[Index].PushConstant) then
       FreeAndNil(fGraphicPipelineList[Index].PushConstant);

  End;

  fGraphicPipelineList[Index].GraphicPipe := Value;

  If assigned(fGraphicPipelineList[Index].GraphicPipe) then
  Begin
    If (RU_MATERIAL in fGraphicPipelineList[Index].GraphicPipe.ResourceUse) and
           assigned(fGraphicPipelineList[Index].GraphicPipe.MaterialRes) then
    Begin
      fGraphicPipelineList[Index].MaterialRes := TvgDescriptorSet.Create(nil);
      fGraphicPipelineList[Index].MaterialRes.Assign(fGraphicPipelineList[Index].GraphicPipe.MaterialRes);
    End;

    If (RU_MODEL in fGraphicPipelineList[Index].GraphicPipe.ResourceUse) and
        assigned(fGraphicPipelineList[Index].GraphicPipe.ModelRes) then
    Begin
      fGraphicPipelineList[Index].ModelRes := TvgDescriptorSet.Create(nil);
      fGraphicPipelineList[Index].ModelRes.Assign(fGraphicPipelineList[Index].GraphicPipe.ModelRes);
    End;

    If assigned(fGraphicPipelineList[Index].GraphicPipe.PushConstantCol) then
    Begin
      fGraphicPipelineList[Index].PushConstant:= TvgPushConstantCol.Create(nil);
      fGraphicPipelineList[Index].PushConstant.assign(fGraphicPipelineList[Index].GraphicPipe.PushConstantCol);
    End;

  End;

end;

(*
procedure TvgRenderNode.SetGraphicPipeline(const Value: TvgGraphicPipeline);

begin
  If fGraphicPipeline = Value then exit;

  SetDisabled;

  If assigned(fGraphicPipeline) then
  Begin
    If assigned(fMaterialRes) then
       FreeAndNil(fMaterialRes);

    If assigned(fModelRes) then
       FreeAndNil(fModelRes);

    If assigned(fPushConstantCol) then
       FreeAndNil(fPushConstantCol);

  End ;

  fGraphicPipeline := Value;

  If assigned(fGraphicPipeline) then
  Begin
    If (RU_MATERIAL in fGraphicPipeline.ResourceUse) and assigned(fGraphicPipeline.MaterialRes) then
    Begin
      fMaterialRes := TvgDescriptorSet.Create(nil);
      fMaterialRes.Assign(fGraphicPipeline.MaterialRes);
    End;

    If (RU_MODEL in fGraphicPipeline.ResourceUse) and assigned(fGraphicPipeline.ModelRes) then
    Begin
      fModelRes := TvgDescriptorSet.Create(nil);
      fModelRes.Assign(fGraphicPipeline.ModelRes);
    End;

    If assigned(fGraphicPipeline.PushConstantCol) then
    Begin
      fPushConstantCol:= TvgPushConstantCol.Create(nil);
      fPushConstantCol.assign(fGraphicPipeline.PushConstantCol);
    End;

  End ;
end;
*)
procedure TvgRenderNode.SetNodeMode(const Value: TvgNodeMode);
begin
  If fRenderMode=Value then exit;
  If fActive then exit;       //check

  fRenderMode := Value;

end;

procedure TvgRenderNode.SetPipelineCount(const Value: Integer);
begin
  If Length(fGraphicPipelineList) = Value then exit;
  SetDisabled;

  SetLength(fGraphicPipelineList,Value);

end;

procedure TvgRenderNode.SetRenderer(const Value: TvgRenderEngine);
 var L,I:Integer;
begin
  If fRenderer = Value then exit;
  SetDisabled;
  L:=Length(fGraphicPipelineList);
  If L>0 then
    For I:=0 to L- 1 do
      Begin

          If assigned(fGraphicPipelineList[I].MaterialRes) then
             fGraphicPipelineList[I].MaterialRes.LogicalDevice:=nil;

          If assigned(fGraphicPipelineList[I].ModelRes) then
             fGraphicPipelineList[I].ModelRes.LogicalDevice:=nil;
      end;

  fRenderer := Value;

  If (L>0 )and
     Assigned(fRenderer) and
     assigned(fRenderer.Linker) and
     Assigned(fRenderer.Linker.ScreenDevice) then
    For I:=0 to L- 1 do
      Begin
        If assigned(fGraphicPipelineList[I].MaterialRes) then
           fGraphicPipelineList[I].MaterialRes.LogicalDevice:=fRenderer.Linker.ScreenDevice;

        If assigned(fGraphicPipelineList[I].ModelRes) then
           fGraphicPipelineList[I].ModelRes.LogicalDevice:=fRenderer.Linker.ScreenDevice;
      end;

end;

procedure TvgRenderNode.SetUpResourceData;
  Var L,I:Integer;
begin
  L:=Length(fGraphicPipelineList);
  If L=0 then exit;
  For I:=0 to L-1 do
  Begin
    if assigned(fGraphicPipelineList[I].MaterialRes) then
    Begin
      fGraphicPipelineList[I].MaterialRes.SetUpShaderData;
    End;

    if assigned(fGraphicPipelineList[I].ModelRes) then
    Begin
      fGraphicPipelineList[I].ModelRes.SetUpShaderData;
    End;
  end;

end;

function TvgRenderNode.UnLockData: Boolean;
begin
  Assert(Assigned(fSection),'Data Lock not assigned');
  fSection.Release;
  Result      := True;
end;

procedure TvgRenderNode.UploadAllData(aPool:TvgCommandBufferPool);
  Var Queue          : TpvVulkanQueue;
      TransferBuffer : TvgCommandBuffer;
      StageMode      : TpvVulkanBufferUseTemporaryStagingBufferMode;
      Data,D1        : Pointer;
      VSize,
      ISize,
      DSize          : TvkUint32;

begin

  if not fUploadNeeded then exit;

  If  not assigned(fDataBuffer) then exit;//this is OK for a No Data node

  Assert(assigned(aPool),'Buffer Pool NOT assigned');

  Assert(assigned(fRenderer),'Renderer NOT assigned');
  Assert(assigned(fRenderer.Linker),'Window Link NOT assigned');
  Assert((fRenderer.Linker.active=True),'Window Link NOT active');
  Assert(assigned(fRenderer.Linker.ScreenDevice.VulkanDevice),'Window Link NOT active');

  Queue := aPool.Queue[-1];
  Assert(Assigned(Queue),'Queue NOT available.');

  If LockData(False) then
  Begin
    Try
      TransferBuffer    := aPool.RequestCommand(0, 0, CB_PRIMARY, False, [BU_SIMULTANEOUS_USE_BIT]);

      Assert(Assigned(TransferBuffer),'Transfer Buffer NOT available.');
      TransferBuffer.Active := True;

      VSize := GetVertexDataSize;
      ISize := GetIndexDataSize;
      DSize := VSize + ISize + fVToIGap ;

      GetMem(Data, DSize);
      Try
         FillChar(Data^,DSize,#0);

         If  VSize>0 then
            Move(GetVertexDataPointer^,Data^,VSize); //copy in Vertex  data

         If ISize>0 then
         Begin
           D1 := Data;
           inc(pByte(D1), VSize + fVToIGap) ;
           Move(GetIndexDataPointer^, D1^, ISize); //copy in Index  data
         end;

         If fUseStaging then
            StageMode :=  TpvVulkanBufferUseTemporaryStagingBufferMode.Yes
         else
            StageMode :=  TpvVulkanBufferUseTemporaryStagingBufferMode.Automatic;

          fDataBuffer.UploadData(Queue,
                                   TransferBuffer.VulkanCommandBuffer,
                                   TransferBuffer.fBufferFence,
                                   Data^,                          //data
                                   0,                              //data offset
                                   DSize,                          //data size
                                   StageMode,
                                   False);  //dont wait

          TransferBuffer.SetBufferState(BS_PENDING,True) ;

      Finally
        FreeMem(Data);

        fUploadNeeded := False;
      End;


    Finally
      UnLockData;
    End;
  End;


end;

{ TvgRenderObject }

constructor TvgRenderObject.Create(AOwner: TComponent);
begin

  Inherited;

  CreateRenderNode;

end;

procedure TvgRenderObject.CreateRenderNode;
  Var N :TvgRenderNodeType;
begin
  If assigned(fRenderNode) then exit;

  N := GetRenderNodeClass;
  If not assigned(N) then exit;

  fRenderNode := N.Create(Self);

  fRenderNode.SetUpAllData;

end;

destructor TvgRenderObject.Destroy;
begin

  If assigned(fRenderer) then
  Begin
    fRenderer.RemoveRenderObject(self);
    fRenderer := nil;
  End;     //must stay here

  If assigned(fRenderNode) then
  Begin
     fRenderNode.Active:=False;
     If assigned(fRenderer) then
       fRenderer.RemoveRenderNode(fRenderNode,False);
     fRenderNode.Renderer := Nil;
     FreeAndNil(fRenderNode);
  end;

  inherited;
end;

function TvgRenderObject.GetActive: Boolean;
begin
  Result := fActive;
end;
(*
function TvgRenderObject.GetMaterialRes(Index: Integer): TvgDescriptorSet;
  Var L:Integer;
begin
  Result := nil;
  If assigned(fRenderNode) and (Length(fRenderNode.fGraphicPipelineList)>0) then
  Begin
     L:= Length(fRenderNode.fGraphicPipelineList);
     If (Index<0) or (Index>= L) then exit;

     Result := fRenderNode.fGraphicPipelineList[Index].MaterialRes ;
  end;
end;

function TvgRenderObject.GetModelRes(Index: Integer): TvgDescriptorSet;
  Var L:Integer;
begin
  Result := nil;
  If assigned(fRenderNode) and (Length(fRenderNode.fGraphicPipelineList)>0) then
  Begin
     L:= Length(fRenderNode.fGraphicPipelineList);
     If (Index<0) or (Index>= L) then exit;

     Result := fRenderNode.fGraphicPipelineList[Index].ModelRes ;
  end;
end;
*)
(*
function TvgRenderObject.GetMaterialRes: TvgDescriptorSet;
begin
  If assigned(fRenderNode) then
     Result := fRenderNode.fMaterialRes
  else
     Result := nil;
end;

function TvgRenderObject.GetModelRes: TvgDescriptorSet;
begin
  If assigned(fRenderNode) then
     Result := fRenderNode.fModelRes
  else
     Result := nil;
end;
*)

function TvgRenderObject.GetNodeMode: TvgNodeMode;
begin
  If assigned(fRenderNode) then
     Result := fRenderNode.NodeMode
  else
     Result := NM_NONE;
end;

function TvgRenderObject.GetRenderer: TvgRenderEngine;
begin
  Result := fRenderer;
end;

function TvgRenderObject.GetRenderNode: TvgRenderNode;
begin
  Result := fRenderNode;
end;

function TvgRenderObject.GetRenderNodeClass: TvgRenderNodeType;
begin
  Result := TvgRenderNode;
end;

procedure TvgRenderObject.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);

  Case Operation of
     opInsert : Begin
                  If aComponent=self then exit;
                  If NotificationTestON and Not (csDesigning in ComponentState) then exit ;      //don't mess with links at runtime

                  If (aComponent is TvgRenderEngine) and not assigned(fRenderer) then
                  Begin
                    SetRenderer(TvgRenderEngine(aComponent));
                  End;

                End;

     opRemove : Begin

                  If (aComponent is TvgRenderEngine) and (TvgRenderEngine(aComponent)=fRenderer) then
                  Begin
                    SetRenderer(nil);
                  End;

                end;
  End;

end;

procedure TvgRenderObject.SetActive(const Value: Boolean);
begin
  If fActive = Value then exit;
  SetActiveState(Value) ;
end;

procedure TvgRenderObject.SetDisabled;
begin
  If  assigned(fRenderNode) then
    fRenderNode.Active:=False;

  fActive := False;
end;

procedure TvgRenderObject.SetEnabled(aComp: TvgBaseComponent);
begin
  If assigned(fRenderNode) then
  Begin
    If assigned(fRenderer) and not assigned(fRenderNode.fRenderer) then
      fRenderer.AddRenderNode(fRenderNode);
    fRenderNode.Active := True;
  end;

  fActive := True;
end;

procedure TvgRenderObject.SetNodeMode(const Value: TvgNodeMode);
begin
  Assert(assigned(fRenderNode),'Render Node not created');

  If fActive then exit;
  If  fRenderNode.NodeMode = Value then exit;

  If assigned(fRenderer) then
     fRenderer.MoveRenderNode(fRenderNode, fRenderNode.NodeMode, Value);

  fRenderNode.NodeMode := Value;
end;

procedure TvgRenderObject.SetRenderer(const Value: TvgRenderEngine);
begin
  If fRenderer = Value then exit;
   SetActiveState(False);

  If assigned(fRenderer) then
  Begin
     If assigned(fRenderNode) then
     Begin
       fRenderNode.fRenderer        := Nil;
   //    fRenderNode.fGraphicPipeline := Nil;
     End;
     fRenderer := Nil;

  End;

  fRenderer := Value;

  If assigned(fRenderer) then
  Begin
     fRenderer.AddRenderObject(self);
     If assigned(fRenderNode) then
     Begin
       fRenderer.AddRenderNode(fRenderNode);
     end
  End;
end;

{ TvgDescriptorCol }

function TvgDescriptorCol.Add: TvgDescriptorItem;
begin
  Result := TvgDescriptorItem(inherited Add);

  If assigned(Result) and assigned(fComp) then
  Begin
      Result.Device := FComp.fDevice;

  End;
end;

function TvgDescriptorCol.AddItem(Item: TvgDescriptorItem; Index: Integer): TvgDescriptorItem;
begin
  if Item = nil then
  Begin
    Result := TvgDescriptorItem.Create(self);
    If assigned(Result) and assigned(fComp) then
      Result.Device := FComp.fDevice;
  end else
    Result := Item;

  if Assigned(Result) then
  begin
    Result.Collection := Self;
    if Index < 0 then
      Index := Count - 1;
    Result.Index := Index;
  end;
end;

procedure TvgDescriptorCol.Assign(Source: TPersistent);
  Var DC: TvgDescriptorCol;
      DI,DIS: TvgDescriptorItem;
      I : Integer;
begin
  If Source is TvgDescriptorCol then
  Begin
    DC          := TvgDescriptorCol(Source);
    FCollString := DC.FCollString;

    If DC.Count>0 then
    Begin
      For I:= 0 to DC.Count-1 do
      Begin
        DIS := DC.Items[I] ;
        DI  := Add;

        DI.fActive          := False ;
        DI.fName            := DIS.fName ;
        DI.fDevice          := DIS.fDevice ;
        DI.DescriptorName       := DIS.DescriptorName ;  //should create ShaderData instance
        If assigned(DI.Descriptor) then
           DI.Descriptor.Assign(DIS.Descriptor);
      End;
    End;

  End else
    Inherited Assign(Source);


end;

constructor TvgDescriptorCol.Create(CollOwner: TvgDescriptorSet);
begin
  Inherited Create(TvgDescriptorItem);
  FComp := CollOwner;
end;

function TvgDescriptorCol.GetItem(Index: Integer): TvgDescriptorItem;
begin
  Result := TvgDescriptorItem(inherited GetItem(Index));
end;

function TvgDescriptorCol.GetOwner: TPersistent;
begin
  Result := nil;
end;

function TvgDescriptorCol.Insert(Index: Integer): TvgDescriptorItem;
begin
  Result := AddItem(nil, Index);
end;

procedure TvgDescriptorCol.SetItem(Index: Integer;  const Value: TvgDescriptorItem);
begin
  inherited SetItem(Index, Value);
end;

procedure TvgDescriptorCol.Update(Item: TCollectionItem);
var
  str: string;
  i: Integer;
begin
  inherited;
  // update everything in any case...
  str := '';
  for i := 0 to Count - 1 do
  begin
    str := str + String((Items [i] as TvgDescriptorItem).fName);
    if i < Count - 1 then
      str := str + '-';
  end;
  FCollString := str;
end;

{ TvgShaderResources }

procedure TvgDescriptorSet.Assign(Source: TPersistent);
  Var SR:TvgDescriptorSet;
begin

  If (Source is TvgDescriptorSet) then
  Begin
    SR           := TvgDescriptorSet(Source) ;
    Name         := SR.Name;
    SetDevice(SR.fDevice);
    FrameCount  := SR.fFrameCount;

    fDescriptorCol.Assign(SR.fDescriptorCol);

    SetUpShaderData;
  end else
    Inherited assign(Source);
end;

procedure TvgDescriptorSet.BuildDescriptorSetLayout;
  Var I,VDI  : Integer;
      SD     : TvgDescriptor;
      VD     : TvgDescriptorEnumType;
      CountArrayL : Integer;

begin
  fActive := False;     //important

  Assert(Assigned(fDevice),'Logical Device NOT assigned');
  Assert(Assigned(fDevice.VulkanDevice),'Vulkan Logical Device NOT assigned');

  If (fDescriptorCol.Count=0) then exit    ;    //cant handle an empty set

  CountArrayL := Ord(High(TvgDescriptorEnumType)) - Ord(Low(TvgDescriptorEnumType)) + 1 ;

  Setlength(fCountArray,CountArrayL);
  FillChar(fCountArray[0],CountArrayL,#0);

  fSetCount                  := 0;
  fVulkanDescriptorSetLayout := TpvVulkanDescriptorSetLayout.Create(fDevice.VulkanDevice);

  For I:=0 to fDescriptorCol.Count-1 do
  Begin
    If Not assigned(fDescriptorCol.Items[I].Device) or (fDescriptorCol.Items[I].Device<>fDevice) then
       fDescriptorCol.Items[I].Device :=  fDevice;

    SD:= fDescriptorCol.Items[I].fDescriptor;
    If assigned(SD) then
    Begin
        fVulkanDescriptorSetLayout.AddBinding(I,                     //binding
                                              SD.fDescriptorType,
                                              1,                     //count
                                              SD.fStageFlags,
                                              [],
                                              SD.fBindingFlags);

        VD  := GetVGDescriptorType(SD.fDescriptorType);
        VDI := Ord(VD);

        fCountArray[VDI] :=  fCountArray[VDI] + 1;
        //getting the number of Descriptor Types    to be able to build Pool
        Inc(fSetCount);
    end;

  End;

   //If no Descriptor Items then create EMPTY set
  fVulkanDescriptorSetLayout.Initialize;

end;

procedure TvgDescriptorSet.ClearDescriptorSetLayout;
begin
  If assigned(fVulkanDescriptorSetLayout) then
     FreeAndNil(fVulkanDescriptorSetLayout);
  fSetCount:=0;
  SetLength(fCountArray,0);

end;

constructor TvgDescriptorSet.Create(AOwner: TComponent);

begin
  fDescriptorCol := TvgDescriptorCol.Create(self);

  inherited;

  fFrameCount := MaxFramesInFlight;

end;

destructor TvgDescriptorSet.Destroy;
begin
  SetActiveState(False);

  If assIgned(fDescriptorCol) then
     FreeAndNil(fDescriptorCol);

  If assIgned(fDSGraphicCommandPool) then
     FreeAndNil(fDSGraphicCommandPool);

  If assIgned(fDSTransferCommandPool) then
     FreeAndNil(fDSTransferCommandPool);


  inherited;
end;

function TvgDescriptorSet.GetActive: Boolean;
begin
  Result :=fActive;
end;

function TvgDescriptorSet.GetDevice: TvgLogicalDevice;
begin
  Result := fDevice;
end;

function TvgDescriptorSet.GetFRameCount: TvkUint32;
begin
  Result := fFrameCount;
end;

function TvgDescriptorSet.GetLinkerFrameCount: TvkUint32;
begin
  Result := MaxFramesInFlight;

  If not assigned(fDevice) then exit;
  If not (fDevice is TvgScreenRenderDevice) then exit;
  If not assigned(TvgScreenRenderDevice(fDevice).fLinker) then exit;

  Result := TvgScreenRenderDevice(fDevice).fLinker.FrameCount;

end;

function TvgDescriptorSet.GetShaderDescriptorStringTemplate_Fragment(aSet : TvkUInt32): String;
  Var I  :Integer;
      DI :  TvgDescriptorItem;
      DS:String;
begin
  Result := '';
  If fDescriptorCol.Count=0 then exit;

  For I:=0 to fDescriptorCol.Count-1 do
  Begin
    DI:= fDescriptorCol.Items[I];
    If assigned(DI) and Assigned(DI.Descriptor) then
    Begin
      DS:= DI.Descriptor.GetShaderDescriptorStringTemplate_Fragment(aSet, I);
      If DS<>'' then
      Begin
        DS := DS + #13+#10;
        Result := Result + DS;
      End;
    End;
  End;

end;

function TvgDescriptorSet.GetShaderDescriptorStringTemplate_Geometry(aSet : TvkUInt32): String;
begin
  Result := '';
end;

function TvgDescriptorSet.GetShaderDescriptorStringTemplate_Vertex(aSet : TvkUInt32): String;
begin
  Result := '';
end;

function TvgDescriptorSet.GetVulkanDescriptorSet( index: Integer): TpvVulkanDescriptorSet;
begin
  If (index<Low(fVulkanDescriptorSets)) or (index>High(fVulkanDescriptorSets)) then
    Result := nil
  else
    Result := fVulkanDescriptorSets[index]
end;

procedure TvgDescriptorSet.SetActive(const Value: Boolean);
begin
  If fActive = Value then exit;
  SetActiveState(Value);
end;

procedure TvgDescriptorSet.SetCurrentFrame(const Value: TvkUint32);
  Var I:Integer;
      D:TvgDescriptor;
begin
  If fCurrentFrame = Value  then exit;
  //DO NOT Disable here
  fCurrentFrame := Value;

  If assigned(fDSGraphicCommandPool) then
     fDSGraphicCommandPool.FrameIndex  := fCurrentFrame;

  If assigned(fDSTransferCommandPool) then
     fDSTransferCommandPool.FrameIndex := fCurrentFrame;

  If fDescriptorCol.Count>0 then
  For I:=0 to fDescriptorCol.Count-1 do
  Begin
    D :=  fDescriptorCol.Items[I].Descriptor;
    If assigned(D) then
       D.CurrentFrame := fCurrentFrame;
  End;
end;

procedure TvgDescriptorSet.UploadDescriptorSetData(aFrameIndex:TvkUint32);
  Var I: Integer;
    SD : TvgDescriptorItem;
begin
  If not fActive then exit;
  If fDescriptorCol.Count=0 then exit;

  For I:=0 to fDescriptorCol.Count-1 do
  Begin
    SD:= fDescriptorCol.Items[I];
    If assigned(SD) and assigned(SD.Descriptor)  then
    Begin
      SD.Descriptor.UpLoadDescriptorData(aFrameIndex,
                                     fDSGraphicCommandPool,
                                     fDSTransferCommandPool);
    End;
  End;
end;

procedure TvgDescriptorSet.SetDescriptorCol(const Value: TvgDescriptorCol);
begin
  If not assigned(Value) then exit;
  SetActiveState(False);
  fDescriptorCol.Clear;
  fDescriptorCol.Assign(Value);
end;

procedure TvgDescriptorSet.SetDevice(aDevice: TvgLogicalDevice);
  Var I:Integer;
      SD:TvgDescriptorItem;
begin
  If fDevice = aDevice then exit;
  SetActiveState(False);
  fDevice := aDevice;

  If fDescriptorCol.Count>0 then
  For I:=0 to fDescriptorCol.Count-1 do
  Begin
    SD:= fDescriptorCol.Items[I];
    If assigned(SD) then
      SD.Device := fDevice;
  End;

  If assigned(fDSGraphicCommandPool) then
    fDSGraphicCommandPool.Device := fDevice;

  If assigned(fDSTransferCommandPool) then
    fDSTransferCommandPool.Device := fDevice;

end;

procedure TvgDescriptorSet.SetDisabled;
  Var I:Integer;
      SD : TvgDescriptor;

begin
  fActive :=False;

  If assigned(fDSGraphicCommandPool) then
  Begin
    fDSGraphicCommandPool.ReleaseAllCommands(True);
    fDSGraphicCommandPool.Active := False;
    FreeAndNil(fDSGraphicCommandPool);
  End;

 // If assigned(fGraphicFence) then
   //     FreeAndNil(fGraphicFence);

  If assigned(fDSTransferCommandPool) then
  Begin
    fDSTransferCommandPool.ReleaseAllCommands(True);
    fDSTransferCommandPool.Active := False;
    FreeAndNil(fDSTransferCommandPool);
  End;

//  If assigned(fTransferFence) then
     //   FreeAndNil(fTransferFence);

  For I:=0 to fDescriptorCol.Count-1 do
  Begin
    SD:= fDescriptorCol.Items[I].fDescriptor;
    If assigned(SD) then
      SD.SetDisabled;
  End;

  For I:=0 to High(fVulkanDescriptorSets) do
    If assigned( fVulkanDescriptorSets[I]) then
       FreeAndNil(fVulkanDescriptorSets[I]);

  SetLength(fVulkanDescriptorSets,0);

  If assigned(fVulkanDescriptorPool) then
   FreeAndNil(fVulkanDescriptorPool);

   ClearDescriptorSetLayout;

end;

procedure TvgDescriptorSet.SetEnabled(aComp: TvgBaseComponent);

  Var I,J,L: Integer;
      SD : TvgDescriptor;

begin
  fActive := False;

  Assert(Assigned(fDevice),'Logical Device NOT assigned');
  Assert(Assigned(fDevice.VulkanDevice),'Vulkan Logical Device NOT assigned');

  If (fDescriptorCol.Count=0) then exit    ;    //cant handle an empty set

  fFrameCount  := GetLinkerFrameCount ;

  fDSGraphicCommandPool                   := TvgCommandBufferPool.Create(self);
  fDSGraphicCommandPool.SetUpBufferArrays(TvkUint32(fFrameCount),1);
  fDSGraphicCommandPool.QueueFamilyType   := VGT_GRAPHIC;
  fDSGraphicCommandPool.QueueCreateFlags  :=  [ CP_TRANSIENT,                           //< Command buffers have a short lifetime
                                              CP_RESET_COMMAND_BUFFER];                 //< Command buffers may release their memory individually
  fDSGraphicCommandPool.Device            := fDevice;
  fDSGraphicCommandPool.Active            := True;

  fDSGraphicCommandPool.active := True;

  fDSTransferCommandPool                   := TvgCommandBufferPool.Create(self);
  fDSTransferCommandPool.SetUpBufferArrays(TvkUint32(fFrameCount),1);
  fDSTransferCommandPool.QueueFamilyType   := VGT_TRANSFER;
  fDSTransferCommandPool.QueueCreateFlags  :=  [CP_TRANSIENT,                           //< Command buffers have a short lifetime
                                              CP_RESET_COMMAND_BUFFER];                //< Command buffers may release their memory individually
  fDSTransferCommandPool.Device            := fDevice;

  fDSTransferCommandPool.Active            := True;

//  fGraphicFence  := TpvVulkanFence.Create(fDevice.VulkanDevice);
//  fTransferFence := TpvVulkanFence.Create(fDevice.VulkanDevice);

  BuildDescriptorSetLayout;

  fVulkanDescriptorPool      := TpvVulkanDescriptorPool.Create(fDevice.VulkanDevice,
                                                               TVkDescriptorPoolCreateFlags(VK_DESCRIPTOR_POOL_CREATE_FREE_DESCRIPTOR_SET_BIT),
                                                               fFrameCount * fSetCount);     //Max Set Count

  L := Length(fCountArray);

  For I := 0 to L-1 do
  Begin
    If fCountArray[I]>0 then
    Begin
      For J:=0 to fFrameCount-1 do
        fVulkanDescriptorPool.AddDescriptorPoolSize( GetVKDescriptorType(TvgDescriptorEnumType(I)),
                                                     fCountArray[I] * fFrameCount);
    End;
  End;

  fVulkanDescriptorPool.Initialize;

  SetLength(fVulkanDescriptorSets,
            fFrameCount);   //sized to Frames in Flight

  For J:=0 to fDescriptorCol.Count-1 do
  Begin
    SD := fDescriptorCol.Items[J].fDescriptor;
    If assigned(SD) then
    Begin
    //   SD.FrameCount   := fFrameCount;
       SD.CurrentFrame := fCurrentFrame;
       SD.Active       := True;
    End;
  End;


  For I:=0 to fFrameCount-1 do   //frames in flight
  Begin
    fVulkanDescriptorSets[I]      := TpvVulkanDescriptorSet.Create(fVulkanDescriptorPool,
                                                                   fVulkanDescriptorSetLayout);

    For J:=0 to fDescriptorCol.Count-1 do
    Begin
      SD := fDescriptorCol.Items[J].fDescriptor;
      If assigned(SD) then
         SD.WriteToDescriptorSet(fVulkanDescriptorSets[I],
                                 I,    // frame index
                                 J);   //binding
    End;

    fVulkanDescriptorSets[I].Flush;

  end ;

  fActive := (fVulkanDescriptorSetLayout<>Nil);  //MUST stay here

end;

procedure TvgDescriptorSet.SetFrameCount(const Value: TvkUint32);
begin
  If fFrameCount = Value then exit;
  SetActiveState(False);
  fFrameCount := Value;
end;

procedure TvgDescriptorSet.SetUpShaderData;
 var    I    : Integer;
      SD     : TvgDescriptor;
begin

    For I:=0 to fDescriptorCol.Count-1 do
    Begin
      SD := fDescriptorCol.Items[I].fDescriptor;
      If assigned(SD) then
      Begin
       Try
        If SD.LockData(-1,False) then
           SD.SetupData;
       Finally
         SD.UnLockData(-1);
       End;
      End;
    End;


end;

{ TvgShaderData }

procedure TvgDescriptor.Assign(Source: TPersistent);
  Var DIS:TvgDescriptor;
begin

  If source is TvgDescriptor then
  Begin
     DIS := TvgDescriptor(Source);
     fActive         := False ;
     fFrameCount     := DIS.fFrameCount ;
     fUseStaging     := DIS.fUseStaging ;
     fBindingFlags   := DIS.fBindingFlags ;
     fDescriptorType := DIS.fDescriptorType ;
     fExtendedBinding:= DIS.fExtendedBinding ;
     fLayoutFlags    := DIS.fLayoutFlags ;
     fStageFlags     := DIS.fStageFlags ;

  end else
     inherited Assign(Source);

end;

constructor TvgDescriptor.Create(AOwner: TComponent);
  Var I:Integer;
begin
  inherited Create(aOwner);

  fUseStaging := True;

  fFrameCount := MaxFramesInFlight;

  Setlength(fSection, fFrameCount);
  For I:= 0 to  fFrameCount-1 do
     fSection[I]    := TvgCriticalSection.Create;

  Setlength(fUploadNeeded, fFrameCount);
  SetUploadFlags ;

end;

destructor TvgDescriptor.Destroy;
  Var I:Integer;
begin
  Setlength(fUploadNeeded,0);

  For I:=0 to Length(fSection)-1 do
  Begin
    If assigned(fSection[I]) then
    Begin
      fSection[I].Release;
      FreeAndNil(fSection[I]);
    End;
  End;

  inherited;
end;

function TvgDescriptor.GetActive: Boolean;
begin
  Result := fActive;
end;

function TvgDescriptor.GetDevice: TvgLogicalDevice;
begin
  Result := fDevice
end;

function TvgDescriptor.GetFrameCount: TvkUint32;
begin
  Result := fFrameCount;
end;

class function TvgDescriptor.GetPropertyName: String;
begin
  Result := 'DescriptorData';
end;

function TvgDescriptor.GetShaderDescriptorStringTemplate_Fragment(aSet, aBinding : TvkUInt32): String;
begin
  Result := '';
end;

function TvgDescriptor.GetShaderDescriptorStringTemplate_Geometry(aSet, aBinding : TvkUInt32): String;
begin
  Result := '';
end;

function TvgDescriptor.GetShaderDescriptorStringTemplate_Vertex(aSet, aBinding : TvkUInt32): String;
begin
  Result := '';
end;

function TvgDescriptor.GetUploadNeeded(Index: Integer): Boolean;
begin
  If (Index>-1) and (index<Length(fUploadNeeded)) then
     Result := fUploadNeeded[Index]
  else
     Result := False;
end;

procedure TvgDescriptor.SetActive(const Value: Boolean);
begin
 If fActive = Value then exit;
 SetActiveState(Value);
end;

procedure TvgDescriptor.SetCurrentFrame(const Value: TvkUint32);
begin
  fCurrentFrame := Value;
  //do not set disabled


end;

procedure TvgDescriptor.SetDescriptor(Value: TvgDescriptorItem);
begin
  If self.fDescriptorItem=Value then exit;
  SetActiveState(False);
  fDescriptorItem:=Value;
end;

procedure TvgDescriptor.SetDevice(const Value: TvgLogicalDevice);
begin
  If fDevice = Value then exit;
  SetActiveState(False);
  fDevice := Value;
end;

procedure TvgDescriptor.SetDisabled;
begin
  inherited;

end;

procedure TvgDescriptor.SetEnabled(aComp: TvgBaseComponent);
begin
  SetUploadFlags;
  inherited;

end;

procedure TvgDescriptor.SetFrameCount(const Value: TvkUint32);
begin
  If fFRameCount=Value then exit;

  If Value = 0 then
     fFrameCount := MaxFramesInFlight
  else
     fFrameCount := Value;
end;

procedure TvgDescriptor.SetResourceType(const Value: TvgResourceType);
begin
  If  fResourceType = Value then exit;
  SetActiveState(False);
  fResourceType := Value;
end;

Function TvgDescriptor.LockData(aFrame:Integer; aWaitFor: Boolean=False):Boolean;
  Var I:Integer;
begin
  Result:=False;
  If (aFrame<0) or (aFrame>=Length(fSection)) then
  Begin
    For I:=0 to High(fSection) do
    Begin
      If aWaitFor then
      Begin
         fSection[I].Enter ;
         Result := True;
      end else
         Result := fSection[I].TryEnter;
    End;
  End else
  Begin
      If aWaitFor then
      Begin
         fSection[aFrame].Enter ;
         Result := True;
      end else
         Result := fSection[aFrame].TryEnter;
  End;
end;

procedure TvgDescriptor.SetupData;
begin
  //see descendants
end;

procedure TvgDescriptor.SetUploadFlags;
  Var I:Integer;
begin
  If Length(fUploadNeeded)=0 then exit;
  For I:= 0 to Length(fUploadNeeded)-1 do
    fUploadNeeded[I]:=True;
end;

procedure TvgDescriptor.SetUploadNeeded(Index: Integer; const Value: Boolean);
begin
  If (Index>-1) and (index<Length(fUploadNeeded)) then
     fUploadNeeded[Index] := Value;
end;

function TvgDescriptor.UnLockData(aFrame:Integer): Boolean;
  Var I:Integer;
begin
  If (aFrame<0) or (aFrame>=Length(fSection)) then
  Begin
    For I:= 0 to High(fSection) do
      fSection[I].Leave;
    Result      := True;
  End else
  Begin
    fSection[aFrame].Leave;
    Result      := True;
  End;
end;

{ TvgResourceUniformBuffer }

constructor TvgDescriptor_UBO.Create(AOwner: TComponent);
begin
  inherited;

//  fStageFlags      := VK_SHADER_STAGE_VERTEX_BIT;


end;

procedure TvgDescriptor_UBO.SetDisabled;
  Var I,L : Integer;
begin
  Inherited;

  fActive := False;

  L:= Length(fVulkanBuffer)  ;

  If L>0 then
  Begin
    For I:=0 to L-1 do
    Begin
      If assigned(fVulkanBuffer[I]) then
         FreeAndNil(fVulkanBuffer[I]);
    End;

    SetLength(fVulkanBuffer,0) ;

  End;

end;

procedure TvgDescriptor_UBO.SetEnabled(aComp: TvgBaseComponent);
  Var SZ  : TVkDeviceSize;
      I,L : Integer;

begin
  Inherited;

  If fActive then exit;

  SZ := GetSize;
  L  := GetFrameCount  ;
  If L=0 then L:=1;

  Try
    Assert(assigned(fDescriptorItem),'No Descriptor Item connected.');
    Assert(assigned(fDescriptorItem.Device),'No device connected.');

    Assert(assigned(fDescriptorItem.Device.VulkanDevice),'Vulkan Device not available.');
    Assert(SZ>0,'No data assigned.');

    SetLength(fVulkanBuffer, L);

    For I:= 0 to L-1 do
    Begin

      fVulkanBuffer[I] := TpvVulkanBuffer.Create(fDescriptorItem.Device.VulkanDevice,                  //TpvVulkanDevice;
                                              SZ,                   //TVkDeviceSize;
                                              fBufferUsageFlags,    //TVkBufferUsageFlags;
                                              fBufferSharingMode,   // TVkSharingMode;
                                              [],         // QueueFamilyIndices:array of TvkUint32;
                                              TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT) or
                                              TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT), // MemoryRequiredPropertyFlags:TVkMemoryPropertyFlags;
                                              0,                                                  // MemoryPreferredPropertyFlags:TVkMemoryPropertyFlags;
                                              0,                                                  // MemoryAvoidPropertyFlags:TVkMemoryPropertyFlags;
                                              0,//TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT),   // MemoryPreferredNotPropertyFlags:TVkMemoryPropertyFlags;
                                              0,                                                  // MemoryRequiredHeapFlags:TVkMemoryHeapFlags;
                                              0,                                                  // MemoryAvoidHeapFlags:TVkMemoryHeapFlags;
                                              0,                                                  // MemoryPreferredNotHeapFlags:TVkMemoryHeapFlags;
                                              0,                                                  // MemoryPreferredNotHeapFlags:TVkMemoryHeapFlags;
                                              [TpvVulkanBufferFlag.PersistentMapped]) ;          // TpvVulkanBufferFlags


    end;
    fActive := True;

  Except
    On E:Exception do
    Begin
      fActive:=False;
      Raise;
    End;
  End;


end;

procedure TvgDescriptor_UBO.UpLoadDescriptorData(aIndex:TvkUint32;
                                                aGraphicPool:TvgCommandBufferPool;
                                               aTransferPool:TvgCommandBufferPool);


  Var Queue      : TpvVulkanQueue;
      aCommand   : TvgCommandBuffer;
      Data       : Pointer;
      DSize      : TvkUint32;
      StageMode  : TpvVulkanBufferUseTemporaryStagingBufferMode;

begin

    If not fUploadNeeded[aIndex] then exit;

    Assert((Length(fVulkanBuffer)>0), 'Buffers not assigned');

    Assert(assigned(aTransferPool),'Transfer Buffer Pool NOT assigned');

    Assert(assigned(fDescriptorItem),'No Descriptor Item connected.');
    Assert(assigned(fDescriptorItem.Device),'No device connected.');

    If not assigned(fDescriptorItem.Device.VulkanDevice) then
       fDescriptorItem.Device.Active:=True;

    Assert(assigned(fDescriptorItem.Device.VulkanDevice),'Vulkan Device not available.');

    Queue := aTransferPool.Queue[aIndex];
    Assert(Assigned(Queue),'Queue NOT available.');

    DSize := GetSize;
    If DSize=0 then exit;

    Data := GetDataPointer(aIndex);
    Assert( (Data<>Nil),'No data available');

    aCommand        := aTransferPool.RequestCommand(0,0,CB_PRIMARY,false,[BU_SIMULTANEOUS_USE_BIT]); //will reset if required
    aCommand.Active := True;

    If fUseStaging then
      StageMode     :=  TpvVulkanBufferUseTemporaryStagingBufferMode.Yes
    else
      StageMode     :=  TpvVulkanBufferUseTemporaryStagingBufferMode.Automatic;

  Try

       if fDescriptorItem.Device.VulkanDevice.MemoryManager.CompleteTotalMemoryMappable then
         begin
            fVulkanBuffer[aIndex].UploadData(Queue,
                                              aCommand.VulkanCommandBuffer,
                                              aCommand.BufferFence,
                                              Data^,
                                              0,
                                              DSize,
                                              StageMode);//TpvVulkanBufferUseTemporaryStagingBufferMode.No);
            aCommand.SetBufferState(BS_EXECUTABLE,True);
         end else
         begin
            fDescriptorItem.Device.VulkanDevice.MemoryStaging.Upload(Queue,
                                                                 aCommand.VulkanCommandBuffer,
                                                                 aCommand.BufferFence,
                                                                 Data^,
                                                                 fVulkanBuffer[aIndex],
                                                                 0,
                                                                 DSize);
            aCommand.SetBufferState(BS_EXECUTABLE,True);
         end;


      fUploadNeeded[aIndex]:=False;

  Finally
  //  aTransferPool.ReleaseCommand(aCommand);

  End;
end;

procedure TvgDescriptor_UBO.WriteToDescriptorSet( aSet: TpvVulkanDescriptorSet; aFrameIndex, aBinding: TvkUint32);
begin
  Assert(assigned( aSet), 'Descriptor Set not assigned') ;
  Assert(assigned( fVulkanBuffer[aFrameIndex]), 'Vulkan Buffer not created') ;

  aSet.WriteToDescriptorSet( aBinding,
                             0,
                             1,
                             fDescriptorType,
                             [],
                             [fVulkanBuffer[aFrameIndex].DescriptorBufferInfo],
                             [],
                             False); //important

end;

{ TvgResourceTexture }

procedure TvgDescriptor_Texture.Assign(Source: TPersistent);
  Var DL :TvgDescriptor_Texture;
begin
  inherited assign(Source); //must stay here

  If (Source is TvgDescriptor_Texture) then
  Begin
    DL := TvgDescriptor_Texture(Source);

    fFileName    := DL.fFileName;
    fFrameCount  := DL.fFrameCount;
    fWrapModeU   := DL.fWrapModeU;
    fWrapModeV   := DL.fWrapModeV;
    fWrapModeW   := DL.fWrapModeW;
    fBorderColor := DL.fBorderColor;

  End;
end;

constructor TvgDescriptor_Texture.Create(AOwner: TComponent);
begin
  inherited;
  Name         := 'TexRect';

  fSampler      := TvgSampler.Create(self);
  fSampler.SetSubComponent(True);
  fSampler.Name := 'Sampler';

  fDescriptorType   := VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER;//VK_DESCRIPTOR_TYPE_SAMPLED_IMAGE;

  fStageFlags       :=  TVkShaderStageFlags(VK_SHADER_STAGE_FRAGMENT_BIT);

  fFrameCount       := 1;
  //Default  Leave here OPnly need ONE copy for permanant data

  fWrapModeU    := TpvVulkanTextureWrapMode.ClampToBorder;
  fWrapModeV    := TpvVulkanTextureWrapMode.ClampToBorder;
  fWrapModeW    := TpvVulkanTextureWrapMode.ClampToBorder;
  fBorderColor  := VK_BORDER_COLOR_FLOAT_TRANSPARENT_BLACK;

end;

destructor TvgDescriptor_Texture.Destroy;
begin
  If assigned(fSampler) then
    FreeAndNil(fSampler);
  inherited;
end;

function TvgDescriptor_Texture.GetBorderColor: TvgBorderColor;
begin
  Result := GetVGBorderColor(fBorderColor);
end;

function TvgDescriptor_Texture.GetFilename: String;
begin
  Result := fFileName;
end;

class function TvgDescriptor_Texture.GetPropertyName: String;
begin
  Result := 'TextureImage';
end;

function TvgDescriptor_Texture.GetShaderDescriptorStringTemplate_Fragment(aSet, aBinding: TvkUInt32): String;
begin
  Result := Format('layout(set = %d, binding = %d) uniform sampler2D ',[aSet, aBinding]);
  Result := Result + '%s'+#13+#10;
end;

function TvgDescriptor_Texture.GetWrapModeU: TpvVulkanTextureWrapMode;
begin
  Result := fWrapModeU;
end;

function TvgDescriptor_Texture.GetWrapModeV: TpvVulkanTextureWrapMode;
begin
  Result := fWrapModeV;
end;

function TvgDescriptor_Texture.GetWrapModeW: TpvVulkanTextureWrapMode;
begin
  Result := fWrapModeW;
end;

procedure TvgDescriptor_Texture.SetBorderColor(const Value: TvgBorderColor);
  Var V: TvkBorderColor ;
begin
  V:= GetVKBorderColor(Value);
  If fBorderColor=V then exit;
  SetActiveState(False);
  fBorderColor := V;
end;

procedure TvgDescriptor_Texture.SetDevice(const Value: TvgLogicalDevice);
begin
  Inherited;

  If assigned(fSampler) then
    fSampler.Device := fDevice;

end;

procedure TvgDescriptor_Texture.SetDisabled;
  Var I,L:Integer;
begin
  inherited;

  If assigned(fSampler) then
     fSampler.SetActiveState(False);

  fActive := False;

  L:= Length(fVulkanTexture) ;
  If L>0 then
  Begin
    For I:=0 to  L-1 do
    Begin
      If assigned(fVulkanTexture[I]) then
       FreeAndNil(fVulkanTexture[I]);
    End;

    SetLength(fVulkanTexture,0);
  End;

end;

procedure TvgDescriptor_Texture.SetEnabled(aComp: TvgBaseComponent);
  Var I : Integer;
      F : String;
      FS: TFileStream;
      D : TpvVulkanDevice;

    Procedure LoadVulkanTexture(aIndex:Integer);
    Begin
      fVulkanTexture[aIndex] := TpvVulkanTexture.Create(D);

      fVulkanTexture[aIndex].LoadFromImage(FS,
                                      True,
                                      False,
                                      True );

      fUploadNeeded[aIndex] := True;
    End;

begin

  Inherited;

  fActive := False;

  Assert(assigned( fDescriptorItem),'Descriptor Item Not assigned');
  Assert(assigned( fDescriptorItem.Device),'Descriptor Item Device Not assigned');
  Assert(assigned( fDescriptorItem.Device.VulkanDevice),'Descriptor Item Device Not Active');

  D := fDescriptorItem.Device.VulkanDevice;
  fDevice := fDescriptorItem.Device;

  If fFileName='' then exit;
  F:= Trim(fFileName) ;
  if not FileExists(F) then
  Begin
    F := TextureFolderPath + F;
    if not FileExists(F) then
      Exit;
  End;

  FS:=TFileStream.Create(F, fmOpenRead);
  If FS.Size=0 then
  Begin
    FreeAndNil(FS);
    Exit;
  end;

 Try

   If assigned(fSampler) then
   Begin
      If fSampler.Device<>fDevice then
         fSampler.Device  := fDevice;
      fSampler.FrameCount := fFrameCount;
      fSampler.SetEnabled;
   End;

    SetLength( fVulkanTexture, fFrameCount);
    SetLength( fUploadNeeded, fFrameCount);

    For I:=0 to fFrameCount-1 do
      LoadVulkanTexture(I);

  fActive := True;

 Finally
   FreeAndNil(FS);
 End;

end;

procedure TvgDescriptor_Texture.SetFileName(const Value: String);
begin
  If CompareStr(fFileName , Value)=0 then exit;
  SetActiveState(False);
  fFileName := Value;
end;

procedure TvgDescriptor_Texture.SetFrameCount(const Value: TvkUint32);
begin
  fFrameCount := 1;   //Only want ONE
end;

procedure TvgDescriptor_Texture.SetWrapModeU( const Value: TpvVulkanTextureWrapMode);
begin
  If fWrapModeU = Value then exit;
  SetActiveState(False);
  fWrapModeU := Value;
end;

procedure TvgDescriptor_Texture.SetWrapModeV( const Value: TpvVulkanTextureWrapMode);
begin
  If fWrapModeV = Value then exit;
  SetActiveState(False);
  fWrapModeV := Value;
end;

procedure TvgDescriptor_Texture.SetWrapModeW( const Value: TpvVulkanTextureWrapMode);
begin
  If fWrapModeW = Value then exit;
  SetActiveState(False);
  fWrapModeW := Value;
end;

procedure TvgDescriptor_Texture.UpLoadDescriptorData(aIndex: TvkUint32;
                                                aGraphicPool:TvgCommandBufferPool;
                                               aTransferPool:TvgCommandBufferPool);

  Var I : Integer;
      D : TpvVulkanDevice;
      GQ,
      TQ: TpvVulkanQueue;
      GV,
      TV: TvgCommandBuffer;

    Procedure UploadVulkanTexture(aIndex:Integer);
    Begin

      GV := aGraphicPool.RequestCommand(0,0,CB_PRIMARY,False,[BU_SIMULTANEOUS_USE_BIT]);
      If assigned(GV) then
         GV.Active:=True;

      TV := aTransferPool.RequestCommand(0,0,CB_PRIMARY,False,[BU_SIMULTANEOUS_USE_BIT]);
      If assigned(TV) then
         TV.Active:=True;

       fVulkanTexture[aIndex].Finish (GQ,
                                      GV.VulkanCommandBuffer,
                                      GV.BufferFence,
                                      TQ,
                                      TV.VulkanCommandBuffer,
                                      TV.BufferFence);

      GV.SetBufferState(BS_EXECUTABLE,True);
      TV.SetBufferState(BS_EXECUTABLE,True);

      If assigned(fSampler) then
        fVulkanTexture[aIndex].Sampler := fSampler.fVulkanSampler[aIndex];

       fUploadNeeded[aIndex]           := False;
    End;

begin

  Assert( assigned( fDescriptorItem),'Item not assigned');
  Assert(assigned( fDescriptorItem.Device),'Item Device not assigned');
  Assert(assigned( fDescriptorItem.Device.VulkanDevice),'Item Device not Active');
  Assert(assigned( fDescriptorItem.Collection),'');

  Assert(assigned( aGraphicPool   ),'Graphic Pool not assigned');
  Assert(assigned( aTransferPool   ),'Transfer Pool not assigned');
  Assert((fSampler.fActive = True),'Sampler NOT active');

  Try
    D := fDescriptorItem.Device.VulkanDevice;

    GQ:=D.GraphicsQueue;
    TQ:=D.TransferQueue;

    For I:=0 to fFrameCount-1 do
      If fUploadNeeded[I] then
         UploadVulkanTexture(I);

 Finally

 End;


end;

procedure TvgDescriptor_Texture.WriteToDescriptorSet(aSet: TpvVulkanDescriptorSet;  aFrameIndex, aBinding: TvkUint32);
  Var VT : TpvVulkanTexture;
      L  : TvkUint32;
      DS : TvgDescriptorSet;
begin
  Assert(Assigned(aSet), 'Vulkan Descriptorset NOT assigned.');

  If Length(fVulkanTexture)<>0 then
  Begin
      Assert(Assigned(fDescriptorItem),'Descriptor Item NOT assigned');
      Assert(Assigned(fDescriptorItem.Collection),'Descriptor Item Collection NOT assigned');

      DS := TvgDescriptorCol(fDescriptorItem.Collection).DescriptorSet ;

      UpLoadDescriptorData(aFrameIndex,
                            DS.fDSGraphicCommandPool,
                            DS.fDSTransferCommandPool);
  end;

  L := Length(fVulkanTexture);
  If (aFrameIndex<L)  then
     VT := fVulkanTexture[aFrameIndex]
  else
  If L=1 then
     VT := fVulkanTexture[0]
  else
     Exit;

  Assert(Assigned(VT),'Vulkan Texture NOT available');

  If  (VT.DescriptorImageInfo.Sampler>0)  then
     fDescriptorType := VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER
  else
     fDescriptorType := VK_DESCRIPTOR_TYPE_STORAGE_TEXEL_BUFFER;

  aSet.WriteToDescriptorSet( aBinding,
                             0,
                             1,
                             fDescriptorType,
                             [VT.DescriptorImageInfo],
                             [],
                             [],
                             False);

end;

{ TvgThreadWorker }

procedure TvgRenderWorker.BindDescriptors_Node;
begin
  If Not assigned(fCurrentPipe) then exit;

  fCurrentPipe.BindNodeResources(fGraphicCommandPool.CommandBuffer[fFrameIndex,fSubPassIndex],
                                        //   fTaskData.Commands,
                                           fWorkerIndex,
                                           fSubPassIndex,
                                           fTaskData.RenderNode);
end;

procedure TvgRenderWorker.BindDescriptors_Pipe;
begin
  If Not assigned(fCurrentPipe) then exit;

  fCurrentPipe.BindPipelineResources(fGraphicCommandPool.CommandBuffer[fFrameIndex,fSubPassIndex],
                                           fWorkerIndex,
                                           fSubPassIndex);
end;

procedure TvgRenderWorker.BindPipeLine;
begin

  If (fCurrentPipe<>Nil) and  (fCurrentPipe = fTaskData.GraphicPipe) then exit;  //task pipe is currently bound

  fCurrentPipe :=  fTaskData.GraphicPipe;
  If Not assigned(fCurrentPipe) then exit;

  Assert(assigned(fCurrentCommandBuffer),'Graphic Command NOT available');

  fCurrentPipe.BindPipeline(fCurrentCommandBuffer,
                         //   fTaskData.Commands,
                            fWorkerIndex,
                            fFrameIndex);

  BindDescriptors_Pipe ;
end;

procedure TvgRenderWorker.BuildCommand;

begin

  Assert(assigned(fTaskData.RenderNode),'Render Node nort assigned to Task');
  Assert(assigned(fLinker),'Window Link NOT assigned');
  Assert((fLinker.Active=True),'Window Link NOT Active');
  Assert((fLinker.ScreenDevice.Active=True),'Screen Device NOT Active');
  Assert( assigned(fGraphicCommandPool),'Command Pool not assigned');

  Assert(assigned(fCurrentCommandBuffer),'Working Command not created');

  inc(fRenderCount);
     //count of render node draw commands

  fTaskData.RenderNode.RecordVulkanCommand(fCurrentCommandBuffer,
                                      //     fTaskData.Commands,
                                      //     fWorkerIndex,
                                           fSubPassIndex );

                  //      finish  need to get current/required PIPE
end;

procedure TvgRenderWorker.UploadDataToVulkan;
begin
  Assert(assigned(fTaskData.RenderNode),'Render Node nort assigned to Task');

  Assert(assigned(fLinker),'Window Link not assigned to Worker');
  Assert(assigned(fLinker.ScreenDevice),'Window Link Screen Device not assigned to Worker');
  Assert(assigned(fLinker.ScreenDevice.VulkanDevice),'Window Link Screen Device not Active');

  Assert(assigned(fTransferCommandPool),'Transfer Command Pool not assigned');


  If fTaskData.RenderNode.fUploadNeeded  then
  Begin
    If assigned(fEngineCriticalSection) then
       fEngineCriticalSection.Acquire;
    Try
      fTaskData.RenderNode.UploadAllData(fTransferCommandPool);

    Finally
      If assigned(fEngineCriticalSection) then
         fEngineCriticalSection.Release;
    End;
  End;
end;

procedure TvgRenderWorker.UploadResourceDataToVulkan;
begin

  Assert(assigned(fLinker),'Window Link not assigned to Worker');
  Assert(assigned(fLinker.ScreenDevice),'Window Link Screen Device not assigned to Worker');
  Assert(assigned(fLinker.ScreenDevice.VulkanDevice),'Window Link Screen Device not Active');
  Assert(assigned(fFrame),'Frame not connected');

  If assigned(fTaskData.Resources) then
  Begin
      If assigned(fEngineCriticalSection) then fEngineCriticalSection.Acquire;
     Try
      fTaskData.Resources.UploadDescriptorSetData(fFrameIndex)
     Finally
      If assigned(fEngineCriticalSection) then fEngineCriticalSection.Release;
     End;
  end else
  If assigned(fTaskData.RenderNode) then
  Begin

     If assigned(fTaskData.RenderNode.MaterialRes[fSubPassIndex]) then
     Begin
        If assigned(fEngineCriticalSection) then fEngineCriticalSection.Acquire;
       Try
        fTaskData.RenderNode.MaterialRes[fSubPassIndex].UploadDescriptorSetData(fFrameIndex)  ;
       Finally
        If assigned(fEngineCriticalSection) then fEngineCriticalSection.Release;
       End;
     End;

     If assigned(fTaskData.RenderNode.ModelRes[fSubPassIndex]) then
     Begin
        If assigned(fEngineCriticalSection) then fEngineCriticalSection.Acquire;
       Try
        fTaskData.RenderNode.ModelRes[fSubPassIndex].UploadDescriptorSetData(fFrameIndex)
       Finally
        If assigned(fEngineCriticalSection) then fEngineCriticalSection.Release;
       End;
     End;
  End;
end;

function TvgRenderWorker.BuildCommandAndStartRecording: Boolean;
  Var Info  : TVkCommandBufferInheritanceInfo;
begin

  fRenderCount := 0;
  Result       := False;

  fGraphicCommandPool.RequestCommand(fFrameIndex, fSubPassIndex ,CB_SECONDARY, True,[BU_SIMULTANEOUS_USE_BIT, BU_RENDER_PASS_CONTINUE_BIT]);

  Assert(assigned( fGraphicCommandPool.CurrentCommand),'Graphic Buffer NOT assigned');

  fCurrentCommandBuffer := fGraphicCommandPool.CurrentCommand;

  fCurrentCommandBuffer.Active := True;

  FillChar(Info,SizeOf(Info),#0);

  Info.sType      := VK_STRUCTURE_TYPE_COMMAND_BUFFER_INHERITANCE_INFO;
  Info.pNext      := nil;
  Info.renderPass := fRenderer.Renderpass.RenderPassHandle;
  Info.subpass    := fSubPassIndex;        //current SubPass
  Info.framebuffer:= fFrameBufferHandle;

  fCurrentCommandBuffer.BeginRecording(@Info);

  Result := (fCurrentCommandBuffer.fBufferState=BS_RECORDING);

end;

Function TvgRenderWorker.CompleteTask(aTask: TvgRenderTask):TvgRenderTaskStatus;
 // Var I:Integer;
begin
  Result := TS_NONE;

  Assert(Assigned(fRenderer),'Renderer NOT assigned');
  Assert(Assigned(fLinker),'Linker NOT assigned');

  If not fActive then
     SetEnabled;

  fTaskData :=  aTask;

  If fTaskData.TaskJob = TM_UPLOADRESOURCEDATA then
    Assert(assigned(fTaskData.Resources),'Resource not assigned to Task')
  else
  If fTaskData.TaskJob = TM_RENDER_NODE then
    Assert(assigned(fTaskData.RenderNode),'Render Node not assigned to Task');

 //change Frame
  If (fFrame<>aTask.Frame) then
  Begin
      fCurrentPipe := Nil;
      fCurrentNode := Nil;
      fCurrentCommandBuffer := Nil;
      fRecordingON := False;

      fFrame     := aTask.Frame;
      assert(assigned(fFrame),'Frame NOT connected');

      If assigned(fFrame) then
      Begin
        fFrameIndex    := fFrame.FrameIndex;

        If assigned(fGraphicCommandPool) and (fGraphicCommandPool.FrameIndex<>fFrameIndex) then
           fGraphicCommandPool.FrameIndex := fFrameIndex;

        If assigned(fTransferCommandPool) and (fTransferCommandPool.FrameIndex<>fFrameIndex) then
           fTransferCommandPool.FrameIndex := fFrameIndex;
      end else
        fFrameIndex:=0;
  End;

  //change Render SubPass
  If  (fSubPassIndex <> fTaskData.SubPassIndex) then
  Begin
    fCurrentPipe := Nil;
    fCurrentNode := Nil;
    fCurrentCommandBuffer := Nil;
    fRecordingON := False;

    fSubPassIndex      := fTaskData.SubPassIndex;

    If assigned(fGraphicCommandPool) and (fGraphicCommandPool.FrameIndex<>fFrameIndex) then
       fGraphicCommandPool.SubpassIndex := fSubPassIndex;

    If assigned(fTransferCommandPool) and (fTransferCommandPool.FrameIndex<>fFrameIndex) then
       fTransferCommandPool.SubpassIndex := fSubPassIndex;
  End;

  fFrameBufferHandle :=  {fFrame.FrameBufferHandle;// }fRenderer.ScreenFrameBufferHandle[fTaskData.ImageIndex]  ;  //ok

  fEngineCriticalSection := fTaskData.CriticalSection;

  fCurrentNode       := fTaskData.RenderNode;
  fRenderPassHandle  := fRenderer.RenderPass.fRenderPassHandle;

 //ORDER and SEQUENCE  is IMPORTANT
 Try

  Case aTask.TaskJob of
  //main thread tasks
    TM_UPLOADDATA        : Begin
    //called for each Node
                             UploadDataToVulkan;
                             Result := TS_COMPLETE;
                           End;
    TM_UPLOADRESOURCEDATA: Begin
    //called for each Resource
                             UploadResourceDataToVulkan;
                             Result := TS_COMPLETE;
                           End;

  //below are threaded tasks
    TM_BEGIN_RECORDING_FRAME    : Begin
     //called on each thread
                              fRecordingOn := BuildCommandAndStartRecording;
                              Result       := TS_COMPLETE;
                           End;
    TM_BIND_PIPELINE      : begin
    //called on each thread
                              If not fRecordingOn then
                                 fRecordingOn := BuildCommandAndStartRecording;
                             If fRecordingOn then
                             Begin
                               BindPipeLine;
                               Result := TS_COMPLETE;
                             end;
                           end;
    TM_RENDER_NODE        : Begin     //Must be in recording state
    //called for each NODE and picked up by available thread
                              If not fRecordingOn then
                                 fRecordingOn := BuildCommandAndStartRecording;
                             CreateDataBuffer;
                             UploadDataToVulkan;
                             UploadResourceDataToVulkan;
                             If fRecordingOn then
                             Begin
                             //  BindPipeLine;                        //only if Graphic Pipe has  changed
                               BindDescriptors_Node ;
                               BuildCommand;
                               Result := TS_COMPLETE;
                             end;
                           End;
    TM_END_RECORDING_FRAME  : Begin
    //called on each thread
                             If {fRecordingOn and} EndCommandRecording then
                               Result       := TS_COMPLETE
                             else
                               Result       := TS_FAIL;
                             fRecordingOn := False;
                           End;
    TM_EXECUTE_SECONDARY : Begin
    //called on each thread
                             If fRecordingOn and EndCommandRecording then
                               fRecordingOn := False;
                             ExecuteSecondaryCommand   ;                     //called on each thread
                             Result := TS_COMPLETE;

                           End;
    TM_RESET             : Begin
    //called on each thread
                             Result                := TS_COMPLETE;
                             fCurrentPipe          := Nil;
                             fCurrentNode          := nil;
                             fCurrentCommandBuffer := nil;
                             FillChar(fTaskData,SizeOf(fTaskData),#0);
                             fRecordingON          := False;
                           End;
  end;
 Except
    On E:Exception do
    Begin
      Result := TS_FAIL;
    End;
 End;
end;

constructor TvgRenderWorker.Create(aWorkerIndex:Integer);
begin
  Inherited Create;

  fWorkerIndex           := aWorkerIndex;
  fEngineCriticalSection := nil;

end;

procedure TvgRenderWorker.CreateDataBuffer;
begin
  Assert(assigned(fTaskData.RenderNode),'Render Node not assigned to Task');

  fTaskData.RenderNode.CreateDataBuffer;
end;

procedure TvgRenderWorker.ActivateVulkanPipeline;
begin
  Assert(assigned(fCurrentPipe),'Graphic pipeline not assigned to Worker');

  fCurrentPipe.Active := True;

end;

destructor TvgRenderWorker.Destroy;
begin
  SetDisabled;  //important
  inherited;

end;

function TvgRenderWorker.EndCommandRecording : Boolean;

begin
  Result := False;
  If not assigned(fCurrentCommandBuffer) then exit;

  fCurrentCommandBuffer.EndRecording;

  Result  := fCurrentCommandBuffer.fBufferState=BS_EXECUTABLE;

end;

procedure TvgRenderWorker.ExecuteSecondaryCommand;

begin
  assert(assigned(fCurrentCommandBuffer),'Working command buffer not assigned');

  //no need to execute command

   //execute worker commande
  If assigned(fCurrentCommandBuffer) and
     assigned(fCurrentCommandBuffer.fVulkanCommandBuffer) then
  Begin
      If assigned(fEngineCriticalSection) then
         fEngineCriticalSection.Acquire;                           // fix

    Try
     fFrame.FrameCommandBuffer.CmdExecuteCommands( 1,
                                                  @fCurrentCommandBuffer.fVulkanCommandBuffer.Handle);
       //check
    Finally

      If assigned(fEngineCriticalSection) then
         fEngineCriticalSection.Release;

    End;

  end;
end;

function TvgRenderWorker.GetActive: Boolean;
begin
  Result:=fActive;
end;

procedure TvgRenderWorker.SetActive(const Value: Boolean);
begin
  If fActive=Value then exit;

  SetDisabled;
  fActive := Value;
  If fActive then
     SetEnabled;
end;

procedure TvgRenderWorker.SetDisabled;

begin

  fActive := False;

  If assigned(fTransferCommandPool) then
  Begin
    fTransferCommandPool.ReleaseAllCommands(True);
    fTransferCommandPool.Active := False;
    FreeAndNil(fTransferCommandPool);
  End;

//  If assigned(fGraphicFence) then
//     FreeAndNil(fGraphicFence);

  If assigned(fGraphicCommandPool) then
  Begin
    fGraphicCommandPool.ReleaseAllCommands(True);
    fGraphicCommandPool.Active := False;
    FreeAndNil(fGraphicCommandPool);
  End;

  fCurrentNode := Nil;
  fCurrentPipe := nil;
  fCurrentCommandBuffer := Nil;
  fFrameIndex  := 0;
  fSubPassIndex:= 0;

end;

procedure TvgRenderWorker.SetEnabled(aComp: TvgBaseComponent);

begin
  Assert(assigned(fLinker),'Window Link not assigned');
  Assert((fLinker.Active=True),'Window Link not Active');

  If Not assigned(fRenderer) then
     fRenderer := fLinker.Renderer;

  Assert(assigned(fRenderer),'Renderer not assigned');
  Assert(assigned(fRenderer.RenderPass),'Renderer Renderpass not assigned');

  fSubPassCount :=  fRenderer.RenderPass.SubPasses.count;
  If fSubPassCount=0 then
     fSubPassCount := 1;
  fSubPassIndex :=0;

  fFrameCount := fLinker.FrameCount;
  fFrameIndex := 0;

  If not assigned(fGraphicCommandPool) then
  Begin
    fGraphicCommandPool                 := TvgCommandBufferPool.Create(nil);
    fGraphicCommandPool.Name            := 'GP';
    fGraphicCommandPool.SetSubComponent(True);
    fGraphicCommandPool.Device          := fLinker.ScreenDevice ;
    fGraphicCommandPool.QueueFamilyType := VGT_GRAPHIC ;
    fGraphicCommandPool.QueueCreateFlags:= [CP_TRANSIENT,
                                            CP_RESET_COMMAND_BUFFER];
  End;

  fGraphicCommandPool.SetUpBufferArrays(fFrameCount,fSubPassCount);
  fGraphicCommandPool.Active  := True;

//  fGraphicFence    := TpvVulkanFence.Create(fLinker.ScreenDevice.VulkanDevice);

  If not assigned(fTransferCommandPool) then
  Begin
    fTransferCommandPool                 := TvgCommandBufferPool.Create(nil);
    fTransferCommandPool.Name            := 'TP';
    fTransferCommandPool.SetSubComponent(True);
    fTransferCommandPool.Device          := fLinker.ScreenDevice ;
    fTransferCommandPool.QueueFamilyType := VGT_TRANSFER ;
    fTransferCommandPool.QueueCreateFlags:= [CP_TRANSIENT,
                                             CP_RESET_COMMAND_BUFFER];
  End;

  fTransferCommandPool.SetUpBufferArrays(fFrameCount,fSubPassCount);
  fTransferCommandPool.Active:= True;

  fCurrentPipe := nil;
  fCurrentNode := Nil;

  fActive := True;

end;

procedure TvgRenderWorker.SetRenderer(const Value: TvgRenderEngine);
begin
  If fRenderer=Value then exit;
  SetDisabled;

  fRenderer := Value;
  If assigned(fRenderer) then
    fLinker   := fRenderer.linker
  else
    fLinker   := nil;
end;

{ TvgGraphicPipeLists }

function TvgGraphicPipeLists.Add: TvgGraphicPipeItem;
begin
  Result := TvgGraphicPipeItem(inherited Add);

end;

function TvgGraphicPipeLists.AddItem(Item: TvgGraphicPipeItem; Index: Integer): TvgGraphicPipeItem;
begin
  if Item = nil then
    Result := TvgGraphicPipeItem.Create(self)
  else
    Result := Item;

  if Assigned(Result) then
  begin
    Result.Collection := Self;
    if Index < 0 then
      Index := Count - 1;
    Result.Index := Index;
  end;
end;

constructor TvgGraphicPipeLists.Create(CollOwner: TvgRenderEngine);
begin
  inherited Create(TvgGraphicPipeItem);
  fComp := CollOwner;
end;

function TvgGraphicPipeLists.GetItem(Index: Integer): TvgGraphicPipeItem;
begin
  Result := TvgGraphicPipeItem(inherited GetItem(Index));
end;

function TvgGraphicPipeLists.GetOwner: TPersistent;
begin
  Result := fComp;
end;

function TvgGraphicPipeLists.GetRenderer: TvgRenderEngine;
begin
  Result := fComp;
end;

function TvgGraphicPipeLists.Insert(Index: Integer): TvgGraphicPipeItem;
begin
  Result := AddItem(nil, Index);
end;

procedure TvgGraphicPipeLists.SetItem(Index: Integer; const Value: TvgGraphicPipeItem);
begin
  inherited SetItem(Index, Value);
end;

procedure TvgGraphicPipeLists.Update(Item: TCollectionItem);
begin
  inherited;

end;

{ TvgGraphicPipeItem }

procedure TvgGraphicPipeItem.Assign(Source: TPersistent);
  var PI:TvgGraphicPipeItem;
begin
  If (Source is TvgGraphicPipeItem) then
  Begin
    PI := TvgGraphicPipeItem(Source) ;
    GraphicPipeType := PI.GetGraphicPipeType  ;
  End else
    inherited;

end;

constructor TvgGraphicPipeItem.Create(Collection: TCollection);
begin
  inherited Create(Collection);

end;

function TvgGraphicPipeItem.GetGraphicPipe: TvgGraphicPipeline;
begin
  Result := fGraphicPipeline;
end;

function TvgGraphicPipeItem.GetGraphicPipeName: String;
begin
  If assigned(fGraphicPipeType) then
    Result := fGraphicPipeType.GetPropertyName
  else
    Result:='<NONE>';
end;

function TvgGraphicPipeItem.GetGraphicPipeType: TvgGraphicsPipelineType;
begin
  Result := fGraphicPipeType;
end;

function TvgGraphicPipeItem.GetRenderNodeType: TvgRenderNodeType;
begin
   Result := fRenderNodeType;
end;

function TvgGraphicPipeItem.GetRenderPassType: TvgRenderPassType;
begin
  Result := fRenderPassType;
end;

function TvgGraphicPipeItem.GetSubPassRef: Integer;
begin
  Result := fSubPassRef;
end;

procedure TvgGraphicPipeItem.SetGraphicPipeName(const Value: String);
  Var I:Integer;
begin
  If assigned(fGraphicPipeType) and
    (CompareStr(Value, fGraphicPipeType.GetPropertyName)=0) then exit;

  If Value = '' then
    GraphicPipeType := nil
  else
    For I:=0 to GraphicPipeTypeList.Count-1 do
    Begin
    (*
      If CompareStr(Value, GraphicPipeTypeList.Items[I].GetPropertyName)=0 then
      Begin
        SetGraphicPipeType(GraphicPipeTypeList.Items[I]);
        Exit;
      End;
     *)
    End;
end;

procedure TvgGraphicPipeItem.SetGraphicPipeType( const Value: TvgGraphicsPipelineType);
begin
  If fGraphicPipeType=Value then exit;
  If assigned(fGraphicPipeline) then
     FreeAndNil(fGraphicPipeline);

  fGraphicPipeType := Value;

  If assigned(fGraphicPipeType) then
  Begin
    fGraphicPipeline := fGraphicPipeType.Create(TvgGraphicPipeLists(Collection).GetRenderer);
    fGraphicPipeline.Name := fGraphicPipeline.GetPropertyName;
    fGraphicPipeline.SetSubComponent(True);
  End;

end;

procedure TvgGraphicPipeItem.SetRenderNodeType(const Value: TvgRenderNodeType);
begin
  If fRenderNodeType = Value then exit;
 // SetDisabled;
  fRenderNodeType := Value;
end;

procedure TvgGraphicPipeItem.SetRenderPassType(const Value: TvgRenderPassType);
begin
  If fRenderPassType = Value then exit;
 // SetDisabled;
  fRenderPassType := Value;
end;

procedure TvgGraphicPipeItem.SetSubPassRef(const Value: Integer);
begin
  If fSubPassRef = Value then exit;
 // SetDisabled;
  fSubPassRef := Value;
end;

{ TvgSampler }

constructor TvgSampler.Create(AOwner: TComponent);
begin
  inherited;

  fFrameCount       := 1;

  fMagFilter        := VK_FILTER_LINEAR;
  fMinFilter        := VK_FILTER_LINEAR;
  fMipmapMode       := VK_SAMPLER_MIPMAP_MODE_LINEAR;
  fAddressModeU     := VK_SAMPLER_ADDRESS_MODE_REPEAT;
  fAddressModeV     := VK_SAMPLER_ADDRESS_MODE_REPEAT;
  fAddressModeW     := VK_SAMPLER_ADDRESS_MODE_REPEAT;
  fMipLodBias       := 0.0;
  fAnisotropyEnable := false;
  fMaxAnisotropy    := 1.0;
  fCompareEnable    := false;
  fCompareOp        := VK_COMPARE_OP_NEVER;
  fMinLod           := 0.0;
  fMaxLod           := 1.0;
  fBorderColor      := VK_BORDER_COLOR_FLOAT_OPAQUE_BLACK;
  fUnnormalizedCoordinates := false;
  fReductionMode    := TVkSamplerReductionMode.VK_SAMPLER_REDUCTION_MODE_WEIGHTED_AVERAGE;
end;

function TvgSampler.GetAddressModeU: TvgSamplerAddressMode;
begin
  Result := GetVGSamplerAddressMode(fAddressModeU);
end;

function TvgSampler.GetAddressModeV: TvgSamplerAddressMode;
begin
  Result := GetVGSamplerAddressMode(fAddressModeV);
end;

function TvgSampler.GetAddressModeW: TvgSamplerAddressMode;
begin
  Result := GetVGSamplerAddressMode(fAddressModeW);
end;

function TvgSampler.GetAnisotropyEnable: Boolean;
begin
  Result := fAnisotropyEnable;
end;

function TvgSampler.GetBorderColor: TvgBorderColor;
begin
  Result := GetVGBorderColor(fBorderColor);
end;

function TvgSampler.GetCompareEnable: Boolean;
begin
  Result := fCompareEnable;
end;

function TvgSampler.GetCompareOp: TvgCompareOpBit;
begin
  Result := GetVGCompareOp(fCompareOp);
end;

function TvgSampler.GetDevice: TvgLogicalDevice;
begin
  Result := fDevice;
end;

function TvgSampler.GetMagFilter: TvgFilter;
begin
  Result := GetVGFilkter(fMagFilter);
end;

function TvgSampler.GetMaxAnisotropy: TvkFloat;
begin
  Result := fMaxAnisotropy;
end;

function TvgSampler.GetMaxLod: TvkFloat;
begin
  Result := fMaxLod;
end;

function TvgSampler.GetMinFilter: TvgFilter;
begin
  Result := GetVGFilkter(fMinFilter);
end;

function TvgSampler.GetMinLod: TvkFloat;
begin
  Result := fMinLod;
end;

function TvgSampler.GetMipLodBias: TvkFloat;
begin
  Result := fMipLodBias;
end;

function TvgSampler.GetMipmapMode: TvgSamplerMipmapMode;
begin
  Result := GetVGSamplerMipmapMode(fMipmapMode);
end;

function TvgSampler.GetReductionMode: TvgSamplerReductionMode;
begin
  Result := GetVGSamplerReductionMode(fReductionMode);
end;

function TvgSampler.GetUnnormalizedCoordinates: Boolean;
begin
  Result := fUnnormalizedCoordinates;
end;

procedure TvgSampler.SetAddressModeU(const Value: TvgSamplerAddressMode);
  Var V: TVkSamplerAddressMode;
begin
  V := GetVKSamplerAddressMode(Value);
  If fAddressModeU=V then exit;
  SetActiveState(False);
  fAddressModeU := V;
end;

procedure TvgSampler.SetAddressModeV(const Value: TvgSamplerAddressMode);
  Var V: TVkSamplerAddressMode;
begin
  V := GetVKSamplerAddressMode(Value);
  If fAddressModeV=V then exit;
  SetActiveState(False);
  fAddressModeV := V;
end;

procedure TvgSampler.SetAddressModeW(const Value: TvgSamplerAddressMode);
  Var V: TVkSamplerAddressMode;
begin
  V := GetVKSamplerAddressMode(Value);
  If fAddressModeW=V then exit;
  SetActiveState(False);
  fAddressModeW := V;
end;

procedure TvgSampler.SetAnisotropyEnable(const Value: Boolean);
begin
  If fAnisotropyEnable = Value then exit;
  SetActiveState(False);
  fAnisotropyEnable := Value;
end;

procedure TvgSampler.SetBorderColor(const Value: TvgBorderColor);
  Var V: TVkBorderColor;
begin
  V := GetVKBorderColor(Value);
  If fBorderColor=V then exit;
  SetActiveState(False);
  fBorderColor := V;
end;

procedure TvgSampler.SetCompareEnable(const Value: Boolean);
begin
  If fCompareEnable = Value then exit;
  SetActiveState(False);
  fCompareEnable := Value;
end;

procedure TvgSampler.SetCompareOp(const Value: TvgCompareOpBit);
  Var V: TVkCompareOp;
begin
  V := GetVKCompareOp(Value);
  If fCompareOp=V then exit;
  SetActiveState(False);
  fCompareOp := V;
end;

procedure TvgSampler.SetDevice(const Value: TvgLogicalDevice);
begin
  If fDevice = Value then exit;
  SetActiveState(False);
  fDevice := Value;
end;

procedure TvgSampler.SetDisabled;
  Var I,L:Integer;
begin
  L:= Length(fVulkanSampler);
  For I:=0 to L-1 do
    If assigned(fVulkanSampler[I]) then
     FreeAndNil( fVulkanSampler[I]) ;

  SetLength(fVulkanSampler,0) ;
end;

procedure TvgSampler.SetEnabled(aComp: TvgBaseComponent);
  Var I:Integer;
begin
  fActive := False;
  Assert(assigned(fDevice),'Device NOT assigned');
  Assert(assigned(fDevice.VulkanDevice ),'Vulkan Device NOT assigned');
  If fFrameCount=0 then
     fFrameCount := 1;

  SetLength(fVulkanSampler,fFrameCount);
  For I:=0 to fFrameCount-1 do
  Begin
    fVulkanSampler[I] :=  TpvVulkanSampler.Create(fDevice.VulkanDevice,
                                                  fMagFilter,
                                                  fMinFilter,
                                                  fMipmapMode,
                                                  fAddressModeU,
                                                  fAddressModeV,
                                                  fAddressModeW,
                                                  fMipLodBias,
                                                  fAnisotropyEnable,
                                                  fMaxAnisotropy,
                                                  fCompareEnable,
                                                  fCompareOp,
                                                  fMinLod,
                                                  fMaxLod,
                                                  fBorderColor,
                                                  fUnnormalizedCoordinates,
                                                  fReductionMode   );


  End;
  fActive := True;


end;

procedure TvgSampler.SetFrameCount(const Value: TvkUint32);
begin
  If fFrameCount = Value then exit;
  SetActiveState(False);
  fFrameCount := Value;
end;

procedure TvgSampler.SetMagFilter(const Value: TvgFilter);
  Var V: TVkFilter;
begin
  V := GetVKFilter(Value);
  If fMagFilter=V then exit;
  SetActiveState(False);
  fMagFilter := V;
end;

procedure TvgSampler.SetMaxAnisotropy(const Value: TvkFloat);
begin
  If fMaxAnisotropy = Value then exit;
  SetActiveState(False);
  fMaxAnisotropy := Value;
end;

procedure TvgSampler.SetMaxLod(const Value: TvkFloat);
begin
  If IsZero(fMaxLod - Value) then exit;
  SetActiveState(False);
  fMaxLod := Value;
end;

procedure TvgSampler.SetMinFilter(const Value: TvgFilter);
  Var V: TVkFilter;
begin
  V := GetVKFilter(Value);
  If fMinFilter=V then exit;
  SetActiveState(False);
  fMinFilter := V;
end;

procedure TvgSampler.SetMinLod(const Value: TvkFloat);
begin
  If IsZero(fMinLod - Value) then exit;
  SetActiveState(False);
  fMinLod := Value;
end;

procedure TvgSampler.SetMipLodBias(const Value: TvkFloat);
begin
  If IsZero(fMipLodBias - Value) then exit;
  SetActiveState(False);
  fMipLodBias := Value;
end;

procedure TvgSampler.SetMipmapMode(const Value: TvgSamplerMipmapMode);
  Var V: TVkSamplerMipmapMode;
begin
  V := GetVKSamplerMipmapMode(Value);
  If fMipmapMode=V then exit;
  SetActiveState(False);
  fMipmapMode := V;
end;

procedure TvgSampler.SetReductionMode(const Value: TvgSamplerReductionMode);
  Var V: TVkSamplerReductionMode;
begin
  V := GetVKSamplerReductionMode(Value);
  If fReductionMode=V then exit;
  SetActiveState(False);
  fReductionMode := V;
end;

procedure TvgSampler.SetUnnormalizedCoordinates(const Value: Boolean);
begin
  If fUnnormalizedCoordinates = Value then exit;
  SetActiveState(False);
  fUnnormalizedCoordinates := Value;
end;

{ TvgPushConstantCol }

function TvgPushConstantCol.Add: TvgPushConstantItem;
begin
  Result := TvgPushConstantItem(inherited Add);
end;

function TvgPushConstantCol.AddItem(Item: TvgPushConstantItem; Index: Integer): TvgPushConstantItem;
begin
  if Item = nil then
  Begin
    Result := TvgPushConstantItem.Create(self);
  end else
    Result := Item;

  if Assigned(Result) then
  begin
    Result.Collection := Self;
    if Index < 0 then
      Index := Count - 1;
    Result.Index := Index;
  end;
end;

procedure TvgPushConstantCol.Assign(Source: TPersistent);
  Var PC      : TvgPushConstantCol;
      PCI,PCIS: TvgPushConstantItem;
      I       : Integer;
begin
  If Source is TvgPushConstantCol then
  Begin
    PC          := TvgPushConstantCol(Source);
    FCollString := PC.FCollString;

    If (PC.Count>0) then
    Begin
      For I:= 0 to PC.Count-1 do
      Begin
        PCIS := PC.Items[I] ;
        PCI  := Add;

        PCI.fActive          := False ;
        PCI.fName            := PCIS.fName ;
        PCI.PushConstantName := PCIS.PushConstantName ;  //should create ShaderData instance
        If assigned(PCI.PushConstant) then
           PCI.PushConstant.Assign(PCIS.PushConstant);
      End;
    End;

  End else
    Inherited Assign(Source);


end;

constructor TvgPushConstantCol.Create(CollOwner: TvgGraphicPipeline);
begin
  Inherited Create(TvgPushConstantItem);
  FComp := CollOwner;
end;

function TvgPushConstantCol.GetItem(Index: Integer): TvgPushConstantItem;
begin
  Result := TvgPushConstantItem(inherited GetItem(Index));
end;

function TvgPushConstantCol.GetOwner: TPersistent;
begin
  Result := nil;
end;

function TvgPushConstantCol.Insert(Index: Integer): TvgPushConstantItem;
begin
  Result := AddItem(nil, Index);
end;

procedure TvgPushConstantCol.SetActive(const Value: Boolean);
begin
  If fActive = Value then exit;
     fActive := Value;

  If fActive then
    SetEnabled
  else
    SetDisabled;
end;

procedure TvgPushConstantCol.SetDisabled;
  Var I:Integer;
begin
  fActive := False;
  If Count=0 then exit;
  For I:=0 to count-1 do
  Begin
    If assigned(Items[I].PushConstant) then
       Items[I].PushConstant.Active := False;
  End;
end;

procedure TvgPushConstantCol.SetEnabled;
  Var I:Integer;
begin
  fActive := TRue;
  If Count=0 then exit;
  For I:=0 to count-1 do
  Begin
    If assigned(Items[I].PushConstant) then
       Items[I].PushConstant.SetEnabled;
  End;
end;

procedure TvgPushConstantCol.SetFrameCount(const Value: Integer);
  Var I  :Integer;
      PC : TvgPushConstant;
begin
  If fFrameCount = Value then exit;
  fFrameCount := Value;

  For I:=0 to count-1 do
  Begin
    PC := Items[I].PushConstant;
    If assigned(PC) then
       PC.FrameCount := fFrameCount;
  End;
end;

procedure TvgPushConstantCol.SetItem(Index: Integer; const Value: TvgPushConstantItem);
begin
  inherited SetItem(Index, Value);
end;

procedure TvgPushConstantCol.Update(Item: TCollectionItem);
var
  str: string;
  i: Integer;
begin
  inherited;
  // update everything in any case...
  str := '';
  for i := 0 to Count - 1 do
  begin
    str := str + String((Items [i] as TvgPushConstantItem).fName);
    if i < Count - 1 then
      str := str + '-';
  end;
  FCollString := str;

end;

{ TvgPushConstantItem }

constructor TvgPushConstantItem.Create(Collection: TCollection);
begin
  inherited Create(Collection);

  fPushConstantType := Nil;
end;

destructor TvgPushConstantItem.Destroy;
begin
  If assigned(fPushConstant) then
     FreeAndNil(fPushConstant);

  inherited;
end;

function TvgPushConstantItem.GetActive: Boolean;
begin
  Result := fActive;
end;

function TvgPushConstantItem.GetDisplayName: string;
begin
  Result := fName;
  If Result='' then
    Inherited GetDisplayName;
end;

function TvgPushConstantItem.GetName: String;
begin
  Result := fName;
end;

function TvgPushConstantItem.GetPushConstant: TvgPushConstant;
begin
  Result := fPushConstant;
end;

function TvgPushConstantItem.GetPushConstantName: String;
begin
  If not assigned(fPushConstantType) then
     Result := '<NONE>'
  else
     Result := fPushConstantType.GetPropertyName;
end;
(*
function TvgPushConstantItem.GetPushConstantType: TvgPushConstantType;
begin
  Result := self.fPushConstantType;
end;
*)
procedure TvgPushConstantItem.SetActive(const Value: Boolean);
begin
  fActive := Value;
end;

procedure TvgPushConstantItem.SetName(const Value: String);
begin
  fName := Value;
end;

procedure TvgPushConstantItem.SetPushConstantName(const Value: String);
  Var I:Integer;
begin
  If Value = '' then
     SetPushConstantType(nil)
  else
  Begin
    For I:= 0 to PushConstantTypeList.count-1 do
    Begin
      If  CompareStr(Value, PushConstantTypeList.Items[I].GetPropertyName)=0 then
      Begin
        SetPushConstantType(PushConstantTypeList.Items[I]);
        exit;
      End;
    End;
  End;
end;

procedure TvgPushConstantItem.SetPushConstantType(  const Value: TvgPushConstantType);
Begin
  If fPushConstantType = Value then exit;

  If assigned(fPushConstant) then
     FreeAndNil(fPushConstant);

  fPushConstantType := Value ;

  If  fPushConstantType = Nil then exit;

  fPushConstant := CreatePushConstantFromType(fPushConstantType, nil);

  If assigned(fPushConstant) then
  Begin
     fPushConstant.SetSubComponent(True);
     fPushConstant.FrameCount := TvgPushConstantCol(Collection).framecount;

 //    fPushConstant.Descriptor := Self;  //important
 //    If fPushConstant.FrameCount=0 then
 //       fPushConstant.FrameCount := TvgDescriptorSet(TvgDescriptorCol(Collection).Owner).FrameCount;
  end;

end;

{ TvgPushConstant }

procedure TvgPushConstant.Assign(Source: TPersistent);
  Var PC:TvgPushConstant;
begin
  If source is TvgPushConstant then
  Begin
     PC := TvgPushConstant(Source);
     fActive         := False ;
     fFrameCount     := PC.fFrameCount ;
     fShaderStage    := PC.fShaderStage ;

  end else
     inherited Assign(Source);

end;

constructor TvgPushConstant.Create(AOwner: TComponent);
begin
  inherited;
  fFrameCount  := MaxFramesInFlight;
  fShaderStage := 0;
end;

destructor TvgPushConstant.Destroy;
begin

  inherited;
end;

function TvgPushConstant.GetDataPointer(FrameIndex: TvkUint32): Pointer;
begin
  Result := nil;
end;

function TvgPushConstant.GetDataSize: TVkUInt32;
begin
  Result := 0;
end;

class function TvgPushConstant.GetPropertyName: String;
begin
  Result := 'PushConstant' ;
end;

function TvgPushConstant.GetShaderFlags: TvgShaderStageFlagBits;
begin
  Result :=  GetVGStageFlags(fShaderStage);
end;

procedure TvgPushConstant.SetActive(const Value: Boolean);
begin
  if fActive = Value then exit;
  SetActiveState(Value);
end;

procedure TvgPushConstant.SetDisabled;
begin
  fActive := False;
end;

procedure TvgPushConstant.SetEnabled(aComp: TvgBaseComponent);
begin
  fActive := True;

  If fFrameCount = 0 then
     fFrameCount:= MaxFramesInFlight;

end;

procedure TvgPushConstant.SetFrameCount(const Value: TvkUint32);
begin
  fFrameCount := Value;
end;

procedure TvgPushConstant.SetShaderFlags(const Value: TvgShaderStageFlagBits);
  Var V:TVkShaderStageFlags  ;
begin
  V := GetVKStageFlags(Value);
  If fShaderStage = V then exit;
  SetActiveState(False);
  fShaderStage := V;
end;

procedure TvgPushConstant.SetupData(FrameIndex:TvkUint32);
begin
  //see descendants
end;

Initialization

  DescriptorTypeList      := TvgDescriptorTypeList.Create;
  PushConstantTypeList    := TvgPushConstantTypeList.Create;

  GraphicPipeTypeList := TvgGraphicPipeTypeList.Create;

  RegisterDescriptorType(TvgDescriptor_Texture);



Finalization
   If assigned(DescriptorTypeList) then
     FreeAndNil(DescriptorTypeList);

   If assigned(PushConstantTypeList) then
     FreeAndNil(PushConstantTypeList);

   If assigned(GraphicPipeTypeList) then
     FreeAndNil(GraphicPipeTypeList);

end.
