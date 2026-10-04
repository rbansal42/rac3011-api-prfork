import { Body, Controller, Post, Req, Res, UseGuards } from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';
import { Throttle, ThrottlerGuard } from '@nestjs/throttler';
import type { Request, Response } from 'express';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { SecondFactorStage } from '../common/decorators/access.decorators';
import type { RequestContext } from '../common/types/access';
import { VerifySecondFactorDto } from './dto/second-factor.dto';
import { SecondFactorService } from './second-factor.service';

@ApiTags('auth')
@Controller('second-factor')
export class SecondFactorController {
  constructor(private readonly secondFactor: SecondFactorService) {}

  @Post('verify')
  @SecondFactorStage()
  async verify(
    @Req() req: Request,
    @Res({ passthrough: true }) res: Response,
    @CurrentUser() ctx: RequestContext,
    @Body() dto: VerifySecondFactorDto,
  ): Promise<{ status: 'verified' }> {
    await this.secondFactor.verify(req, res, ctx, dto);
    return { status: 'verified' };
  }

  @Post('resend')
  @SecondFactorStage()
  @UseGuards(ThrottlerGuard)
  @Throttle({ default: { limit: 3, ttl: 300000 } })
  async resend(@CurrentUser() ctx: RequestContext): Promise<{ status: 'sent' }> {
    await this.secondFactor.resend(ctx.user.email);
    return { status: 'sent' };
  }
}
