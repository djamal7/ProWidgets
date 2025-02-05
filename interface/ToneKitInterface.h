@class TKTonePicker, TKToneTableController, TLDividerTableViewCell;

@interface TKTonePicker : UIView
{
    UITableView *_table;
    TKToneTableController *_tableController;
    id _delegate;
}

- (void)setStyleProvider:(id)styleProvider;

+ (id)tonePickerWithFrame:(CGRect)arg1;
+ (id)texttonePickerWithFrame:(CGRect)arg1;
+ (id)ringtonePickerWithFrame:(CGRect)arg1;
@property(nonatomic, assign) id delegate; // @synthesize delegate=_delegate;
- (void)ringtoneTableController:(id)arg1 willPlayRingtoneWithIdentifier:(id)arg2;
- (void)ringtoneTableController:(id)arg1 selectedMediaItemWithIdentifier:(id)arg2;
- (void)ringtoneTableController:(id)arg1 selectedRingtoneWithIdentifier:(id)arg2;
- (float)contentHeight;
- (void)setCustomTableViewCellClass:(Class)arg1;
//@property(retain, nonatomic) id <TKTonePickerStyleProvider> styleProvider;
- (void)finishedWithPicker;
- (void)stopPlayingWithFadeOut:(BOOL)arg1;
- (void)stopPlaying;
- (void)displayScrollerIndicators;
- (void)layoutSubviews;
- (void)didMoveToWindow;
- (void)setSelectedVibrationIdentifier:(id)arg1;
- (id)selectedVibrationIdentifier;
- (void)setAllowsDeletingCurrentSystemVibration:(BOOL)arg1;
- (BOOL)allowsDeletingCurrentSystemVibration;
- (void)setShowsNoVibrationSelected:(BOOL)arg1;
- (void)setShowsNoneVibration:(BOOL)arg1;
- (void)setShowsUserGeneratedVibrations:(BOOL)arg1;
- (void)setShowsDefaultVibration:(BOOL)arg1;
- (void)setShowsVibrations:(BOOL)arg1;
- (void)removeMediaItems:(id)arg1;
- (void)addMediaItems:(id)arg1;
- (void)setSelectedMediaIdentifier:(id)arg1;
- (id)selectedIdentifier:(char *)arg1;
- (id)selectedRingtoneIdentifier;
- (void)setSelectedRingtoneIdentifier:(id)arg1;
- (void)ringtoneManagerContentsChanged:(id)arg1;
- (void)_toneManagerContentsChanged;
- (void)_buildTable;
- (void)buildUIWithAVController:(id)arg1 filter:(NSUInteger)arg2 tonePicker:(BOOL)arg3;
- (void)setContext:(int)arg1;
- (void)setShowsStoreButtonInNavigationBar:(BOOL)arg1;
- (void)setMediaAtTop:(BOOL)arg1;
- (void)setShowsMedia:(BOOL)arg1;
- (void)setShowsNothingSelected:(BOOL)arg1;
- (void)setNoneString:(id)arg1;
@property(retain, nonatomic) NSString *vibrationAccountIdentifier; // @dynamic vibrationAccountIdentifier;
- (void)setDefaultIdentifier:(id)arg1;
- (void)setNoneAtTop:(BOOL)arg1;
- (void)setShowsNone:(BOOL)arg1;
- (void)setShowsDefault:(BOOL)arg1;
- (void)setAVController:(id)arg1;
- (void)_reloadData;
- (void)dealloc;
- (id)initWithFrame:(CGRect)arg1 avController:(id)arg2 filter:(NSUInteger)arg3 tonePicker:(BOOL)arg4;
- (id)initWithFrame:(CGRect)arg1 avController:(id)arg2;
- (id)initWithFrame:(CGRect)arg1;

@end

@interface TKToneTableController : NSObject<UITableViewDelegate, UITableViewDataSource>

- (id)initWithAVController:(id)arg1 filter:(NSUInteger)arg2 tonePicker:(BOOL)arg3;
- (void)setTableView:(UITableView *)tableView;
- (id)ringtoneManager;

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface TLDividerTableViewCell : UITableViewCell

- (void)setContentBackgroundColor:(UIColor *)backgroundColor;
- (void)setContentFillColor:(UIColor *)fillColor;

@end