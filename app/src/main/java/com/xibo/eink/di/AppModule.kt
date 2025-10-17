package com.xibo.eink.di

import android.content.Context
import com.xibo.eink.eink.EinkDisplayManager
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.android.qualifiers.ApplicationContext
import dagger.hilt.components.SingletonComponent
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
object AppModule {

    @Provides
    @Singleton
    fun provideEinkDisplayManager(@ApplicationContext context: Context): EinkDisplayManager {
        return EinkDisplayManager(context)
    }
}
