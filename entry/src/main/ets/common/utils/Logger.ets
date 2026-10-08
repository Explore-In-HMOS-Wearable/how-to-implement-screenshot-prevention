import { hilog } from '@kit.PerformanceAnalysisKit';
import AppConstants from '../constants/AppConstants';

class Logger {
  private readonly domain: number;
  private readonly tag: string;
  private readonly format: string = '%{public}s';

  constructor(domain: number, tag: string) {
    this.domain = domain;
    this.tag = tag;
  }

  info(message: string): void {
    hilog.info(this.domain, this.tag, this.format, message);
  }

  error(message: string): void {
    hilog.error(this.domain, this.tag, this.format, message);
  }
}

export default new Logger(AppConstants.LOG_DOMAIN, AppConstants.LOG_TAG);