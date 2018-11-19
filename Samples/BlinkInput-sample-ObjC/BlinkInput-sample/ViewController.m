//
//  ViewController.m
//  BlinkOCR-sample
//
//  Created by Jura on 02/03/15.
//  Copyright (c) 2015 MicroBlink. All rights reserved.
//

#import "ViewController.h"
#import "CustomOverlayViewController.h"

#import <MicroBlink/MicroBlink.h>

@interface ViewController () <MBBarcodeOverlayViewControllerDelegate>

@property (nonatomic, strong) MBRawParser *rawParser;
@property (nonatomic, strong) MBParserGroupProcessor *parserGroupProcessor;
@property (nonatomic, strong) MBBlinkInputRecognizer *blinkInputRecognizer;

@property (nonatomic, strong) MBBarcodeRecognizer *barcodeRecognizer;
@property (nonatomic, strong) MBPdf417Recognizer *pdf417Recognizer;

@end

@implementation ViewController

- (IBAction)didTapScan:(id)sender {
    
    MBBarcodeOverlaySettings* settings = [[MBBarcodeOverlaySettings alloc] init];

    self.rawParser = [[MBRawParser alloc] init];
    self.parserGroupProcessor = [[MBParserGroupProcessor alloc] initWithParsers:@[self.rawParser]];
    self.blinkInputRecognizer = [[MBBlinkInputRecognizer alloc] initWithProcessors:@[self.parserGroupProcessor]];

    /** Create recognizer collection */
    MBRecognizerCollection *recognizerCollection = [[MBRecognizerCollection alloc] initWithRecognizers:@[self.blinkInputRecognizer]];
    
    MBBarcodeOverlayViewController *overlayVC = [[MBBarcodeOverlayViewController alloc] initWithSettings:settings recognizerCollection:recognizerCollection delegate:self];
    UIViewController<MBRecognizerRunnerViewController>* recognizerRunnerViewController = [MBViewControllerFactory recognizerRunnerViewControllerWithOverlayViewController:overlayVC];
    
    /** Present the recognizer runner view controller. You can use other presentation methods as well (instead of presentViewController) */
    [self presentViewController:recognizerRunnerViewController animated:YES completion:nil];
}

- (IBAction)didTapCustomScan:(id)sender {
    
    /** Create barcode recognizer */
    self.barcodeRecognizer = [[MBBarcodeRecognizer alloc] init];
    self.barcodeRecognizer.scanQrCode = YES;
    
    self.pdf417Recognizer = [[MBPdf417Recognizer alloc] init];
    
    /** Crate recognizer collection */
    NSArray *recognizerList = @[self.barcodeRecognizer, self.pdf417Recognizer];
    MBRecognizerCollection *recognizerCollection = [[MBRecognizerCollection alloc] initWithRecognizers:recognizerList];
    
    /** Create your overlay view controller */
    CustomOverlayViewController *overlayVC = [CustomOverlayViewController initFromStoryBoard];
    
    /** This has to be called for custom controller */
    [overlayVC reconfigureRecognizers:recognizerCollection];
    
    /** Create recognizer view controller with wanted overlay view controller */
    UIViewController<MBRecognizerRunnerViewController>* recognizerRunnerViewController = [MBViewControllerFactory recognizerRunnerViewControllerWithOverlayViewController:overlayVC];
    
    /** Present the recognizer runner view controller. You can use other presentation methods as well (instead of presentViewController) */
    [self presentViewController:recognizerRunnerViewController animated:YES completion:nil];
    
}

#pragma mark - MBBarcodeOverlayViewControllerDelegate

- (void)barcodeOverlayViewControllerDidFinishScanning:(MBBarcodeOverlayViewController *)barcodeOverlayViewController state:(MBRecognizerResultState)state {
    
    // check for valid state
    if (state == MBRecognizerResultStateValid) {
        
        // first, pause scanning until we process all the results
        [barcodeOverlayViewController.recognizerRunnerViewController pauseScanning];
        
        ViewController __weak *weakSelf = self;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSLog(@"OCR results are:");
            NSLog(@"Raw ocr: %@", weakSelf.rawParser.result.rawText);

            // Show result on the initial screen
            self.labelResult.text = weakSelf.rawParser.result.rawText;
            
            MBOcrLayout* ocrLayout = weakSelf.parserGroupProcessor.result.ocrLayout;
            NSLog(@"Dimensions of ocrLayout are %@", NSStringFromCGRect(ocrLayout.box));
            
            [barcodeOverlayViewController.recognizerRunnerViewController resumeScanningAndResetState:YES];
        });
    }
}

- (void)barcodeOverlayViewControllerDidTapClose:(MBBarcodeOverlayViewController *)barcodeOverlayViewController {
    // As scanning view controller is presented full screen and modally, dismiss it
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
