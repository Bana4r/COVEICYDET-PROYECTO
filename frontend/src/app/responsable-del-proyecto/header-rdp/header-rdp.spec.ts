import { ComponentFixture, TestBed } from '@angular/core/testing';

import { HeaderRDP } from './header-rdp';

describe('HeaderRDP', () => {
  let component: HeaderRDP;
  let fixture: ComponentFixture<HeaderRDP>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [HeaderRDP]
    })
    .compileComponents();

    fixture = TestBed.createComponent(HeaderRDP);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
