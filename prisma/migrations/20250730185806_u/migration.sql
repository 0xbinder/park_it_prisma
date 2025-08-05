/*
  Warnings:

  - You are about to drop the column `callback_data` on the `payments` table. All the data in the column will be lost.
  - You are about to drop the column `checkout_url` on the `payments` table. All the data in the column will be lost.
  - You are about to drop the column `paid_at` on the `payments` table. All the data in the column will be lost.
  - You are about to drop the column `paystack_access_code` on the `payments` table. All the data in the column will be lost.
  - You are about to drop the column `paystack_ref` on the `payments` table. All the data in the column will be lost.

*/
-- AlterEnum
ALTER TYPE "PaymentStatus" ADD VALUE 'ABANDONED';

-- DropIndex
DROP INDEX "payments_paystack_ref_idx";

-- DropIndex
DROP INDEX "payments_paystack_ref_key";

-- AlterTable
ALTER TABLE "payments" DROP COLUMN "callback_data",
DROP COLUMN "checkout_url",
DROP COLUMN "paid_at",
DROP COLUMN "paystack_access_code",
DROP COLUMN "paystack_ref";
