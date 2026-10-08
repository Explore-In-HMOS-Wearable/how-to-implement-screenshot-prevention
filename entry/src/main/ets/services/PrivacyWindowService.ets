import { window } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import Logger from '../common/utils/Logger';

export interface PrivacyResult {
  success: boolean;
  isProtected: boolean;
  errorCode: number;
}

export class PrivacyWindowService {
  private windowClass: window.Window | undefined = undefined;

  async init(context: common.Context): Promise<PrivacyResult> {
    try {
      this.windowClass = await window.getLastWindow(context);
      Logger.info('Window instance obtained');
      return this.buildResult(true, 0);
    } catch (error) {
      return this.handleError('getLastWindow', error as BusinessError);
    }
  }

  async setPrivacyMode(enabled: boolean): Promise<PrivacyResult> {
    if (this.windowClass === undefined) {
      return this.buildResult(false, 0);
    }
    try {
      await this.windowClass.setWindowPrivacyMode(enabled);
      Logger.info(`Privacy mode set to ${enabled}`);
      return this.buildResult(true, 0);
    } catch (error) {
      return this.handleError('setWindowPrivacyMode', error as BusinessError);
    }
  }

  isPrivacyMode(): boolean {
    try {
      return this.windowClass?.getWindowProperties().isPrivacyMode ?? false;
    } catch (error) {
      Logger.error(`getWindowProperties failed, code: ${(error as BusinessError).code}`);
      return false;
    }
  }

  private handleError(api: string, error: BusinessError): PrivacyResult {
    Logger.error(`${api} failed, code: ${error.code}, message: ${error.message}`);
    return this.buildResult(false, error.code);
  }

  private buildResult(success: boolean, errorCode: number): PrivacyResult {
    const result: PrivacyResult = {
      success: success,
      isProtected: this.isPrivacyMode(),
      errorCode: errorCode
    };
    return result;
  }
}