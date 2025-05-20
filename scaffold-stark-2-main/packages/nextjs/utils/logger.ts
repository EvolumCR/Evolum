// Basic logger utility

enum LogLevel {
  INFO = "INFO",
  WARN = "WARN",
  ERROR = "ERROR",
  DEBUG = "DEBUG",
}

const log = (level: LogLevel, message: string, ...optionalParams: any[]) => {
  const timestamp = new Date().toISOString();
  console.log(`[${timestamp}] [${level}] ${message}`, ...optionalParams);
};

export const logger = {
  info: (message: string, ...optionalParams: any[]) => log(LogLevel.INFO, message, ...optionalParams),
  warn: (message: string, ...optionalParams: any[]) => log(LogLevel.WARN, message, ...optionalParams),
  error: (message: string, ...optionalParams: any[]) => log(LogLevel.ERROR, message, ...optionalParams),
  debug: (message: string, ...optionalParams: any[]) => {
    if (process.env.NODE_ENV !== "production") {
      log(LogLevel.DEBUG, message, ...optionalParams);
    }
  },
};