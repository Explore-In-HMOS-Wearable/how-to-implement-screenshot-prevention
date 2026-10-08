import { PrivacyResult, PrivacyWindowService } from '../services/PrivacyWindowService';
import AppConstants from '../common/constants/AppConstants';

@Entry
@Component
struct Index {
  @State isProtected: boolean = false;
  @State message: ResourceStr = '';
  private privacyService: PrivacyWindowService = new PrivacyWindowService();
  private isReady: boolean = false;

  aboutToAppear(): void {
    this.initService();
  }

  aboutToDisappear(): void {
    this.privacyService.setPrivacyMode(false);
  }

  @Builder
  statusRing() {
    Stack() {
      Progress({ value: 100, total: 100, type: ProgressType.Ring })
        .width($r('app.float.ring_size'))
        .height($r('app.float.ring_size'))
        .color(this.isProtected ? $r('app.color.color_protected') : $r('app.color.color_exposed'))
        .style({ strokeWidth: $r('app.float.ring_stroke') })
      Column() {
        Text(this.isProtected ? $r('app.string.status_on') : $r('app.string.status_off'))
          .fontSize($r('app.float.font_status'))
          .fontWeight(FontWeight.Bold)
          .fontColor(this.isProtected ? $r('app.color.color_protected') : $r('app.color.color_exposed'))
        Text($r('app.string.status_caption'))
          .fontSize($r('app.float.font_caption'))
          .fontColor($r('app.color.color_text_secondary'))
      }
    }
    .margin({ bottom: $r('app.float.space_m') })
  }

  @Builder
  sensitiveCard() {
    Column() {
      Text($r('app.string.card_caption'))
        .fontSize($r('app.float.font_caption'))
        .fontColor($r('app.color.color_text_secondary'))
      Text($r('app.string.card_value'))
        .fontSize($r('app.float.font_code'))
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.color_text_primary'))
        .letterSpacing(2)
    }
    .width(AppConstants.CARD_WIDTH_PERCENT)
    .padding($r('app.float.card_padding'))
    .borderRadius($r('app.float.card_radius'))
    .backgroundColor($r('app.color.color_card_bg'))
  }

  @Builder
  actionButtons() {
    Row() {
      Button($r('app.string.btn_enable'))
        .fontSize($r('app.float.font_button'))
        .fontWeight(FontWeight.Medium)
        .height($r('app.float.button_height'))
        .layoutWeight(1)
        .backgroundColor($r('app.color.color_protected'))
        .enabled(!this.isProtected)
        .opacity(this.isProtected ? AppConstants.OPACITY_DISABLED : 1)
        .onClick(() => {
          this.applyProtection(true);
        })
      Button($r('app.string.btn_disable'))
        .fontSize($r('app.float.font_button'))
        .fontWeight(FontWeight.Medium)
        .height($r('app.float.button_height'))
        .layoutWeight(1)
        .backgroundColor($r('app.color.color_exposed'))
        .enabled(this.isProtected)
        .opacity(this.isProtected ? 1 : AppConstants.OPACITY_DISABLED)
        .margin({ left: $r('app.float.space_s') })
        .onClick(() => {
          this.applyProtection(false);
        })
    }
    .width(AppConstants.BUTTON_ROW_WIDTH_PERCENT)
    .margin({ top: $r('app.float.space_m') })
  }

  build() {
    Column() {
      this.statusRing()
      this.sensitiveCard()
      this.actionButtons()
      Text(this.message)
        .width(AppConstants.MESSAGE_WIDTH_PERCENT)
        .textAlign(TextAlign.Center)
        .fontSize($r('app.float.font_caption'))
        .fontColor($r('app.color.color_text_secondary'))
        .height($r('app.float.message_height'))
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .margin({ top: $r('app.float.space_s') })
    }
    .width(AppConstants.FULL_PERCENT)
    .height(AppConstants.FULL_PERCENT)
    .justifyContent(FlexAlign.Center)
    .backgroundColor($r('app.color.color_page_bg'))
  }

  private async initService(): Promise<void> {
    const context = this.getUIContext().getHostContext();
    if (context === undefined) {
      return;
    }
    const result: PrivacyResult = await this.privacyService.init(context);
    this.isReady = result.success;
    this.isProtected = result.isProtected;
    if (!result.success) {
      this.message = $r('app.string.msg_window_error', result.errorCode);
    }
  }

  private async applyProtection(enabled: boolean): Promise<void> {
    if (!this.isReady) {
      return;
    }
    const result: PrivacyResult = await this.privacyService.setPrivacyMode(enabled);
    this.isProtected = result.isProtected;
    this.message = this.toMessage(result, enabled);
  }

  private toMessage(result: PrivacyResult, enabled: boolean): ResourceStr {
    if (result.success) {
      return enabled ? $r('app.string.msg_blocked') : $r('app.string.msg_allowed');
    }
    if (result.errorCode === AppConstants.ERROR_PERMISSION_DENIED) {
      return $r('app.string.msg_permission_missing');
    }
    return $r('app.string.msg_failed', result.errorCode);
  }
}