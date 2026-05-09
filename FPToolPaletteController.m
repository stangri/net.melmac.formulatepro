#import "FPToolPaletteController.h"
#import "FPDocumentWindow.h"
#import "FPLogging.h"

#import "FPRectangle.h"
#import "FPEllipse.h"
#import "FPSquiggle.h"
#import "FPTextAreaB.h"
#import "FPCheckmark.h"

NSString *FPToolChosen = @"FPToolChosen";

@implementation FPToolPaletteController

static FPToolPaletteController *_sharedController;

- (void)windowDidLoad {
    [super windowDidLoad];

    for (NSButton *btn in _buttonArray) {
        [btn setRefusesFirstResponder:YES];
    }

    [(NSPanel *)[self window] setBecomesKeyOnlyIfNeeded:YES];
}

- (void)awakeFromNib
{
    [(NSPanel *)[self window] setFloatingPanel:YES];
    [(NSPanel *)[self window] setBecomesKeyOnlyIfNeeded:YES];

    _buttonArray = [NSArray arrayWithObjects:arrowToolButton,
                                 ellipseToolButton,
                                 rectangleToolButton,
                                 squiggleToolButton,
                                 textAreaToolButton,
                                 textFieldToolButton,
                                 checkmarkToolButton,
                                 stampToolButton,
                                 nil];
    [_buttonArray retain];
    assert([_buttonArray count] > 0);

    _sharedController = self;
    _inQuickMove = NO;
    _toolBeforeQuickMove = 0;

    [[NSNotificationCenter defaultCenter]
        addObserver:self selector:@selector(beginQuickMove:)
        name:FPBeginQuickMove object:nil];
    [[NSNotificationCenter defaultCenter]
        addObserver:self selector:@selector(abortQuickMove:)
        name:FPAbortQuickMove object:nil];
    [[NSNotificationCenter defaultCenter]
        addObserver:self selector:@selector(endQuickMove:)
        name:FPEndQuickMove object:nil];
}

+ (FPToolPaletteController *)sharedToolPaletteController
{
    return _sharedController;
}

- (IBAction)chooseTool:(id)sender
{
    for (NSButton *btn in _buttonArray) {
        [btn setState:NSControlStateValueOff];
    }
    [sender setState:NSControlStateValueOn];

    [[NSNotificationCenter defaultCenter] postNotification:
        [NSNotification notificationWithName:FPToolChosen object:self]];
}

- (NSUInteger)currentTool
{
    for (NSUInteger i = 0; i < [_buttonArray count]; i++) {
        NSButton *b = [_buttonArray objectAtIndex:i];
        DLog(@"button = %p\n", (void *)b);
        if ([b state] == NSControlStateValueOn)
            return i;
    }
    // No tool button is selected (shouldn't happen — palette nib starts with
    // arrow on, and chooseTool: always sets one). Fall back to arrow rather
    // than aborting; arrow is the safest tool because it doesn't create new
    // graphics on click.
    FPCheck(NO, {});
    return FPToolArrow;
}

- (Class)classForCurrentTool
{
    switch ([self currentTool]) {
        case FPToolEllipse: DLog(@"ellispe\n"); return [FPEllipse class];
        case FPToolRectangle: DLog(@"rect\n"); return [FPRectangle class];
        case FPToolSquiggle: DLog(@"squiggle\n"); return [FPSquiggle class];
        case FPToolTextArea: DLog(@"text area\n"); return [FPTextAreaB class];
        case FPToolCheckmark: DLog(@"checkmark\n"); return [FPCheckmark class];
    }
    return [FPRectangle class];
}

- (void)keyDown:(NSEvent *)theEvent
{
    if (1 != [[theEvent charactersIgnoringModifiers] length])
        return;

    // we don't want any modifiers, except numeric pad is okay
    if ((NSEventModifierFlagDeviceIndependentFlagsMask ^ NSEventModifierFlagNumericPad) & [theEvent modifierFlags]) {
        return;
    }

    unichar c = [[theEvent charactersIgnoringModifiers] characterAtIndex:0];
    switch (c) {
        case 't': [self chooseTool:textAreaToolButton]; break;
        case 'm': [self chooseTool:arrowToolButton]; break;
        case 'e': [self chooseTool:ellipseToolButton]; break;
        case 'u': [self chooseTool:rectangleToolButton]; break;
        case 'p': [self chooseTool:squiggleToolButton]; break;
        case 'x': [self chooseTool:checkmarkToolButton]; break;
    }
}

- (void)beginQuickMove:(id)unused
{
    _toolBeforeQuickMove = [self currentTool];

    for (NSButton *btn in _buttonArray) {
        [btn setEnabled:NO];
    }

    [arrowToolButton setEnabled:YES];
    [self chooseTool:arrowToolButton];
    _inQuickMove = YES;
}

- (void)abortQuickMove:(id)unused
{
    for (NSButton *btn in _buttonArray) {
        [btn setEnabled:YES];
    }
    [self chooseTool:[_buttonArray objectAtIndex:FPToolArrow]];
    _inQuickMove = NO;
}

- (void)endQuickMove:(id)unused
{
    if (NO == _inQuickMove) return;

    for (NSButton *btn in _buttonArray) {
        [btn setEnabled:YES];
    }
    [self chooseTool:[_buttonArray objectAtIndex:_toolBeforeQuickMove]];
}

@end
