import type { NextApiRequest, NextApiResponse } from 'next';

interface ApiError {
  statusCode: number;
  message: string;
  details?: any;
}

export const handleError = (res: NextApiResponse, error: any) => {
  // Basic error handling. This can be expanded.
  const statusCode = error.statusCode || 500;
  const message = error.message || "An unexpected error occurred.";
  
  logger.error(`API Error: ${message}`, error.details || error);

  res.status(statusCode).json({
    success: false,
    error: {
      message,
      details: error.details, // Include details if available
    },
  });
};

// Example of a custom error class
export class CustomApiError extends Error {
  statusCode: number;
  details?: any;

  constructor(statusCode: number, message: string, details?: any) {
    super(message);
    this.statusCode = statusCode;
    this.details = details;
    Object.setPrototypeOf(this, CustomApiError.prototype); // Ensure instanceof works
  }
}

// You might need to import your logger here if it's not globally available
// For now, assuming logger is accessible or you'll add an import like:
import { logger } from './logger';