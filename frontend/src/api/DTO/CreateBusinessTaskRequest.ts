export interface CreateBusinessTaskRequest {
  customerRequest: string;
  requestedWork: string;
  targetDeliveryDate: string;
  buildEstimate: string;
  owner: string;
}
