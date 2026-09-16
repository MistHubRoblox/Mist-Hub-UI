--!strict
-- MistUI v4.0 Stable public declarations.
-- The executor distribution stays --!nocheck for broad executor compatibility;
-- consumers can use this file as the development-facing API contract.

export type Connection = {
    Disconnect: (self: Connection) -> (),
}

export type KeybindMode = "Toggle" | "Hold" | "Press" | "Always"
export type KeybindKey = Enum.KeyCode | Enum.UserInputType
export type KeybindModifier = Enum.KeyCode | string
export type Breakpoint = "Compact" | "Medium" | "Large"
export type NotificationType = "Info" | "Success" | "Warning" | "Error" | string

export type ActivityStatusKind = "neutral" | "info" | "success" | "warning" | "danger" | "error" | "accent" | "clear" | "detected" | string

export type ActivityRowConfig = {
    Title: string?,
    Text: string?,
    Description: string?,
    Value: any?,
    Status: ActivityStatusKind?,
    Kind: ActivityStatusKind?,
    StatusColorTitle: boolean?,
    [string]: any,
}

export type ActivitySectionConfig = {
    Title: string?,
    Text: string?,
    Icon: string?,
    Counter: any?,
    Order: number?,
    BackgroundColor: Color3?,
    BackgroundTransparency: number?,
    [string]: any,
}

export type ActivityConfig = {
    Title: string?,
    Icon: string?,
    Width: number?,
    Position: UDim2?,
    AnchorPoint: Vector2?,
    Closable: boolean?,
    Minimizable: boolean?,
    Minimized: boolean?,
    Counter: any?,
    Total: any?,
    CounterLabel: string?,
    Target: any?,
    TargetLabel: string?,
    Status: string?,
    StatusType: ActivityStatusKind?,
    Progress: number?,
    ProgressText: string?,
    ProgressType: ActivityStatusKind?,
    Time: string?,
    AutoTimer: boolean?,
    TimerOffset: number?,
    [string]: any,
}

export type ActivityRow = {
    Instance: GuiObject,
    Container: GuiObject,
    SetTitle: (self: ActivityRow, value: any) -> ActivityRow,
    SetDescription: (self: ActivityRow, value: any) -> ActivityRow,
    SetValue: (self: ActivityRow, value: any) -> ActivityRow,
    SetStatus: (self: ActivityRow, kind: ActivityStatusKind) -> ActivityRow,
    SetVisible: (self: ActivityRow, visible: boolean) -> ActivityRow,
    Destroy: (self: ActivityRow) -> (),
}

export type ActivitySection = {
    Instance: GuiObject,
    Header: GuiObject,
    Rows: GuiObject,
    Items: {ActivityRow},
    SetTitle: (self: ActivitySection, value: any) -> ActivitySection,
    SetCounter: (self: ActivitySection, value: any) -> ActivitySection,
    SetVisible: (self: ActivitySection, visible: boolean) -> ActivitySection,
    AddRow: (self: ActivitySection, config: ActivityRowConfig) -> ActivityRow,
    AddStatus: (self: ActivitySection, config: ActivityRowConfig) -> ActivityRow,
    Clear: (self: ActivitySection) -> ActivitySection,
    Destroy: (self: ActivitySection) -> (),
}

export type Activity = {
    Type: "Activity",
    Instance: GuiObject,
    Panel: GuiObject,
    Header: GuiObject,
    Content: GuiObject,
    Closed: any,
    Sections: {ActivitySection},
    SetTitle: (self: Activity, value: any) -> Activity,
    SetIcon: (self: Activity, icon: string) -> Activity,
    SetCounter: (self: Activity, current: any, total: any?, label: string?) -> Activity,
    SetTarget: (self: Activity, value: any, label: string?) -> Activity,
    SetStatus: (self: Activity, value: any, kind: ActivityStatusKind?) -> Activity,
    SetTime: (self: Activity, value: any) -> Activity,
    StartTimer: (self: Activity, offsetSeconds: number?) -> Activity,
    StopTimer: (self: Activity) -> Activity,
    SetProgress: (self: Activity, value: number, label: string?, kind: ActivityStatusKind?) -> Activity,
    HideProgress: (self: Activity) -> Activity,
    AddSection: (self: Activity, config: ActivitySectionConfig) -> ActivitySection,
    SetMinimized: (self: Activity, minimized: boolean) -> Activity,
    ToggleMinimized: (self: Activity) -> Activity,
    IsMinimized: (self: Activity) -> boolean,
    SetVisible: (self: Activity, visible: boolean) -> Activity,
    Show: (self: Activity) -> Activity,
    Hide: (self: Activity) -> Activity,
    SetPosition: (self: Activity, position: UDim2) -> Activity,
    GetPosition: (self: Activity) -> UDim2,
    Close: (self: Activity, immediate: boolean?) -> Activity,
    Destroy: (self: Activity, immediate: boolean?) -> Activity,
}

export type ComponentConfig = {
    Id: string?,
    Flag: string?,
    Text: string?,
    Name: string?,
    Description: string?,
    Default: any?,
    Value: any?,
    Options: {any}?,
    Values: {any}?,
    Min: number?,
    Max: number?,
    Step: number?,
    Key: KeybindKey?,
    DefaultKey: KeybindKey?,
    Callback: ((...any) -> ())?,
    OnChanged: ((...any) -> ())?,
    [string]: any,
}

export type InputConfig = ComponentConfig & {
    Placeholder: string?,
    Finished: boolean?,
    Numeric: boolean?,
    AllowEmpty: boolean?,
    EmptyReset: string?,
    ClearTextOnFocus: boolean?,
    MaxLength: number?,
}

export type DropdownConfig = ComponentConfig & {
    Searchable: boolean?,
    Multi: boolean?,
    MaxVisibleDropdownItems: number?,
    AllowNull: boolean?,
    NullText: string?,
    DisabledValues: {any} | {[any]: boolean}?,
    ValueImages: {[any]: string}?,
    SearchPlaceholder: string?,
    SpecialType: "Player" | "Team"?,
    ExcludeLocalPlayer: boolean?,
    EnablePlayerImages: boolean?,
    FormatDisplayValue: ((any) -> string)?,
    FormatListValue: ((any) -> string)?,
    FormatSearchValue: ((any) -> string)?,
}

export type KeybindConfig = ComponentConfig & {
    Mode: KeybindMode?,
    DefaultMode: KeybindMode?,
    Modifiers: {KeybindModifier}?,
    DefaultModifiers: {KeybindModifier}?,
    NoUI: boolean?,
}

export type ColorValue = {
    Color: Color3,
    Transparency: number,
}

export type ColorPickerConfig = ComponentConfig & {
    Default: Color3 | ColorValue | string?,
    Value: Color3 | ColorValue | string?,
    Transparency: number?,
    AllowTransparency: boolean?,
}

export type ViewportConfig = ComponentConfig & {
    Object: Instance?,
    Model: Instance?,
    Height: number?,
    Interactive: boolean?,
    CloneObject: boolean?,
    FieldOfView: number?,
    Camera: Camera?,
}

export type VideoConfig = ComponentConfig & {
    Video: string?,
    Height: number?,
    Looped: boolean?,
    Volume: number?,
    Playing: boolean?,
}

export type UIPassthroughConfig = ComponentConfig & {
    Instance: GuiObject?,
    Object: GuiObject?,
    Height: number?,
    Clone: boolean?,
}

export type Component = {
    Type: string?,
    Name: string?,
    Description: string?,
    Flag: string?,
    Instance: Instance?,
    Container: Instance?,
    Default: any?,
    Set: ((self: Component, value: any, ...any) -> any)?,
    SetSilent: ((self: Component, value: any, ...any) -> any)?,
    Get: ((self: Component) -> any)?,
    SetVisible: ((self: Component, visible: boolean) -> Component)?,
    SetDisabled: ((self: Component, disabled: boolean) -> Component)?,
    Show: ((self: Component) -> Component)?,
    Hide: ((self: Component) -> Component)?,
    Enable: ((self: Component) -> Component)?,
    Disable: ((self: Component) -> Component)?,
    On: (self: Component, eventName: string, callback: (...any) -> ()) -> Connection,
    OnChanged: (self: Component, callback: (...any) -> ()) -> Connection,
    OnClick: ((self: Component, callback: (...any) -> ()) -> Connection)?,
    OnOpen: ((self: Component, callback: (...any) -> ()) -> Connection)?,
    OnClose: ((self: Component, callback: (...any) -> ()) -> Connection)?,
    OnFocus: ((self: Component, callback: (...any) -> ()) -> Connection)?,
    OnBlur: ((self: Component, callback: (...any) -> ()) -> Connection)?,
    Reset: ((self: Component, fire: boolean?) -> Component)?,
    GetDefault: ((self: Component) -> any)?,
    SetDefault: ((self: Component, value: any) -> Component)?,
    IsVisible: ((self: Component) -> boolean)?,
    IsDisabled: ((self: Component) -> boolean)?,
    IsDestroyed: ((self: Component) -> boolean)?,
    DestroyEvents: ((self: Component) -> Component)?,
    Destroy: ((self: Component) -> any)?,
    [string]: any,
}

export type DiagnosticRecord = {
    Kind: string,
    Message: string,
    Context: {[any]: any},
    Time: number,
    Traceback: string?,
}

export type Diagnostics = {
    SafeCalls: number,
    CallbackErrors: number,
    Warnings: number,
    Records: {DiagnosticRecord},
    MaxRecords: number,
}

export type ProfilerEntry = {
    Name: string,
    Count: number,
    Total: number,
    Average: number,
}

export type ProfilerSample = {
    Name: string,
    Duration: number,
    Time: number,
}

export type ProfilerSnapshot = {
    Enabled: boolean,
    Entries: {ProfilerEntry},
    Samples: {ProfilerSample},
}

export type LeakSnapshot = {
    Time: number,
    Instances: number,
    MaidTasks: number,
    Components: number,
    Cards: number,
    Tabs: number,
    Categories: number,
    Keybinds: number,
    Commands: number,
    Overlays: number,
    ThemeBindings: number,
    RegisteredFlagComponents: number,
    ActiveNotifications: number,
    [string]: number,
}

export type LeakComparison = {
    Before: LeakSnapshot,
    After: LeakSnapshot,
    Delta: {[string]: number},
    PotentialLeakUnits: number,
    Clean: boolean,
}

export type LayoutSnapshotItem = {
    Path: string,
    ClassName: string,
    Visible: boolean,
    X: number,
    Y: number,
    Width: number,
    Height: number,
    ZIndex: number,
    Text: string?,
}

export type LayoutChange = {
    Path: string,
    Before: LayoutSnapshotItem,
    After: LayoutSnapshotItem,
}

export type LayoutComparison = {
    Equal: boolean,
    Added: {string},
    Removed: {string},
    Changed: {LayoutChange},
    BeforeCount: number,
    AfterCount: number,
    Tolerance: number,
}

export type DoctorCheck = {
    Name: string,
    Ok: boolean,
    Message: string,
}

export type DoctorReport = {
    Score: number,
    Healthy: boolean,
    Checks: {DoctorCheck},
    Errors: {string},
    Warnings: {string},
    Snapshot: LeakSnapshot,
    Diagnostics: Diagnostics,
}

export type QualityTestResult = {
    Name: string,
    Passed: boolean,
    Detail: string,
    Duration: number,
}

export type QualityReport = {
    Passed: boolean,
    PassedCount: number,
    Total: number,
    Score: number,
    Tests: {QualityTestResult},
    Doctor: DoctorReport,
    Snapshot: LeakSnapshot,
}

export type AdvancedDropdown = Component & {
    List: ScrollingFrame?,
    Virtualized: boolean?,
    GetRenderedRowCount: ((self: AdvancedDropdown) -> number)?,
    GetOptionCount: ((self: AdvancedDropdown) -> number)?,
    SetOptions: ((self: AdvancedDropdown, options: {any}) -> AdvancedDropdown)?,
    Refresh: ((self: AdvancedDropdown) -> AdvancedDropdown)?,
    Open: ((self: AdvancedDropdown) -> AdvancedDropdown)?,
    Close: ((self: AdvancedDropdown) -> AdvancedDropdown)?,
}

export type MultiDropdown = AdvancedDropdown & {
    Get: ((self: MultiDropdown) -> {any})?,
}

export type VirtualListComponent = Component & {
    List: ScrollingFrame?,
    Virtualized: boolean?,
    GetRenderedRowCount: ((self: VirtualListComponent) -> number)?,
    GetItemCount: ((self: VirtualListComponent) -> number)?,
    SetItems: ((self: VirtualListComponent, items: {any}) -> VirtualListComponent)?,
}

export type ColorPicker = Component & {
    Set: (self: ColorPicker, value: Color3 | ColorValue | string, transparency: number?) -> ColorPicker,
    SetSilent: (self: ColorPicker, value: Color3 | ColorValue | string, transparency: number?) -> ColorPicker,
    SetValueRGB: (self: ColorPicker, value: Color3 | ColorValue | string, transparency: number?) -> ColorPicker,
    SetHSVFromRGB: (self: ColorPicker, value: Color3 | ColorValue | string) -> ColorPicker,
    SetValue: (self: ColorPicker, hsv: {H: number?, S: number?, V: number?, [number]: number?}, transparency: number?) -> ColorPicker,
    GetHSV: (self: ColorPicker) -> {H: number, S: number, V: number},
    Get: (self: ColorPicker) -> Color3,
    GetColor: (self: ColorPicker) -> Color3,
    GetTransparency: (self: ColorPicker) -> number,
    SetTransparency: (self: ColorPicker, value: number, fireCallback: boolean?) -> ColorPicker,
    GetConfigValue: (self: ColorPicker) -> ColorValue,
    Open: (self: ColorPicker) -> ColorPicker,
    Close: (self: ColorPicker) -> ColorPicker,
}

export type Viewport = Component & {
    SetObject: (self: Viewport, object: Instance?, cloneObject: boolean?) -> Viewport,
    GetObject: (self: Viewport) -> Instance?,
    SetHeight: (self: Viewport, height: number) -> Viewport,
    Focus: (self: Viewport) -> Viewport,
    SetCamera: (self: Viewport, camera: Camera?) -> Viewport,
    SetInteractive: (self: Viewport, enabled: boolean) -> Viewport,
    ResetRotation: (self: Viewport) -> Viewport,
}

export type Video = Component & {
    SetVideo: (self: Video, asset: string) -> Video,
    SetHeight: (self: Video, height: number) -> Video,
    SetLooped: (self: Video, looped: boolean) -> Video,
    SetVolume: (self: Video, volume: number) -> Video,
    SetPlaying: (self: Video, playing: boolean) -> Video,
    Play: (self: Video) -> Video,
    Pause: (self: Video) -> Video,
}

export type UIPassthrough = Component & {
    SetInstance: (self: UIPassthrough, object: GuiObject?, cloneObject: boolean?) -> UIPassthrough,
    GetInstance: (self: UIPassthrough) -> GuiObject?,
    SetHeight: (self: UIPassthrough, height: number) -> UIPassthrough,
}

export type DependencyBox = Component & {
    Body: GuiObject,
    Components: {any},
    Adopt: (self: DependencyBox, component: any) -> any,
    Add: (self: DependencyBox, controlType: string, config: ComponentConfig?) -> Component,
    AddControl: (self: DependencyBox, controlType: string, config: ComponentConfig?) -> Component,
    GetComponents: (self: DependencyBox) -> {any},
    SetupDependencies: (self: DependencyBox, conditions: any, logic: string?) -> DependencyBox,
    SetDependencies: (self: DependencyBox, conditions: any, logic: string?) -> DependencyBox,
    ClearDependency: (self: DependencyBox) -> DependencyBox,
    Clear: (self: DependencyBox) -> DependencyBox,
}

export type Card = {
    Components: {Component},
    Add: (self: Card, controlType: string, config: ComponentConfig?) -> Component,
    AddControl: (self: Card, controlType: string, config: ComponentConfig?) -> Component,

    AddButton: (self: Card, ...any) -> Component,
    AddToggle: (self: Card, ...any) -> Component,
    AddSlider: (self: Card, ...any) -> Component,
    AddCheckbox: (self: Card, ...any) -> Component,
    AddDropdown: (self: Card, ...any) -> Component,
    AddKeybind: (self: Card, ...any) -> Component,
    AddTextbox: (self: Card, ...any) -> Component,
    AddNumberBox: (self: Card, ...any) -> Component,
    AddRangeSlider: (self: Card, ...any) -> Component,
    AddSearchDropdown: (self: Card, ...any) -> Component,
    AddToggleKeybind: (self: Card, ...any) -> Component,
    AddButtonGroup: (self: Card, ...any) -> Component,
    AddStatus: (self: Card, ...any) -> Component,
    AddBadge: (self: Card, ...any) -> Component,
    AddLabel: (self: Card, ...any) -> any,
    AddDivider: (self: Card, ...any) -> any,
    AddParagraph: (self: Card, ...any) -> Component,
    AddSection: (self: Card, ...any) -> Component,

    AddButtonEx: (self: Card, config: ComponentConfig) -> Component,
    AddInput: (self: Card, config: InputConfig) -> Component,
    AddDropdownEx: (self: Card, config: DropdownConfig) -> AdvancedDropdown,
    AddMultiDropdown: (self: Card, config: DropdownConfig) -> MultiDropdown,
    AddKeybindEx: (self: Card, config: KeybindConfig) -> Component,
    AddColorPicker: (self: Card, config: ColorPickerConfig) -> ColorPicker,
    AddProgressBar: (self: Card, ...any) -> Component,
    AddRadioGroup: (self: Card, ...any) -> Component,
    AddSegmentedControl: (self: Card, ...any) -> Component,
    AddStepper: (self: Card, ...any) -> Component,
    AddIconButton: (self: Card, ...any) -> Component,
    AddImage: (self: Card, ...any) -> Component,
    AddAvatar: (self: Card, ...any) -> Component,
    AddViewport: (self: Card, config: ViewportConfig) -> Viewport,
    AddVideo: (self: Card, config: VideoConfig) -> Video,
    AddUIPassthrough: (self: Card, config: UIPassthroughConfig) -> UIPassthrough,
    AddDependencyBox: (self: Card, config: any?) -> DependencyBox,
    AddSpinner: (self: Card, ...any) -> Component,
    AddSeparator: (self: Card, ...any) -> Component,
    AddCollapsibleSection: (self: Card, ...any) -> Component,
    AddTabs: (self: Card, ...any) -> Component,
    AddAccordion: (self: Card, ...any) -> Component,
    AddList: (self: Card, ...any) -> VirtualListComponent,
    AddTable: (self: Card, ...any) -> Component,
    AddTreeView: (self: Card, ...any) -> Component,
    AddTag: (self: Card, ...any) -> Component,
    AddBreadcrumb: (self: Card, ...any) -> Component,
    AddCodeBox: (self: Card, ...any) -> Component,
    AddFormattedText: (self: Card, ...any) -> Component,
    AddActionMenu: (self: Card, ...any) -> Component,
    AddVirtualList: (self: Card, ...any) -> Component,
    AddConfirmButton: (self: Card, ...any) -> Component,

    SetWidth: (self: Card, width: any) -> Card,
    SetSize: (self: Card, size: any) -> Card,
    SetSide: (self: Card, side: any) -> Card,
    ApplyBreakpoint: (self: Card, breakpoint: Breakpoint) -> Card,
    SetOrder: (self: Card, order: number) -> Card,
    MoveBefore: (self: Card, otherCard: Card) -> Card,
    MoveAfter: (self: Card, otherCard: Card) -> Card,
    MoveToRow: (self: Card, row: any) -> boolean,
    SetTitle: (self: Card, title: string) -> Card,
    SetDescription: (self: Card, description: string?) -> Card,
    SetIcon: (self: Card, iconName: string?) -> Card,
    GetTitle: (self: Card) -> string,
    SetVisible: (self: Card, visible: boolean) -> Card,
    Show: (self: Card) -> Card,
    Hide: (self: Card) -> Card,
    SetDisabled: (self: Card, disabled: boolean) -> Card,
    Enable: (self: Card) -> Card,
    Disable: (self: Card) -> Card,
    Collapse: (self: Card) -> Card,
    Expand: (self: Card) -> Card,
    ToggleCollapsed: (self: Card) -> Card,
    IsCollapsed: (self: Card) -> boolean,
    GetComponents: (self: Card) -> {Component},
    Destroy: (self: Card) -> (),
    [string]: any,
}

export type Row = {
    AddCard: (self: Row, title: string?, subtitle: string?, layout: any?) -> Card,
    [string]: any,
}

export type Page = {
    CreateRow: (self: Page) -> Row,
    [string]: any,
}

export type KeybindDefinition = {
    Id: string?,
    Flag: string?,
    Name: string?,
    Text: string?,
    Default: KeybindKey?,
    Key: KeybindKey?,
    Mode: KeybindMode?,
    Modifiers: {KeybindModifier}?,
    DefaultModifiers: {KeybindModifier}?,
    Callback: ((...any) -> ())?,
    [string]: any,
}

export type Category = {
    AddScript: (self: Category, nameOrConfig: any, builder: ((Page) -> ())?, icon: string?) -> GuiButton,
    AddGroup: (self: Category, name: string, icon: string?, pages: {any}) -> GuiButton,
    SetExpanded: (self: Category, expanded: boolean) -> Category,
    Expand: (self: Category) -> Category,
    Collapse: (self: Category) -> Category,
    Toggle: (self: Category) -> Category,
    [string]: any,
}

export type NotificationConfig = {
    Id: string?,
    GroupKey: string?,
    Title: string?,
    Content: string?,
    Type: NotificationType?,
    Duration: number?,
    Priority: number?,
    Closable: boolean?,
    PauseOnHover: boolean?,
    ActionText: string?,
    OnAction: (() -> ())?,
    Force: boolean?,
    [string]: any,
}

export type WindowConfig = {
    Title: string?,
    Size: UDim2?,
    Position: UDim2?,
    ReplaceExisting: boolean?,
    Responsive: boolean?,
    KeyboardNavigation: boolean?,
    GamepadNavigation: boolean?,
    UseMemoryStorage: boolean?,
    StorageAdapter: any?,
    MobileToggle: boolean?,
    MobileToggleSide: string?,
    Resizable: boolean?, -- deprecated/ignored: manual resize is disabled
    [string]: any,
}

export type CommandConfig = {
    Id: string?,
    Name: string?,
    Description: string?,
    Keywords: string | {string}?,
    Callback: ((...any) -> any)?,
    Enabled: boolean?,
    Order: number?,
}

export type Command = CommandConfig & {
    Id: string,
    Name: string,
    Run: (self: Command, ...any) -> any,
    SetEnabled: (self: Command, enabled: boolean) -> Command,
    Destroy: (self: Command) -> (),
}

export type Overlay = {
    Panel: GuiObject?,
    Close: (self: Overlay) -> (),
    Closed: any?,
    [string]: any,
}

export type Window = {
    CreateCategory: (self: Window, nameOrConfig: any) -> Category,
    CreateTopTab: (self: Window, config: any) -> any,
    CreateActivity: (self: Window, config: ActivityConfig) -> Activity,
    GetActivities: (self: Window) -> {Activity},
    CloseActivities: (self: Window, immediate: boolean?) -> Window,

    GetFlag: (self: Window, flag: string) -> any,
    GetFlags: (self: Window) -> {[string]: any},
    SetFlag: (self: Window, flag: string, value: any, silent: boolean?) -> any,
    ObserveFlag: (self: Window, flag: string, callback: (...any) -> (), fireImmediately: boolean?) -> Connection,
    BindDependency: (self: Window, ...any) -> any,
    BindConditions: (self: Window, ...any) -> any,
    ShowWhen: (self: Window, ...any) -> any,
    DisableWhen: (self: Window, ...any) -> any,

    RefreshKeybindMenu: (self: Window) -> Window,
    SetKeybindMenuOpen: (self: Window, open: boolean) -> Window,
    GetKeybindMenuOpen: (self: Window) -> boolean,
    RegisterKeybind: (self: Window, ...any) -> any,
    RegisterKeybindDefinition: (self: Window, definition: KeybindDefinition, owner: string?) -> any,
    RegisterKeybindDefinitions: (self: Window, definitions: {KeybindDefinition}, owner: string?) -> {any},
    GetKeybinds: (self: Window) -> {any},
    GetKeybindConflicts: (self: Window, ...any) -> {any},
    GetAllKeybindConflicts: (self: Window) -> {any},
    ClearKeybind: (self: Window, ...any) -> any,
    ClearAllKeybinds: (self: Window) -> any,

    ConfigExists: (self: Window, name: string) -> boolean,
    GetConfigData: (self: Window, name: string?) -> (boolean, any),
    ApplyConfigData: (self: Window, data: any, transactional: boolean?) -> any,
    SaveFlagsConfig: (self: Window, name: string, flags: {string}) -> (boolean, any),
    SaveConfig: (self: Window, name: string) -> (boolean, any),
    LoadConfig: (self: Window, name: string) -> (boolean, any),
    DeleteConfig: (self: Window, name: string) -> (boolean, any),
    GetConfigs: (self: Window) -> {string},
    SetAutoload: (self: Window, name: string?) -> any,
    GetAutoload: (self: Window) -> string?,
    ValidateConfigData: (self: Window, data: any) -> (boolean, any),
    BeginConfigTransaction: (self: Window, label: string?) -> (boolean, any),
    CommitConfigTransaction: (self: Window) -> (boolean, any?),
    RollbackConfigTransaction: (self: Window, reason: any?) -> (boolean, any?),
    WithConfigTransaction: (self: Window, label: string | ((...any) -> any), callback: ((...any) -> any)?) -> any,
    Snapshot: (self: Window, ...any) -> any,
    Undo: (self: Window) -> any,
    Redo: (self: Window) -> any,
    ResetFlags: (self: Window) -> any,

    SetTheme: (self: Window, theme: any) -> boolean,
    GetThemes: (self: Window) -> {string},
    RegisterTheme: (self: Window, name: string, theme: any) -> boolean,
    RemoveTheme: (self: Window, name: string) -> boolean,
    ExportTheme: (self: Window, name: string?) -> any,
    ImportTheme: (self: Window, ...any) -> any,
    ResetTheme: (self: Window) -> any,
    SetAccent: (self: Window, color: Color3) -> any,

    SetStatusText: (self: Window, value: string?) -> Window,
    SetScriptInfo: (self: Window, gameName: string?, version: string?) -> Window,
    GetStatusText: (self: Window) -> string,
    SetInterfaceBlurred: (self: Window, enabled: boolean) -> Window,
    GetInterfaceBlurred: (self: Window) -> boolean,
    SetVisible: (self: Window, visible: boolean) -> Window,
    IsVisible: (self: Window) -> boolean,
    Minimize: (self: Window) -> Window,
    Restore: (self: Window) -> Window,
    Toggle: (self: Window) -> Window,
    SetTitle: (self: Window, title: string) -> Window,
    GetTitle: (self: Window) -> string,
    SetSize: (self: Window, size: UDim2) -> Window,
    SetPosition: (self: Window, position: UDim2) -> Window,
    Center: (self: Window) -> Window,
    SetScale: (self: Window, scale: number) -> Window,
    GetScale: (self: Window) -> number,
    SetMinMaxSize: (self: Window, ...any) -> Window,
    LockDrag: (self: Window, locked: boolean) -> Window,
    SetResizable: (self: Window, enabled: boolean) -> Window,
    IsResizable: (self: Window) -> boolean,
    LockResize: (self: Window, locked: boolean) -> Window,
    Maximize: (self: Window) -> Window,
    RestoreWindow: (self: Window) -> Window,
    ToggleMaximize: (self: Window) -> Window,
    SnapToEdge: (self: Window, ...any) -> Window,
    EnableSnap: (self: Window, enabled: boolean) -> Window,
    SetTransparency: (self: Window, value: number) -> Window,

    EnableResponsive: (self: Window, enabled: boolean) -> Window,
    GetBreakpoint: (self: Window) -> Breakpoint,
    SetLocale: (self: Window, name: string) -> boolean,
    Translate: (self: Window, key: string, fallback: string?) -> string,
    SetKeyboardNavigationEnabled: (self: Window, enabled: boolean) -> Window,
    SetGamepadNavigationEnabled: (self: Window, enabled: boolean) -> Window,
    FocusNext: (self: Window) -> any,
    FocusPrevious: (self: Window) -> any,
    IsTouchDevice: (self: Window) -> boolean,
    SetMobileToggleEnabled: (self: Window, enabled: boolean, options: any?) -> Window,
    SetMobileToggleSide: (self: Window, side: string) -> Window,

    SelectTab: (self: Window, nameOrId: string) -> any,
    CloseTab: (self: Window, nameOrId: string) -> any,
    GetActiveTab: (self: Window) -> any,
    GetTabs: (self: Window) -> {any},
    NextTab: (self: Window) -> any,
    PreviousTab: (self: Window) -> any,
    NavigateBack: (self: Window) -> any,

    GetComponent: (self: Window, id: string) -> Component?,
    FindComponent: (self: Window, ...any) -> Component?,
    GetComponents: (self: Window) -> {Component},
    GetCards: (self: Window) -> {Card},
    GetCategories: (self: Window) -> {Category},
    Search: (self: Window, query: string) -> {any},
    SearchSidebar: (self: Window, query: string) -> {any},

    CreatePopup: (self: Window, ...any) -> Overlay,
    CreateModal: (self: Window, ...any) -> Overlay,
    CreateDrawer: (self: Window, ...any) -> Overlay,
    CreatePopover: (self: Window, ...any) -> Overlay,
    CreateContextMenu: (self: Window, ...any) -> Overlay,
    Confirm: (self: Window, ...any) -> any,
    AttachTooltip: (self: Window, ...any) -> any,
    AttachFunctionInfo: (self: Window, ...any) -> any,
    SetFunctionInfoEnabled: (self: Window, enabled: boolean) -> Window,
    GetFunctionInfoEnabled: (self: Window) -> boolean,

    RegisterCommand: (self: Window, command: CommandConfig | string, callback: ((...any) -> any)?) -> Command,
    UnregisterCommand: (self: Window, id: string) -> boolean,
    GetCommands: (self: Window) -> {Command},
    SearchCommands: (self: Window, query: string) -> {Command},
    RunCommand: (self: Window, id: string, ...any) -> any,
    OpenCommandPalette: (self: Window, options: any?) -> Overlay,

    CreateVirtualList: (self: Window, ...any) -> any,
    SetNotificationSettings: (self: Window, settings: any) -> Window,
    GetNotificationSettings: (self: Window) -> any,
    UpdateNotification: (self: Window, id: string, changes: any) -> any,
    DismissNotification: (self: Window, id: string, immediate: boolean?) -> any,
    DismissLatestNotification: (self: Window, immediate: boolean?) -> any,
    ClearNotifications: (self: Window) -> any,
    Track: (self: Window, item: any) -> any,
    Connect: (self: Window, signalObject: any, callback: (...any) -> ()) -> any,
    SetProfilerEnabled: (self: Window, enabled: boolean) -> Window,
    IsProfilerEnabled: (self: Window) -> boolean,
    Profile: (self: Window, name: string, callback: (...any) -> any, ...any) -> any,
    GetProfilerSnapshot: (self: Window) -> ProfilerSnapshot,
    ClearProfiler: (self: Window) -> Window,
    CreateLeakSnapshot: (self: Window) -> LeakSnapshot,
    CompareLeakSnapshots: (self: Window, before: LeakSnapshot, after: LeakSnapshot?) -> LeakComparison,
    CaptureLayoutSnapshot: (self: Window) -> {LayoutSnapshotItem},
    CompareLayoutSnapshots: (self: Window, before: {LayoutSnapshotItem}, after: {LayoutSnapshotItem}?, tolerance: number?) -> LayoutComparison,
    Doctor: (self: Window, options: any?) -> DoctorReport,
    RunQualitySuite: (self: Window, options: any?) -> QualityReport,
    AssertHealthy: (self: Window, minimumScore: number?) -> any,
    OpenDebugPanel: (self: Window, options: any?) -> Overlay,
    GetLastUnloadReport: (self: Window) -> any,
    GetDebugState: (self: Window) -> any,
    GetStore: (self: Window) -> any,
    On: (self: Window, eventName: string, callback: (...any) -> ()) -> Connection,
    Emit: (self: Window, eventName: string, ...any) -> Window,
    Unload: (self: Window) -> boolean,
    Destroy: (self: Window) -> boolean,
    [string]: any,
}

export type Library = {
    Version: string,
    SchemaVersion: number,
    Capabilities: {[string]: boolean},
    Flags: {[string]: any},
    CreateWindow: (self: Library, config: WindowConfig?) -> Window,
    GetVersion: (self: Library) -> string,
    GetFlag: (self: Library, flag: string) -> any,
    GetFlags: (self: Library) -> {[string]: any},
    SetFlag: (self: Library, flag: string, value: any, silent: boolean?) -> boolean,
    ObserveFlag: (self: Library, flag: string, callback: (...any) -> (), fireImmediately: boolean?) -> Connection,
    BindTheme: (self: Library, instance: Instance, property: string, token: string, transform: ((any, any) -> any)?) -> Instance?,
    GetThemeBinding: (self: Library, instance: Instance, property: string) -> any,
    UnbindTheme: (self: Library, instance: Instance, property: string?) -> boolean,
    SafeCall: (self: Library, callback: (...any) -> any, ...any) -> any,
    SafeCallContext: (self: Library, context: any, callback: (...any) -> any, ...any) -> any,
    Boundary: (self: Library, context: any, callback: (...any) -> any) -> (...any) -> any,
    GetDiagnostics: (self: Library) -> Diagnostics,
    ClearDiagnostics: (self: Library) -> boolean,
    CreateMaid: (self: Library) -> any,
    NextZIndex: (self: Library) -> number,
    RegisterConfigMigration: (self: Library, fromVersion: number, callback: (any) -> any) -> boolean,
    Notify: (self: Library, config: NotificationConfig) -> any,
    DismissNotification: (self: Library, id: string, immediate: boolean?) -> any,
    DismissLatestNotification: (self: Library, immediate: boolean?) -> any,
    GetLatestNotificationId: (self: Library) -> string?,
    RefreshNotificationTheme: (self: Library) -> boolean,
    LoadRemoteIcons: (self: Library) -> boolean,
    SetRemoteIconsEnabled: (self: Library, enabled: boolean) -> boolean,
    GetExecutorAdapter: (self: Library) -> any,
    SetStorageAdapter: (self: Library, adapter: any) -> boolean,
    GetStorageAdapter: (self: Library) -> any,
    GetStorageAdapterName: (self: Library) -> string,
    IsPersistentStorage: (self: Library) -> boolean,
    GetStorageStatus: (self: Library) -> { Name: string, Persistent: boolean, FallbackReason: string? },
    RegisterLocale: (self: Library, name: string, values: {[string]: string}) -> boolean,
    SetLocale: (self: Library, name: string) -> boolean,
    SetAnimationsEnabled: (self: Library, enabled: boolean) -> (),
    SetAnimationSpeed: (self: Library, multiplier: number) -> (),
    SetReducedMotion: (self: Library, enabled: boolean) -> (),
    SetDebugMode: (self: Library, enabled: boolean) -> boolean,
    UseMemoryStorage: (self: Library) -> any,
    [string]: any,
}

return {}
