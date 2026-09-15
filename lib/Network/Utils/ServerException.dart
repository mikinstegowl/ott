abstract class ServerExceptions {
  String message;
  ServerExceptions({this.message = "Something went wrong"});
}

class LoginException extends ServerExceptions {
  LoginException({super.message = "Login failed"});
}

class SignupException extends ServerExceptions {
  SignupException({super.message = "Signup failed"});
}

class FetchQuestionException extends ServerExceptions {
  FetchQuestionException({super.message = "Failed to fetch questions"});
}

class GetProductException extends ServerExceptions {
  GetProductException({super.message = "Failed to get products"});
}

class GetCartException extends ServerExceptions {
  GetCartException({super.message = "Failed to get cart"});
}

class AddCartException extends ServerExceptions {
  AddCartException({super.message = "Failed to add cart"});
}

class RemoveCartException extends ServerExceptions {
  RemoveCartException({super.message = "Failed to remove cart"});
}

class SendAnswerException extends ServerExceptions {
  SendAnswerException({super.message = "Failed to add Answer"});
}

class ResetPasswordException extends ServerExceptions {
  ResetPasswordException({super.message = "ResetPassword failed"});
}

class OTPException extends ServerExceptions {
  OTPException({super.message = "OTP sent failed"});
}

class NewPasswordException extends ServerExceptions {
  NewPasswordException({super.message = "NewPassword set failed"});
}

class DeleteCustomerException extends ServerExceptions {
  DeleteCustomerException({super.message = "Failed to delete customer"});
}

class AddNewProductException extends ServerExceptions {
  AddNewProductException({super.message = "Failed to add product"});
}

class DeleteProductException extends ServerExceptions {
  DeleteProductException({super.message = "Failed to delete product"});
}

class UpdateProductException extends ServerExceptions {
  UpdateProductException({super.message = "Failed to update product"});
}

class FetchProductException extends ServerExceptions {
  FetchProductException({super.message = "Failed to update product"});
}
class AddNewInvoiceException extends ServerExceptions {
  AddNewInvoiceException({super.message = "Failed to add invoice"});
}
class UpdateInvoiceException extends ServerExceptions {
  UpdateInvoiceException({super.message = "Failed to update invoice"});
}
class DeleteInvoiceException extends ServerExceptions {
  DeleteInvoiceException({super.message = "Failed to delete invoice"});
}
class FetchInvoiceException extends ServerExceptions {
  FetchInvoiceException({super.message = "Failed to fetch invoice"});
}
class FetchInvoiceNumberException extends ServerExceptions {
  FetchInvoiceNumberException({super.message = "Failed to fetch invoice number"});
}
class AddArchitectEngException extends ServerExceptions {
  AddArchitectEngException({super.message = "Failed to add architect engineer"});
}
class FetchArchitectEngException extends ServerExceptions {
  FetchArchitectEngException({super.message = "Failed to fetch architect engineer"});
}
class DashBoardDataException extends ServerExceptions {
  DashBoardDataException({super.message = "Failed to fetch dashboard data"});
}